function [X, map, alpha] = pnmreadsgi(filename)
%PNMREADSGI Read image data from a SGI file.
%
%   [X,MAP,ALPHA] = PNMREADSGI(FILENAME) reads image data from the specified
%   file.  X is a uint8 or uint16 array, MAP is always a double array and ALPHA
%   is the same class as X.
%
%   X is 2-D for grayscale images, M-by-N-by-3 for RGB and RGBA images.  X is
%   of class uint8 if the image uses 1 byte per color component and uint16 if
%   the image uses 2 bytes per color component.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   This program is based on the SGI image file format specification version
%   1.00 (http://reality.sgi.com/grafica/sgiimage.html) by Paul Haeberli
%   (paul@sgi.com).

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   info = pnmimsgiinfo(filename);

   if isempty(info)
      error('Image might be corrupted.');
   end

   X     = [];
   map   = [];
   alpha = [];

   % Open file for reading.  SGI images are big-endian.
   fid = fopen(filename, 'rb', 'ieee-be');
   if fid < 0
      error([filename ': ' msg]);
   end

   % Skip image file header.
   status = fseek(fid, info.HeaderSize, 0);
   if status < 0
      fclose(fid);
      error([filename ': can''t skip header; seek failed']);
   end

   width    = info.Width;               % x-size
   height   = info.Height;              % y-size
   channels = info.Channels;            % z-size
   bpc      = info.BytesPerComponent;

   pixels   = height * width;           % number of pixels in image
   values   = pixels * channels;        % number of values in image
   pixmin   = info.Pixmin;              % the minimum pixel value
   pixmax   = info.Pixmax;              % the maximum pixel value

   % Precision string for FREAD.
   switch bpc
      case 1, precision = 'uint8';
      case 2, precision = 'uint16';
   end

   switch info.Compression
      case 'none'               % uncompressed SGI image

         % read image data, get position, and close file
         [X, count] = fread(fid, values, ['*' precision]);
         fpos = ftell(fid);
         fclose(fid);

         % see if file contains too much data
         if info.FileSize > fpos
            warning([filename ': file contains too much data']);
         end

         % see if file contains too little data
         if count < values      % or, equivalently, info.FileSize < fpos
            warning([filename ': end of file reached while reading' ...
                     ' image data']);
            X(values) = 0;      % append black to fill image
         end

         X = reshape(X, [width height channels]);
         X = permute(X, [2 1 3]);
         X = flipdim(X, 1);

      case 'rle'                % RLE compressed SGI image

         % Initialize output matrix.
         switch bpc
            case 1, X = repmat(uint8(0),  [height width channels]);
            case 2, X = repmat(uint16(0), [height width channels]);
         end

         % Read the offset tables.  The file position indicator should be at
         % file offset info.OffsetTablesOffset before reading.
         tablen = height * channels;
         [starttab,  stcount] = fread(fid, tablen, 'uint32');
         [lengthtab, ltcount] = fread(fid, tablen, 'uint32');
         if (stcount < tablen) | (ltcount < tablen)
            fclose(fid);
            error([filename ': file ended while reading RLE offset tables.']);
         end

         % The file position indicator should now be at offset
         % info.ImageDataOffset.

         % Convert from abolute file offset to offset relative to image data.
         starttab = starttab - info.ImageDataOffset;

         % File offset and data lengths are in bytes, so adjust if the image
         % data uses two bytes per color component.
         if bpc == 2
            starttab  = starttab/2;
            lengthtab = lengthtab/2;
         end

         % Read the RLE data.
         rledata = fread(fid, ['*' precision]);
         fclose(fid);

         % See if we got as much RLE data as we need.
         [dummy, k] = max(starttab);
         needed_length  = max(starttab(k) + lengthtab(k));
         rledata_length = length(rledata);
         if rledata_length < needed_length        % not enough RLE data
            % Ideally, give no error, but decode the data we have and
            % replace missing data with black or white.
            error([filename ': file ended while reading RLE data']);
         elseif rledata_length > needed_length    % too much RLE data
            warning([filename ': file contains too much data.']);
         end

         % Decompress image.
         for channel = 1 : channels
            for row = height : -1 : 1

               % Get RLE data for this scanline.
               rleidx = height * channel - row + 1;
               rleoffset = starttab(rleidx);
               rlelength = lengthtab(rleidx);
               src = rledata(rleoffset + 1 : rleoffset + rlelength);

               % Decompress RLE data and insert into image array.
               X(row,:,channel) = rle_decompress(src, width, row, channel);

            end
         end

   end

   % do some checking of the data
   % k = X < pixmin;
   % if any(k(:))
   %    warning([filename ': PIXMIN header value is incorrect']);
   % end
   % k = X > pixmax;
   % if any(k(:))
   %    warning([filename ': PIXMIN header value is incorrect']);
   % end

   % see if there is an alpha channel present
   if size(X, 3) > 3
      alpha = X(:,:,4);             % get alpha channel
      X     = X(:,:,1:3);           % strip alpha off of X
   end

   switch info.PixelValueInterpretation

      case 'normal'

      case 'dithered'
         % This is an obsolete format, but the required processing is
         % simple, so we implement it nonetheless.
         if size(X, 3) > 1
            error([filename ': dithered images have only one channel.']);
         end

         % red is bits 7..5 (three highest)
         R = bitand(X, 224);            % binary 11100000 -> decimal 224
         R = bitor(R, bitshift(R, -3)); % 11100000 -> 11111100
         R = bitor(R, bitshift(R, -6)); % 11111100 -> 11111111

         % green is bits 4..2 (three middle)
         G = bitand(X, 28);             % binary 00011100 = decimal 28
         G = bitor(bitshift(G, 3), G);  % 00011100 -> 11111100
         G = bitor(G, bitshift(G, -6)); % 11111100 -> 11111111

         % blue is bits 1..0 (two lowest)
         B = bitand(X, 3);             % binary 00000011 = decimal 3
         B = bitor(bitshift(B, 2), B); % 00000011 -> 00001111
         B = bitor(bitshift(B, 4), B); % 00001111 -> 11111111

         X = cat(3, R, G, B);

      case 'indexed'
         % This is an obsolete format.  Indexed SGI images have no
         % colormap, but require an external colormap to be displayed.

      case 'colormap'
         % The image is a color map from an SGI machine and is not
         % displayable in the ordinary sense.

   end


function dest = rle_decompress(src, width, row, channel)
%RLE_DECOMPRESS Decompress RLE (run-length encoded) data.
%
%   DEST = RLE_DECOMPRESS(SRC, WIDTH, ROW, CHANNEL) decompresses the RLE
%   data in the vector SRC into an uncompressed vector DEST with length
%   WIDTH. ROW and CHANNEL are only used for the warning messages.
%
%   The code is currently only partially vectorized.

   srcleft  = length(src);              % number of elements left in source
   srcptr   = 1;                        % index into source array
   dest     = zeros(1, width);          % vector for uncompressed data
   destleft = width;                    % number of elements left in dest
   destptr  = 1;                        % index into destination vector

   while srcleft

      % Get next element from source array and extract count value.
      el      = bitand(src(srcptr), 255);
      srcptr  = srcptr + 1;
      srcleft = srcleft - 1;
      count   = double(bitand(el, 127));

      % Scanline is done when COUNT is zero.
      if count == 0
         return
      end

      % Are we are expected to copy more elements than there is room for in
      % the destination array?
      if destleft < count
         count = destleft;
         warning(sprintf(['Too much input data: got %d, need only %d' ...
            ' (row %d, channel %d).'], count, destleft, row, channel));
      end

      destleft = destleft - count;
      if bitand(el, 128)                % is rem(floor(el/128), 2) faster?

         % Copy the next COUNT elements of SRC into DEST.
         if srcleft < count
            count = srcleft;
            warning(sprintf(['Not enough data for literal run:' ...
               ' data left %d, need %d (row %d, channel %d)'], ...
               srcleft, count, row, channel));
         end

         dest(destptr:destptr+count-1) = src(srcptr:srcptr+count-1);
         srcptr  = srcptr  + count;
         srcleft = srcleft - count;

      else

         % Copy the next element of SRC COUNT times into DEST.
         if srcleft == 0
            warning(sprintf(['Not enough data for replicate run' ...
               ' (row %d, channel %d)'], row, channel));
            next_el = 0;
         else
            next_el = src(srcptr);
         end
         dest(destptr:destptr+count-1) = next_el(ones(1,count));
         srcptr  = srcptr  + 1;
         srcleft = srcleft - 1;

      end
      destptr = destptr + count;

   end

   warning(sprintf('No terminating 0-byte (row %d, channel %d)', ...
                   row, channel));
