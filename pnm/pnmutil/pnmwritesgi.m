function pnmwritesgi(data, map, filename, varargin)
%PNMWRITESGI Write an SGI (Silicon Graphics Image) file to disk.
%
%   PNMWRITESGI(BM, [], FILENAME) writes the bitmap image BM to the file
%   specified by the string FILENAME.
%
%   PNMWRITESGI(I, [], FILENAME) writes the grayscale image I to the file
%   specified by the string FILENAME.
%
%   PNMWRITESGI(RGB, [], FILENAME) writes the truecolor image represented by
%   the M-by-N-by-3 array RGB.
%
%   PNMWRITESGI(X, MAP, FILENAME) writes the indexed image X with colormap MAP.
%   The resulting file will contain the equivalent truecolor image.
%
%   PNMWRITESGI(...,'Compression',COMP) uses the compression type indicated by
%   the string COMP. COMP can be 'none' or 'rle'.  The default is 'none'.
%
%   PNMWRITESGI(...,'BytesPerChannel',BPC) specifies the number of bytes to use
%   per pixel component. BPC can be 1 or 2.  Default is 2 if image array is
%   'uint16' and 1 otherwise.
%
%   PNMWRITESGI(...,'ImageName',NAME) may be used to specify the image
%   name. NAME must be a zero-terminated string no more than 80 characters long
%   (image name will be truncated and/or a terminating zero will be appended if
%   necessary).  The default is 'no name'.
%
%   PNMWRITESGI(...,'Alpha',ALPHA) adds the alpha (transparency) channel to the
%   image.  ALPHA must be a 2D matrix with the same number or rows and columns
%   as the image matrix.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   This program is based on the SGI image file format specification version
%   1.00 (http://reality.sgi.com/grafica/sgiimage.html) by Paul Haeberli
%   (paul@sgi.com).

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
      error(sprintf('%d-D data not supported for SGI files', nd));
   end

   if ~ischar(filename) | isempty(filename)
      error('Filename must be a non-empty string.');
   end

   [height, width, channels] = size(data);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Set default BPC (bytes per channel) value.
   %

   bpc = 1;
   if isa(data, 'uint16')
      bpc = 2;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Process param/value pairs
   %

   compression = 0;
   imagename   = 'no name';
   alpha = [];

   paramStrings = ['compression    '
                   'bytesperchannel'
                   'imagename      '
                   'alpha          '];

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

         case 'compression'
            compression = varargin{k+1};
            if strcmp(compression, 'none')
               compression = 0;
            elseif strcmp(compression, 'rle')
               compression = 1;
            else
               error('Invalid "Compression" property value.');
            end

         case 'bytesperchannel'
            bpc = varargin{k+1};
            if ~isequal(bpc, 1) & ~isequal(bpc, 2)
               error('Invalid "BytesPerChannel" property value.');
            end

         case 'imagename'
            imagename = varargin{k+1};
            if ~ischar(imagename)
               error('Value of "ImageName" property must be a string.');
            end
            if length(imagename) > 79
               imagename = imagename(1:79);
               warning(['Value of "ImageName" property too long so' ...
                        ' truncating it.']);
            end

      end
   end

   % Precision string for FWRITE when writing image data.
   switch bpc
      case 1, prec = 'uint8';
      case 2, prec = 'uint16';
   end

   % Convert from indexed image to intensity or rgb image.
   if ~isempty(map)
      % Convert the colormap to the class of the color components.
      switch bpc
         case 1, map = uint8(round(255*map));
         case 2, map = uint16(round(65535*map));
      end
      % Compute the image array.
      switch class(data)
         case 'double'
            data = reshape(map(data,:), [height width 3]);
         case {'uint8' 'uint16'}
            data = reshape(map(double(data)+1,:), [height width 3]);
      end
      % Now there are three channels in the image.
      channels = 3;
   end

   % Convert from bitmap image to grayscale image.
   if islogical(data)
      switch class(data)
         case 'double'
            data(data) = 1;     % let all non-zero values be 1
         case 'uint8'
            data(data) = 255;   % let all non-zero values be 255
         case 'uint16'
            data(data) = 65535; % let all non-zero values be 65535
      end
      data = +data;
   end

   % Get the number of dimensions.  An SGI image with one row is 1-D.
   dimensions = 1;
   if height   > 1, dimensions = 2; end
   if channels > 1, dimensions = 3; end

   % Make sure the image array is either uint8 or uint16 (depending on bpc).
   switch bpc
      case 1
         switch class(data)
            case 'double'
               % [0,1] -> {0,...,255}
               data = uint8(round(255*data));
            case 'uint16'
               % {0,...,65535} -> {0,...,255}
               data = uint8(bitshift(data, -8));
         end
         if ~isempty(alpha)
            switch class(alpha)
               case 'double'
                  % [0,1] -> {0,...,255}
                  alpha = uint8(round(255*alpha));
               case 'uint16'
                  % {0,...,65535} -> {0,...,255}
                  alpha = uint8(bitshift(alpha, -8));
            end
         end
      case 2
         switch class(data)
            case 'double'
               % [0,1] -> {0,...,65535}
               data = uint16(round(65535*data));
            case 'uint8'
               % {0,...,255} -> {0,...,65535}
               data = uint16(data);
               data = bitor(bitshift(data, 8), data);
         end
         if ~isempty(alpha)
            switch class(alpha)
               case 'double'
                  % [0,1] -> {0,...,65535}
                  alpha = uint16(round(65535*alpha));
               case 'uint8'
                  % {0,...,255} -> {0,...,65535}
                  alpha = uint16(alpha);
                  alpha = bitor(bitshift(alpha, 8), alpha);
            end
         end
   end

   % The alpha channel is the last channel.
   if ~isempty(alpha)
      data = cat(3, data, alpha);
      channels = channels + 1;
   end

   % Open file for writing.  SGI images are big endian.
   fid = fopen(filename, 'wb', 'ieee-be');
   if fid < 0
      error([filename ': can''t open file for writing.']);
   end
   filename = fopen(fid);       % get full name if file is not in cwd

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Write the image file header and the image data.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   magic    = 474;                      % SGI image magic number
   pixmin   = min(data(:));             % minimum pixel value
   pixmax   = max(data(:));             % maximum pixel value
   colormap = 0;

   % FWRITE seems to require that the input array is double.
   pixmin = double(pixmin);
   pixmax = double(pixmax);

   % Make sure image name is 80 chars long and ends with a zero.
   imagename(80) = 0;
                                                % SGI names:
   fwrite(fid, magic,        'uint16');         % MAGIC
   fwrite(fid, compression,  'uchar' );         % STORAGE
   fwrite(fid, bpc,          'uchar' );         % BPC
   fwrite(fid, dimensions,   'uint16');         % DIMENSIONS
   fwrite(fid, width,        'uint16');         % XSIZE
   fwrite(fid, height,       'uint16');         % YSIZE
   fwrite(fid, channels,     'uint16');         % ZSIZE
   fwrite(fid, pixmin,       'uint32');         % PIXMIN
   fwrite(fid, pixmax,       'uint32');         % PIXMAX
   fwrite(fid, zeros(1,4),   'uchar' );         % DUMMY
   fwrite(fid, imagename,    'uchar' );         % IMAGENAME
   fwrite(fid, colormap,     'uint32');         % COLORMAP
   fwrite(fid, zeros(1,404), 'uchar' );         % DUMMY (fill to 512 bytes)

   % The file offset should now be 512, but just in case...
   if ftell(fid) ~= 512
      fclose(fid);
      error('Internal error: Wrong file offset after writing header.');
   end

   % Now write the image data.
   switch compression
      case 0
         write_sgi_vrb(fid, data, height, width, channels, prec, bpc);
      case 1
         write_sgi_rle(fid, data, height, width, channels, prec, bpc);
   end


function write_sgi_vrb(fid, data, height, width, channels, prec, bpc)
%WRITE_SGI_VRB Write a verbatim SGI image file.

   for channel = 1:channels
      for row = height:-1:1     % bottom scanline is written first
         fwrite(fid, double(data(row,:,channel)), prec);
      end
   end

   fclose(fid);


function write_sgi_rle(fid, data, height, width, channels, prec, bpc)
%WRITE_SGI_RLE Write an RLE SGI image file.

   % Initialize offset tables.
   tablen    = height * channels;       % number of table entries
   starttab  = zeros(1, tablen);        % table of offset values
   lengthtab = zeros(1, tablen);        % table of length values

   rledata = [];                        % RLE data for the whole image

   for channel = 1:channels
      for row = height:-1:1             % bottom scanline is written first

         % Get the index into the offset tables.
         rleidx = height * channel - row + 1;

         dest = rle_compress_scanline(data(row,:,channel), width);

         starttab(rleidx)  = length(rledata);
         lengthtab(rleidx) = length(dest);
         rledata = [rledata dest];    % append data for this scanline

      end
   end

   % Adjust offset tables of two bytes are used per pixel component.
   if bpc == 2
      starttab  = 2*starttab;
      lengthtab = 2*lengthtab;
   end

   % The image data follows the offset tables that follow the header, so
   % adjust the start table appropriately. The two offset tables are
   % written as 4 byte uints and the header is 512 bytes.
   starttab = starttab + 2*4*tablen + 512;

   %
   % Write the offset tables and image data.
   %
   count1 = fwrite(fid, starttab,  'uint32');
   count2 = fwrite(fid, lengthtab, 'uint32');
   if (count1 < tablen) | (count2 < tablen)
      fclose(fid);
      error('An error occurred while writing offset tables.');
   end

   count = fwrite(fid, double(rledata), prec);
   if count < tablen
      fclose(fid);
      error('An error occurred while writing image data.');
   end

   fclose(fid);


function dest = rle_compress_scanline(src, width)
%RLE_COMPRESS_SCANLINE RLE compress a scanline.
%
%   This function returns a vector with the RLE data for a scanline when
%   given the image data for that scanline. The length of the scanline
%   is also assumed given.

   dest = [];                   % RLE data for this scanline
   in   = 1;                    % index into source vector SRC

   while (in <= width)

      count = 1;                % length of this run
      first = in;               % index of first element in this run
      in = in + 1;              % point to next element in source

      if (in <= width) & (src(in-1) == src(in))

         % Replicate run.
         while (in <= width) & (src(in) == src(first)) & (count < 127)
            in    = in    + 1;
            count = count + 1;
         end
         el = count;            % 8th bit not set: replicate run
         val = src(first);

      else

         % Literal run.
         while   (   ( ( in > width-2 ) & ( in <= width ) ) ...
                   | (   ( in <= width-2 )                  ...
                       & (   ( src(in) ~= src(in+1) )       ...
                           | ( src(in) ~= src(in+2) ) ) ) ) ...
               & ( count < 127 )
            in    = in    + 1;
            count = count + 1;
         end
         el = bitor(count, 128);        % 8th bit set: literal run
         val = src(first:in-1);

      end

      dest = [dest el val];           % append data for this run

   end

   dest = [dest 0];           % append terminating 0-byte
