function [mrQ_struc]= mrQ_complex_from_phase(mrQ_struc)


phase_dat=dicomLoadAllSeries(mrQ_struc.seir.quick_3param.complex_Dir);
mag_dat=dicomLoadAllSeries(mrQ_struc.seir.inputDir);

[r c]=size(mag_dat);

for ii=1:c
    
phas(:,:,:,ii)=phase_dat(ii).imData;
mag(:,:,:,ii)=mag_dat(ii).imData;

end

phas=double(phas);
mag=double(mag);


[mrQ_complex]=phase_to_complex(phas,mag);


load(fullfile(mrQ_struc.seir.inputDir, 'SEIR_Dat'));

clear data

data=mrQ_complex;

save_name=fullfile(mrQ_struc.seir.quick_3param.complex_Dir,'SEIR_complex.mat')
save(save_name,'data', 'xform', 'extra')

     mrQ_fitSEIR_T1_phantom(mrQ_struc.seir.quick_3param.complex_Dir ,mrQ_struc.seir.quick_3param.complex_OutDir,1,1);
mrQ_struc.seir.quick_3param.complex_done='done';

save( mrQ_struc.name,'mrQ_struc') 

end

