function raswrite(varargin)
%RASWRITE Write a RAS (Sun raster) file to disk.
%
%   RASWRITE(BM, FILENAME) writes the bitmap image BM to the file specified by
%   the string FILENAME.
%
%   RASWRITE(I, FILENAME) writes the grayscale image I to the file.
%
%   RASWRITE(RGB, FILENAME) writes the truecolor image represented by the
%   M-by-N-by-3 array RGB.
%
%   RASWRITE(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   RASWRITE(...,'Type',TYPE) writes an image file of the type indicated by the
%   string TYPE.  TYPE can be 'standard' (uncompressed, uses b-g-r color order
%   with RGB images), 'rgb' (like 'standard', but uses r-g-b color order for
%   RGB images) or 'rle' (run-length compression of 1 and 8 bit images).
%
%   RASWRITE(...,'Alpha',ALPHA) adds the alpha (transparency) channel to the
%   image.  ALPHA must be a 2D matrix with the same number or rows and columns
%   as the image matrix.  Only allowed with RGB images.
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
      varargin{3} = [varargin{3}, '.ras'];
   else
      if ~ismember(lower(ext), {'.ras'})
         error('File must have a .ras suffix.');
      end
   end

   % Write the image.

   pnmwriteras(varargin{:});
