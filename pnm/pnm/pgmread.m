function [X, map] = pgmread(filename)
%PGMREAD Read image data from a PGM file.
%
%   This program is just a front-end to PNMREAD.
%   See the help entry in PNMREAD for details.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:19:43 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   [X, map] = pnmread(filename);
