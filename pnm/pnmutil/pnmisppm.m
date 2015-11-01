function tf = pnmisppm(filename)
%PNMISPPM Returns true for a PPM file.
%   TF = PNMISPPM(FILENAME)

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   fid = fopen(filename, 'rb', 'ieee-be');
   if (fid < 0)
      tf = logical(0);
   else
      sig = fread(fid, 2, 'uint8');
      fclose(fid);
      tf = isequal(sig, [80;51]) | ...     % 'P1'
           isequal(sig, [80;54]);          % 'P4'
   end
