/*

%% ==================================================================%
%        CONVERT DDSM LJPEG1 IMAGES TO ANY FILE FORMAT LIKE PNG
%                        ----(MAIN FILE)----
% ==================================================================%
%           Author - Anmol Sharma (Undergraduate Engineering Student)
%      Affiliation - DAV Institute of Engineering & Technology
%      Supervisers - Dr. Jayasree Chakraborty* and Dr. Abhishek Midya#
%                    *Research Fellow, Memorial Sloan Kettering Cancer Center
%                    #Assistant Professor, NIT Silchar
%      Description - This code is used to convert the LJPEG (Lossless JPEG)
%                    Format supplied with the DDSM database into the 
%                    decompressed LJPEG1 format. This is done by (smartly)
%                    using the "jpeg" utility supplied with Dr. Chris Rose's
%                    DDSM software to convert all the LJPEG files present in a
%                    directory into decompressed LJPEG1 format. The LJPEG1 
%                    format is suitable for further conversion into other 
%                    famous formats like PNG, JPG, TIF, GIF etc.  
%     Compile 
%     Instructions - g++ getDDSMNamesAndConvertToLJPEG1.cpp -o 
%                        getDDSMNamesAndConvertToLJPEG1 -std=c++0x
%                     
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
%===================================================================%*/

#include <stdio.h>
#include <dirent.h>
#include <iostream>
#include <stdexcept>
#include <string.h>
#include <vector>
#include <fstream>
#include <stdexcept>
#include <algorithm>

using namespace std;

static string toLowerCase(const string& in) {
    string t;
    for (string::const_iterator i = in.begin(); i != in.end(); ++i) {
        t += tolower(*i);
    }
    return t;
}

static void getFilesInDirectory(const string& dirName, vector<string>& fileNames, const vector<string>& validExtensions) {
    printf("Opening directory %s\n", dirName.c_str());
    struct dirent* ep;
    size_t extensionLocation;
    DIR* dp = opendir(dirName.c_str());
    if (dp != NULL) {
        while ((ep = readdir(dp))) {
            // Ignore (sub-)directories like . , .. , .svn, etc.
            if (ep->d_type & DT_DIR) {
                continue;
            }
            extensionLocation = string(ep->d_name).find_last_of("."); // Assume the last point marks beginning of extension like file.ext
            // Check if extension is matching the wanted ones
            string tempExt = toLowerCase(string(ep->d_name).substr(extensionLocation + 1));
            if (find(validExtensions.begin(), validExtensions.end(), tempExt) != validExtensions.end()) {
                printf("Found matching data file '%s'\n", ep->d_name);
                fileNames.push_back((string) dirName + ep->d_name);
            } else {
                printf("Found file does not match required file type, skipping: '%s'\n", ep->d_name);
            }
        }
        (void) closedir(dp);
    } else {
        printf("Error opening directory '%s'!\n", dirName.c_str());
    }
    return;
}

void printHelp()	{
	cout<<"--help\n";
	cout<<"getDDSMNamesAndConvertToLJPEG1 <LJPEG_images_directory_name>";
}

int main(int argc, char* argv[])
{
	if (argc < 2)	{
		cout<<"No arguments supplied!";
		printHelp();
		exit;
	}
    static string posSamplesDir = argv[1];
    static vector<string> LJPEGImageNames;
    static vector<string> validExtensions;
    validExtensions.push_back("ljpeg");
    getFilesInDirectory(posSamplesDir, LJPEGImageNames, validExtensions);
    int count = 0;
    vector<string>::iterator iter;
    char command[100];
    for (iter = LJPEGImageNames.begin();iter < LJPEGImageNames.end();iter++)    {
        cout<<(*iter)<<endl;
        string filename = *iter;
        sprintf(command, "./jpeg -d -s %s", filename.c_str());
        cout<<endl<<endl;
        system(command);
        cout<<endl<<endl<<"Calling JPEG program using ->"<<(*iter)<<" file";
        ++count;
    }
    cout<<endl<<endl<<"Number of Images Decompressed to LJPEG1 -> "<<count<<endl;
    cout<<"End of program"<<endl;
    return 0;
}