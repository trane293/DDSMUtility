function [int, count, msg] = pnmpnmgeti(fid, n)
%PNMPNMGETI Get integers from an ASCII encoded PBM/PGM/PPM file.
%
%   [INT, COUNT, MSG] = PNMPNMGETI(FID, N) tries to read N integers from the
%   ASCII encoded PBM/PGM/PPM file with file identifier FID and returns the
%   integers in the vector INT.  COUNT is the number of values successfully
%   read.  MSG is an error message string if an error occurred, and an empty
%   matrix if an error did not occur.
%
%   If N is omitted, PNMPNMGETI reads from the current file position to the end
%   of the file.
%
%   The main difference between PNMPNMGETI(FID) and FSCANF(FID, '%d') is that
%   PNMPNMGETI ignores PBM/PGM/PPM comments (which begin at a `#' character and
%   go to the end of line).  PNMPNMGETI also ignores garbage, which is anything
%   that is neither whitespace, digit nor comment.

%   Author:      Peter J. Acklam
%   Time-stamp:  2009-07-21 14:21:53 +02:00
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % Check number of input arguments and assign default value to omitted
   % argument.
   error(nargchk(1, 2, nargin));
   if nargin < 2
      n = Inf;
   end

   % Initialize output arguments.
   int   = [];          % image data vector
   count = 0;           % number of elements read. same as length(int)
   msg   = '';          % error message string

   while 1

      % Calculate number of integers missing and try to read that many.
      ints_missing = n - count;
      [x, this_count] = fscanf(fid, '%d', ints_missing);

      % Append new data to main data vector and increment counter.
      int = [int ; x];
      count = count + this_count;

      % Return if we have got the desired number of elements.
      if count == n
         return
      end

      % Return if we have reached EOF.
      if feof(fid)
         msg = 'End of file reached too early.';
         return
      end

      % If we get here we have reached a comment or some garbage.  Garbage is
      % anything that is neither whitespace, digit nor comment.
      %
      char = fscanf(fid, '%c', 1);      % get next character
      if (char == '#')

         % Found a comment, so read the rest of the line and throw it away.
         fgetl(fid);

      else

         % We found some garbage, so give a message.
         msg = 'Garbage found where image data was expected.';

         % Read past the garbage and following whitespace (i.e., until first number
         % character or comment mark).
         %
         fscanf(fid, '%[^0-9#]');

         % Return if we have reached EOF.  This error message may overwrite any
         % error message telling about garbage, but that doesn't matter since
         % reaching EOF too early is a more serious error.
         %
         if feof(fid)
            msg = 'End of file reached too early.';
            return
         end

      end

   end
