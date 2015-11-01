function pnmwritexbm(data, map, filename, varargin)
%PNMWRITEXBM Write a XBM (X bitmap) file to disk.
%
%   PNMWRITEXBM(BM, [], FILENAME) writes the bitmap image BM to the file
%   specified by the string FILENAME.
%
%   PNMWRITEXBM(I, [], FILENAME) converts the grayscale image I into a bitmap
%   (by thresholding) and writes the resulting image to the file specified by
%   the string FILENAME.
%
%   PNMWRITEXBM(RGB, [], FILENAME) converts the truecolor image represented by
%   the M-by-N-by-3 array RGB into a bitmap (by grayscaling and thresholding)
%   and writes the resulting image to the file specified by the string
%   FILENAME.
%
%   PNMWRITEXBM(X, MAP, FILENAME) converts the indexed image represented by the
%   index matrix X and colormap MAP into a bitmap (by grayscaling and by
%   thresholding) and writes the resulting image to the file specified by the
%   string FILENAME.
%
%   PNMWRITEXBM(...,'XHotSpot',VAL) sets the XHotSpot value to VAL.  VAL must
%   be a non-negative integer.
%
%   PNMWRITEXBM(...,'YHotSpot',VAL) sets the YHotSpot value to VAL.  VAL must
%   be a non-negative integer.
%
%   See also IMREAD, IMWRITE, IMFINFO.

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
      error(sprintf('%d-D data not supported for XBM files', nd));
   end

   if ~ischar(filename) | isempty(filename)
      error('Filename must be a non-empty string.');
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Process param/value pairs
   %

   xhotspot = [];
   yhotspot = [];

   paramStrings = ['xhotspot'
                   'yhotspot'];

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
         case 'xhotspot'
            xhotspot = varargin{k+1};
            if ~isscalnonnegint(xhotspot)
               error('XHOTSPOT must be a scalar positive integer.');
            end
         case 'yhotspot'
            yhotspot = varargin{k+1};
            if ~isscalnonnegint(yhotspot)
               error('YHOTSPOT must be a scalar positive integer.');
            end
      end
   end

   [height, width, channels] = size(data);
   cls = class(data);

   rgbw = [ 0.298936 ; 0.587043 ; 0.114021 ];   % RGB weights

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert any image to a bitmap image.  Afterwards, `data' should be a
   % uint8 array of zeros (black) and ones (white).
   %

   if isempty(map)
      % no colormap, so it is not an indexed image

      if channels > 1
         % it is an rgb image

         % adjust rgb weights (to save work we convert from rgb image to
         % grayscale _and_ map pixel values to the set {0,1} all in one go)
         switch class(data)
            case 'uint8',  rgbw = rgbw / 255;
            case 'uint16', rgbw = rgbw / 65535;
            case 'double', % do nothing
         end

         % convert to uint8 array of zeros and ones
         data = uint8(round(   rgbw(1) * double(data(:,:,1)) ...
                             + rgbw(2) * double(data(:,:,2)) ...
                             + rgbw(3) * double(data(:,:,3)) ));

      else
         % it is a grayscale image or a bitmap image

         if islogical(data)
            % it is a bitmap image

            % convert to zeros and ones; let all non-zero values be one
            data(data) = 1;

         else
            % it is a grayscale image

            % convert to zeros and ones by bitshifting or thresholding
            switch class(data)
               case 'uint8',  data = bitshift(data, -7);
               case 'uint16', data = uint8(bitshift(data, -15));
               case 'double', data = uint8(data >= 0.5);
            end

         end
      end
   else
      % it is an indexed image

      % convert colormap to a vector of ones and zeros by thresholding
      bwmap = uint8(map * rgbw >= 0.5);

      % get image data
      switch class(data)
         case 'double',            data = bwmap(data);
         case {'uint8', 'uint16'}, data = bwmap(double(data)+1);
         otherwise, error('Index array is of invalid class.');
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert the bitmap image into a vector containing the integer values
   % that will be written to the image file.
   %

   % adjust values since XBM uses zeros for white and ones for black
   data = bitxor(data, 1);

   % add padding if necessary
   byteWidth = ceil(width/8);           % number or bytes for one scanline
   paddedWidth = 8*byteWidth;           % padded width of image
   if paddedWidth > width
      data(:,width+1:paddedWidth) = 0;
   end

   % convert from bits (zeros and ones) to bytes {0,1,...,255} without
   % temporary conversion to double
   bytedata = repmat(uint8(0), [height byteWidth]);
   for i = 1:8
      bytedata = bitor(bytedata, bitshift(uint8(data(:,i:8:end)), i-1));
   end

   % Open output file for writing.
   fid = fopen(filename, 'wt');
   if fid < 0
      error([filename ': can''t open file for writing.']);
   end

   % Get file basename and trim it so it is suitable as an identifier.
   k = find(filename == '.');
   if isempty(k)
      filebase = filename;
   else
      filebase = filename(1:k(end)-1);
   end
   k =   (filebase < 'a' | filebase > 'z') ...
       & (filebase < 'A' | filebase > 'Z') ...
       & (filebase < '0' | filebase > '9');
   filebase(k) = '_';

   % Write file header.
   fprintf(fid, '#define %s_width %d\n', filebase, width);
   fprintf(fid, '#define %s_height %d\n', filebase, height);
   if ~isempty(xhotspot)
      fprintf(fid, '#define %s_x_hot %d\n', filebase, xhotspot);
   end
   if ~isempty(yhotspot)
      fprintf(fid, '#define %s_y_hot %d\n', filebase, yhotspot);
   end

   % Write image data.  Some XBM software writes images with a header saying
   % "static unsigned char ...", but some software failes to read the image
   % if the word "unsigned" is present, so just write "static char ...".
   bytedata = bytedata.';
   fprintf(fid, 'static char %s_bits[] = {\n', filebase);
   format = [repmat(' 0x%02x,', [1 12]) '\n'];
   fprintf(fid, format, double(bytedata(1:end-1)));
   fprintf(fid, '%02x};\n', double(bytedata(end)));

   % Close file.
   fclose(fid);


function tf = isscalnonnegint(x)
%ISSCALNONNEGINT True if input is a scalar non-negative integer.

   tf = all(size(x) == 1) & isnumeric(x);       % scalar and numeric
   if ~tf, return, end

   x = double(x);
   tf = x == round(x) & x >= 0;                 % integer and positive
