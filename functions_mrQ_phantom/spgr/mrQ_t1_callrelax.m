
function [mrQ_struc] = mrQ_t1_callrelax(mrQ_struc)
%% fits t1 map with biases
data_spgr=fullfile(mrQ_struc.spgr.inputDir,'SPGR_Dat');
           load(data_spgr)
           
          data= double( cat(4,s(:).imData));
          
         b1Map=B1;
         
          [t1,pd] = relaxFitT1(data,flipAngles,tr,b1Map); %the fit

    outDir=mrQ_struc.spgr.relaxfit.output;
    
t1file_L =fullfile(outDir,'t1_L');
dtiWriteNiftiWrapper (t1,xform,t1file_L );
M0file_L =fullfile(outDir,'M0_L'); 
dtiWriteNiftiWrapper (pd,xform,M0file_L );

mrQ_struc.spgr.relaxfit.done='done';

    save( mrQ_struc.name,'mrQ_struc') 
    
end