function pnmsetup(option)
%PNMSETUP Set up the PNM Toolbox.
%
%   PNMSETUP adds the necessary directories to MATLAB's search path and,
%   optionally, registers the supported image formats.
%
%   When the supported image formats are registered, the functions in the PNM
%   Toolbox are accessed through the standard MATLAB functions IMREAD, IMWRITE,
%   and IMFINFO.
%
%   When the supported image formats are not registered, the functions in the
%   PNM toolbox are accessed in the "old-style" way where the image format is
%   given as part of the file name, like PNMREAD, XBMWRITE etc.  Type "help
%   pnm" at the MATLAB command prompt to see a complete list of functions.
%
%   Options for registering image formats
%   -------------------------------------
%
%      -NEW Register only the new formats provided by the toolbox.  This will
%           only register image formats that are not already registered.
%
%      -ALL Register all image formats provided by the toolbox.  This will
%           overwrite image formats that already are registered.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:19:43 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % Check number of input arguments.
   error(nargchk(0, 1, nargin));

   % Add the PNM root directory and the utility directory to the path.
   location = which(mfilename);         % location of this file
   pnmroot = fileparts(location);       % get directory portion

   % Add the utility directory.
   addpath(pnmroot, fullfile(pnmroot, 'pnmutil'), '-end');

   % If image formats shall not be registered, add the subdirectory with the
   % front-ends and bail out.
   if nargin < 1
      addpath(pnmroot, fullfile(pnmroot, 'pnm'), '-end');
      return
   end

   % Assemble the registry from hard-coded values
   new_fmts(1).ext = {'pbm'};
   new_fmts(1).isa = @pnmispbm;
   new_fmts(1).info = @pnmimpbminfo;
   new_fmts(1).read = @pnmreadpnm;
   new_fmts(1).write = @pnmwritepnm;
   new_fmts(1).alpha = 0;
   new_fmts(1).description = 'Portable Bitmap (PBM)';

   new_fmts(end + 1).ext = {'pgm'};
   new_fmts(end).isa = @pnmispgm;
   new_fmts(end).info = @pnmimpnminfo;
   new_fmts(end).read = @pnmreadpnm;
   new_fmts(end).write = @pnmwritepnm;
   new_fmts(end).alpha = 0;
   new_fmts(end).description = 'Portable Graymap (PGM)';

   new_fmts(end + 1).ext = {'ppm'};
   new_fmts(end).isa = @pnmisppm;
   new_fmts(end).info = @pnmimpnminfo;
   new_fmts(end).read = @pnmreadpnm;
   new_fmts(end).write = @pnmwritepnm;
   new_fmts(end).alpha = 0;
   new_fmts(end).description = 'Portable Pixmap (PPM)';

   new_fmts(end + 1).ext = {'pnm'};
   new_fmts(end).isa = @pnmispnm;
   new_fmts(end).info = @pnmimpnminfo;
   new_fmts(end).read = @pnmreadpnm;
   new_fmts(end).write = @pnmwritepnm;
   new_fmts(end).alpha = 0;
   new_fmts(end).description = 'Portable Anymap (PNM)';

   new_fmts(end + 1).ext = {'ras'};
   new_fmts(end).isa = @pnmisras;
   new_fmts(end).info = @pnmimrasinfo;
   new_fmts(end).read = @pnmreadras;
   new_fmts(end).write = @pnmwriteras;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'Sun Raster (RAS)';

   new_fmts(end + 1).ext = {'xbm'};
   new_fmts(end).isa = @pnmisxbm;
   new_fmts(end).info = @pnmimxbminfo;
   new_fmts(end).read = @pnmreadxbm;
   new_fmts(end).write = @pnmwritexbm;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'X Bitmap (XBM)';

   new_fmts(end + 1).ext = {'sgi'};
   new_fmts(end).isa = @pnmissgi;
   new_fmts(end).info = @pnmimsgiinfo;
   new_fmts(end).read = @pnmreadsgi;
   new_fmts(end).write = @pnmwritesgi;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'Silicon Graphics Image (SGI)';

   new_fmts(end + 1).ext = {'bw'};
   new_fmts(end).isa = @pnmissgi;
   new_fmts(end).info = @pnmimsgiinfo;
   new_fmts(end).read = @pnmreadsgi;
   new_fmts(end).write = @pnmwritesgi;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'Silicon Graphics Bitmap (BW)';

   new_fmts(end + 1).ext = {'rgb'};
   new_fmts(end).isa = @pnmissgi;
   new_fmts(end).info = @pnmimsgiinfo;
   new_fmts(end).read = @pnmreadsgi;
   new_fmts(end).write = @pnmwritesgi;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'Silicon Graphics RGB Image (RGB)';

   new_fmts(end + 1).ext = {'rgba'};
   new_fmts(end).isa = @pnmissgi;
   new_fmts(end).info = @pnmimsgiinfo;
   new_fmts(end).read = @pnmreadsgi;
   new_fmts(end).write = @pnmwritesgi;
   new_fmts(end).alpha = 1;
   new_fmts(end).description = 'Silicon Graphics RGB Image with Alpha (RGBA)';

   pnmimreg(new_fmts, option);

function pnmimreg(fmts, option)

   error(nargchk(2, 2, nargin));

   % Get the already registered formats.
   old_fmts = imformats;

   % Find the dimension along which we should concatenate the vectors.
   dim = find(size(old_fmts) ~= 1);
   if length(dim) ~= 1
      error('Image format structure is not a vector.');
   end

   % The "imformats" data structure can't contain duplicate suffixes, so we need
   % to compare the suffixes supported by this toolbox with the suffixes
   % already registered.

   option = lower(option);
   switch option

      case '-new'
         imformats(cat(dim, old_fmts, pnmimfmtdiff(fmts, old_fmts)));

      case '-all'
         imformats(cat(dim, pnmimfmtdiff(old_fmts, fmts), fmts));

      otherwise
         error(['Invalid option -- ', option]);
   end

function c = pnmimfmtdiff(a, b)
%PNMIMFMTDIFF Image format set difference.
%
%   PNMIMFMTDIFF(A, B), where A and B are image format structures, returns the
%   image structures in A which are not in B.

   % Check number of input arguments.
   error(nargchk(2, 2, nargin));

   % Get a list of all suffixes in the B structure.
   b_ext = [b.ext];

   % A mask indicating which elements to keep from the the A structure.
   mask = logical(zeros(size(a)));

   % Iterate over the elements in the A structure.
   for i = 1 : length(a)

      % Find the suffixes in the Ith element which are not anywhere in the B
      % structure.
      new_ext = setdiff(a(i).ext, b_ext);

      if ~isempty(new_ext)
         a(i).ext = new_ext;            % keep only unique suffixes
         mask(i) = 1;                   % mark for use
      end

   end

   c = a(mask);
