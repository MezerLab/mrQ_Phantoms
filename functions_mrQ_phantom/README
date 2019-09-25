How to Scan , Organize the files and preform the Analysis:

mrQ_phantom is a software package designed to calculate MR parameters (T1 and PD) using spoiled gradient echo scans (SPGR, FLASH) and Spin -Echo Inversion Recovery( SEIR).
This code ia a modification for mrQ
For that purposes: 
It is necessary to have https://github.com/mezera/mrQ tool box (with all the relevant repositories) for this code to work

1. Create a phantom with samples in a box, where the area around the samples is filled with Agar-Gd (see paper for more details)
2. SEIR-GS scan with at least 4 invertion recovery (recomanded parameters as detailed in the paper)
3. SPGR scan with at least 4 flip angles (recomanded parameters as detailed in the paper)
4. Organize the dicom images in folders
   GS- the Mag folders for each TI in one folder called GS
   SPGR- the Mag folders for each FA in one folder called SPGR
   create output folders for GS,SPGR
5. Prepare mrQ_phantom_sructure with the right flags and paths for the data and output folders.
6. Run mrQ_phantom_run in 2 steps:
   
   Step #1:Step 1 do initiation and creats important structurs for mrQ_phantom and Nifti fiels of the data.
     After Step #1 is finishes, use one of the Nifti SEIR files( for exmaple SEIR in 50 ms) and create a mask for Agar-Gd area that is labled=1.
       (we manualy segmented the agar with the use of Itk-gray sotware) .
       (Now you have one-slice of agar-gs segmeted( usally one slice-but poosible to scan couple of slices )

       Next, use one of the Nifti SPGR files in one FA( for example fa=10) and segmet the Agar-Gd in the whole volume labeld as=1.
       (Now you have multi slices mask for the spgr)
           

 
   Step 2: Do the B1+ and B1- correction and created a final T1 and PD maps.

       The final T1 map is called T1_WL_last.nii.gz
       The final PD map is caled PD.nii.gz

       other outputs are Gain.nii.gz for the gain, and B1_smooths.nii.gz which is the B1+ after smooting the whole area .

      In order to preform analysis on the samples please add to the SPGR_mask more labels of the samples, starting from 2>
       Use only slices that have Agar-Gd lables as well( before the analysis).

In order to calculate WF map, find the median value of the water samples for PD.Then normalize the PD map to the median of the water samples.





For more information, please contact:
Oshrat Shtangel: oshrat.shtangel(AT)mail.huji.ac.il
Aviv Mezer: aviv.mezer(AT)elsc.huji.ac.il
