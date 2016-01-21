function [X, map, alpha] = rasread(filename)
%RASREAD Read image data from a RAS file.
%
%   [X,MAP,ALPHA] = RASREAD(FILENAME) reads image data from the specified file.
%   X is always a uint8 array, MAP is always a double array and ALPHA is always
%   a uint8 array.
%
%   For bitmap images, X is an M-by-N matrix and MAP and ALPHA are empty.
%   These are stored with 1 bit per pixel.
%
%   For indexed images, X is an M-by-N matrix, MAP is a K-by-3 matrix and ALPHA
%   is empty.  These are stored with 8 bits per index value, 8 bits per color
%   component and 1 or 3 color components per pixel.
%
%   For true color images, X is an M-by-N-by-3 array, and MAP and ALPHA are
%   empty.  These are stored with 8 bits per color component, 3 color
%   components per pixel.
%
%   For true color images with alpha channel, X is an M-by-N-by-3 array, MAP is
%   empty and ALPHA is an M-by-N matrix.  These are stored with 8 bits per
%   color component, 4 color components per pixel.
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

   [X, map, alpha] = pnmreadras(filename);
