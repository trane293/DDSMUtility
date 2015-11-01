function [X, map, alpha] = pnmreadras(filename)
%PNMREADRAS Read image data from a RAS file.
%
%   [X,MAP,ALPHA] = PNMREADRAS(FILENAME) reads image data from the specified
%   file.  X is always a uint8 array, MAP is always a double array and ALPHA is
%   always a uint8 array.
%
%   For bitmap images, X is an M-by-N matrix and MAP and ALPHA are empty.
%   These are stored with 1 bit per pixel.
%
%   For indexed images, X is an M-by-N matrix, MAP is a K-by-3 matrix and ALPHA
%   is empty.  These are stored with 8 bits per index value, 8 bits per color
%   component and 1 or 3 color components per pixel.
%
%   For true color images, X is an M-by-N-by-3 array, and MAP and ALPHA are
%   empty.  These are stored with 8 bits per color component, 3 color
%   components per pixel.
%
%   For true color images with alpha channel, X is an M-by-N-by-3 array, MAP is
%   empty and ALPHA is an M-by-N matrix.  These are stored with 8 bits per
%   color component, 4 color components per pixel.
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

   info = pnmimrasinfo(filename);

   X     = [];
   map   = [];
   alpha = [];

   height     = info.Height;
   width      = info.Width;
   maplength  = info.MapLength;         % length of colormap data chunk
   datalength = info.Length;            % length of image data chunk

   headersize = 8*4;                    % header is 8 uint32 values

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % From /usr/include/rasterfile.h
   %
   % Sun supported ras_type's (the info.Type field)
   RT_OLD          = 0;         % raw pixrect image in 68000 byte order
   RT_STANDARD     = 1;         % raw pixrect image in 68000 byte order
   RT_BYTE_ENCODED = 2;         % run-length compression of bytes
   RT_FORMAT_RGB   = 3;         % XRGB or RGB instead of XBGR or BGR
   RT_FORMAT_TIFF  = 4;         % tiff <-> standard rasterfile
   RT_FORMAT_IFF   = 5;         % iff (TAAC format) <-> standard rasterfile
   RT_EXPERIMENTAL = 65535;     % reserved for testing
                                %
                                % Sun registered ras_maptype's (the info.MapType field)
   RMT_RAW         = 2;
   % Sun supported ras_maptype's (the info.MapType field)
   RMT_NONE        = 0;         % ras_maplength is expected to be 0
   RMT_EQUAL_RGB   = 1;         % red[ras_maplength/3],green[],blue[]

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Try to open the file for reading.
   %
   [fid, msg] = fopen(filename, 'rb', 'ieee-be');
   if fid < 0
      error([filename ': ' msg]);
   end

   % Seek past the file header.
   fseek(fid, headersize, 'bof');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % If there is a color map, read it.
   %
   if maplength

      % Read the colormap.
      [map, count] = fread(fid, maplength, 'uint8');
      if count < maplength
         fclose(fid);
         error([filename ': file ended while reading color map.']);
      end

      % Convert the color map to MATLAB type color map.
      switch info.MapType
         case RMT_NONE
            warning([filename ': maplength should be 0 when maptype is 0.']);
         case RMT_EQUAL_RGB
            map = reshape(map, [maplength/3 3])/255;
         case RMT_RAW
            % not sure if this is correct...
            map = map(:,[1 1 1])/255;
         otherwise
            error([filename ': invalid RAS maptype.']);
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % RAS files are stored so that each scanline uses a multiple of
   % 2 bytes.
   %
   % paddedWidth     - width of image including padding
   % paddedByteWidth - number of bytes required to store one scanline
   % numBytes        - number of bytes required to store all scanlines
   %
   switch info.BitDepth
      case 1
         paddedWidth = 16*ceil(width/16);
         numBytes = paddedWidth * height / 8;
      case 8
         paddedWidth = 2*ceil(width/2);
         numBytes = paddedWidth * height;
      case 24
         byteWidth = 3*width;
         paddedByteWidth = 2*ceil(byteWidth/2);
         numBytes = paddedByteWidth * height;
      case 32
         byteWidth = 4*width;
         numBytes = paddedByteWidth * height;
      otherwise
         error(sprintf('%s: invalid bitdepth: %d.\n', ...
                       filename, info.BitDepth));
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % In RT_OLD, which is uncompressed, the length field is often
   % (always?) zero, so we need to compute it.
   %
   if datalength == 0
      datalength = numBytes;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % This is just to see if we are dealing with a corrupt image.  When the
   % image is not run-length encoded, the Length header field should match
   % the number of bytes required to store the uncompressed data.
   %
   if info.Type ~= RT_BYTE_ENCODED & datalength ~= numBytes
      numBytes = datalength;    % computed value is more reliable
      warning([filename ': data length value is not as expected.' ...
               ' Possibly corrupt image.']);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Read the image data.
   %
   [X, count] = fread(fid, datalength, '*uint8');
   if count < datalength
      warning([filename ': file ended while reading image data.']);
      % Fill in the missing values with zeros.
      X(datalength) = 0;
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % We have got the data we need, so close the file.
   %
   fclose(fid);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % See if there is more image data than there ought to be.
   %
   fname = dir(filename);
   fsize = fname.('bytes');
   if fsize > headersize + maplength + datalength
      warning([filename ': too much image data. Possibly corrupt image.']);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Process (decode) image data if necessary.
   %
   switch info.Type
      case RT_OLD
         % As RT_STANDARD, but the length field is often (always?)
         % zero.
      case RT_STANDARD
         % This is the standard uncompressed RAS image format.  It
         % uses blue-green-red or alpha-blue-green-red color order.
      case RT_BYTE_ENCODED
         % As RT_STANDARD, but the image data is RLE compressed, so
         % perform RLE decoding.
         X = rasdrle(X, numBytes);
      case RT_FORMAT_RGB
         % As RT_STANDARD, but it uses blue-green-red or
         % alpha-blue-green-red color order.
      case RT_FORMAT_TIFF
         error([filename ': tiff RAS type is not supported.']);
      case RT_FORMAT_IFF
         error([filename ': iff RAS type is not supported.']);
      case RT_EXPERIMENTAL
         error([filename ': experimental RAS type is not supported.']);
      otherwise
         error([filename ': invalid RAS type.']);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Pixels are stored left to right, top to bottom.
   %
   switch info.BitDepth
      case 1
         XX = reshape(X, [paddedWidth/8 height]).';
         XX = bitxor(XX, 255);  % RAS: white=0, black=1, so invert.

         X = logical(repmat(uint8(0), [height paddedWidth]));
         X(:,1:8:end) = bitget(XX, 8);
         X(:,2:8:end) = bitget(XX, 7);
         X(:,3:8:end) = bitget(XX, 6);
         X(:,4:8:end) = bitget(XX, 5);
         X(:,5:8:end) = bitget(XX, 4);
         X(:,6:8:end) = bitget(XX, 3);
         X(:,7:8:end) = bitget(XX, 2);
         X(:,8:8:end) = bitget(XX, 1);

         if width < paddedWidth
            X = X(:,1:width);                   % remove padding
         end
      case 8
         X = reshape(X, [paddedWidth height]).';
         if width < paddedWidth
            X = X(:,1:width);                   % remove padding
         end
      case 24
         X = reshape(X, [paddedByteWidth height]);
         if byteWidth < paddedByteWidth
            X = X(1:byteWidth,:);               % remove padding
         end
         X = reshape(X, [3 width height]);
         X = permute(X, [3 2 1]);
         if info.Type ~= RT_FORMAT_RGB          % RGB color order
            X = flipdim(X, 3);
         end
      case 32
         X = reshape(X, [4 width height]);
         X = permute(X, [3 2 1]);
         alpha = X(:,:,1);                      % get alpha channel
         X = X(:,:,2:4);                        % strip alpha off of X
         if info.Type ~= RT_FORMAT_RGB          % RGB color order
            X = flipdim(X, 3);
         end
         if nargout ~= 3
            % Composite the image if the alpha channel is not requested
            cl = class(X); X = double(X);
            X(:,:,1) = X(:,:,1) .* (double(alpha)./255);
            X(:,:,2) = X(:,:,2) .* (double(alpha)./255);
            X(:,:,3) = X(:,:,3) .* (double(alpha)./255);
            X = feval(cl,X);
         end

      otherwise
         error(sprintf('invalid bitdepth: %d\n', info.BitDepth));
   end


%%%
%%% rasdrle --- Decode RLE data.
%%%
function X = rasdrle(Xrle, decoded_length)
%RASDRLE Decompress RLE-compressed data from a RAS file.
%   X = RASDRLE(XRLE, DECODED_LENGTH) decodes the RLE-compressed byte-stream
%   from a RAS file.  XRLE is a uint8 vector.  DECODED_LENGTH is the length
%   of the decoded (output) vector.  X is a uint8 vector containing the
%   decompressed image data.

   encoded_length = length(Xrle);

   % Initialize output vector.
   X = repmat(uint8(0), [decoded_length 1]);

   % DIST is a vector where DIST(I) tells the distance from XRLE(I) to the
   % nearest following element in XRLE whose value is 128.  If there are no
   % elements in XRLE(I:END) that have the value 128, DIST(I) is
   % LENGTH(XRLE(I:END)), the distance to the end of XRLE.

   i = find(Xrle == 128);
   dist = repmat(-1, [encoded_length 1]);
   if i(end) == encoded_length
      dist([1 ; i(1:end-1)+1]) = diff([0 ; i])-1;
   else
      dist([1 ; i+1]) = diff([0 ; i ; encoded_length+1])-1;
   end
   dist = cumsum(dist);

   i = 1;         % Index into XRLE vector.
   j = 1;         % Index into X vector.

   while i <= encoded_length
      d = dist(i);
      if d
         % Literate run of length D.
         X(j:j+d-1) = Xrle(i:i+d-1);
         j = j+d;
         i = i+d;
      else
         if Xrle(i+1)
            % The next COUNT elements all have the value XRLE(I+2).
            count = double(Xrle(i+1)) + 1;
            X(j:j+count-1) = Xrle(i+2);
            j = j+count;
            i = i+3;
         else
            % A single value of 128.
            X(j) = 128;
            j = j+1;
            i = i+2;
         end
      end
   end
