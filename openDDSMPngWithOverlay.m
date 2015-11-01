%% ==================================================================%
%     OPEN AND VIEW PNG FORMAT DDSM IMAGES WITH THEIR ANNOTATIONS 
%                        ----(MAIN FILE)----
% ===================================================================%
%           Author - Anmol Sharma (Undergraduate Engineering Student)
%      Affiliation - DAV Institute of Engineering & Technology
%      Supervisers - Dr. Jayasree Chakraborty* and Dr. Abhishek Midya#
%                    *Research Fellow, Memorial Sloan Kettering Cancer Center
%                    #Assistant Professor, NIT Silchar
%      Description - The code is used to view the PNG format DDSM images
%                    created using the openDDSMLJPEG1AndConvertToPNG.m 
%                    script. This script opens the PNG file, and then also
%                    opens the corresponding OVERLAY file to get the boundary
%                    information of the mass present in that particular 
%                    mammogram.
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
directoryOfDDSMPNG = 'D:\DDSM Database Downloaded\DoDMalignantAllCasesPNG\';
directoryOfDDSM = 'D:\DDSM Database Downloaded\DoDMalignantAllCases\';
imageOutputFileFormat = '*.png'; % Notice the STAR dot. Can be *.tif, *.jpg...
filenames = dir(strcat([directoryOfDDSMPNG, imageOutputFileFormat]));
%%
for i = 1:length(filenames)
    overlayName = strcat([directoryOfDDSM, filenames(i).name((1:(length(filenames(i).name) - 4))), '.OVERLAY']);
    [bnd_c,bnd_r] = readBoundary(overlayName, 1);
    
    image = imread(strcat(directoryOfDDSMPNG, filenames(i).name));
    [heightOfImage, widthOfImage] = size(image);
    temp_mask = poly2mask(bnd_c,bnd_r, heightOfImage,widthOfImage);
    imshow(image, []);
    hold on
    plot(bnd_c, bnd_r, '--r'); 
    pause;
    close all;
end

