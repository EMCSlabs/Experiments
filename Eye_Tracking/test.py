# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 19:41:07 2015

@author: jookai
"""
Gen_Bitmap_RegFile('.', 'malgun', 'Korean', ['km_story01.txt'])
Gen_Bitmap_RegFile('.', 'malgun', 'Korean', ['km_story02.txt'])
Gen_Bitmap_RegFile('.', 'malgun', 'Korean', ['km_story03.txt'])
Gen_Bitmap_RegFile('.', 'LiberationMono', 'English', ['en_story01.txt'])
Gen_Bitmap_RegFile('.', 'LiberationMono', 'English', ['en_story02.txt'])
Gen_Bitmap_RegFile('.', 'LiberationMono', 'English', ['en_story03.txt'])

#Gen_Bitmap_RegFile('.', 'Arial', 'English', ['test.txt'])

# pixel size should be set dim=(1024,768). Default: dim=(1280,1024)
# extract Sac/Fix from raw data
#SacDF, FixDF = read_SRRasc('./', '1950024.asc', [], 'RP')
#write_Sac_Report('./', SacDF)
#write_Fix_Report('./', FixDF)
read_write_SRRasc_b('./', [], 'RP')

# classifying fixations and saccades into different lines of texts, 
# assigning fixations into different word regions, and 
# identifying cross-line saccades and fixations
#SacDF, crlSac, FixDF, crlFix = cal_crlSacFix('./', '1950024', [], 'RP')
#write_Sac_crlSac('./', '1950024', SacDF, crlSac)
#write_Fix_crlFix('./', '1950024', FixDF, crlFix)
#cal_write_SacFix_crlSacFix_b('./', [], 'RP')
#SacDF, crlSac, FixDF, crlFix = read_cal_SRRasc('./', '1950024.asc', [], 'RP')
read_cal_write_SRRasc_b('./', [], 'RP')

# visualization
#draw_SacFix('./', '1950024', [], [], 'ALL')
#draw_SacFix_b('./', '1950024', [], [], 'ALL')

#changePNG2GIF('./')
#animate('./', '1950024', 0)

cal_write_EM('./', '1950024', [])
cal_write_EM_b('./', [])