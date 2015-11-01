function image = ConvertDDSMImageToRaw(filename, columns, rows, digitizer)
%// ConvertDDSMImageToRaw Convert an image of ddsm database to raw image.
%// -------------------------------------------------------------------------
%// Input:-
%//  o filename : String representing ddsm image file name.
%//  o columns  : Double representing number of columns in the image.
%//  o rows     : Double representing number of rows in the image.
%//  o digitizer: String representing image normalization function name,
%//     which differ from one case to another and have the set of 
%//    values ['dba', 'howtek-mgh', 'howtek-ismd' and 'lumisys' ]
%// -------------------------------------------------------------------------
%// Prepare and execute command of image decompression
commandDecompression = [which('jpeg.exe') ' -d -s ' filename];
dos(commandDecompression);
%// -------------------------------------------------------------------------
%// Prepare and execute command that convert the decompressed image to pnm format.
rawFileName          = [ filename '.1'];
columns              = num2str(columns);
rows                 = num2str(rows);
digitizer            = ['"' digitizer '"'];
commandConversion    =[ which('pnm.exe') ,' ',rawFileName,' ',columns,' ',rows,' ',digitizer];
dos(commandConversion);
%// -------------------------------------------------------------------------
%// Wrtie the image into raw format
pnmFileName          = [rawFileName '-ddsmraw2pnm.pnm'];
image                = pnmread(pnmFileName);
imwrite(image,[filename '.raw']);
end