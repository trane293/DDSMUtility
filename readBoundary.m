%% ==================================================================%
%             OPEN OVERLAY FILES AND VIEW MASS BOUNDARIES 
%                        ----(MAIN FILE)----
% ==================================================================%
%           Author - Dr. Jayasree Charaborty
%      Affiliation - Research Fellow, Memorial Sloan Kettering Cancer Center
%      Description - The code simply takes the name of OVERLAY file as input 
%                    and a paramter obj = 1, to open, and read the OVERLAY
%                    file and then parse it for the boundary information,
%                    returned by the names bnd_c and bnd_r. If there are
%                    more than one boundaries present, this script takes
%                    the inner one. 
%          License - Copyright (C) 2015  Jayasree Chakraborty
%
%                    This program is free software: you can redistribute it
%                    and/or modify it under the terms of the GNU General 
%                    Public License as published by the Free Software 
%                    Foundation, either version 3 of the License, or (at
%                    your option) any later version.
% 
%                    This program is distributed in the hope that it will 
%                    be useful, but WITHOUT ANY WARRANTY; without even the 
%                    implied warranty of MERCHANTABILITY or FITNESS FOR A 
%                    PARTICULAR PURPOSE.  See the GNU General Public License
%                    for more details.
% 
%                    You should have received a copy of the GNU General 
%                    Public License along with this program.  If not, 
%                    see <http://www.gnu.org/licenses/>. 
%===================================================================%
%%
function [bnd_c,bnd_r]=readBoundary(overlay_name,obj)
fid= fopen(overlay_name);
FileData=textscan(fid, '%s');
strt_loc= find(strcmp('BOUNDARY', FileData{1,1}(:))==1);
if obj<length(strt_loc)
   EF = strcmp('#', FileData{1,1}(strt_loc(obj):strt_loc(obj+1)));
else
   EF = strcmp('#', FileData{1,1}(:));
   EndLoc=find(EF==1);
   clear  EF
   EF = strcmp('#', FileData{1,1}(strt_loc(obj):EndLoc(length(EndLoc))));
   clear EndLoc
end
string=strt_loc(obj);
EndLoc=find(EF==1)+string-1;
if length(EndLoc)>1  % more than one boundary present, taking the inner one
    if obj<length(strt_loc)
        TF = strcmp('CORE', FileData{1,1}(strt_loc(obj):strt_loc(obj+1))) ;
    else
        EF = strcmp('#', FileData{1,1}(:));
        EndLoc=find(EF==1);
        clear  EF
        TF = strcmp('CORE', FileData{1,1}(strt_loc(obj):EndLoc(length(EndLoc)))) ;
    end
        Loc= find(TF==1)+strt_loc(obj)-1;
        str_pt=Loc(length(Loc))+1; end_pt=EndLoc(length(EndLoc))-1;
        BoundaryPoint(1:end_pt-str_pt+1)=str2double(FileData{1,1}(str_pt:end_pt));
else
   Loc= strt_loc(obj);
   BoundaryPoint(1:EndLoc(1)-Loc-1)=str2double(FileData{1,1}(Loc+1:EndLoc(1)-1));
end
bnd_c(1)=round(BoundaryPoint(1));bnd_r(1)=round(BoundaryPoint(2));
for i=3:length(BoundaryPoint)
    code_val=BoundaryPoint(i);
    switch code_val
        case 0
           bnd_c(i-1) =bnd_c(i-2);bnd_r(i-1) =bnd_r(i-2)-1;
        case 1
           bnd_c(i-1) =bnd_c(i-2)+1;bnd_r(i-1) =bnd_r(i-2)-1;
        case 2
           bnd_c(i-1) =bnd_c(i-2)+1;bnd_r(i-1) =bnd_r(i-2);
        case 3
           bnd_c(i-1) =bnd_c(i-2)+1;bnd_r(i-1) =bnd_r(i-2)+1;
        case 4
           bnd_c(i-1) =bnd_c(i-2);bnd_r(i-1) =bnd_r(i-2)+1;
        case 5
           bnd_c(i-1) =bnd_c(i-2)-1;bnd_r(i-1) =bnd_r(i-2)+1;
        case 6
           bnd_c(i-1) =bnd_c(i-2)-1;bnd_r(i-1) =bnd_r(i-2);
        otherwise
           bnd_c(i-1) =bnd_c(i-2)-1;bnd_r(i-1) =bnd_r(i-2)-1;
    end
end
fclose(fid);