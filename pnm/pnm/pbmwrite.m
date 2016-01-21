function pbmwrite(varargin)
%PBMWRITE Write a PBM file to disk.
%
%   This program is just a front-end to PNMWRITE.
%   PNMWRITE/PBMWRITE will write a PBM file if the given file name has
%   a .pbm suffix.  See the help entry in PNMWRITE for details.
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
      varargin{3} = [varargin{3}, '.pbm'];
   else
      if ~ismember(lower(ext), {'.pbm'})
         error('File must have a .pbm suffix.');
      end
   end

   % Write the image.

   pnmwritepnm(varargin{:});
