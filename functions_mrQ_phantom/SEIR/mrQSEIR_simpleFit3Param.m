

function [mrQ_struc]=mrQSEIR_simpleFit3Param(datafile,outputPath,mrQ_struc)

%function mrQSEIR_simpleFit3Param(datafile,outputPath )
% 
% datafile - is the path to the mat file which is the output of the
% function mrQ_initSEIR.
% the file name will be SEIR_Dat.mat:
%           include the variable: data  --> 4D magnitude SEIR data. 
%            and the variable: extra -included field extra.tVec with
%           the coresponding inversion time
%  outputPath-is the path where you want to save the result of this
%  This function calls to the function simplefit - fits the data
%  with simple fit of 3 parameters Y=A+B*EXP(-TI/T1),returning the 3
%  computed parameterS and the error norm.

datafile=strcat(datafile,'/SEIR_Dat')

load(datafile);

sz=size(data);
Nx=sz(1);  %NUMBER OF VOXLES
Ny=sz(2);
Nz=sz(3) ;%NUMBER OF slices

Output=zeros([sz(1:3) 3]);

size_TI=length(extra.tVec);

x0(1)=1300; % a guess for the parameter A
x0(2)=data(round(Nx/2),round(Ny/2),round(Nz/2),size_TI);     % a guess for the parameter c
% a guess for the parameter B
x0(3)=1000;   % a guess for the parameter T1

min3input.ti=extra.tVec;

OPTIONS = optimset([],[],'Display', 'off','Tolx',1e-10,'TolFun',1e-8);

for ss=1:Nz
for ii=1:Nx
for jj=1:Ny

min3input.sig=squeeze(data(ii,jj,ss,:))';

[xCurrent,Resnorm] = lsqnonlin(@(x) mrQ_simplefit3(x,min3input),x0,[],[],OPTIONS);

Output3(ii,jj,ss,1)=xCurrent(1);% return the parameter A
Output3(ii,jj,ss,2)=xCurrent(2);  % return the parameter B
Output3(ii,jj,ss,3)=xCurrent(3); % return the parameter T1
Output3(ii,jj,ss,4)=Resnorm; %returning the norm error

end
end
end

fileName=fullfile(outputPath,'Sim3ParT1fit');
save(fileName,'Output3','min3input')
mrQ_struc.seir.long_3param.done='done'
save( mrQ_struc.name,'mrQ_struc') 


% 
% % mask and showing a montage of the fitted data
% T1=Output3(:,:,:,3);
% showMontage(T1(:,:,:))
% mask= T1>0 & T1<1000;
%  caxis([0 1000])
% colormap hot;
% 
% figure;hist(T1(mask),1000) % histogram of the t1 pics
% 
% [Values Density]= ksdensity(T1(mask) ); %smooth histogram of the t1 pics
% figure; plot(Density, Values)


%Simulation: if you would like to simulate the equation first, without the data
% 
%Ti1=1000;
%TI=[50 400 1200 2400];
%a=2;
%b=3;
%SigSim= a+b.*exp(-TI/Ti1);

%SigSimMe= SigSim +rand(1,4)./10;

%mininput.ti=  TI;
%mininput.sig=SigSimMe;
