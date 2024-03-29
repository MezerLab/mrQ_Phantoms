function err =errB1PD(x,flipAngles,tr,S,T1,lsq,SD)
%   
%err =errB1PD(x,flipAngles,tr,S,T1,lsq,SD)
% estimate the fit of x(1) M0 and x(2) B1 to fit the SPGRs images with the T1 values from SEIR fit T1.
%the SPGR are data mesure with different flip angles
%
%Arrguments
% x the fitted parameters
% flipAngles the scansflipAngles 
% tr the scans tr
% S - the mesured SPGRs images in SEIR space
% T1  the T1 value calculated in SEIR space
%lsq the kind of error calculation
% SD a way to normalize the error by the data std.
%outPut
%err -the error between the estimation and the data.
     







if (~exist('lsq','var')||isempty(lsq)) 
    lsq=1;
end;
if lsq~=0, lsq=1;end
    if (~exist('SD','var')||isempty(SD)),
    SD=1;
end;
M0=x(1);
B1=x(2);
fa=flipAngles.*B1;
fa = fa./180.*pi;
% the SPGR eqation 
Sc =M0.*(1-exp(-tr./T1)).*sin(fa)./(1-exp(-tr./T1).*cos(fa));


if lsq==1
    
      err=1/SD.*((S-Sc));
        err=sqrt(abs(err)); %let fit the median and not the mean that will give less whiat for outlayers

    else,

err=1/SD.*sum(sum(abs ((S-Sc)./S) ));

 end;
