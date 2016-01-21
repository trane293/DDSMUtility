function pnmwriteras(data, map, filename, varargin)
%PNMWRITERAS Write a RAS (Sun raster) file to disk.
%
%   PNMWRITERAS(BM, [], FILENAME) writes the bitmap image BM to the file
%   specified by the string FILENAME.
%
%   PNMWRITERAS(I, [], FILENAME) writes the grayscale image I to the file.
%
%   PNMWRITERAS(RGB, [], FILENAME) writes the truecolor image represented by
%   the M-by-N-by-3 array RGB.
%
%   PNMWRITERAS(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   PNMWRITERAS(...,'Type',TYPE) writes an image file of the type indicated by
%   the string TYPE.  TYPE can be 'standard' (uncompressed, uses b-g-r color
%   order with RGB images), 'rgb' (like 'standard', but uses r-g-b color order
%   for RGB images) or 'rle' (run-length compression of 1 and 8 bit images).
%
%   PNMWRITERAS(...,'Alpha',ALPHA) adds the alpha (transparency) channel to the
%   image.  ALPHA must be a 2D matrix with the same number or rows and columns
%   as the image matrix.  Only allowed with RGB images.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   A complete official specification for the RAS (Sun Raster) image format
%   does not seem to have been made publicly available.  As sources for the RAS
%   image format I have used
%
%     * /usr/include/rasterfile.h of the Sun OS
%     * The rasterfile(4) man page of the Sun OS
%     * The files libpnm4.c, rasttopnm.c, and pnmtorast.c in the NetPBM 8.3
%       distribution
%     * "Inside SUN Rasterfile", a note by Jamie Zawinski
%      <jwz@teak.berkeley.edu> containing an excerpt from "Sun-Spots
%      Digest", Volume 6, Issue 84.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Some argument checking
   %

   error(nargchk(3, Inf, nargin));

   nd = ndims(data);
   if nd > 3
      error(sprintf('%d-D data not supported for RAS files', nd));
   end

   if ~ischar(filename) | isempty(filename)
      error('Filename must be a non-empty string.');
   end

   [height, width, ncomp] = size(data);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Process param/value pairs
   %

   type  = 'standard';
   alpha = [];

   paramStrings = ['type '
                   'alpha'];

   if rem(length(varargin), 2)
      error('Odd number of Parameter-Value arguments.');
   end

   for k = 1:2:length(varargin)
      param = lower(varargin{k});
      if ~ischar(param)
         error('Parameter name must be a string');
      end
      idx = strmatch(param, paramStrings);
      if isempty(idx)
         error(sprintf('Unrecognized parameter name "%s"', param));
      elseif (length(idx) > 1)
         error(sprintf('Ambiguous parameter name "%s"', param));
      end

      param = deblank(paramStrings(idx,:));

      switch param

         case 'type'
            type = varargin{k+1};
            if ~ischar(type)
               error('TYPE must be a string');
            end
            if ~ismember(type, {'standard', 'rgb', 'rle'})
               error(sprintf('Invalid RAS file type: "%s".', type));
            end

         case 'alpha'
            alpha = varargin{k+1};

      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Figure out the bitdepth.
   %

   if islogical(data)
      bitdepth = 1;
   elseif ncomp == 3
      if isempty(alpha)
         bitdepth = 24;
      else
         bitdepth = 32;
      end
   else
      bitdepth = 8;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Check the classes.
   %

   if ~ismember(class(data), {'double', 'uint8', 'uint16'})
      error(sprintf('Unsupported image class "%s"', class(data)));
   end
   if ~strcmp(class(map), 'double')
      error(sprintf('Unsupported colormap class "%s"', class(data)));
   end
   if ~ismember(class(alpha), {'double', 'uint8', 'uint16'})
      error(sprintf('Unsupported image class "%s"', class(data)));
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Bitmap RAS file.
   %

   if islogical(data)

      % First do some checking.
      if ~isempty(map)
         error('Colormap not supported with RAS bitmap files.');
      elseif ~isempty(alpha)
         error('Alpha channel not supported with RAS bitmap files.');
      elseif ncomp ~= 1
         error('Bitmap image matrix can not be 3-D with RAS files.');
      end

      % Bitmaps have no color maps.
      maptype = 0;
      maplength = 0;

      % Add padding if necessary.
      paddedWidth = 16*ceil(width/16);
      if paddedWidth > width
         data(:,width+1:paddedWidth) = 0;
      end

      % Convert from ones and zeros to uint8 without converting to double.
      % Make sure data is uint8 and contains only zeros and ones.
      byteWidth = paddedWidth/8;
      datalength = height*byteWidth;
      bytedata = repmat(uint8(0), [height byteWidth]);
      for i = 1:8
         bytedata = bitor(bytedata, bitshift(uint8(data(:,i:8:end) == 0), 8-i));
      end
      bytedata = bytedata.';
      data = bytedata(:);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Indexed RAS file.
      %

   elseif ~isempty(map)

      % First do some checking.
      if ~isempty(alpha)
         error('Alpha channel not supported with indexed RAS files.');
      elseif ncomp ~= 1
         error('Index matrix can not be 3-D with RAS files.');
      end
      if size(map, 1) > 256
         error(['Colormaps with more than 256 colors are not supported' ...
                ' with RAS files.']);
      end

      % Clip colormap, round and convert to uint8.
      map = map(:);
      k = map > 1;
      if any(k)
         warning('Some colormap values are > 1, so clipping colormap.');
         map(k) = 1;
      end
      k = map < 0;
      if any(k)
         warning('Some colormap values are < 0, so clipping colormap.');
         map(k) = 0;
      end
      map = uint8(round(255*map));

      maptype = 1;
      maplength = length(map);

      % Check index matrix and make sure it is uint8.
      switch class(data)
         case 'double'
            if any(data(:) < 1)
               error(['Index matrix of class double must have' ...
                      ' positive values.']);
            end
            if any(data(:) > maplength)
               error('Index values too large for colormap.');
            end
            data = uint8(round(data-1));
         case 'uint8'
            % Nothing to do.
         otherwise
            %            error(sprintf(['Index matrix must be double or uint8,' ...
            %                           ' not "%s".'], class(data)));
      end

      % Add padding if necessary.
      paddedWidth = 2*ceil(width/2);
      if width < paddedWidth
         data(:,width+1:paddedWidth) = 0;
      end

      data = data.';
      data = data(:);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Grayscale (intensity) or RGB RAS file.
      %

   else

      % First do some checking.
      if (ncomp ~= 1) & (ncomp ~= 3)
         error(sprintf(['Data with %d components not supported for' ...
                        ' RAS files', ncomp]));
      end

      % Grayscale and RGB images have no color maps.
      maptype = 0;
      maplength = 0;

      % Check image array and convert to uint8.
      switch class(data)
         case 'double'
            % Clip values, round and convert to uint8.
            data = min(max(data, 0), 1);
            data = uint8(round(255*data));
         case 'uint8'
            % Nothing to do.
         case 'uint16'
            warning(sprintf(['RAS images does not allow 16 bits pr' ...
                             ' component.\nReducing to 8 bits pr component.']));
            %data = uint8(round(double(data)/257)); % 257 = (2^16-1)/(2^8-1)
            data = bitshift(data, -8);
      end

      % Check alpha channel and convert to uint8.
      if ~isempty(alpha)
         if ncomp == 1
            error(['Alpha channel not supported with grayscale RAS' ...
                   ' files.']);
         end
         if size(alpha,1) ~= size(data,1) | size(alpha,2) ~= size(data,2)
            error(['Height and width of alpha data must match that' ...
                   ' of image data.']);
         end

         % Convert to uint8.
         switch class(alpha)
            case 'double'
               % Clip values, round and convert to uint8.
               alpha = min(max(alpha, 0), 1);
               alpha = uint8(round(255*alpha));
               %alpha = alpha(:);
            case 'uint8'
               % Nothing to do.
            case 'uint16'
               warning(sprintf(['RAS images does not allow 16 bits pr' ...
                                ' component.\nReducing to 8 bits pr component.']));
               %alpha = uint8(round(double(A)/257)); % 257 = (2^16-1)/(2^8-1)
               alpha = bitshift(alpha, -8);
         end
      end

      % Default is blue-green-red color order.
      if (ncomp == 3) & ~strcmp(type, 'rgb')
         data = flipdim(data, 3);
      end

      % The alpha channel is the first channel.
      if ~isempty(alpha)
         data = cat(3, alpha, data);
      end

      byteWidth = size(data, 3)*width;
      paddedByteWidth = 2*ceil(byteWidth/2);

      data = permute(data, [3 2 1]);
      data = reshape(data, [byteWidth height]);
      if byteWidth < paddedByteWidth
         data(byteWidth+1:paddedByteWidth,:) = 0;
      end

      data = data(:);

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % RLE is only supported when bitdepth <= 8.
   %

   if strcmp(type, 'rle')
      if bitdepth <= 8
         data = raserle(data);
         datalength = length(data);
      else
         warning(sprintf(['RLE not supported with %d bit RAS files.' ...
                          ' Writing standard RAS file.'], bitdepth));
         type = 'standard';
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Figure out some other values that are needed for the image header.
   %

   datalength = length(data);           % DATA should be a vector now
   switch type
      case 'standard', typeval = 1;
      case 'rle',      typeval = 2;
      case 'rgb',      typeval = 3;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Open image file and write image header.
   %

   fid = fopen(filename, 'wb', 'ieee-be');
   if fid < 0
      error([filename ': can''t open file for writing.']);
   end

   fwrite(fid, 1504078485, 'uint32');   % magic number: hex2dec('59A66A95')
   fwrite(fid, width,      'uint32');   % width (pixels) of image
   fwrite(fid, height,     'uint32');   % height (pixels) of image
   fwrite(fid, bitdepth,   'uint32');   % depth (1, 8, 24, or 32 bits) pr pixel
   fwrite(fid, datalength, 'uint32');   % length (bytes) of image
   fwrite(fid, typeval,    'uint32');   % type of file; see PNMREADRAS for details
   fwrite(fid, maptype,    'uint32');   % type of colormap; see PNMREADRAS for details
   fwrite(fid, maplength,  'uint32');   % length (bytes) of following map

   if sscanf(version, '%g', 1) < 6
      data = double(data);
      map = double(map);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the colormap.
   %

   if ~isempty(map)
      fwrite(fid, map, 'uint8');
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image data.
   %

   fwrite(fid, data, 'uint8');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Close the file.
   %

   fclose(fid);

%%%
%%% raserle --- RLE encode RAS data.
%%%
function Xrle = raserle(X)
%RASERLE Perform RAS RLE encoding.
%   XRLE = RASERLE(X) performs RLE-compression on X and returns the RLE
%   data.

   decoded_length = length(X);

   % Initialize output vector.  Add one since a single value of 128 is
   % encoded as [ 128 0 ] (only case when encoded data is longer than
   % decoded data).
   Xrle = repmat(uint8(0), decoded_length+1, 1);

   % RAS RLE Encoding:
   %
   % verbatim:  VAL                  (if VAL not 128)
   %            128   0              (if VAL is 128)
   % rle:       128 COUNT VAL

   i = 1;         % Index into X vector.
   j = 1;         % Index into XRLE vector.

   while i <= decoded_length

      if   ( i+1 <= decoded_length ) & ( X(i) == X(i+1) ) ...
             & (   ( i+2 <= decoded_length ) & ( X(i+1) == X(i+2) ) ...
                   | ( X(i) == 128 ) )
         len = 1;
         while   ( len <= 255 ) & ( i+len <= decoded_length ) ...
                & ( X(i) == X(i+len) )
            len = len + 1;
         end
         Xrle(j)   = 128;
         Xrle(j+1) = len - 1;
         Xrle(j+2) = X(i);
         j = j + 3;
         i = i + len;
      else
         while 1
            Xrle(j) = X(i);
            i = i + 1;
            if Xrle(j) == 128
               Xrle(j+1) = 0;
               j = j + 2;
            else
               j = j + 1;
            end
            if ( i+1 > decoded_length ) | ( X(i) == X(i+1) )
               break
            end
         end
      end

   end

   Xrle = Xrle(1:j-1);
