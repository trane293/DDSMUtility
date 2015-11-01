%% ==================================================================%
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
%% SET THESE PATHS FIRST!
allFilesDirectory = 'D:\DDSM Database Downloaded\DoD Malignant Cases\BCRP 1\PNGFiles\DoD_BCRP_1_ALL_Files\'; 
writePNGFilesHere = 'D:\DDSM Database Downloaded\DoD Malignant Cases\BCRP 1\PNGFiles\DoDMalignantAllCasesPNG\';
imageOutputFileFormat = '.png'; % Notice the dot. Can be .tif, .jpg...
%% Lets start. 
allOverlays = dir(strcat([allFilesDirectory, '*.OVERLAY']));
allICS = dir(strcat([allFilesDirectory, '*.ics']));
directoryOfDDSM = allFilesDirectory;
for i = 1:length(allOverlays)
    % Get the image name, which is the first name of the file by removing
    % the extension (OVERLAY). Also, it assumes that every overlay will
    % have a corresponding image, but the vice versa may not be true. 
    imageCorrespondingToOverlay = strcat([allOverlays(i).name(1:(length(allOverlays(i).name) - 8)), '.LJPEG.1' ]);
    icsCorrespondingToImage = strcat([imageCorrespondingToOverlay(1:8), '.ics']);
    
    % Change underscore to hyphen
    icsCorrespondingToImage(icsCorrespondingToImage == '_') = '-';
    
%     fidImage = fopen(strcat(directoryOfDDSM, imageCorrespondingToOverlay),'r','b');
    text = fileread(strcat(directoryOfDDSM, icsCorrespondingToImage));
    
    % Now we need to find the size of image. For that, we need to find a
    % way to parse the ics file to get size of images. 
    
    if ~isempty(strfind(imageCorrespondingToOverlay, 'RIGHT'))
        if ~isempty(strfind(imageCorrespondingToOverlay, 'MLO'))
            textToFindForWidth = imageCorrespondingToOverlay(10:18);
        else 
            textToFindForWidth = imageCorrespondingToOverlay(10:17);
        end
    end
    
     if ~isempty(strfind(imageCorrespondingToOverlay, 'LEFT'))
        if ~isempty(strfind(imageCorrespondingToOverlay, 'MLO'))
            textToFindForWidth = imageCorrespondingToOverlay(10:17);
        else 
            textToFindForWidth = imageCorrespondingToOverlay(10:16);
        end
    end
    
    
    startingPointOfText = strfind(text, textToFindForWidth);
    
    % The width is written after exactly 7 places to where the word ends.
    % That means, add 7 to the total length of the word we are searching. 
    widthStart = (startingPointOfText + (length(textToFindForWidth) +7));
    widthEnd = (startingPointOfText + (length(textToFindForWidth) +7)) + 4;
    widthOfImage = str2double(text(widthStart:widthEnd));
    
    heightStart = widthEnd + 17;
    heightEnd = heightStart + 4;
    heightOfImage = str2double(text(heightStart:heightEnd));
    
    if ~isempty(strfind(text, 'HOWTEK'))
        if strfind(imageCorrespondingToOverlay(1), 'A') == 1
            digitizer = 'howtek-mgh';
        elseif strfind(imageCorrespondingToOverlay(1), 'D') == 1
            digitizer = 'howtek-ismd';
        end
    end
    
    if strfind(imageCorrespondingToOverlay(1), 'B') == 1 |...
            strfind(imageCorrespondingToOverlay(1), 'C') == 1
        digitizer = 'lumisys';
    end
    
    if ~isempty(strfind(text, 'DBA')) &...
            strfind(imageCorrespondingToOverlay(1), 'A') == 1
        digitizer = 'dba';
    end
    
    % Lets call the main functions
    
    imageLJPEGFilename = imageCorrespondingToOverlay(1:(length(imageCorrespondingToOverlay) - 2));
    disp(strcat(['Converting file ', imageLJPEGFilename, '...']));
    
	DDSM_formattedToRAW = ConvertDDSMImageToRaw(imageLJPEGFilename,...
                        widthOfImage, heightOfImage, digitizer);

    disp(strcat(['Saving ', imageOutputFileFormat, ' ', 'file number ', num2str(i) ,' to disk...']));
	pause;
    % Write the image as PNG or other user defined type. 
%     imwrite(DDSM_formattedToRAW, strcat([writePNGFilesHere, allOverlays(i).name(1:(length(allOverlays(i).name) - 8)), imageOutputFileFormat]));
    clc;
end
