function [X, map, alpha] = sgiread(filename)
%SGIREAD Read image data from a SGI file.
%
%   [X,MAP,ALPHA] = SGIREAD(FILENAME) reads image data from the specified file.
%   X is a uint8 or uint16 array, MAP is always a double array and ALPHA is the
%   same class as X.
%
%   X is 2-D for grayscale images, M-by-N-by-3 for RGB and RGBA images.  X is
%   of class uint8 if the image uses 1 byte per color component and uint16 if
%   the image uses 2 bytes per color component.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:19:43 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   if ~ischar(filename) | isempty(filename)
      error('File name must be a non-empty char array (string).');
   end

   if ~exist(filename, 'file')
      error([filename ': file does not exist.']);
   end

   [X, map, alpha] = pnmreadsgi(filename);
