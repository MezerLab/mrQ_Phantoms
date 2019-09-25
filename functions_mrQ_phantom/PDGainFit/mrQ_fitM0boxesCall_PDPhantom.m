function mrQ_fitM0boxesCall_PDPhantom(opt_logname)
% INPUTS:
%         opt:   This is the optimization structure that was passed from
%                   mrQ_fitPD_multicoil. It has all the needed information.
%
% OUTPUTS:
%                The function will save an output file with fitted
%                parameters in a tmp directory. This will be used later by
%                mrQfitPD_multiCoils_M0 to make the PD map.

% SEE ALSO:
% mrQ_PD_multicoil_RgXv_GridCall
% ezer Copyright The Hebrew University 2016
%
%%
load (opt_logname);
dirname=opt.dirname;
jumpindex=opt.jumpindex ;

if (~exist(dirname,'dir')),
        mkdir(dirname);
end
        
 jumpindex=   length(opt.wh);
    opt.jumpindex=jumpindex;
    

jobindex=1;
%
%

%% I. Initialization

%Find the box to work on
j=0;
st=1 +(jobindex-1)*jumpindex;
ed=st+jumpindex-1;

%Check that this box has brain data
if ed>length(opt.wh), ed=length(opt.wh);end;

nIteration=ed-st+1;
%Initialize the parameters and saved outputs

% Get the M0 and T1 information

% Multi coil M0
M0=readFileNifti(opt.M0file);
M0=M0.data;


%Brain mask
seg=readFileNifti(opt.BMfile);
seg=seg.data;

BM=logical(seg);
smoothkernel=opt.smoothkernel;

% The poly basis to fit the coil gains
pBasis = mrQ_CreatePoly(opt.boxS,opt.degrees,3,opt.BasisFlag);

nVoxels=size(pBasis,1);
nPolyCoef=size(pBasis,2);

% Initiate the saved parameters
fb=zeros(nIteration,1,3);
gEst=zeros(nPolyCoef,nIteration);
resnorm=zeros(nIteration,1);
exitflag=zeros(nIteration,1);
skip=zeros(nIteration,1);

Iter=0;

%%  II. Go over it, box by box

for jj= st:ed,
    %run over the box you like to fit
    clear M01  t1  BM1  SZ M0_v R1basis PDinit Segmask g0 G0 mask1
    Iter= Iter+1;
    tic
    %Find the x,y,z location of the box.
    % (This is not the x,y,z location in image space, but rather the grid
    % of boxes we made by meshgrid in  mrQ_PD_multicoil_RgXv_GridCall.m)
    [fb(Iter,1,1), fb(Iter,1,2), fb(Iter,1,3)]=ind2sub(size(opt.X),opt.wh(jj));
    
    % Get all the relevant box data for the fit
    [M01, BM1, SZ, skip(Iter), Segmask]= mrQ_GetPhantomM0_boxData(opt,M0,BM,fb(Iter,1,:),smoothkernel,seg);
    M0_v = M01(:);
  
    
    
    if  skip(Iter)==1
       % disp(['skipping box ' num2str(jj) ' bad data'])
        
    else
 
        %% Fit
        Segmask=logical(Segmask);
         g = pBasis(Segmask,:) \ M01(Segmask);
        
       
        gEst(:,Iter)=g;
    end
end

name=[ opt.name '_' num2str(st) '_' num2str(ed)];

save(name,'gEst','st','ed','skip','fb')


    
    
