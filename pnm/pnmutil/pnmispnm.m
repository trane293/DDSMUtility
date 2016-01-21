function tf = pnmispnm(filename)
%PNMISPNM Returns true for a PNM file (PBM, PGM, or PPM).
%   TF = PNMISPNM(FILENAME)

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
      tf = isequal(sig, [80; 49]) | ...   % 'P1' ASCII PBM file
           isequal(sig, [80; 52]) | ...   % 'P4' binary PBM file
           isequal(sig, [80; 50]) | ...   % 'P2' ASCII PGM file
           isequal(sig, [80; 53]) | ...   % 'P5' binary PGM file
           isequal(sig, [80; 51]) | ...   % 'P3' ASCII PPM file
           isequal(sig, [80; 54]);        % 'P6' binary PPM file
   end
