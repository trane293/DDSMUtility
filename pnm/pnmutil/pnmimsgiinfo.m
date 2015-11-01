function [info, msg] = pnmimsgiinfo(filename)
%PNMIMSGIINFO Get information about the image in a SGI file.
%
%   [INFO, MSG] = PNMIMSGIINFO(FILENAME) returns information about the image
%   contained in a SGI file.  If an error occurs, INFO will be empty and an
%   error message is returned in MSG, otherwise MSG is empty.
%
%   SGI image files often have one of the suffices .BW (bitmap or grayscale
%   image), .RGB (truecolor image), or .RGBA (truecolor image with alpha
%   channel).
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   This program is based on the SGI image file format specification version
%   1.00 (http://reality.sgi.com/grafica/sgiimage.html) by Paul Haeberli
%   (paul@sgi.com).

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
      return
   end

   % See if the file exists.
   if exist(filename, 'file') ~= 2
      msg = 'File does not exist.';
      return
   end

   % Try to open the file for reading.
   [fid, fopen_msg] = fopen(filename, 'rb', 'ieee-be');
   if fid < 0
      msg = fopen_msg;
      return;
   end

   filename = fopen(fid);               % get the full path name
   fileinfo = dir(filename);            % read file information

   % Initialize universal structure fields to fix the order
   info.Filename        = filename;
   info.FileModDate     = fileinfo.date;
   info.FileSize        = fileinfo.bytes;
   info.Format          = 'sgi';
   info.FormatVersion   = [];
   info.Width           = [];
   info.Height          = [];
   info.BitDepth        = [];
   info.ColorType       = [];
   info.FormatSignature = [];

   % Initialize SGI-specific structure fields to fix the order. The
   % names used are the ones used in the specification.
   info.BytesPerComponent = [];    % Number of bytes per pixel component.
   info.Dimension         = [];    % Number of dimensions.
   info.Channels          = [];    % Number of channels.
   info.Pixmin            = [];    % Minimum pixel value.
   info.Pixmax            = [];    % Maximum pixel value.
   info.ImageName         = '';    % Image name.
   info.HeaderSize        = [];    % Size of image header.
   info.ImageDataOffset   = [];    % Offset of image data.

   % These are just text versions of some of the above.
   info.PixelValueInterpretation = '';
   info.Compression              = '';

   % Read format signature.  SGI name: 'MAGIC'.
   info.FormatSignature = fread(fid, 1, 'uint16');
   if isempty(info.FormatSignature)
      msg = 'File ended while reading magic number.';
      info = [];
      fclose(fid);
      return
   end
   if info.FormatSignature ~= 474
      msg = 'Invalid magic number. File is corrupt or not an SGI image.';
      info = [];
      fclose(fid);
      return
   end

   % Read compression type.  SGI name: 'STORAGE'.
   storage = fread(fid, 1, 'char');
   if isempty(storage)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end
   switch storage
      case 0
         info.Compression = 'none';
      case 1
         info.Compression = 'rle';
      otherwise
         msg = sprintf(['Invalid ''Storage'' value %d' ...
                        ' (only 0, 1 allowed)'], storage);
         info = [];
         fclose(fid);
         return
   end

   % Bytes per pixel per channel (component).  SGI name: 'BPC'.
   info.BytesPerComponent = fread(fid, 1, 'char');
   if isempty(info.BytesPerComponent)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end
   if all(info.BytesPerComponent ~= [1 2])
      msg = sprintf(['Invalid number of bytes per component %d' ...
                     ' (only 1-2 allowed)'], info.BytesPerComponent);
      info = [];
      fclose(fid);
      return
   end

   % The number of dimensions in the data.  SGI name: 'DIMENSIONS'.
   info.Dimension = fread(fid, 1, 'uint16');
   if isempty(info.Dimension)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   % The width of the image in pixels.  SGI name: 'XSIZE'.
   info.Width = fread(fid, 1, 'uint16');
   if isempty(info.Width)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   % The height of the image in pixels.  SGI name: 'YSIZE'.
   info.Height = fread(fid, 1, 'uint16');
   if isempty(info.Height)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   % The number of channels.  SGI name: 'ZSIZE'.
   info.Channels = fread(fid, 1, 'uint16');
   if isempty(info.Channels)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end
   if all(info.Channels ~= [1 3 4])
      msg = sprintf(['Invalid number of channels %d' ...
                     ' (only 1,3,4 allowed)'], info.Channels);
      info = [];
      fclose(fid);
      return
   end

   % The minimum pixel value in the image.  SGI name: 'PIXMIN'.
   info.Pixmin = fread(fid, 1, 'uint32');
   if isempty(info.Pixmin)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   % The maximum pixel value in the image.  SGI name: 'PIXMAX'.
   info.Pixmax = fread(fid, 1, 'uint32');
   if isempty(info.Pixmax)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   % These 4 bytes of data should be set to 0.  SGI name: 'DUMMY'.
   fread(fid, 4, 'char');

   % Image name. Zero-terminated string.  This is not commonly used.
   info.ImageName = fread(fid, 80, 'char').';
   k = find(info.ImageName == 0);
   if isempty(k)            % this should not happen, but just in case...
      k = length(info.ImageName);
   else
      k = k(1) - 1;
   end
   info.ImageName = char(info.ImageName(1:k));

   % This controls how the pixel values in the file should be interpreted.
   % SGI name: 'COLORMAP'.
   colormap = fread(fid, 1, 'uint32');
   if isempty(colormap)
      msg = 'File ended while reading image header.';
      info = [];
      fclose(fid);
      return
   end

   %info.Format    = 'rgb';         % default; handle exceptions below
   info.ColorType = 'truecolor';   % ditto
   switch colormap
      case 0       % normal image; uncompressed or RLE compressed
         info.PixelValueInterpretation = 'normal';
         switch info.Channels
            case 1
               %info.Format = 'bw';      % bitmap or grayscale image
               info.ColorType = 'grayscale';
            case 4
               %info.Format = 'rgba';    % RGB image with alpha channel
         end
      case 1       % RGB values packed into a single byte; obsolete
         info.PixelValueInterpretation = 'dithered';
      case 2       % indexed image; obsolete
         info.PixelValueInterpretation = 'indexed';
         info.ColorType = 'indexed';
      case 3       % image is a color map from an SGI machine
         info.PixelValueInterpretation = 'colormap';
      otherwise
         msg = sprintf('Invalid colormap ID %d (only 0-3 allowed)', ...
                       colormap);
         info = [];
         fclose(fid);
         return
   end

   % Now we have read what we need of the image header. The next 404 bytes
   % are just for making the header exactly 512 bytes.
   fclose(fid);

   % SGI image headers are always 512 bytes. Calculate the number of bits
   % per pixel.
   info.HeaderSize = 512;
   info.BitDepth = 8 * info.BytesPerComponent * info.Channels;

   switch info.Compression
      case 'none'
         % In uncompressed SGI images, the image data comes right after the
         % header.
         info.ImageDataOffset = info.HeaderSize;
      case 'rle'
         % In RLE compressed SGI images, the image data comes after 2 offset
         % tables with 4 byte longs, one long for each row for each channel.
         info.ImageDataOffset = info.HeaderSize ...
                                  + 2 * 4 * info.Height * info.Channels;
      otherwise
         % We should never get here.
         error([mfilename ': internal error']);
   end
