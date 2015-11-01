function pnmwrite(varargin)
%PNMWRITE Write a PPM/PGM/PBM file to disk.
%
%   PNMWRITE(BM, FILENAME) writes the bitmap image BM to the file specified by
%   the string FILENAME.
%
%   PNMWRITE(I, FILENAME) writes the grayscale image I to the file.
%
%   PNMWRITE(RGB, FILENAME) writes the truecolor image represented by the
%   M-by-N-by-3 array RGB.
%
%   PNMWRITE(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   If the filename suffix is .PPM, .PGM, or .PBM, then it is the suffix, not
%   the image data, that determines what kind of image that will be written.
%   For instance, if the suffix is .PGM, then a portable graymap will be
%   written regardless of the image data given and the input image will be
%   converted to grayscale if neccessay.
%
%   If the filename suffix is .PNM, then file format and suffix will be chosen
%   automatically depending on the image data.
%
%   PNMWRITE(..., 'MaxValue', VALUE) may be used to write an image with a
%   different maximum pixel value than what is the default.  VALUE must be a
%   positive integer.  The default value is 255 except for uint16 images, for
%   which the default is 65535.  PBM images don't have a maximum pixel value,
%   so VALUE will be ignored for PBM images.
%
%   PNMWRITE(..., 'Encoding', ENCODING) may be used to specify the output
%   encoding.  ENCODING must be 'plain', 'ascii', or 'text' for ASCII encoded
%   images and 'raw' or 'binary' for binary encoded images.  The default
%   encoding is 'binary' if the maximum pixel value is less than or equal to
%   255 and ASCII encoding otherwise.
%
%   A comment on non-standard 'MaxValue'/'Encoding' property values
%   ---------------------------------------------------------------
%   The PPM/PGM file format specification does not allow that a binary PPM/PGM
%   image has a maximum pixel value larger than 255, but since some software
%   (notably NetPBM) supports binary PPM/PGM images with a maximum pixel value
%   of up to 65535, this is supported.  Note, however, that this is
%   non-standard, so some software might not be able to read the resulting
%   image file).
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
      varargin{3} = [varargin{3}, '.pnm'];
   else
      if ~ismember(lower(ext), {'.pbm', '.pgm', '.ppm', '.pnm'})
         error('File must have a .pbm, .pgm, .ppm, or .pnm suffix.');
      end
   end

   % Write the image.

   pnmwritepnm(varargin{:});
