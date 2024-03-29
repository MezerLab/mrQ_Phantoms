function [logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,subName,degrees,M0file,... 
                                         Maskfile,outMm,boxSize,percent_overlap,Inclusion_Criteria,clobber)
% [logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,subName,degrees,M0file,... 
%                                          Maskfile,outMm,boxSize,percent_overlap,Inclusion_Criteria,clobber)
%
%
% This function creates a structure of information to fit the M0 boxes for
% coil gain and PD, using parallel computation via SunGrid Engine (SGE).
%
%   ~INPUTS~
%             outDir:   The output directory. 
%                           The function also reads the file from there.
%            subName:   The subject name for the SGE run.
%            degrees:   Polynomial degrees for the coil estimation.
%             M0file:   The combined/aligned M0 data.
%             Maskfile:   The defined brain mask.

%              outMm:   The resample (undersample) resolution of those 
%                           images. (Default is 2mm x 2mm x 2mm.) This can
%                           shorten the fits. The fit procedure was written
%                           to this resolution. This resolution is assumed
%                           to be high, given the low frequency change of
%                           the coils gain.
%            boxSize:   The box size that is used for the fit (in mm)
%                           Default is 14.
%    percent_overlap:   The overlap between the boxes. 
%                           (Default is 0.5 --> 50%)
%            clobber:   Overwrite existing data and reprocess. 
%                           Default is false.
% Inclusion_Criteria:   Default is [0.8 200].
%
%     ~OUTPUTS~
%            logname:   A structure that saves the fit parameters. It is 
%                           saved in the outDir, and in the tmp directory,
%                           with the name fitLog.mat. It calls to
%                           FitM0_sanGrid_v2 that saves the fitted files
%                           (output) in the tmp directory. This will be
%                           used later by mrQfitPD_multiCoils_M0.m to make
%                           the PD map.
%
%
% SEE ALSO:
%   mrQ_CoilPDFit_grid.m
%
% ASSUMPTIONS:
%   This code assumes that your SGE output directory is '~/sgeoutput'
%
% AM (C)The Hebrew University

%
%

%% I. Check inputs and set defaults
%  Saving parameters and relevant information for the Gain fit in the "opt"
%  structure. This allows us to send them to all the grid calls running 
%  in parallel

if (notDefined('outDir') || ~exist(outDir,'dir'))
    outDir = uigetDir(pwd,'Select outDir');
end
   opt.outDir  = outDir;

if(~exist('degrees','var'))
    disp('Using the default polynomials: degrees = 3 for coil estimation');
    degrees = 3;
end
   opt.degrees = degrees;

% If the M0file is not an input, we load the file that was made by
% mrQ_multicoilM0.m (default)
if(~exist('M0file','var') || isempty(M0file))
[~, M0file,~]=mrQ_get_T1M0_files(mrQ,0,1,0);
    if ~exist(M0file,'file')
        disp('Cannot find the M0 file.')
        error
    end
end
   opt.M0file = M0file;

if notDefined('boxSize')
    boxSize =14;
end

if notDefined('percent_overlap')
    percent_overlap =0.5;
end

% In cases of high-resolution data, we can undersample the data to outMm
% resolution
if notDefined('outMm')
    outMm=[2 2 2];
end

% Default T1 regularization
if notDefined('PDfit_Method')
    PDfit_Method=1;
end
  opt.PDfit_Method=PDfit_Method;

if notDefined('Coilsinfo')
    if PDfit_Method~=1; 
             % We define the number of coils that will be used for the fit
             % and the pull of best coil      
        Coilsinfo.maxCoil=4; Coilsinfo.minCoil=4; Coilsinfo.useCoil=[1:16];
    else % in case we use only one coil
        Coilsinfo.maxCoil=1; Coilsinfo.minCoil=1; Coilsinfo.useCoil=1; 
    end
end


if (notDefined('Inclusion_Criteria'))
    opt.Inclusion_Criteria=[0.4 200];
else
    opt.Inclusion_Criteria=Inclusion_Criteria;
    
end

% Load the brain mask file
if(~exist('Maskfile','var') || isempty(Maskfile))
  error( 'Maskfile is missing');
end   

if (exist(Maskfile,'file'))
    disp(['Loading brain Mask data from ' Maskfile '...']);
    Mask = readFileNifti(Maskfile);
    mmPerVox  = Mask.pixdim;
    opt.BMfile = Maskfile;
    
    % In cases of high resolution data, we can undersample the data when we
    % fit the coil gains. This may shorten the fit time. Note that the coil
    % gain was written for 2mm x 2mm x 2mm resolution. Images with a
    % different resolution may need some changes in the regularization
    % protocol.
    
    if outMm(1)~=0 % Unless we don't want to change the fitting resolution
       if (outMm(1)~=mmPerVox(1) || outMm(2)~=mmPerVox(2) || outMm(3)~=mmPerVox(3) )
          [opt]=mrQ_resamp4G_fit(opt,outMm);
           Mask = readFileNifti(opt.BMfile);
           mmPerVox  = Mask.pixdim;
       end
    end
    Mask = logical(Mask.data);
else
    error('Cannot find the file: %s', BMfile);
end

% Get the subject prefix for SGE job naming
if notDefined('subName')
    % This is a job name we get from the for SGE
    [~, subName] = fileparts(fileparts(fileparts(fileparts(fileparts(outDir)))));
    disp([' Subject name for LSQ fit is: ' subName]);
end

% Clobber flag. 
% Overwrite existing fit and redo the PD Gain fits. 
%      ** Not yet implemented in full **
if notDefined('clobber')
    clobber = false;
end


    
%% II. Identify the boxes we want to fit

% Try to parcel the brain into boxes of roughly boxSize mm^3 and with an
% overlap of 2;
sz   = (size(Mask));

boxS = round(boxSize./mmPerVox);
even = find(mod(boxS,2)==0);

boxS(even)  = boxS(even)+1;
opt.boxS = boxS;

% Determine the percentage of percent_overlap  (0.1, 0.5, 0.7)
overlap = round(boxS.*percent_overlap);

% Create a grid of the center of the boxes that will be used to fit
[opt.X,opt.Y,opt.Z] = meshgrid(round(boxS(1)./2):boxS(1)-overlap(1):sz(1)    ,    round(boxS(2)./2):boxS(2)-overlap(2):sz(2)    , round(boxS(3)./2):boxS(3)-overlap(3):sz(3));


%donemask is a volume of the center locations and is used for bookkeeping. 
%(i.e., which boxes are done and which need be done or skipped.)
donemask = zeros(size(opt.X));

opt.HboxS = (boxS-1)/2;

%% III. Loop over the identified boxes and check that the data is there

ii = 1;
opt.donemask = donemask;

for i=1:prod(size(opt.X))
    
    [fb(1) fb(2) fb(3)] = ind2sub(size(opt.X),i);
    [empty] = mrQ_isDataBox(opt,Mask,fb);
    if empty == 0 % this is a good box
        opt.wh(ii) = i;
        ii = ii+1;
        
    elseif empty == 1 %box we won't use
        donemask(fb(1),fb(2),fb(3)) = -1e3;
        
    elseif empty == -1 %box we won't use
        donemask(fb(1),fb(2),fb(3)) = -2e3;
        opt.wh(ii) = i;
        ii = ii+1;
    end
    
end

opt.donemask = donemask;

%% IV. Initiate other parameters for the fit and SGE call

opt.BasisFlag = 'qr'; %orthonormal basis for the coil polynomials


Coilsinfo.maxCoil=1; Coilsinfo.minCoil=1; Coilsinfo.useCoil=1;
% The coils information: how many coils to use and to pull from.
opt.maxCoil=Coilsinfo.maxCoil;
opt.minCoil=Coilsinfo.minCoil;
opt.useCoil=Coilsinfo.useCoil;

opt.smoothkernel=0;
sgename    = [subName '_MultiCoilM0'];
dirname    = [outDir '/tmpSGM0' ];
dirDatname = [outDir '/tmpSGM0dat'];
    jumpindex  = length(opt.wh);


opt.dirDatname = dirDatname;
opt.name = [dirname '/M0boxfit_iter'] ;
opt.date = date;
opt.jumpindex = jumpindex;
opt.dirname=dirname;

opt.SGE=sgename;

% Save out a logfile with all the options used during processing
logname = [outDir '/fitLog.mat'];
opt.logname=logname;

%saving an information file we can load afterwards if needed
save(opt.logname,'opt');

if clobber && (exist(dirname,'dir'))
    % in the case we start over and there are old fits, we will
    % delete them
    eval(['! rm -r ' dirname]);
end
return


%% %   Perform the gain fits
% % Perform the fits for each box using the Sun Grid Engine
% if SunGrid==1;
%     
%     % Check to see if there is an existing SGE job that can be
%     % restarted. If not start the job, if yes prompt the user.
%     if (~exist(dirname,'dir')),
%         mkdir(dirname);
%         eval(['!rm -f ~/sgeoutput/*' sgename '*'])
%         if proclass==1
%             sgerun2('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(length(opt.wh)/jumpindex),[],[],5000);
%         else
%             sgerun('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(length(opt.wh)/jumpindex),[],[],5000);
%             
%         end
%     else
%         % Prompt the user
%         inputstr = sprintf('An existing SGE run was found. \n Would you like to try and finish the exsist SGE run?');
%         an1 = questdlg( inputstr,'mrQ_fitPD_multiCoils','Yes','No','Yes' );
%         if strcmpi(an1,'yes'), an1 = 1; end
%         if strcmpi(an1,'no'),  an1 = 0; end
%         
%         % User opted to try to finish the started SGE run
%         if an1==1
%             reval = [];
%             list  = ls(dirname);
%             ch    = 1:jumpindex:length(opt.wh);
%             k     = 0;
%             
%             for ii=1:length(ch),
%                 ex=['_' num2str(ch(ii)) '_'];
%                 if length(regexp(list, ex))==0,
%                     k=k+1;
%                     reval(k)=(ii);
%                 end
%             end
%             
%             if length(find(reval)) > 0
%                 eval(['!rm -f ~/sgeoutput/*' sgename '*'])
%                 if proclass==1
%                     for kk=1:length(reval)
%                         sgerun2('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',[sgename num2str(kk)],1,reval(kk),[],[],5000);
%                     end
%                 else
%                     sgerun('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',sgename,1,reval,[],[],5000);
%                 end
%             end
%             
%             % User opted to restart the existing SGE run
%         elseif an1==0,
%             t = pwd;
%             cd (outDir)
%             eval(['!rm -rf ' dirname]);
%             cd (t);
%             eval(['!rm -f ~/sgeoutput/*' sgename '*'])
%             mkdir(dirname);
%             if proclass==1
%                 sgerun2('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(length(opt.wh)/jumpindex),[],[],5000);
%             else
%                 sgerun('mrQ_CoilPD_gridFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(length(opt.wh)/jumpindex),[],[],5000);
%                 
%             end
%         else
%             error('User cancelled');
%         end
%     end
%     
% else
%     % with out grid call that will take very long
%     disp(  'No parallre computation grid is used to fit PD. Using the local machin instaed , this may take very long time !!!');
%     jumpindex=   length(opt.wh);
%     opt.jumpindex=jumpindex;
%     
%     mrQ_CoilPD_gridFit(opt,jumpindex,1);
%     save(opt.logname,'opt');
% end

%end

