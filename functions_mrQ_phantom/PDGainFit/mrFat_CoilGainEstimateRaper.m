function mrFat_CoilGainEstimateRaper(M0file,Maskfile,outDir,outMm,Name,boxSize)

if notDefined('outMm');outMm=0;end
if notDefined('Name');Name=tempname;end
if notDefined('boxSize');boxSize=8;end

                                     
[logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,Name,[],M0file,...
    Maskfile,outMm,boxSize);

mrQ_fitM0boxesCall_PDPhantom(logname)

mrQ_buildPDPhantom(logname);