cd /home/code/aviv/git/mrFat
addpath(genpath(fullfile(mrFatRootPath)));

Name='PCchol_11.1'
M0file='/Mezer-lab/analysis/HUJI/oshrat/Pc_Chol_Buffer_11_01_16/lwfit/PD_WL_last.nii.gz';
outMm=0;
outDir='/Mezer-lab/analysis/HUJI/oshrat/Pc_Chol_Buffer_11_01_16/lwfit'
Maskfile='/Mezer-lab/rawData/HUJI/oshrat/Phantoms/Chol_PC_Buffer_11.01.16/SPGR/Mag/SPGR_MASK_FLIP4_seperate_cuvettes.nii.gz'



[logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,Name,[],M0file,... 
                                         Maskfile,outMm,6);
                                     
                                     
%mrQ_fitM0boxesCall_T1PD(logname);
mrQ_fitM0boxesCall_PDPhantom(logname)

mrQ_buildPDPhantom(logname);%,[],[],mrQ.RepErrThreshold,mrQ.PrcCutOff,mrQ.ErrorThresh);

%% I also tried T1 mask. it was not helpful


%MaskT1='/Users/avivmezer/Downloads/documents-export-2016-07-07/MaskT1.nii.gz'
% T1file='/Users/avivmezer/Downloads/documents-export-2016-07-07/T1_WL_last.nii.gz'
% mask=readFileNifti(Maskfile);
% T=readFileNifti(T1file);
% M=  T.data>median(T.data(find(mask.data==1)))- std(T.data(find(mask.data==1))) & T.data<median(T.data(find(mask.data==1)))+ std(T.data(find(mask.data==1)));
% 
%         [~, ~, z]=ind2sub(size(mask.data),find(mask.data));
% z=unique(z);
% M(:,:,1:z(1)-1)=0;
% M(:,:,z(end)+1:end)=0;
% 
% dtiWriteNiftiWrapper(single(M),T.qto_xyz,MaskT1)
