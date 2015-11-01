function [X, map] = pnmread(filename)
%PNMREAD Read image data from a PPM/PGM/PBM file.
%
%   [X, MAP] = PNMREAD(FILENAME) reads image data from a PPM, PGM or PBM
%   file.  X is an M-by-N array for PBM (bitmap) and PGM (grayscale) images
%   and an M-by-N-by-3 array for PPM (pixmap) images.  PPM, PGM, and PBM
%   images have no colormap so MAP is always empty.
%
%   PNM is not an image format by itself but means any of PPM, PGM, and PBM.
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

   [X, map] = pnmreadpnm(filename);
