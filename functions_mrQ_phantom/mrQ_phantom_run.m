 function [mrQ_struc]= mrQ_phantom_run(mrQ_struc)

%running  mrQ_Phantom
%This is the main script to run in order to create T1 and PD maps with B1+
%and B- corrections for phantoms.
%It is nesesary to create the mrQ_struc before, with the relevant flags and
%paths to the dicoms files and output folders. Please create mrQ_struc
%using the script  mrQ_phantom_structure

%plese note- it is possible to stop the fiiting in the end of each step and continue
%later for the next one.It is needed to load  mrQ_struc and run mrQ_phantom(it will automatcly continue) .

%% SEIR -GS 
%This part create a T1 map for GS-SEIR measurments
%First it is initiating the files and creates Nifti files.
%Secondly its calcualting SEIR-T1 maps(  without B1+ biases) according to Barral et al. (2010).
%It is recomended to use the parameters for this scan as describe in  Shtangel et al. 2018 BioRxiv.


if mrQ_struc.seir.flag=='y'
    
    %%initiation: load the dicoms and save dat file with data, xform and extra
    if isempty(mrQ_struc.seir.int)
    [data, extra ,xform ,saveName, mrQ_struc]= mrQ_initSEIR_phantom(mrQ_struc,mrQ_struc.seir.inputDir,[],[],[]);
     mrQ_struc.seir.int='done'
 save( mrQ_struc.name,'mrQ_struc') 

     if mrQ_struc.seir.mess=='y' %for cases when the data is fliped
          path_dicomDat=  fullfile(mrQ_struc.seir.inputDir, 'SEIR_Dat');
          path_nifty= mrQ_struc.seir.niftiDir;
            correct_dicomdata(path_dicomDat,path_nifty,'SEIR');
             mrQ_struc.seir.mess_done='done'
             save(mrQ_struc.name,'mrQ_struc') 

        end     
    end
    
% fit joelle code  using 3 param
 if  mrQ_struc.seir.quick_3param.flag=='y'
     if isempty(mrQ_struc.seir.quick_3param.done)

      % Fit SEIR
     mrQ_fitSEIR_T1_phantom( mrQ_struc.seir.inputDir,mrQ_struc.seir.quick_3param.outputDir,0,0);
     if  mrQ_struc.seir.quick_3param.complex=='y'
         
         [mrQ_struc]=mrQ_complex_from_phase(mrQ_struc); %is wanted to uses complex data
 save( mrQ_struc.name,'mrQ_struc') 

     end
mrQ_struc.seir.quick_3param.done='done' 
save( mrQ_struc.name,'mrQ_struc') 
         
     end
 end 
  
end    
     
   
    


%% EPI 
% same alanysis as above, only for EPI measurments
 if mrQ_struc.epi.flag=='y'
    
    %%initiation: load the dicoms and save dat file with data, xform and extra
    if isempty(mrQ_struc.epi.int)
    [data, extra ,xform ,saveName, mrQ_struc]= mrQ_initSEIR_phantom(mrQ_struc,mrQ_struc.epi.inputDir,[],[],[]);
     mrQ_struc.epi.int='done'
 save( mrQ_struc.name,'mrQ_struc') 

     if mrQ_struc.epi.mess=='y' %%for cases when the data is fliped
          path_dicomDat=  fullfile(mrQ_struc.epi.inputDir, 'SEIR_Dat');
          path_nifty= mrQ_struc.epi.niftiDir;
            correct_dicomdata(path_dicomDat,path_nifty,'SEIR');
             mrQ_struc.epi.mess_done='done'
        save(mrQ_struc.name,'mrQ_struc') 

     end     
    end
    
 % fit joelle code  3 param
 if  mrQ_struc.epi.quick_3param.flag=='y'
     if isempty(mrQ_struc.epi.quick_3param.done)

      % Fit SEIR
      mrQ_fitSEIR_T1_phantom( mrQ_struc.epi.inputDir,mrQ_struc.epi.quick_3param.outputDir,0,0);
    
mrQ_struc.epi.quick_3param.done='done'
save( mrQ_struc.name,'mrQ_struc') 

         
     end
 end
 
end
     
  
%% SPGR

%This part first initiation the data and creates Nifti files. Then it uses
%the agar masks of GS and SPGR to calcualte B1+ map.Finaly it create T1
%maps without the biases B1+ and and a PD map with corrections of the B1-.
%(we will run this part twice- once for the creationg of nifti, secondly we will make
%masks for the GS and SPGR from the nifti files for the agar and samples and run this part again.


if mrQ_struc.spgr.flag=='y'
    
    
      %%initiation: load the dicoms and save dat file with data, flip angles and  TR 
    if isempty(mrQ_struc.spgr.done);
        
        [mrQ_struc]=  mrQ_initSPGR_phantom(mrQ_struc);
        mrQ_struc.spgr.done='done';
       save('mrQ_phantom_structure','mrQ_struc') 

        if mrQ_struc.spgr.mess=='y' %In cases the data is flipped
          path_dicomDat=  fullfile(mrQ_struc.spgr.inputDir, 'SPGR_Dat');
          path_nifty=mrQ_struc.spgr.niftiDir;
            correct_dicomdata(path_dicomDat,path_nifty,'SPGR');
             mrQ_struc.spgr.mess_done='done'
             save('mrQ_phantom_structure','mrQ_struc') 

        end     
   end
    
  if mrQ_struc.spgr.relaxfit.flag=='y'
       
       if isempty(mrQ_struc.spgr.relaxfit.done);
      
[mrQ_struc] = mrQ_t1_callrelax(mrQ_struc); %calcualting initial t1 map with biases

       end  
  end

   
  if mrQ_struc.spgr.seg.flag=='y'
      
      if isempty(mrQ_struc.spgr.seg.done)
          [mrQ_struc]=mrQ_segmentation(mrQ_struc);  %comparing the agar in the GS T1 map to the agar in the spgr
      end 
  end
          
   
      if mrQ_struc.spgr.B1lsq.flag=='y'

    if isempty(mrQ_struc.spgr.B1lsq.done)
 
      [mrQ_struc]= mrQ_SPGR_B1lsq(mrQ_struc); %creating a B1+ map according to the Agar. It is possible to run this step on cluster for a faster run time.
       mrQ_struc.spgr.B1lsq.done='done';
      save( mrQ_struc.name,'mrQ_struc') 

    end
      end
      
    
  
   
 if  mrQ_struc.spgr.smooth.flag=='y'
     
     if isempty( mrQ_struc.spgr.smooth.done)
    
     [B1,mrQ_struc]=mrQ_B1_smooth_phantom(mrQ_struc); %smooting the B1+ to all the volume of the scan.
     mrQ_struc.spgr.smooth.done='done'
       save( mrQ_struc.name,'mrQ_struc') 
       
     end
 end


  if mrQ_struc.spgr.lwfit.flag=='y'
      
             if isempty(mrQ_struc.spgr.lwfit.done)
                 
        [mrQ_struc]= mrQ_SPGR_lwfit_T1_corrected_B1_map(mrQ_struc); %creating the final T1 map 
        [mrQ_struc]= mrQ_phantom_gain(mrQ_struc);  %%Calcualting the Gain of the coil and creates PD maps

              
        
        mrQ_struc.spgr.lwfit.done='done'
    save( mrQ_struc.name,'mrQ_struc') 

             end 
  end



end