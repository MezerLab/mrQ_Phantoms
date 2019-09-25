function mrQ_Tubes(Inpath)

%This function calles other function to fit T1 for phantom's tubes in the methood of SPGR
%under the assumption B1=ones
    Inpath='/home/oshrat.shtangel/Documents/mri_data/coconut/T1_FL3D_FA/sorted/1.3.12.2.1107.5.2.19.45343.30000015040209040281600000004/'
 s=dicomLoadAllSeries(Inpath)
 flipAngles = [s(:).flipAngle];
 tr  = [s(:).TR];
   % Check that all TRs are the same.
    if ~all(tr == tr(1))
        error('TR''s do not match!');
    end
    tr = tr(1);
  B1 = ones(size(s(1).imData));
[t1,pd]= relaxFitT1(double( cat(4,s(:).imData)),flipAngles,tr,B1);
%whos

showMontage(t1)

 caxis([0 1])
colormap hot;

end
save t1



%%%  B1 maps
bpath='/home/oshrat.shtangel/Documents/mri_data/aviv_data/Phantom_Feb5/B1';

 bb=dicomLoadAllSeries(bpath)


 
 %%
 sub='name'
   Gain = ones(size(s(1).imData));
outDir=''
xform=s(1).imToScanXform;
SunGrid=1;
proclus=0;
[T1w, T1L,M0w, MOL] = mrQ_T1M0_LWFit(s,mask,tr,flipAngles,Gain,B1,outDir,xform,SunGrid,1,sub,proclus);

%%


 [T1,M0] = mrQ_fitT1PD_LSQ(s2,mask,tr,flipAngles,M0L,T1L,Gain,B1,outDir,xform,SunGrid,1,sub,proclus);
 
