function mrQ_PhantomSpoiledGE_B1Fit_cluster(Inpath, SEIRmaskT1,outDir,job_outDir,useSGE)
%
%

% ADD description
%

if notDefined('useSGE')
    useSGE=0;
end

if notDefined('savenow')
    savenow=0
end

proclass=1

[~, sub]=fileparts(tempname); sub=sub(1:3);

%This function calles a function to fit T1 for phantom's tubes in the methood of SPGR
%under the assumption B1=ones
 s=dicomLoadAllSeries(Inpath);
 xform=s(1).imToScanXform;
mmPerVox=s(1).mmPerVox;

 flipAngles = [s(:).flipAngle];
 tr  = [s(:).TR]
   % Check that all TRs are the same.
    if ~all(tr == tr(1))
        error('TR''s do not match!');
    end
    tr = tr(1)
  B1 = ones(size(s(1).imData));
  
 
[t1,M0]= relaxFitT1(double( cat(4,s(:).imData)),flipAngles,tr,B1);
%whos
t1fileHM =fullfile(outDir,'t1HM')
dtiWriteNiftiWrapper (t1,xform,t1fileHM );

%%

exist(SEIRmaskT1,'file')

SEIRmaskT1=niftiRead(SEIRmaskT1);
SEIRmaskT1=double(SEIRmaskT1.data);


 Res{1}.name = 'target_(GS)';
 Res{1}.im = SEIRmaskT1;
  
        Res{2}.im=t1
        Res{2}.name = 't1 align'
        
        for i=1:size(s,2)
            Res{i+2}.im=double(s(i).imData);
            Res{i+2}.name = ['FA' num2str(s(i).flipAngle)];
        end
        
Mask=logical(SEIRmaskT1);

jumpindex=500; %%change if you want different jumps



mrQ_fitB1_LSQ_ELSC(Res,Mask,tr,flipAngles,outDir,job_outDir,M0(Mask),xform,useSGE,savenow,sub,proclass,jumpindex);


%[B1 resNorm PD] = mrQ_fitB1_LSQ_ELSC(Res,Mask,tr,flipAngles,outDir,job_outDir,M0(Mask),xform,useSGE,savenow,sub,proclass,jumpindex);