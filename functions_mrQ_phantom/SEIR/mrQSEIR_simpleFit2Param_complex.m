function [mrQ_struc]=mrQSEIR_simpleFit2Param_complex(datafile,outputPath ,mrQ_struc)
%function mrQSEIR_simpleFit2Param(datafile,outputPath )
%
% datafile - is the path to the mat file which is the output of the
% function mrQ_initSEIR.
% the file name will be SEIR_Dat.mat:
%           include the variable: data  --> 4D magnitude SEIR data. 
%            and the variable: extra -included field extra.tVec with
%           the coresponding inversion time
%  outputPath-is the path where you want to save the result of this
%  This function calls to the function simplefit - fits the data
%  with simple fit of  2 parameters Y=C*EXP(-TI/T1),returning the 2
%  computed parameter and the error norm.
% 
%

r_datafile=strcat(datafile,'/SEIR_complex.mat')
load(r_datafile);

sz=size(data);
Nx=sz(1);  %NUMBER OF VOXLES
Ny=sz(2);
Nz=sz(3);%NUMBER OF slices

size_TI=length(extra.tVec);
Output=zeros(size(data));


%%need to be changes inside the loop- try to have a first guess according
%%to solving a 2/3 linear equations, for a,b and t1 first guess.
x0(1)=abs(data(round(Nx/2),round(Ny/2),round(Nz/2),size_TI));     % a guess for the parameter c
x0(2)=1000;   % a guess for the parameter T1


mininput.ti=extra.tVec;
OPTIONS = optimset(  [],[],'Display', 'off','Tolx',1e-10,'TolFun',1e-8);

for ss=1:Nz
for ii=1:Nx
for jj=1:Ny

mininput.sig=squeeze(data(ii,jj,ss,:))'; 
right_sign=SEIR_invert_sigh(mininput.sig,mininput.ti);%find the right sign

mininput.sig=abs(mininput.sig);%%abs to data

mininput.sig=mininput.sig.*right_sign;%% correction for sign
%%guess
%%y=b*exp(-ti/t1);

% syms b t1
% [solb, solt1] = solve ([ b*exp((mininput.ti(1)/t1))==mininput.sig(1) ,b*exp((mininput.ti(2)/t1))==mininput.sig(2)], [b, t1]);
% if isempty(solb) || solb<1
%     solb=0;
% end
% if isempty(solt1) || solt<1
%     solt1=0;
% end
% 
% x0(1)=real(solb(1));
% x0(2)=abs(solt1(1));
% x0=double(x0);
%end for guess
[xCurrent,Resnorm] = lsqnonlin(@(x) mrQ_simplefit(x,mininput),x0,[],[],OPTIONS);

Output(ii,jj,ss,1)=xCurrent(1); %retuning C
Output(ii,jj,ss,2)=xCurrent(2); %returning T1
 Output(ii,jj,ss,3)=Resnorm; %returning the norm error

end
end
end

fileName=fullfile(outputPath,'Sim2ParT1fit_complex');
save(fileName,'Output','mininput')
mrQ_struc.seir.long_2param.complex.done='done'

save( mrQ_struc.name,'mrQ_struc') 

end