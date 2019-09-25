function [mrQ_struc]=mrQ_segmentation(mrQ_struc)
%% this function does all the nessecary preperation with the segmentation-mask files. 
%Note it is needed to segement the Agar mask to a label value of 1.

%load the data via mrQ initiate-SEIR.mat or from the epi parameters and save t1.mat

 if  strcmp( mrQ_struc.spgr.seg.seir_fit ,  'seir')
    load(fullfile( mrQ_struc.seir.inputDir,'SEIR_Dat.mat'))
     num =mrQ_struc.seir.quick_3param.change_Invertion;

    switch mrQ_struc.spgr.seg.seir_fit_type
        
        case 'quick_3param'
              load(fullfile(mrQ_struc.seir.quick_3param.outputDir,'T1FitNLSPR_SEIR_Dat.mat'))
               t1map=ll_T1(:,:,:,1);
               if num>0
              load(fullfile(mrQ_struc.seir.quick_3param.outputDir,'T1FitNLSPR_SEIR_Dat_Multi_Maps.mat'))
              t1map=T1_InveMaps(:,:,:,1,num);
               end
                   
        case 'long_3param'
              load(fullfile(mrQ_struc.seir.long_3param.outputDir,'Sim3ParT1fit.mat'))
               t1map=Output3(:,:,:,3);

        case 'long_2param'
              load(fullfile(mrQ_struc.seir.long_2param.outputDir,'Sim2ParT1fit.mat'))
              t1map=Output(:,:,:,2);

    end   
else
   load(fullfile(mrQ_struc.epi.inputDir,'SEIR_Dat.mat'))

    switch mrQ_struc.spgr.seg.seir_fit_type
        
        case 'quick_3param'
              load(fullfile(mrQ_struc.epi.quick_3param.outputDir,'T1FitNLSPR_SEIR_Dat.mat'))
              t1map=ll_T1(:,:,:,1);
               if num>0
              load(fullfile(mrQ_struc.epi.quick_3param.outputDir,'T1FitNLSPR_SEIR_Dat_Multi_Maps.mat'))
              t1map=T1_InveMaps(:,:,:,1,num);
               end
        case 'long_3param'
              load(fullfile(mrQ_struc.epi.long_3param.outputDir,'Sim3ParT1fit.mat')) %other method that was used for the calculation of GS-T1 map
              t1map=Output3(:,:,:,3);
        case 'long_2param'
              load(fullfile(mrQ_struc.epi.long_2param.outputDir,'Sim2ParT1fit.mat'))%other method that was used for the calculation of GS-T1 map
              t1map=Output(:,:,:,2);
    end   
    
    
end
%outseg=  fullfile( mrQ_struc.spgr.seg.output,'EPIRaw.nii.gz');
%dtiWriteNiftiWrapper(single(ll_T1(:,:,:,1)),xform,outseg);
clear xform

%t1spgr=fullfile(mrQ_struc.spgr.seg.output,'T1_FL3D_FA')
load(fullfile(mrQ_struc.spgr.inputDir,'SPGR_Dat'));

%dtiWriteNiftiWrapper(single(s(1).imData),s(1).imToScanXform,t1spgr);

%seg_spgr_agar='T1_FL3D_FA_seg_agar.nii.gz'
%dtiWriteNiftiWrapper(single(sim),xf,name);??

% Segmanet

% claculate 
Mask=readFileNifti(mrQ_struc.spgr.seg.seg_seirfile);
% 
% Maskcoco=niftiRead('name')
% Maskspgrcoco=niftiRead('name')

Mask=double(Mask.data);

%t1map=niftiRead(outseg)

%t1map=double(t1map.data);

T1_agar=median(t1map(find(Mask==1)));

name_agar=fullfile(mrQ_struc.spgr.seg.output,'T1_agar');
save(name_agar,'T1_agar');

if mrQ_struc.spgr.seg.groups>1
    sp=readFileNifti(strcat(mrQ_struc.spgr.relaxfit.output,'/t1_L.nii.gz'));
    sp=sp.data;
    groups=mrQ_struc.spgr.seg.groups;
    Masktubes=readFileNifti(mrQ_struc.spgr.seg.seg_tubesfile);
    Masktubes=double(Masktubes.data);
    for ii=1:groups
 T1_group(ii)=median(sp(find(Masktubes==ii)));
    end
name_tubes=fullfile(mrQ_struc.spgr.seg.output,'T1_tubes');

    save(name_tubes,'T1_group')
end
SegMaskFile= mrQ_struc.spgr.seg.seg_spgrfile;



Agarmask=niftiRead(SegMaskFile);
%%i
SPGR_AGAR_SEIRT1mask=(Agarmask.data==1).*T1_agar;

if mrQ_struc.spgr.mess=='y'
   
   SPGR_AGAR_SEIRT1mask= permute(SPGR_AGAR_SEIRT1mask,[ 3  1 2]);
      
    
end
    
    

 SPGR_agar_seirmaskT1=fullfile(mrQ_struc.spgr.seg.output,'SPGR_agar_seirmaskT1.nii.gz');
dtiWriteNiftiWrapper(single(SPGR_AGAR_SEIRT1mask),Agarmask.qto_xyz, SPGR_agar_seirmaskT1);
 mrQ_struc.spgr.seg.done='done'; 
  save( mrQ_struc.name,'mrQ_struc') 


end 