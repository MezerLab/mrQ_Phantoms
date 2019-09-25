function   correct_dicomdata(path_dicomDat,path_nifty,scan_type)
%%this function correct the s.imData, which dicomLoadallserieas costructed
%for GE using the correct organized data from the nifti( with the siemens)
%note that the nifty files should be named ( 1 2 3 etc... according to the
%order of the flip angles in s)
%path_nifti is a path to a dir with all the niftis
%scan_type-'SPGR' or 'SEIR'

load(path_dicomDat);%% loading B1,flip angles,s,tr,xform

nif= dir((path_nifti));


switch scan_type
    case 'SPGR'
[l c]=size(nif);

count=1;
for i=1:l
    num=num2str(count);
   nam=strcat(num,'.nii.gz');
   eq=strcmp(nif(i).name,nam);
    if eq==1
       
      d=readFileNifti(strcat( path_nifty,'/',nif(i).name));
        s(count).imData=d.data;
        s(count).imToScanXform=d.qto_xyz;
        s(count).imData=permute(s(count).imData,[ 3  1 2]);
        

        %if you want to look the data in
% another perspective, might need to change the xform?!
        count=count+1;
        
        
    end
    
end

% s(count).imData=permute(s.imData,[ 3  1 2]);if you want to look the data in
% another perspective, might need to change the xform?!


saveName= fullfile(path_dicomDat);
save(saveName,'s','tr','flipAngles','B1','xform')

    
 case  'SEIR'
    [l c]=size(nif);

count=1;
for i=1:l
    [ a b c] =size ( data (:,:,:,1))
   
    num=num2str(count);
   nam=strcat(num,'.nii.gz');
   eq=strcmp(nif(i).name,nam);
    if eq==1
       
      d=readFileNifti(strcat( path_nifty,'/',nif(i).name));
      da(:,:,1:c,count)=double(d.data);
       da(:,:,:,count)=permute( da(:,:,:,count),[ 2  1 3 ]);


 
        count=count+1;
        
        
    end

end
           %if you want to look the data in
% another perspective, might need to change the xform?!
clear data

data=da;

   %  xform=d.qto_xyz;
     
saveName= fullfile(path_dicomDat);
     save(saveName,'data','extra','xform')

end