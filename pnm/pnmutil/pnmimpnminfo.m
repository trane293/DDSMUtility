function [info, msg] = pnmimpnminfo(filename)
%PNMIMPNMINFO Get information about the image in a PPM/PGM/PBM file.
%
%   [INFO, MSG] = PNMIMPNMINFO(FILENAME) returns information about the image
%   contained in a PPM, PGM or PBM file.  If an error occurs, INFO will be
%   empty and an error message is returned in MSG, otherwise MSG is empty.
%
%   PNM is not an image format by itself but means any of PPM, PGM, and PBM.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   The PNM formats PPM, PGM and PBM are descibed in the UNIX manual pages
%   ppm(5), pgm(5) and pbm(5) respectively.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % Check number of input arguments.
   error(nargchk(1, 1, nargin));

   % Initialize output arguments.
   info = [];
   msg  = '';

   % See if file name is a non-empty string.
   if ~ischar(filename) | isempty(filename)
      msg = 'File name must be a non-empty string';
      info = [];
      return;
   end

   % See if the file exists.
   if exist(filename, 'file') ~= 2
      msg = ['File ' filename ' does not exist.'];
      info = [];
      return;
   end

   % Try to open the file for reading.
   [fid, fopen_msg] = fopen(filename, 'r');
   if fid == -1
      msg = fopen_msg;
      info = [];
      return;
   end

   filename = fopen(fid);               % get the full path name
   fileinfo = dir(filename);            % read file information

   % Initialize universal structure fields to fix the order
   info.Filename        = filename;
   info.FileModDate     = fileinfo.date;
   info.FileSize        = fileinfo.bytes;
   info.Format          = '';
   info.FormatVersion   = [];
   info.Width           = [];
   info.Height          = [];
   info.BitDepth        = [];
   info.ColorType       = '';
   info.FormatSignature = [];

   % Initialize PNM-specific structure fields to fix the order.

   info.Encoding        = '';
   info.MaxValue        = [];
   info.ImageDataOffset = [];

   % Look for the magic number (i.e., format signature).
   [magic, count] = fscanf(fid, '%c', 2);
   if count < 2
      fclose(fid);
      info = [];
      return;
   end
   info.FormatSignature = magic;

   % Get the image format and encoding ('plain' is ascii, 'raw' is binary).
   switch magic
      case 'P1'
         info.Format        = 'PBM';
         info.ColorType     = 'grayscale';      % black and white, actually
         info.Encoding      = 'ASCII';
         info.FormatVersion = 'P1';
      case 'P2'
         info.Format        = 'PGM';
         info.ColorType     = 'grayscale';      % black and white, actually
         info.Encoding      = 'ASCII';
         info.FormatVersion = 'P2';
      case 'P3'
         info.Format        = 'PPM';
         info.ColorType     = 'truecolor';
         info.Encoding      = 'ASCII';
         info.FormatVersion = 'P3';
      case 'P4'
         info.Format        = 'PBM';
         info.ColorType     = 'grayscale';
         info.Encoding      = 'rawbits';
         info.FormatVersion = 'P4';
      case 'P5'
         info.Format        = 'PGM';
         info.ColorType     = 'grayscale';
         info.Encoding      = 'rawbits';
         info.FormatVersion = 'P5';
      case 'P6'
         info.Format        = 'PPM';
         info.ColorType     = 'truecolor';
         info.Encoding      = 'rawbits';
         info.FormatVersion = 'P6';
      otherwise
         fclose(fid);                   % close file
         msg = 'Invalid magic number. File is not a PPM, PGM, or PBM file.';
         info = [];
         return;
   end

   % Read image size.
   [header_data, count] = pnmpnmgeti(fid, 2);
   if count < 2
      fclose(fid);                      % close file
      msg = 'File ended while reading image header.';
      info = [];
      return;
   else
      info.Width  = header_data(1);     % image width
      info.Height = header_data(2);     % image height
   end

   % Read the maximum color-component value.  PBM images do not explicitly
   % contain this value because it has to be 1.  The maximum color component
   % value of PGM and PPM images may be any positive integer so BitDepth
   % might not be an integer!
   if strcmp(info.Format, 'PBM')
      info.MaxValue = 1;
   else
      [header_data, count] = pnmpnmgeti(fid, 1);
      if count < 1
         fclose(fid);                   % close file
         msg = 'File ended while reading image header.';
         info = [];
         return;
      end
      info.MaxValue = header_data(1);
   end
   info.BitDepth = log2(info.MaxValue + 1);

   % Because truecolor images have 3 channels
   if strcmp(info.ColorType, 'truecolor')
       info.BitDepth = info.BitDepth * 3;
   end

   % Raw PNM images should have a single byte of whitespace between the
   % image header and the pixel area.  Plain PNM images might have more
   % whitespace and even comments but the main point in the plain case is
   % that we are passed the header.
   info.ImageDataOffset = ftell(fid) + 1;

   % We've got what we need, so close the file.
   fclose(fid);
