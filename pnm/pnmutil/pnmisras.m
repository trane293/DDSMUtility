function tf = pnmisras(filename)
%PNMISRAS Returns true for a RAS file.
%   TF = PNMISRAS(FILENAME)

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:54 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   fid = fopen(filename, 'r', 'ieee-be');
   if (fid < 0)
      tf = logical(0);
   else
      sig = fread(fid, 1, 'uint32');
      fclose(fid);
      tf = isequal(sig, 1504078485);      % 0x59a66a95
   end
