function   correct_data_readdicom(dicomDir,scan_type)



if (isunix)
    d = explode(':',genpath(dicomDir));
else
    d = explode(';',genpath(dicomDir));
end
 
 
d = d(2:end-1);
for ii=1:length(d)
    
   d2 = dir(fullfile(d{ii},'*'));
   n=0;
   for (jj = 1:length(d2))
	 if (~d2(jj).isdir)
	  n = n+1;
	  dicomFiles{n} = fullfile(d{ii},d2(jj).name);
     end
   end


    for (imNum = 1:length(dicomFiles))
  
	info = dicominfo(dicomFiles{imNum});
    dic_data=dicomread(dicomFiles{imNum});
      s_loc(imNum)= info.SliceLocation;
      s_insnum(imNum)=info.InstanceNumber;
    img_dat(:,:,imNum,ii)=dic_data;
      
    end  
 [sort_loc,ind]=sort( s_loc);

         for j=1:length(ind)
          index= ind(j);
          img_order(:,:,index,ii)= img_dat(:,:,j,ii);
     
         end
         
         
    
end  


% sort the series properly
[junk,ind] = sort([s(:).seriesNum]);
s = s(ind);

% Sort the slices based on sliceNum and break timeseries up into separate
% volumes (good for fMRI and DTI acquisitions).


switch scan_type
    case 'SPGR'
       for ii=1:r
           
           if dic_files(ii).isdir==1
               n=dic_files(ii).name;
            nam=strcat(path_dicom,'/',n)
             files_dir=dir(nam);
           
    
           
           end
           
       end  
        
        
        
        
name=strcat(path_dicom,'/SPGR_Dat.mat');
load(name);%% loading B1,flip angles,s,tr,xform

[l c]=size(nif);

count=1;
for i=1:l
  

    
end

% s(count).imData=permute(s.imData,[ 3  1 2]);if you want to look the data in
% another perspective, might need to change the xform?!

saveName= fullfile(path_dicomDat);
save(saveName,'s','tr','flipAngles','B1','xform')

    
 case  'SEIR'
     
     name=strcat(path_dicom,'/SEIR_Dat.mat')
load(name);%% loading B1,flip angles,s,tr,xform

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