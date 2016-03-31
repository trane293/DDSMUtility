% ==================================================================%
%        CONVERT DDSM LJPEG1 IMAGES TO ANY FILE FORMAT LIKE PNG
%                        ----(MAIN FILE)----
% ==================================================================%
%           Author - Anmol Sharma
%      Affiliation - DAV Institute of Engineering & Technology
%                    Jalandhar, India.
%       Superviser - Dr. Jayasree Chakraborty* and Dr. Abhishek Midya#
%                    *Research Fellow, Memorial Sloan Kettering Cancer Center
%                     New York, NY.
%                    #Assistant Professor, NIT Silchar, Assam, India.
%      Description - The code is used to convert the compressed LJPEG
%                    files into PNG or any other user defined format for
%                    easy viewing and support. The code assumes that all
%                    files of the extension LJPEG are present in one
%                    single folder along with their corresponding .ics and
%                    .OVERLAY files. You need to manually change the paths
%                    below to reflect your own directories for the same.
%                    *NOTE*
%                    This script will only convert the image files which
%                    have corresponding OVERLAY files with them. If you
%                    want to convert ALL the LJPEG1 files to PNG, modifying
%                    the script won't be tough. IF you need help, please
%                    email me at - anmol.sharma293@gmail.com
%          License - Copyright (C) 2015  Anmol Sharma
%
%                    This program is free software: you can redistribute it
%                    and/or modify it under the terms of the GNU General
%                    Public License as published by the Free Software
%                    Foundation, either version 3 of the License, or (at
%                    your option) any later version.
%
%                    This program is distributed in the hope that it will
%                    be useful, but WITHOUT ANY WARRANTY; without even the
%                    implied warranty of MERCHANTABILITY or FITNESS FOR A
%                    PARTICULAR PURPOSE.  See the GNU General Public License
%                    for more details.
%
%                    You should have received a copy of the GNU General
%                    Public License along with this program.  If not,
%                    see <http://www.gnu.org/licenses/>.
%===================================================================%
clear all
clc
%--------------------------------------------------------------------------
%                               Set Paths Here
%--------------------------------------------------------------------------
%% SET THESE PATHS FIRST!

% Directory where all cases are present. Just change this directory for all
% folders you have, like Benign01, Benign02, ...
CollectionDirectory = 'D:\Test_For_New_Script\';

% These are for the other script. NOTICE THE BRACKETS DIRECTION. ALSO
% NOTICE A SEMICOLON IN FIRST VAR.
pathToJPEGandDDSM2RAWfiles = 'D://Test_For_New_Script//;';
cygwinLocation = 'C:\\cygwin\\bin\\bash';

imageOutputFileFormat = '.png'; % Notice the dot. Can be .tif, .jpg...

% Make sure PNMREADER script is run
run('pnm\pnmsetup.m');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% DDSM_Dataset
% |- Benign01
% |- Benign02
%    |- Case1452
%    |- Case1462

AllCollectionsOfDDSM = struct2cell(dir(CollectionDirectory));
numOfFolders1 = size(AllCollectionsOfDDSM,2);

for t = 1:numOfFolders1
    % DIR command also outputs "." and "..", so we need to skip those
    if(~strcmp(AllCollectionsOfDDSM{1,t}, '.') && ...
            ~strcmp(AllCollectionsOfDDSM{1,t}, '..') && ...
            AllCollectionsOfDDSM{4,t} == 1)
        
        
        %% Lets start.
        a = struct2cell(dir(strcat(CollectionDirectory, AllCollectionsOfDDSM{1,t})));
        numOfFolders = size(a,2);
        
        for i = 1:numOfFolders
            % DIR command also outputs "." and "..", so we need to skip those
            if(~strcmp(a{1,i}, '.') && ~strcmp(a{1,i}, '..') && a{4,i} == 1)
                
                % Get path of first folder.
                CaseDirectory = [CollectionDirectory, AllCollectionsOfDDSM{1,t}, '\'];
                pathToCaseFile = strcat([CaseDirectory, a{1,i}, '\']);
                
                % Find its ICS file
                ICSFile = dir(strcat(pathToCaseFile, '*.ics'));
                
                % Open the ICS file inside the case file. Each case file will only
                % have one ICS file.
                try
                    textICS = fileread(strcat(pathToCaseFile, ICSFile.name));
                catch
                    continue
                end
                % Inside the Case file, find all LJPEG images
                imageFiles = dir(strcat(pathToCaseFile, '*.LJPEG'));
               
                % We need to write PNG files in the same directory
                writePNGFilesHere = [pathToCaseFile, '\PNGFiles\'];
                
                % Get the name of case
                caseName = a{1,i};
                mkdir(pathToCaseFile, 'PNGFiles');
                for j = 1:length(imageFiles)
                    
                    % Get current image's path
                    imageLJPEGFilePath = strcat(pathToCaseFile, imageFiles(j).name);
                    
                    if ~isempty(strfind(imageFiles(j).name, 'RIGHT'))
                        if ~isempty(strfind(imageFiles(j).name, 'MLO'))
                            textToFindForWidth = imageFiles(j).name(10:18);
                        else
                            textToFindForWidth = imageFiles(j).name(10:17);
                        end
                    end
                    
                    if ~isempty(strfind(imageFiles(j).name, 'LEFT'))
                        if ~isempty(strfind(imageFiles(j).name, 'MLO'))
                            textToFindForWidth = imageFiles(j).name(10:17);
                        else
                            textToFindForWidth = imageFiles(j).name(10:16);
                        end
                    end
                    
                    
                    startingPointOfText = strfind(textICS, textToFindForWidth);
                    
                    % The width is written after exactly 7 places to where the word ends.
                    % That means, add 7 to the total length of the word we are searching.
                    widthStart = (startingPointOfText + (length(textToFindForWidth) +7));
                    widthEnd = (startingPointOfText + (length(textToFindForWidth) +7)) + 4;
                    widthOfImage = str2double(textICS(widthStart:widthEnd));
                    
                    heightStart = widthEnd + 17;
                    heightEnd = heightStart + 4;
                    heightOfImage = str2double(textICS(heightStart:heightEnd));
                    
                    if ~isempty(strfind(textICS, 'HOWTEK'))
                        if strcmp(imageFiles(j).name(1), 'A') == 1
                            digitizer = 'howtek-mgh';
                        elseif strcmp(imageFiles(j).name(1), 'D') == 1
                            digitizer = 'howtek-ismd';
                        end
                    end
                    
                    if strcmp(imageFiles(j).name(1), 'B') == 1 ||...
                            strcmp(imageFiles(j).name(1), 'C') == 1
                        digitizer = 'lumisys';
                    end
                    
                    if ~isempty(strfind(textICS, 'DBA')) &&...
                            strcmp(imageFiles(j).name(1), 'A') == 1
                        digitizer = 'dba';
                    end
                    
                    disp(strcat(['Converting file ', imageFiles(j).name, '...']));
                    caseNameForThisFunc = [AllCollectionsOfDDSM{1,t}, '/', caseName];
                    disp('Currently in Folder - ');
                    disp(caseNameForThisFunc);
                    try
                        DDSM_formattedToRAW = ConvertDDSMImageToRaw(imageFiles(j).name,...
                            caseNameForThisFunc, pathToCaseFile, widthOfImage, heightOfImage, digitizer, ...
                            pathToJPEGandDDSM2RAWfiles, cygwinLocation, CollectionDirectory);
                    catch
                        continue
                    end
                    disp(strcat(['Inside case - ', caseName, '...']));
                    disp(strcat(['Saving ', imageOutputFileFormat, ' ', 'file to disk...']));
                    % Write the image as PNG or other user defined type.
                    imwrite(DDSM_formattedToRAW, strcat([writePNGFilesHere,...
                        imageFiles(j).name(1:length(imageFiles(j).name) - 6),...
                        imageOutputFileFormat]));
                    clc;
                end
            end
        end
    end
end

