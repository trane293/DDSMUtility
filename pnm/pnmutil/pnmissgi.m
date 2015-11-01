function tf = pnmissgi(filename)
%PNMISSGI Returns true for a SGI image file.
%   TF = PNMISSGI(FILENAME)

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   fid = fopen(filename, 'rb', 'ieee-be');
   if (fid < 0)
      tf = logical(0);
   else
      sig = fread(fid, 1, 'uint16');
      fclose(fid);
      tf = isequal(sig, 474);
   end
