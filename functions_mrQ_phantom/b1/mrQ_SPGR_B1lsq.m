function [mrQ_struc]=mrQ_SPGR_B1lsq(mrQ_struc)
%
%

%use  this function if you want to creates b1 map using lsq
%
Inpath=mrQ_struc.spgr.inputDir;
mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1=fullfile(mrQ_struc.spgr.seg.output,'SPGR_agar_seirmaskT1.nii.gz');
useSGE=mrQ_struc.spgr.B1lsq.cluster;
outDir=mrQ_struc.spgr.B1lsq.output;
savenow=mrQ_struc.spgr.B1lsq.savenow;
proclass=mrQ_struc.spgr.B1lsq.proclass;

if notDefined('useSGE')
    useSGE=0;
end

if notDefined('savenow')
    savenow=1;
end


[~, sub]=fileparts(tempname); sub=sub(1:3);




%whos
load (fullfile(mrQ_struc.spgr.inputDir,'SPGR_Dat'));
t1file_L =fullfile(mrQ_struc.spgr.relaxfit.output,'t1_L');
M0file =fullfile(mrQ_struc.spgr.relaxfit.output,'M0_L'); 


%%
t1=niftiRead(t1file_L);
M0=niftiRead(M0file);

SPGR_seirmaskT1=niftiRead(mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1);
SPGR_seirmaskT1=double(SPGR_seirmaskT1.data);

%SPGR_seirmaskT1=permute(SPGR_seirmaskT1,[2 3 1]);%%% TO BE AS SAME AS THE DATA!!CHEACK BEFORE RUNNING..

 Res{1}.name = 'target_(GS)';
 Res{1}.im = SPGR_seirmaskT1;
  
        Res{2}.im=t1.data;
        Res{2}.name = 't1 align';
        
        for i=1:size(s,2)
            Res{i+2}.im=double(s(i).imData);
            Res{i+2}.name = ['FA' num2str(s(i).flipAngle)];
        end
        
Mask=logical(SPGR_seirmaskT1);

jumpindex=500; %%change if you want different jumps for cluster
% 
%%this is for the old b1 fit function, dowload the % if you want to fit
% if useSGE==0
%     
% [B1 resNorm PD]=mrQ_fitB1_LSQ(Res,Mask,tr,flipAngles,outDir,M0.data(Mask),xform,useSGE,savenow,sub,proclass);
% else
% job_outDir=outDir;
% 
% mrQ_fitB1_LSQ_ELSC(Res,Mask,tr,flipAngles,outDir,job_outDir,M0.data(Mask),xform,useSGE,savenow,sub,proclass,jumpindex,mrQ_struc)
% end
% 
% mrQ_struc.spgr.B1lsq.done='done';
%         save( mrQ_struc.name,'mrQ_struc') 
%         
%  
% B1epiResidfile=fullfile(outDir,['ResidB1fit_full_best.nii.gz']);
% B1_lsq=fullfileuseSGE(outDir,'B1_lsq_last.nii.gz');
% 
%         
% dtiWriteNiftiWrapper(single(B1), xform, B1_lsq);
% dtiWriteNiftiWrapper(single(resNorm), xform, B1epiResidfile);
%         


%%%fiiting using new B1 fitting algorithem 
tr=repmat(tr, size(flipAngles));

  mrQ_fit_call_b1_lrfit_phantom(Res,Mask,tr,flipAngles,outDir,M0.data(Mask),xform,useSGE,savenow,sub,proclass,jumpindex,mrQ_struc);









