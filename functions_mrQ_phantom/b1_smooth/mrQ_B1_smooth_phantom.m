function [B1,mrQ_struc]=mrQ_B1_smooth_phantom(mrQ_struc)


% Perform smoth the SEIR B1 map and register to SPGR space
%
% INPUTS:
%    B1epifile         -     The B1 map path 
%       outDir         -     Ouput directory where the resulting nifti files will
%                            be saved. 
%       xform          -     Transform
%       B1file         -     output B1 name
%       degree         -     polynomiyal degree for global fit of the smooth B1
%                           (defult 3)
%     
%       t1fileHM       -     a SPGR T1 map for registration  
%       B1epiResidfile -    a residual file of the B1 fit that is used to find outlayers B1
%                       values
% OUTPUTS
% b1 -smooth B1 in SPGR space

B1epifile=fullfile( mrQ_struc.spgr.B1lsq.output,'B1_LRfit.nii.gz')

B1file=fullfile( mrQ_struc.spgr.smooth.output,'B1_smooth')%%name to save

B1epiResidfile=fullfile(mrQ_struc.spgr.B1lsq.output,'restnorm_b1LRfit.nii.gz')



outDir=mrQ_struc.spgr.smooth.output;

load(fullfile(mrQ_struc.spgr.inputDir,'SPGR_Dat'));

degree=mrQ_struc.spgr.smooth.degree;

SPGR_seirmaskT1= mrQ_struc.spgr.seg.seg_spgrfile;

 SPGR_seirmaskT1=niftiRead(SPGR_seirmaskT1);
SPGR_seirmaskT1=double(SPGR_seirmaskT1.data);
Tmask=logical(SPGR_seirmaskT1);
%%


%we smooth the SEIR B1 map by local and then feel the gap by global
%registration and then register back the smooth B1 to the SPGR space 


% See Also:
% mrQfit_T1M0_ver2


if (~exist('degree','var')|| isempty(degree)),
    degree=3;
end;


%  B1 mask
% mask the B1 value that we don't like to use 
% 1. more then 50% T1 variation between SEIR and SPGR is probabaly miss registration
% 2. B1 in the edge of the search space is point that didn't converge in the B1
% fit
% 3.voxel with big fit residual for B1 or SEIR T1 are also out

%load the B1 fit
B1=readFileNifti(B1epifile);
SE_Xform=B1.qto_xyz;
pixdim=B1.pixdim ;
B1=double(B1.data);


%load the data that was used to the B1 fit


%load the B1 fit residual
B1fitResid=readFileNifti(B1epiResidfile);
B1fitResid= B1fitResid.data;

%load the T1 fit residuals



%no fot to big or small B1 (50%)
agarmask=  B1<1.5 & B1>.5 & ~isinf(B1fitResid) ;

%no for big residual

agarmask=agarmask & B1fitResid<prctile(B1fitResid(find(B1fitResid)),97) ;
   

agarmask=agarmask & B1>prctile(B1(agarmask),1) & B1<prctile(B1(agarmask),99);




% fit local regresiions

tmp1=zeros(size(agarmask));


sz=size(agarmask);
tt=ones(sz); 




% % II fit local regresiions
% we will smooth the B1 map by local regresiions
% the fit is done in tree steps
% 1.we first estimate the voxel that have can be estimate with great confidance
% (<45% ) of the area under the filter
% local information 
% 
% 2. we fit  the others that are posible but with less confidance with
% more smooth (biger filter
% 
% 3. the one that are out of reach for local regration will be fitted by
% global polynomyial along the full B1 space (like a fillter along the all B1 map)

tmp1=agarmask;


sz=size(agarmask);
tt=ones(sz); 

%%%
%1. we check the local information by compareing to covariance of
%the filter with a all ones imgage (full information).

area=0.45;
%filter size
FS=30;
filter1=FS./pixdim;
%if you want to cancel the masking, use this
%%tmp1=B1;
%%% 3.   we can do global polynomial if we can't fit localy some locations    
Imsz1=size(tmp1);

%make the 3D polynials
[Poly1,str] = constructpolynomialmatrix3d(Imsz1,find(ones(Imsz1)),degree);

%fit the polynials coefitents to the smooth B1 map
[params,gains,rs] = fit3dpolynomialmodel(B1,(tmp1>0),degree);%%12.01.16 WAS tmp1,(tmp1>0),degree); CHANGE

%reshape from a vector to 3D map
B1match = reshape(Poly1*params(:),Imsz1);%ixdim;
[f1] = makegaussian3d(filter1,[0.5 0.5 0.5],[0.25 0.25 0.25]);

%define the avilable caverage
C1 = convn(agarmask,f1,'same');

%define the maxsimal caverage
CC1=convn(tt,f1,'same');

%the voxel that we will use
agarmask1=C1>max(CC1(:)).*area;
agarmask1=agarmask1 & Tmask;
%where there are B1 estimation (x,y,z location)
[x y z]=ind2sub(size(agarmask),find(agarmask));

%were we will find the smooth B1  estimation (x,y,z location)
[x0 y0 z0]=ind2sub(size(agarmask),find(agarmask1));

%local regrision
w1 = localregression3d(x,y,z,B1(find(agarmask)),(x0),(y0),(z0),[],[],filter1,[]);

%save the result
tmp1(find(agarmask1))=w1;




%%%
    %2. we fit all the others
%we will increase the filter size and reduce the area that is needed to be
%included


area=0.15;
%filter
FS=60;
filter1=FS./pixdim;
[f1] = makegaussian3d(filter1,[0.5 0.5 0.5],[0.25 0.25 0.25]);

%define the avilable caverage
C1 = convn(agarmask,f1,'same');
%where there are B1 estimation

%define the maxsimal caverage
CC1=convn(tt,f1,'same');

%the voxel that we will use
agarmask2=C1>max(CC1(:)).*area & agarmask1==0;
agarmask2=agarmask2 & Tmask;

%where there are B1 estimation (x,y,z location)
[x y z]=ind2sub(size(agarmask),find(agarmask));

%were we will find the smooth B1 estimation (x,y,z location)
[x0 y0 z0]=ind2sub(size(agarmask),find(agarmask2));

%local regrision
w2 = localregression3d(x,y,z,B1(find(agarmask)),(x0),(y0),(z0),[],[],filter1,[]);

%save the result
tmp1(find(agarmask2))=w2;


%if you want to cancel the masking, use this
tmp1=B1;
%%if not put the expression in coma tmp1=B1;
%%% 3.   we can do global polynomial if we can't fit localy some locations    
Imsz1=size(tmp1);

%make the 3D polynials
[Poly1,str] = constructpolynomialmatrix3d(Imsz1,find(ones(Imsz1)),degree);

%fit the polynials coefitents to the smooth B1 map
[params,gains,rs] = fit3dpolynomialmodel(tmp1,(tmp1>0),degree);

%reshape from a vector to 3D map
B1match = reshape(Poly1*params(:),Imsz1);

%find where the B1 value are missing
mask=logical(tmp1>0);

%fill the holls
tmp1(~mask)=B1match(~mask);


%%% last check
%we might get  scaling effect when the smoothing is not perefect , scale it
%back so the mean of the smooth map and the original is the same
Cal=median(B1(agarmask)./tmp1(agarmask));
tmp1=tmp1.*Cal;


B1=tmp1;
%%% save the smooth B1 map
B1_smooth= fullfile(mrQ_struc.spgr.smooth.output,'B1_smooth')
dtiWriteNiftiWrapper(single(tmp1), SE_Xform, B1_smooth);


  mrQ_struc.spgr.smooth.done='done'
      save( mrQ_struc.name,'mrQ_struc') 

end
