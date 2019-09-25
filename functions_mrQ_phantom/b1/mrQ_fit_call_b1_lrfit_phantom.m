function   [mrQ_struc]=mrQ_fit_call_b1_lrfit_phantom(Res,brainMask,tr,flipAngles,outDir,M0,xform,SGE,savenow,sub,proclass,jumpindex,mrQ_struc)
% [ resNorm PD] = mrQ_fitB1_LSQ(Res,brainMask,tr,flipAngles,outDir,...
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
% for i = 3:length(Res)
%     
%     tmp = Res{i}.im(brainMask);
%     
%     opt.s(:,i-2) = double(tmp);
%     
% end

opt.FlipAngles = flipAngles; %(1:4);
opt.TR         = tr;
% opt.wh         = find(brainMask);
% opt.x0(:,1)    = M0; %./Gain(brainMask));
% opt.x0(:,2)    = 1;    


%opt.SEIR_T1 = Res{1}.im(brainMask);
%opt.outDir  = [outDir];
% opt.lb      = [0 0.3];
% opt.ub      = [ inf 1.7];
opt.Res=Res;

if notDefined('FilterSize')
    FilterSize =6; %% 14/01/16 originaly filtersize=6
end

if notDefined('percent_coverage')
    percent_coverage =0.01; %% origanly percentage coverage=0.33
end

opt.percent_coverage=percent_coverage;
opt.FilterSize=FilterSize;

opt.tisuuemaskFile=mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1;
BM=readFileNifti(mrQ_struc.spgr.B1lsq.SPGR_seirmaskT1);

opt.pixdim=BM.pixdim;

BM=BM.data;
BM=double(BM);
%BM=permute(BM,[1 3 2]);%%% TO BE AS SAME AT THEE DATA!!CHEACK BEFORE RUNNING..
opt.BM=BM;




% Use the mask where we would like to have a B1 mask
%need to be redefine to the location you like to have a B1 value (curently
%every where)
%SigMask=logical(ones(size(BM.data)));
SigMask=logical(BM);
opt.sigMask=SigMask;

opt.N_Vox2Fit=length(find(SigMask));

opt.name    = '/B1lsqVx';
opt.filename = fullfile(outDir,'opt');
name='~/opt';
subName= mrQ_struc.spgr.B1lsq.sub; % RANDOM ID
sgename    = [subName '_B1'];
dirname    = [outDir '/tmpSGB1' ];
dirDatname = [outDir '/tmpSGB1dat'];
jumpindex  = 500; %number of boxes for each SGE run

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
mkdir(mrQ_struc.spgr.B1lsq.output,'tmpSGB1')
% Save an information file we can load afterwards, if needed.
save(opt.logname,'opt');


id_str=(mrQ_struc.spgr.B1lsq.sub);
name_save_pwd=fullfile('~/',id_str);

mkdir(name_save_pwd);
name_save_pwd=fullfile(name_save_pwd,'opt');
save(name_save_pwd,'opt');

%mrQ_fitB1PD_SGE_ELSC([],[],opt.filename ) %% solving using persistent

%global optfileName
 
%optfileName=opt.filename;

 
%optfileName=opt.filename;
%global optfileNa
 
%%


id=str2num(mrQ_struc.spgr.B1lsq.sub);


for jobindex=1:ceil(opt.N_Vox2Fit/jumpindex)

if SGE==1 %%Call the cluster
  command=sprintf('qsub -cwd -j y -b y -N job -o cluster_log "matlab -nodisplay -r ''mrQ_B1_LRFit_phantom(%g,%g,%f); exit'' >log_clusterPhantom"', jumpindex,jobindex,id);
 system(command);
else

   mrQ_B1_LRFit_phantom(jumpindex,jobindex,id);


end
end
  

    % build the data that was fit by the SGE to a B1 map
   % This loop checks if all the outputs have been saved and waits until
    %they are all done
    StopAndSave = 0;
    fNum =int16(ceil ( (opt.N_Vox2Fit)/jumpindex));
    
    while StopAndSave==0
        % List all the files that have been created from the call to the
        % grid
        list=ls(opt.dirname);
        % Check if all the files have been made.  If they are, then collect
        % all the nodes and move on.
        if length(regexp(list, '.mat'))==(fNum)
            StopAndSave=1;
        end;
    end
    fNum =ceil((opt.N_Vox2Fit)/jumpindex);

    a=jumpindex; 
    % Loop over the nodes and collect the output
            for i=1:fNum
                
            
     st=1 +(i-1)*a;
     ed= a -1 +st;
                if ed>length(find(brainMask)), ed=length(find(brainMask));end;
                
                name=[opt.name '_' num2str(st) '_' num2str(ed) '.mat'];
                load (name);
                B11(st:ed)=B1;
                resnorm1(st:ed)=resnorm;
                
            end
        
    




 B1      = zeros(size(opt.BM));
% 
resNorm = B1;

B1((find(brainMask)))=B11(1,:);


resNorm(find(brainMask)) = resnorm1(1,:);
      
   

%% Save out results
%
% 
     dtiWriteNiftiWrapper(single(B1), xform, fullfile(outDir,'B1_LRfit.nii.gz'));
     dtiWriteNiftiWrapper(single(resNorm), xform, fullfile(outDir,'restnorm_b1LRfit.nii.gz'));
mrQ_struc.spgr.B1lsq.done='done';
      save( mrQ_struc.name,'mrQ_struc') 


