function tf = pnmisxbm(filename)
%PNMISXBM Returns true for a XBM file.
%   TF = PNMISXBM(FILENAME)

%   XBM images don't have a magic number.  We call it an XBM image if
%   the first two lines look something like
%
%      #define imagename_width  48
%      #define imagename_height 32
%
%   where "imagename" might be any string suitable for a name and each
%   digit might be any positive number.  The ANSI standard allows
%   whitespace between newline and "#" and between "#" and "define".

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:20:14 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   fid = fopen(filename, 'r');
   tf = logical(0);
   if (fid < 0)
      return;
   end

   spc = ' ';
   tab = sprintf('\t');

   for i = 1:2

      % zero or more whitespace characters; skip them
      while 1
         [c, n] = fscanf(fid, '%c', 1);
         if n < 0, fclose(fid); return; end;
         if ~isspace(c), break; end
      end
      fseek(fid, -1, 0);           % back up a byte

      % look for "#"
      [c, n] = fscanf(fid, '%c', 1);
      if n < 0 | ~isequal(c, '#'), fclose(fid); return; end;

      % zero or more space or tab characters; skip them
      while 1
         [c, n] = fscanf(fid, '%c', 1);
         if n < 0, fclose(fid); return; end;
         if c ~= spc & c ~= tab, break; end;
      end
      fseek(fid, -1, 0);           % back up a byte

      % look for "define"
      [c, n] = fscanf(fid, '%c', 6);
      if n < 6 | ~isequal(c, 'define'), fclose(fid); return; end;

      % one or more space or tab characters; skip them
      cnt = 0;
      while 1
         [c, n] = fscanf(fid, '%c', 1);
         if n < 0, fclose(fid); return; end;
         if c ~= spc & c ~= tab, break; end;
         cnt = cnt + 1;            % increment counter
      end
      if cnt < 1, fclose(fid); return; end;
      fseek(fid, -1, 0);           % back up a byte

      % looks promising, so read the rest of the line
      line = fgetl(fid);

      % look for identifier "imagename_width" or "imagename_height"
      [tok, cnt, msg, idx] = sscanf(line, '%s', 1);
      if   ( length(tok) < 7 | ~isequal(tok(end-5:end), '_width')  ) ...
            & ( length(tok) < 8 | ~isequal(tok(end-6:end), '_height') )
         fclose(fid);
         return;
      end
      line = line(idx:end);

      % look for corresponding value (integer)
      [tok, cnt, msg, idx] = sscanf(line, '%d', 1);
      if isempty(tok)
         fclose(fid);
         return;
      end
      line = line(idx:end);

      % the rest of the line should be empty or whitespace
      if ~isempty(line) & ~all(isspace(line))
         fclose(fid);
         return;
      end

   end

   tf = logical(1);
   fclose(fid);
