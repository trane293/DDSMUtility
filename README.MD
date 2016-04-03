This is a tutorial for the DDSM Utility v3.1 written by me (Anmol Sharma, Undergrad Engineering Student at DAVIET Jalandhar) to greatly simplify downloading, converting, viewing and extracting annotations from the Digital Database for Screening Mammography (DDSM) database available here: http://marathon.csee.usf.edu/Mammography/Database.html 

If you use this utility in your research, I would appreciate of you cite it in your paper/thesis. You can do it as:

      @misc{Anmol2015,
      author = {Anmol Sharma},
      title = {DDSM Utility},  
      year = {2015},  
      publisher = {GitHub},  
      journal = {GitHub repository},  
      howpublished = {\url{https://github.com/trane293/DDSMUtility}},  
      }

# Features of the DDSM Utility
* Easily download multiple case files automatically. 
* Normalize LJPEG images according to their scanners automatically! No manual normalization needed. 
* Automatically convert LJPEG DDSM images into PNG, JPEG, TIF, GIF and other formats. 
* Read boundary information of each of the converted images and display them. 


# Initial Requirements

*	A Windows based machine
*	WinSCP
* Cygwin (32 bit)
* MATLAB 201x


# Tested on
*	Dell Inspiron 15 3537
*	Intel i5 4200U 
*	4GB RAM
*	Windows 10 with MATLAB R2015b

# Contact
Anmol Sharma
anmol.sharma293@gmail.com

# Detailed Instructions along with images are present in Tutorial.pdf file.

This is a tutorial for the DDSM Utility v3.1 to greatly simplify downloading, converting, viewing and extracting annotations from the Digital Database for Screening Mammography (DDSM) database available here: http://marathon.csee.usf.edu/Mammography/Database.html 

DDSM is a very famous mammogram database which researchers around the world use to test their mass detection and mass classification algorithms so as to ensure that the results are comparable to other authors or systems. However, an an open source utility or tool doesn’t seem to exist to easily and efficiently download the database. The website where the database is hosted has not been updated from the last 15 (almost 16) years, and hence the deprecated and obsolete software that comes with it is essentially, unusable. None of the authors using the database has released code that can process DDSM images, with their research.   

The utility is capable of automatically parsing ICS files which contains the LJPEG image sizes to facilitate LJPEG to LJPEG1 decompression, and further conversion into other known formats like PNG. I decided to write this utility when I was looking for ways to download and convert DDSM dataset, only to find out that the images are in a very old LJPEG format. The only utility available on the DDSM website (here, written for very old SunOS 5.6) was to convert it into LJPEG1 (another old, obsolete and unusable format), and that too was highly labor intensive because it required the user to manually run the script for every image he wanted to convert. Even if the user did that, converting LJPEG1 file to PNG was a nightmare, if not impossible.  

Another utility available was written by Dr. Chris Rose of University of Manchester (here). It required the user to input names of IMAGE files manually, which then his script used to download the DDSM image in PNG format. This was again, ridiculously labor intensive, and didn't make sense if the user wants to download, say, 1000 images. The source code was not supplied, so making changes to the internal working was not possible. Moreover, if the user wanted to download the annotation files along with the image, he has to repeat the steps all over again. I wasn’t getting paid by the hour, so this was downright ridiculous for me. 


