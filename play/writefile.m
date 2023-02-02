function [textFile] = writefile(fileName)
%saveFile Open text file for writing data

%{
TODO:
- If dataHere dir. DNE, create one.
- Add /dataHere/ to dir

- Same as above, except a folder for each user. (Obtain from header?)
%}


% Make new file if one already exists
i = 0;
while (exist(fileName, 'file') == 2)
    fileName = strrep(fileName, int2str(i), int2str(i+1));
    i = i+1;
end

textFile = fopen(fileName, 'a'); 
% 'a' creates and opens a new file or opens a preexisting file to append to

end