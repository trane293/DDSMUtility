function [info, msg] = pnmimxbminfo(filename)
%PNMIMXBMINFO Get information about the image in a XBM file.
%
%   [INFO, MSG] = PNMIMXBMINFO(FILENAME) returns information about the image
%   contained in a XBM file.  If an error occurs, INFO will be empty and an
%   error message is returned in MSG, otherwise MSG is empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

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
      msg = ['File ' filename ' does not exist.'];
      info = [];
      return
   end

   % Try to open the file for reading.
   [fid, fopen_msg] = fopen(filename, 'r');
   if fid < 0
      msg = fopen_msg;
      info = [];
      return
   end

   filename = fopen(fid);               % get the full path name
   fileinfo = dir(filename);            % read file information

   %
   % Initialize universal structure fields to fix the order.
   %
   info.Filename        = filename;
   info.FileModDate     = fileinfo.date;
   info.FileSize        = fileinfo.bytes;
   info.Format          = 'xbm';
   info.FormatVersion   = [];
   info.Width           = [];
   info.Height          = [];
   info.BitDepth        = 2;
   info.ColorType       = 'grayscale';
   info.FormatSignature = [];

   %
   % Initialize XBM-specific structure fields to fix the order.  The
   % hotspot values indicate the "tip" of the pointer when the xbm image
   % represents a cursor.
   %
   info.XHotSpot  = [];         % horizontal hotspot (tip of pointer)
   info.YHotSpot  = [];         % vertical hotspot (tip of pointer)
   info.ImageName = '';         % image name

   % Read lines until we find one that starts with the word "static".
   found_static = 0;
   while ~found_static

      line = fgetl(fid);
      if ~ischar(line)
         msg = 'End of file reached while reading header.';
         info = [];
         fclose(fid);
         return
      end

      [token, line] = strtok(line);
      if strcmp(token, 'static')
         break
      end

      % Read lines until we find a "#define" directive.  The ANSI standard
      % allows whitespace between newline and "#" and between "#" and
      % "define".
      %
      found_define = 0;
      if strcmp(token, '#define')
         found_define = 1;
      elseif strcmp(token, '#')
         [token, line] = strtok(line);
         if strcmp(token, 'define')
            found_define = 1;
         end
      end

      if found_define

         % The rest of the line should be a string and a decimal digit.
         [string, line] = strtok(line);
         value = sscanf(line, '%d', 1);

         % Look at the end of the string to find the field to assign to.
         if strcmp(string(max(end-5, 1) : end), '_width')
            info.Width = value;
            info.ImageName = string(1:end-6);
         elseif strcmp(string(max(end-6, 1) : end), '_height')
            info.Height = value;
            info.ImageName = string(1:end-7);
         elseif strcmp(string(max(end-5, 1) : end), '_x_hot')
            info.XHotSpot = value;
            info.ImageName = string(1:end-6);
         elseif strcmp(string(max(end-5, 1) : end), '_y_hot')
            info.YHotSpot = value;
            info.ImageName = string(1:end-6);
         end

      end

   end

   % Close file.
   fclose(fid);

   % Check some required image properties.
   if isempty(info.Width)
      msg = 'No information on image width.';
      info = [];
      return
   end
   if isempty(info.Height)
      msg = 'No information on image height.';
      info = [];
      return
   end
