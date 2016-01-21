function [X, map] = xbmread(filename)
%XBMREAD Read image data from an XBM file.
%
%   [X,MAP] = XBMREAD(FILENAME) reads image data from a XBM file.  X is a
%   logical uint8 matrix.  An XBM image has no colormap so MAP is always empty.
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

   [X, map] = pnmreadxbm(filename);
