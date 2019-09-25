function   mrQ_fitB1_LSQ_ELSC(Res,brainMask,tr,flipAngles,outDir,job_outDir,M0,xform,SGE,savenow,sub,proclass,jumpindex,mrQ_struc)
% [B1 resNorm PD] = mrQ_fitB1_LSQ(Res,brainMask,tr,flipAngles,outDir,...
%                                 M0,xform,SGE,savenow,sub)
%
% Perform least squares fitting of B1
%
% INPUTS:
%       Res         - contains:Res{2}.im   = ok;
%                              Res{2}.name ='align_map';
%                              Res{1}.im   = SEIR_T1_1;
%                              Res{1}.name = 'target_(GS)';
%       brainMask   - Tissue mask delineating the brain region
%       tr          - TR taken from the S2 structure of aligned data
%       flipAngles  - Array of flipAngles for each scan.
%       outDir      - Ouput directory where the resulting nifti files will
%                     be saved.
%       M0          - MAP
%       xform       - Transform
%       SGE         - Option to run using SGE [default = 0]
%       savenow     - Saves the outputs to disk [default = 0]
%       sub         - Subject name for SGE call
%
%
% OUTPUTS:
%       B1
%       resNorm
%       PD
%
%
% WEB RESOURCES
%       http://white.stanford.edu/newlm/index.php/Quantitative_Imaging
%
%
% See Also:
%       mrQfit_T1M0_ver2.m


%% Check inputs

if (~exist('sub','var')|| isempty(sub)),
    sub='UN';
end

sgename=[sub '_3dB1'];

if (~exist('SGE','var')|| isempty(SGE)),
    SGE=0;
end

if (~exist('proclass','var')|| isempty(proclass))
    proclass=0;
end
    
    
if (~exist('savenow','var')|| isempty(savenow)),
    savenow=0;
end


%% Set options for optimization procedure

a=version('-date');
if str2num(a(end-3:end))>=2012
    options = optimset('Algorithm', 'levenberg-marquardt','Display', 'off','Tolx',1e-12);
else
    options =  optimset('LevenbergMarquardt','on','Display', 'off','Tolx',1e-12);%'TolF',1e-12
    
end

%options = optimset('LevenbergMarquardt','on','Display', 'off','Tolx',1e-12,'TolF',1e-12);
% we put all the relevant data in a structure call op.t thiss will make it  easyer to send it between the computer in the grid
sz=size(brainMask);
for i = 3:length(Res)
    
    tmp = Res{i}.im(brainMask);
    
    opt.s(:,i-2) = double(tmp);
    
end

opt.FlipAngles = flipAngles; %(1:4);
opt.TR         = tr;
opt.wh         = find(brainMask);
opt.x0(:,1)    = M0; %./Gain(brainMask));
opt.x0(:,2)    = 1;    

opt.job_outDir=job_outDir;
opt.SEIR_T1 = Res{1}.im(brainMask);
opt.outDir  = [outDir ];
opt.lb      = [0 0.3];
opt.ub      = [ inf 1.7];
opt.Res=Res;

if notDefined('FilterSize')
    FilterSize =6;
end

if notDefined('percent_coverage')
    percent_coverage =0.33;
end

opt.percent_coverage=percent_coverage;
opt.FilterSize=FilterSize;

opt.tisuuemaskFile=mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1;
 BM=readFileNifti(mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1);
 opt.pixdim=BM.pixdim;
 BM=logical(ones(size(BM.data)));

% Use the mask where we would like to have a B1 mask
opt.N_Vox2Fit=length(find(BM));

opt.name    = '/B1lsqVx';
opt.filename = fullfile(outDir,'opt');
name='~/opt';
subName= '9999999999' % RANDOM ID
sgename    = [subName '_B1'];
dirname    = [outDir '/tmpSGB1' ];
dirDatname = [outDir '/tmpSGB1dat'];
jumpindex  = 5000; %number of boxes for each SGE run

opt.dirDatname = dirDatname;
opt.name = [dirname '/B1boxfit_iter'] ;
opt.date = date;
opt.jumpindex = jumpindex;
opt.dirname=dirname;

opt.SGE=sgename;
save(name,'opt');
%% IV. Save
% Save a logfile with all the options used during processing:
logname = [outDir '/fitLogB1.mat'];
opt.logname=logname;

% Save an information file we can load afterwards, if needed.
save(opt.logname,'opt');



%mrQ_fitB1PD_SGE_ELSC([],[],opt.filename ) %% solving using persistent

%global optfileName
 
%optfileName=opt.filename;

 
%optfileName=opt.filename;
%global optfileNa
 
%%
%Call the SunGrid





for jobindex=1:ceil(opt.N_Vox2Fit/jumpindex)
    


% this is for the  cluster
% sprintf('parameters_%g_%',opt.filename,jumpindex,ii)
command=sprintf('qsub -cwd -j y -b y -N job "matlab -nodisplay -r ''mrQ_fitB1PD_SGE_ELSC(%g,%g); exit'' >log"',jumpindex,jobindex);
system(command);


end
  
  

    % build the data that was fit by the SGE to a B1 map
   % This loop checks if all the outputs have been saved and waits until
    %they are all done
    StopAndSave = 0;
    fNum = ceil(length(opt.wh)/jumpindex);
    
    while StopAndSave==0
        % List all the files that have been created from the call to the
        % grid
        list=ls(opt.outDir);
        % Check if all the files have been made.  If they are, then collect
        % all the nodes and move on.
        if length(regexp(list, '.mat'))==fNum,
            StopAndSave=1;
            
            % Loop over the nodes and collect the output
            for i=1:fNum,
                
                
                st=1 +(i-1)*jumpindex;
                ed=st+jumpindex-1;
                if ed>length(opt.wh), ed=length(opt.wh);end;
                
                name=[opt.outDir '/' opt.name '_' num2str(st) '_' num2str(ed) '.mat'];
                load (name);
                B11(st:ed)=res(2,:);
                pd1(st:ed)=res(1,:);
                resnorm1(st:ed)=resnorm;
                
            end;
        
    end
end



B1      = zeros(sz);
PD      = B1;
resNorm = PD;

B1(opt.wh) = B11(1,:);
PD(opt.wh) = pd1(1,:);

resNorm(opt.wh) = resnorm1(1,:);
      
   

%% Save out results
%
% 
     dtiWriteNiftiWrapper(single(B1), xform, fullfile(outDir,'B1_lsq_last.nii.gz'));
     dtiWriteNiftiWrapper(single(PD), xform, fullfile(outDir,'PD_lsq_last.nii.gz'));
     dtiWriteNiftiWrapper(single(resNorm), xform, fullfile(outDir,'lsqT1PDresnorm_last.nii.gz'));

