function [mrQ_struc]=mrQSEIR_simpleFit2Param(datafile,outputPath ,mrQ_struc)
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

datafile=strcat(datafile,'/SEIR_Dat')
load(datafile);

sz=size(data);
Nx=sz(1);  %NUMBER OF VOXLES
Ny=sz(2);
Nz=sz(3);%NUMBER OF slices

size_TI=length(extra.tVec);
Output=zeros(size(data));


%%need to be changes inside the loop- try to have a first guess according
%%to solving a 2/3 linear equations, for a,b and t1 first guess.
%x0(1)=data(round(Nx/2),round(Ny/2),round(Nz/2),size_TI);     % a guess for the parameter c
%x0(2)=1000;   % a guess for the parameter T1


mininput.ti=extra.tVec;
OPTIONS = optimset(  [],[],'Display', 'off','Tolx',1e-10,'TolFun',1e-8);

for ss=1:Nz
for ii=1:Nx
for jj=1:Ny

mininput.sig=squeeze(data(ii,jj,ss,:))'; 
%%guess
%%y=b*exp(-ti/t1);

syms b t1
[solb, solt1] = solve ([ b*exp((mininput.ti(1)/t1))==mininput.sig(1) ,b*exp((mininput.ti(2)/t1))==mininput.sig(2)], [b, t1]);
if isempty(solb)
    solb=0;
end
if isempty(solt1)
    solt1=0;
end
x0(1)=real(solb(1));
x0(2)=abs(solt1(1));
x0=double(x0);
%end for guess
[xCurrent,Resnorm] = lsqnonlin(@(x) mrQ_simplefit(x,mininput),x0,[],[],OPTIONS);

Output(ii,jj,ss,1)=xCurrent(1); %retuning C
Output(ii,jj,ss,2)=xCurrent(2); %returning T1
Output(ii,jj,ss,3)=Resnorm; %returning the norm error

end
end
end

fileName=fullfile(outputPath,'Sim2ParT1fit');
save(fileName,'Output','mininput')
mrQ_struc.seir.long_2param.done='done'

save( mrQ_struc.name,'mrQ_struc') 

end
% 
% % mask and showing a montage of the fitted data
% T1=Output(:,:,:,2);
% showMontage(T1(:,:,:))
% mask= T1>0 & T1<1000;
%  %caxis([0 3400 ])
% colormap hot;
% 
% [Values Density]= ksdensity(T1(mask) );% histogram of the t1 pics
% figure; plot(Density, Values)
% 

%%
%Simulation: if you would like to simulate the equation first, without the data
%
%Ti1=1000;
%Ti1=1000;
%TI=[50 400 1200 2400];
%C=2
%SigSim= C.*(1-2.*exp(-TI/Ti1))

%SigSimMe= SigSim +rand(1,4)./10;
