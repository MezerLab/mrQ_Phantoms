function mrFatCoilGainEstimateRaper(M0file,Maskfile,outDir,outMm,name,boxSize)

if notdefined('outMm');outMm=0;end
if notdefined('name');name=tempname;end
if notdefined('boxSize');boxSize=8;end

                                     
[logname]=mrQ_PD_Fit_ConstantPhantomParams(outDir,Name,[],M0file,...
    Maskfile,outMm,boxSize);

mrQ_fitM0boxesCall_PDPhantom(logname)

mrQ_buildPDPhantom(logname);