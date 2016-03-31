%% ==================================================================%
%     				CONVERT LJPEG -> LJPEG1 -> RAW 
%                    ----(FUNCTION DISPATCHER)----
% ===================================================================%
%           Author - Anmol Sharma (Undergraduate Engineering Student)
%      Affiliation - DAV Institute of Engineering & Technology
%      Supervisers - Dr. Jayasree Chakraborty* and Dr. Abhishek Midya#
%                    *Research Fellow, Memorial Sloan Kettering Cancer Center
%                    #Assistant Professor, NIT Silchar
%      Description - The code is a simple system function caller and calls two
%                    main routines:
%                    				jpeg.exe
%                                   ddsm2raw.exe
%                    These routines come with Dr. Chris Rose's DDSM Software 
%                    and I did not write them. This script simply calls them in a
%                    smart way through Cygwin. This function is in turn called by 
%                    another script that passes the parameters to open the file 
%                    for the conversion process. That script is:
%                                   openDDSMLJPEGAndConvertToPNG.m
%                    which simply opens all LJPEG files which have corresponding 
%                    OVERLAY files and then passes their information to this function
%                    for conversion process. The files jpeg.exe and ddsm2raw.exe then 
%                    convert the mammogram to RAW format and also takes care of 
%                    scanner normalization which is an important thing to consider
%                    if we are to compare two mammograms from different scanners. 
%					 
%                    ConvertDDSMImageToRaw
% 				     ================================================================
% 					 Input:-
%  				     o filename : String representing ddsm image file name.
%                    o columns  : Double representing number of columns in the image.
%                    o rows     : Double representing number of rows in the image.
%                    o digitizer: String representing image normalization function name,
%                    which differ from one case to another and have the set of 
%                    values ['dba', 'howtek-mgh', 'howtek-ismd' and 'lumisys' ]
%                    ================================================================
%                    REMEMBER TO RUN PNMSETUP.m BEFORE CONVERSION PROCESS. 
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

function imageRAW = ConvertDDSMImageToRaw(filename, caseName, pathToCaseFile,...
											columns, rows, digitizer,...
											pathToJPEGandDDSM2RAWfiles, cygwinLocation, CollectionDirectory)

%% Prepare and execute command of image decompression
filePath = ['./', caseName, '/', filename];

%--------------------------------------------------------------------------
%               Set Paths Here and take care of Brackets
%--------------------------------------------------------------------------
% pathToJPEGandDDSM2RAWfiles = 'D://Test_For_New_Script//;';
% cygwinLocation = 'C:\\cygwin\\bin\\bash';
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------



commandDecompression = ['"',cygwinLocation, '" -c "cd ', pathToJPEGandDDSM2RAWfiles, './jpeg.exe -d -s ',filePath, '"'];
disp('Decompressing LJPEG -> LJPEG1...');
dos(commandDecompression);
%// -------------------------------------------------------------------------
%// Prepare and execute command that convert the decompressed image to pnm format.
rawFileName          = [ './', caseName, '/', filename, '.1'];
columns              = num2str(columns);
rows                 = num2str(rows);
digitizer            = ['"' digitizer '"'];

commandConversion = ['"', cygwinLocation,'" -c "cd ', pathToJPEGandDDSM2RAWfiles, './ddsmraw2pnm.exe ' rawFileName, ' ', columns, ' ',rows, ' ',digitizer '"'];
disp('Converting LJPEG1 -> RAW...');
dos(commandConversion);
delete(strcat([CollectionDirectory, caseName, '\' ,filename, '.1']));
%// -------------------------------------------------------------------------
%// Wrtie the image into raw format
pnmFileName          = [filename '.1-ddsmraw2pnm.pnm'];
imageRAW                = pnmread(strcat([pathToCaseFile, pnmFileName]));
delete(strcat([CollectionDirectory, caseName, '\' pnmFileName]));

% imwrite(image,[filename '.png']);
end