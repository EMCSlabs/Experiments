function getwordmp3(wordlist)
%% getwordmp3: save pronunciation of words in the input list from the web
% sound source:
%   ('https://ssl.gstatic.com/dictionary/static/sounds/de/0/')

% INPUT:    wordlist (cell array of strings)
%              e.g.  {'math' 'empty' 'table'};
%
% written by YG (11/25/2015)

for i = 1:length(wordlist)
    word = wordlist{i};
    filename = [word '.mp3'];
    url = ['https://ssl.gstatic.com/dictionary/static/sounds/de/0/' filename];
    
    try
        websave(filename,url);
        fprintf('downloaded %d/%d\n',i,length(wordlist));
        
    catch
        sprintf('An error occurred while retrieving %s from the internet',filename);
    end
end
