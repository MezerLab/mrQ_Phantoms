function  [mrQ_struc]= mrQ_initSPGR_phantom(mrQ_struc)
%this function initiate the SPGR data

   Inpath=mrQ_struc.spgr.inputDir;
   

  s=dicomLoadAllSeries(Inpath);
   xform=s(1).imToScanXform;
 flipAngles = [s(:).flipAngle];
 tr  = [s(:).TR];
   % Check that all TRs are the same.
    if ~all(tr == tr(1))
        error('TR''s do not match!');
    end
    tr = tr(1);
  B1 = ones(size(s(1).imData));
  
 saveName= fullfile(Inpath, 'SPGR_Dat');

  save(saveName,'s','tr','flipAngles','B1','xform')

  for ii=1:length(flipAngles)
      angle=s(ii).flipAngle; angle=int2str(angle);
      saveName_nii=fullfile(Inpath, angle)
      
  dtiWriteNiftiWrapper(s(ii).imData,xform, saveName_nii );
  end
  
 mrQ_struc.spgr.done='done';
 
    save(mrQ_struc.name,'mrQ_struc') 

end