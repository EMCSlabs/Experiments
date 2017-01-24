# Sung Hah Hwang
# EMCS Laboratories, Korea University
# Jan 23, 2017

import os
import numpy as np
import tensorflow as tf
import time

''' train a 3 hidden layer regression model '''

def read_and_decode(filename_queue):
  reader = tf.TFRecordReader()
  _, serialized_example = reader.read(filename_queue)
  features = tf.parse_single_example(
    serialized_example,
      features = {
        'MFCC': tf.FixedLenFeature([39], tf.float32),
        'ART': tf.FixedLenFeature([16], tf.float32)
      }
    )
  MFCC = features['MFCC']
  ART = features['ART']
  return MFCC, ART


def input_pipeline(filenames, batch_size, num_epochs):
  with tf.name_scope('input_file'):
    filename_queue = tf.train.string_input_producer([filenames], num_epochs = num_epochs, name = 'shuffle_files')
#     dequeue_many = filename_queue.dequeue_many(len(filenames) * num_epochs, name = 'dequeue_many')
#     dequeue = filename_queue.dequeue()
    MFCC, ART = read_and_decode(filename_queue)
    min_after_dequeue = 1000
    capacity = batch_size * 3 + min_after_dequeue
    MFCC_Batch, ART_Batch = tf.train.shuffle_batch(
      [MFCC, ART], batch_size = batch_size, seed = 777, num_threads = 4,
      capacity = capacity, min_after_dequeue = min_after_dequeue
    )
    return MFCC_Batch, ART_Batch


def weight_variable(shape):
  """Create a weight variable with appropriate initialization."""
  initial = tf.truncated_normal(shape, stddev = 0.1)
  return tf.Variable(initial)


def bias_variable(shape):
  """Create a bias variable with appropriate initialization."""
  initial = tf.constant(0.1, shape = shape)
  return tf.Variable(initial)


def variable_summaries(var):
  """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""
  with tf.name_scope('summaries'):
    mean = tf.reduce_mean(var)
    tf.summary.scalar('mean', mean)
    with tf.name_scope('stddev'):
      stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
    tf.summary.scalar('stddev', stddev)
    tf.summary.scalar('max', tf.reduce_max(var))
    tf.summary.scalar('min', tf.reduce_min(var))
    tf.summary.histogram('histogram', var)


def nn_layer(input_tensor, input_dim, output_dim, layer_name, act = tf.nn.relu):
  with tf.name_scope(layer_name):
    with tf.name_scope('weights'):
      weights = weight_variable([input_dim, output_dim])
      variable_summaries(weights)
    with tf.name_scope('biases'):
      biases = bias_variable([output_dim])
      variable_summaries(biases)
    with tf.name_scope('Wx_plus_b'):
      preactivate = tf.matmul(input_tensor, weights) + biases
      tf.summary.histogram('pre_activations', preactivate)
    activations = act(preactivate, name = 'activation')
    tf.summary.histogram('activations', activations)
    return activations


block = '=' * 50
TRAIN_TFR = '/home/inchon26/tensorflow/exp/TrainSet.TFR'
TEST_TFR = '/home/inchon26/tensorflow/exp/TestSet.TFR'
LOG_DIR = '/home/hdd2tb/TFlog/'
SAVE_DIR = '/home/hdd2tb/TFmodel/'
NUM_EPOCH = 1
NUM_BATCH = 10
DISP_STEP = 1000

with tf.Graph().as_default():

  MFCC_TrainBatch, ART_TrainBatch = input_pipeline(TRAIN_TFR, NUM_BATCH, NUM_EPOCH) # batch_size and num_epochs as 1
#   MFCC_TestBatch, ART_TestBatch = input_pipeline(TEST_TFR, NUM_BATCH, NUM_EPOCH) # batch_size and num_epochs as 1

  hidden1 = nn_layer(MFCC_TrainBatch, 39, 100, 'h_layer1')
  hidden2 = nn_layer(hidden1, 100, 100, 'h_layer2')
  hidden3 = nn_layer(hidden2, 100, 100, 'h_layer3')

  output = nn_layer(hidden3, 100, 16, 'o_layer', act = tf.identity)

  with tf.name_scope('cost'):
    cost = tf.reduce_mean(tf.square(output - ART_TrainBatch))
    tf.summary.scalar('cost', cost)

  with tf.name_scope('train'):
    eta = tf.Variable(1e-5)
    train_step = tf.train.AdamOptimizer(eta).minimize(cost)
    # optimizer = tf.train.GradientDescentOptimizer(eta)
    tf.summary.scalar('l-rate', eta)

  sess = tf.InteractiveSession()
  init_op = tf.group(tf.global_variables_initializer(), tf.local_variables_initializer())
  init_op.run()

  saver = tf.train.Saver(max_to_keep=10)

  merged_summary = tf.summary.merge_all()
  train_writer = tf.summary.FileWriter(LOG_DIR, sess.graph)

  coord = tf.train.Coordinator()
  threads = tf.train.start_queue_runners(sess = sess, coord = coord)

####################
# Training 
####################

  try:
    iter = 0
    train_start = time.time()
    disp_start = train_start
    while not coord.should_stop():
      summary, _, cost_val = sess.run([merged_summary, train_step, cost])

      if iter % DISP_STEP == 0:
        duration = time.time() - disp_start
        print 'Iter: {:d}  Loss: {:.3f} (MSE)  Elapsed time: {:.3f}'.format(iter, cost_val, duration)
        save_path = saver.save(sess, SAVE_DIR + 'reg3L', global_step = iter)
        disp_start = time.time()

      train_writer.add_summary(summary, iter)
      iter += 1

  except tf.errors.OutOfRangeError:
    duration = time.time() - train_start
    print '\n' + block
    print 'Done training for {:d} epochs of {:d} iterations (batch size = {:d})'.format(NUM_EPOCH, iter, NUM_BATCH)
    print 'Training time: {:.2f} sec.'.format(duration)
    print block + '\n'

  except tf.errors.CancelledError:
    print 'Caught an exception: CancelledError'

  finally:
    coord.request_stop()

  coord.join(threads, stop_grace_period_secs = 5)

  train_writer.close()
  sess.close()
