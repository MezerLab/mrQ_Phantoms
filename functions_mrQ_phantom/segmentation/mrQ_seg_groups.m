function mrQ_seg_groups(mask,weighted_map, num_groups,param,output)
%function mrQ_seg_groups(mask,weighted_map, num_groups)
%%this function  recive: 
%mask- the path to itk( or other software) nifiti.gz file,
%which is a files with lable indicis for each group of data(different
%substense).
%weighted_map- the path to the data mat file of any weighted map( T1/T2..)
%%num_groups- how many labels you have?( 1..10..)
%param-what parameter is wighted? T2/T1..?


switch param
 
    case 'T2'
        
        [col row]=size(EMC_results);
        
        for i=1:row
        data(:,:,i)=EMC_results(i).T2map_SEMC;
        data_PD(:,:,i)=EMC_results(i).PDmap_SEMC;
        data_exp(:,:,i)=EMC_results(i).T2map_SEMC_monoexp;
        data_PD_exp(:,:,i)=EMC_results(i).PDmap_SEMC_monoexp;
        end

mask=readFileNifti(mask);
mask=double(mask.data);

for ii=1:groups
weighted.T2(ii)=median(data(find(mask==ii)));
weighted.pd(ii)=median(data_PD(find(mask==ii)));
weighted.exp(ii)=median(data_exp(find(mask==ii)));
weighted.pd_exp(ii)=median( data_PD_exp(find(mask==ii)));

end

save_file=fullfile(output,'weighted_group_vec');
save(save_file,'weighted')

    case 'T1'
        
end
