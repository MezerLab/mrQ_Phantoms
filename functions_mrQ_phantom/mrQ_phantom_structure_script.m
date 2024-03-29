
%%please run Step #1 first( a few min). After Step #1 is finished, please create the GS
%%and SPGR maskes with agar-gd areas labeled as =1 from the nifti files and enter their path in Step #2.
%%Then run step #2( long- depends on the resolution- can take a few hours
%%with a 1x1x1 resolution and up to days for higher resolutions if not using a cluster)
%(for more details please read the ReadMe file)

pathTop_data = 'path_date_scan_data'; %define the path to the top folder of the data. Point this to the folder 'example data'
pathTop_analysis = 'path date scan for analysis' %;please define your path for the whole folder of the analysis

 name = 'name';%  a name for the anlysis
struc_name = strcat('/mrQ_phantom_structure_', name);
mrQ_struc.name = fullfile(pathTop_data, struc_name);
 
%% Step #1 First Run
  mrQ_struc.seir.flag = 'y';
  mrQ_struc.seir.int = [];
    seir_inputDir = ('/GS');
 mrQ_struc.seir.inputDir = fullfile(pathTop_data, seir_inputDir);
 mrQ_struc.seir.mess='n';
    mrQ_struc.seir.quick_3param.flag='y';
    mrQ_struc.seir.quick_3param.complex='n';
    quick_3param_outputDir ='/GS';
    mrQ_struc.seir.quick_3param.outputDir = fullfile(pathTop_analysis, quick_3param_outputDir);
    mkdir(mrQ_struc.seir.quick_3param.outputDir)
    mrQ_struc.seir.quick_3param.change_Invertion=0;
    mrQ_struc.seir.quick_3param.done=[];
  mrQ_struc.seir.long_3param.flag='n';
  mrQ_struc.seir.long_2param.flag='n';
  
  mrQ_struc.epi.flag='n';
  
mrQ_struc.spgr.flag='y';
  spgr_inputDir = '/SPGR';
  mrQ_struc.spgr.inputDir = fullfile(pathTop_data, spgr_inputDir);
  mrQ_struc.spgr.mess='n';
  mrQ_struc.spgr.done=[];
    mrQ_struc.spgr.relaxfit.flag='y';
    relaxfit_output =  '/SPGR/Biased';
    mrQ_struc.spgr.relaxfit.output = fullfile(pathTop_analysis, relaxfit_output);
    mkdir(mrQ_struc.spgr.relaxfit.output)
    mrQ_struc.spgr.relaxfit.done=[];

    
 mrQ_struc.mt.flag='n';

  
  mrQ_struc.t2.flag='n';
  mrQ_struc.t2_star.flag='n';
  mrQ_struc.b1_siemens.flag='n';
  
     mrQ_struc.spgr.seg.flag='n';
    mrQ_struc.spgr.B1lsq.flag='n';
    mrQ_struc.spgr.smooth.flag='n';
    mrQ_struc.spgr.lwfit.flag='n';
  
  
    save(mrQ_struc.name,'mrQ_struc') 
    
    mrQ_phantom_run(mrQ_struc)  
    
 %% Step #2  Second Run 
   
   mrQ_struc.spgr.seg.flag='y';
   mrQ_struc.spgr.seg.seir_fit='seir';
   mrQ_struc.spgr.seg.seir_fit_type='quick_3param';
   seg_output = strcat('/SPGR/Seg');
   mrQ_struc.spgr.seg.output = fullfile(pathTop_analysis, seg_output);
   mkdir (mrQ_struc.spgr.seg.output)
   mrQ_struc.spgr.seg.done=[];
   seg_seirfile = strcat('/GS/GS_mask.nii.gz');%mask seir -please put the gs- mask file in the GS folder
   mrQ_struc.spgr.seg.seg_seirfile = fullfile(pathTop_data, seg_seirfile);
   seg_spgrfile = strcat('/SPGR/SPGR_mask.nii.gz');%mask spgr-please put the spgr mask file in the spgr folder
   mrQ_struc.spgr.seg.seg_spgrfile = fullfile(pathTop_data, seg_spgrfile);
   %
   mrQ_struc.spgr.seg.groups=20; %%change to how much samples you have +1 for agar
   mrQ_struc.spgr.seg.seg_tubesfile=mrQ_struc.spgr.seg.seg_spgrfile;
   
   mrQ_struc.spgr.B1lsq.flag='y';
   B1lsq_output = strcat('/SPGR/B1');
   mrQ_struc.spgr.B1lsq.output = fullfile(pathTop_analysis, B1lsq_output);
   mkdir(mrQ_struc.spgr.B1lsq.output)
   mrQ_struc.spgr.B1lsq.cluster=0; %change this to 1 if you want to use your local cluster
   mrQ_struc.spgr.B1lsq.savenow=1;
   mrQ_struc.spgr.B1lsq.proclass=1;
   B1lsq = randi([100000000, 999999999]);
   B1lsq_sub = num2str(B1lsq);
   mrQ_struc.spgr.B1lsq.sub = B1lsq_sub; % random id
   mrQ_struc.spgr.B1lsq.done=[];
   mrQ_struc.spgr.smooth.flag='y';
   smooth_output = strcat('/SPGR/B1/Smooth');
   mrQ_struc.spgr.smooth.output = fullfile(pathTop_analysis, smooth_output);
   mkdir( mrQ_struc.spgr.smooth.output)
   mrQ_struc.spgr.smooth.degree=[];
   mrQ_struc.spgr.smooth.done=[];
   
   mrQ_struc.spgr.lwfit.flag='y';
   lwfit_output = strcat('/SPGR/lwfit');
   mrQ_struc.spgr.lwfit.output = fullfile(pathTop_analysis, lwfit_output);
   mkdir(mrQ_struc.spgr.lwfit.output)
   mrQ_struc.spgr.lwfit.SunGrid=0; %change this to 1 if you want to use your local cluster 
   lwfit = randi([100000000, 999999999]);
   lwfit_sub = num2str(lwfit);
   mrQ_struc.spgr.lwfit.sub = lwfit_sub; % random id
   mrQ_struc.spgr.lwfit.proclass=1;
   mrQ_struc.spgr.lwfit.savenow=1;
   mrQ_struc.spgr.lwfit.gain_deg=[];
   mrQ_struc.spgr.lwfit.done=[];


  mrQ_struc.mt.flag='n';
    save(mrQ_struc.name,'mrQ_struc') 

mrQ_phantom_run(mrQ_struc)   

