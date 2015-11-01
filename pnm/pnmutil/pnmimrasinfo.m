function [info, msg] = pnmimrasinfo(filename)
%PNMIMRASINFO Get information about the image in a RAS file.
%
%   [INFO, MSG] = PNMIMRASINFO(FILENAME) returns information about the image
%   contained in a RAS file.  If an error occurs, INFO will be empty and an
%   error message is returned in MSG, otherwise MSG is empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   A complete official specification for the RAS (Sun Raster) image format
%   does not seem to have been made publicly available.  As sources for the RAS
%   image format I have used
%
%     * /usr/include/rasterfile.h of the Sun OS
%     * The rasterfile(4) man page of the Sun OS
%     * The files libpnm4.c, rasttopnm.c, and pnmtorast.c in the NetPBM 8.3
%       distribution
%     * "Inside SUN Rasterfile", a note by Jamie Zawinski
%      <jwz@teak.berkeley.edu> containing an excerpt from "Sun-Spots
%      Digest", Volume 6, Issue 84.

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
      return
   end

   % See if the file exists.
   if exist(filename, 'file') ~= 2
      msg = 'File does not exist.';
      info = [];
      return
   end

   % Try to open the file for reading.
   [fid, fopen_msg] = fopen(filename, 'rb', 'ieee-be');
   if fid < 0
      msg = fopen_msg;
      return
   end

   filename = fopen(fid);               % get the full path name
   fileinfo = dir(filename);            % read file information

   % Initialize universal structure fields to fix the order.
   info.Filename        = filename;
   info.FileModDate     = fileinfo.date;
   info.FileSize        = fileinfo.bytes;
   info.Format          = 'RAS';
   info.FormatVersion   = [];
   info.Width           = [];
   info.Height          = [];
   info.BitDepth        = [];
   info.ColorType       = '';
   info.FormatSignature = [];

   % Initialize RAS-specific structure fields to fix the order.
   info.Length    = [];
   info.Type      = [];
   info.MapType   = [];
   info.MapLength = [];

   % magic number
   info.FormatSignature = fread(fid, 1, 'uint32');

   % width (pixels) of image
   info.Width           = fread(fid, 1, 'uint32');

   % height (pixels) of image
   info.Height          = fread(fid, 1, 'uint32');

   % depth (1, 8, 24, or 32 bits) pr pixel
   info.BitDepth        = fread(fid, 1, 'uint32');

   % length (in bytes) of image
   info.Length          = fread(fid, 1, 'uint32');

   % type of file; see PNMREADRAS for details.
   info.Type            = fread(fid, 1, 'uint32');

   % type of colormap; see PNMREADRAS for details.
   info.MapType         = fread(fid, 1, 'uint32');

   % length (bytes) of following map
   info.MapLength       = fread(fid, 1, 'uint32');

   % see if we got the whole header
   if isempty(info.MapLength)
      info = [];
      msg = 'Truncated header';
      fclose(fid);
      return;
   end

   % we have got what we need from the file, so close it
   fclose(fid);

   % get the color type
   if info.MapLength
      info.ColorType = 'indexed';
   elseif info.BitDepth == 1
      info.ColorType = 'grayscale';
   else
      info.ColorType = 'truecolor';
   end
