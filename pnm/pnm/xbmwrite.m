function xbmwrite(varargin)
%XBMWRITE Write a XBM (X bitmap) file to disk.
%
%   XBMWRITE(BM, FILENAME) writes the bitmap image BM to the file specified by
%   the string FILENAME.
%
%   XBMWRITE(I, FILENAME) converts the grayscale image I into a bitmap (by
%   thresholding) and writes the resulting image to the file specified by the
%   string FILENAME.
%
%   XBMWRITE(RGB, FILENAME) converts the truecolor image represented by the
%   M-by-N-by-3 array RGB into a bitmap (by grayscaling and thresholding) and
%   writes the resulting image to the file specified by the string FILENAME.
%
%   XBMWRITE(X, MAP, FILENAME) converts the indexed image represented by the
%   index matrix X and colormap MAP into a bitmap (by grayscaling and by
%   thresholding) and writes the resulting image to the file specified by the
%   string FILENAME.
%
%   XBMWRITE(...,'XHotSpot',VAL) sets the XHotSpot value to VAL.  VAL must be a
%   non-negative integer.
%
%   XBMWRITE(...,'YHotSpot',VAL) sets the YHotSpot value to VAL.  VAL must be a
%   non-negative integer.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:19:43 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(2, Inf, nargin));

   % The PNMWRITEXXX functions always require an image matrix and (a possibly
   % empty) color map.  So if the second argument is a file name, insert an
   % empty colormap between first argument and file name.

   if ischar(varargin{2})
      varargin = {varargin{1}, [], varargin{2:end}};
   end

   % Check the suffix.

   [pth, nam, ext] = fileparts(varargin{3});
   if isempty(ext)
      varargin{3} = [varargin{3}, '.xbm'];
   else
      if ~ismember(lower(ext), {'.xbm'})
         error('File must have a .xbm suffix.');
      end
   end

   % Write the image.

   pnmwritexbm(varargin{:});
