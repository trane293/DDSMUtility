function tf = pnmispbm(filename)
%PNMISPBM Returns true for a PBM file.
%   TF = PNMISPBM(FILENAME)

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   fid = fopen(filename, 'r', 'ieee-le');
   if (fid < 0)
      tf = logical(0);
   else
      sig = fread(fid, 2, 'uint8');
      fclose(fid);
      tf = isequal(sig, [80; 49]) | ...
           isequal(sig, [80; 52]);
   end
