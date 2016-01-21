function sgiwrite(varargin)
%SGIWRITE Write an SGI (Silicon Graphics Image) file to disk.
%
%   SGIWRITE(BM, FILENAME) writes the bitmap image BM to the file specified by
%   the string FILENAME.
%
%   SGIWRITE(I, FILENAME) writes the grayscale image I to the file specified by
%   the string FILENAME.
%
%   SGIWRITE(RGB, FILENAME) writes the truecolor image represented by the
%   M-by-N-by-3 array RGB.
%
%   SGIWRITE(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   SGIWRITE(...,'Compression',COMP) uses the compression type indicated by the
%   string COMP. COMP can be 'none' or 'rle'.  The default is 'none'.
%
%   SGIWRITE(...,'BytesPerChannel',BPC) specifies the number of bytes to use
%   per pixel component. BPC can be 1 or 2.  Default is 2 if image array is
%   'uint16' and 1 otherwise.
%
%   SGIWRITE(...,'ImageName',NAME) may be used to specify the image name. NAME
%   must be a zero-terminated string no more than 80 characters long (image
%   name will be truncated and/or a terminating zero will be appended if
%   necessary).  The default is 'no name'.
%
%   SGIWRITE(...,'Alpha',ALPHA) adds the alpha (transparency) channel to the
%   image.  ALPHA must be a 2D matrix with the same number or rows and columns
%   as the image matrix.
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
      varargin{3} = [varargin{3}, '.sgi'];
   else
      if ~ismember(lower(ext), {'.sgi', '.bw', '.rgb', '.rgba'})
         error('File must have a .sgi suffix.');
      end
   end

   % Write the image.

   pnmwritesgi(varargin{:});
