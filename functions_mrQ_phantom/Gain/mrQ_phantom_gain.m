function [mrQ_struc]=mrQ_phantom_gain(mrQ_struc)



M0file=fullfile(mrQ_struc.spgr.lwfit.output,'PD_WL_last');

AgarMaskFile=mrQ_struc.spgr.seg.seg_spgrfile;

degree=mrQ_struc.spgr.lwfit.gain_deg;

[Gain PD_cor]=GainGlobalPolyFit(M0file,AgarMaskFile,degree);
save_name=fullfile(mrQ_struc.spgr.lwfit.output,'gain');
save(save_name,'Gain');

save_name=fullfile(mrQ_struc.spgr.lwfit.output,'pd_cor')
save(save_name,'PD_cor');

% The new Gain Correction

Name= mrQ_struc.spgr.lwfit.sub;
M0file=fullfile(mrQ_struc.spgr.lwfit.output,'PD_WL_last');
Maskfile=mrQ_struc.spgr.seg.seg_spgrfile;
outDir=fullfile(mrQ_struc.spgr.lwfit.output)

outMm=0;

[logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,Name,[],M0file,Maskfile,outMm,6);
                                     
                                     
%mrQ_fitM0boxesCall_T1PD(logname);
mrQ_fitM0boxesCall_PDPhantom(logname);

mrQ_buildPDPhantom(logname);%,[],[],mrQ.RepErrThreshold,mrQ.PrcCutOff,mrQ.ErrorThresh);




end


