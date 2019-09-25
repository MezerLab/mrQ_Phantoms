function [Gain PD_cor] =GainGlobalPolyFit(M0file,AgarMaskFile,degree)



Agarmask=readFileNifti(AgarMaskFile);
Agarmask=logical(Agarmask.data==1);
M0=readFileNifti(M0file);
M0=double(M0.data);

if notDefined('degree'); degree=5;end
%To test the degree that best explain the variance in the mask use this function:
%    g=mrQ_PolyFitOrder(Agarmask,M0,100);


Imsz1=size(Agarmask);

%make the 3D polynials
[Poly1,str] = constructpolynomialmatrix3d(Imsz1,find(ones(Imsz1)),degree);

%fit the polynials coefitents to the smooth B1 map
[params,gains,rs] = fit3dpolynomialmodel(M0,Agarmask,degree);

%reshape from a vector to 3D map
Gain = reshape(Poly1*params(:),Imsz1);

PD_cor=M0./Gain;

end
