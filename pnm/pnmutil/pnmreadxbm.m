function [X, map] = pnmreadxbm(filename)
%PNMREADXBM Read image data from an XBM file.
%
%   [X,MAP] = PNMREADXBM(FILENAME) reads image data from a XBM file.  X is a
%   logical uint8 matrix.  An XBM image has no colormap so MAP is always empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:20:14 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   info = pnmimxbminfo(filename);
   map = [];

   height     = info.Height;
   width      = info.Width;

   % Try to open the file for reading.
   [fid, msg] = fopen(filename, 'r');
   if fid < 0
      error([filename ': ' msg]);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Read lines until we find one that starts with the word "static".
   %
   while 1
      line = fgets(fid);
      if ~ischar(line)
         fclose(fid);
         error([file ': end of file reached while scanning image header.']);
      end
      if strcmp(sscanf(line, '%s', 1), 'static')
         break
      end
   end
   fseek(fid, -length(line), 0);        % back up to beginning of line

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Look for a left brace "{"
   %
   fscanf(fid, '%[^{]');
   fscanf(fid, '%[{]');
   if feof(fid);
      fclose(fid);
      error([filename ': end of file found while scanning for ' ...
             'image data.']);
   end

   pixels = height*width;
   paddedWidth = 8*ceil(width/8);
   numBytes = paddedWidth * height / 8;

   [X, count] = fscanf(fid, '%x,');
   fclose(fid);
   X = uint8(X);
   if count < numBytes
      warning([filename ': too little data for image; padding data.']);
      X(numBytes) = 0;
   elseif count > numBytes
      warning([filename ': too much data for image; truncating data.']);
      X = X(1:numBytes);
   end

   XX = reshape(X, paddedWidth/8, height).';
   XX = bitxor(XX, 255);        % XBM: white=0, black=1, so invert

   X = logical(repmat(uint8(0), height, paddedWidth));
   X(:,1:8:end) = bitget(XX, 1);
   X(:,2:8:end) = bitget(XX, 2);
   X(:,3:8:end) = bitget(XX, 3);
   X(:,4:8:end) = bitget(XX, 4);
   X(:,5:8:end) = bitget(XX, 5);
   X(:,6:8:end) = bitget(XX, 6);
   X(:,7:8:end) = bitget(XX, 7);
   X(:,8:8:end) = bitget(XX, 8);

   if width < paddedWidth
      X = X(:,1:width);         % remove padding
   end
