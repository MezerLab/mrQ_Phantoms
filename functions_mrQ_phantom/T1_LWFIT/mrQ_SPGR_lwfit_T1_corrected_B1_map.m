function mrQ_struc=mrQ_SPGR_lwfit_T1_corrected_B1_map(mrQ_struc)
%
%preperations
Inpath=mrQ_struc.spgr.inputDir;
load(fullfile(Inpath, 'SPGR_Dat'));
b1_smoothmap=fullfile(mrQ_struc.spgr.smooth.output,'B1_smooth')

  B1 =readFileNifti(b1_smoothmap);
  B1=B1.data;
outDir=mrQ_struc.spgr.lwfit.output;
savenow=mrQ_struc.spgr.lwfit.savenow;
proclass=mrQ_struc.spgr.lwfit.proclass;



if notDefined('savenow')
    savenow=0
end

  
%whos
t1file_L =fullfile(mrQ_struc.spgr.relaxfit.output,'t1_L');
M0file =fullfile(mrQ_struc.spgr.relaxfit.output,'M0_L');



%%

        
Mask=logical(B1); brainMask=Mask;
Gain=ones(size(brainMask));

GridOutputDir=fullfile(mrQ_struc.spgr.lwfit.output,'/grid');

mkdir(GridOutputDir);


 [T1_WL, T1_L,PD_WL, PD_L] = mrQ_T1M0_LWFit_phantom(s,brainMask,tr,flipAngles,Gain,B1,outDir,xform,mrQ_struc,GridOutputDir,savenow) %fittting funcion

 mrQ_struc.spgr.lwfit.done='done';
        save( mrQ_struc.name,'mrQ_struc') 

%
