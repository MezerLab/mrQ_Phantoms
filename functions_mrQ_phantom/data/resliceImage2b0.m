function resliceImage2b0(imageFile,dtDir)
% resliceROI2b0 reslices a given ROI to fit the b0 image in terms of its
% bounding box, and saves it in the ROIs folder.
% roiFile is a nifti format ROI in ACPC.
% dtDir is the directory of the dt files and folders.

b0 = readFileNifti(fullfile(dtDir, '/bin/b0.nii.gz'));%%put the image with the lower resolution(that image you want the second image to be with the same resolotion as this)

im = readFileNifti(imageFile);%pus the image with the higher resolotuion- or the image you want to resample

acpcXform = b0.qto_xyz;

bbDat = round(mrAnatXformCoords(acpcXform, [1 1 1; size(b0.data(:,:,:,1))]));

dwOutMm = b0.pixdim;

interpParams = [7 7 7 0 0 0]; % b-spline interpolation

[im,newAcpcXform] = mrAnatResliceSpm(im.data, im.qto_ijk, bbDat, dwOutMm, interpParams, 0);
im( isnan(im) | im <0 ) = 0;


[~,filename] = fileparts(imageFile);
dtiWriteNiftiWrapper(im, b0.qto_xyz, fullfile(dtDir,'bin', [filename(1:end-4), '_2DTI.nii.gz']));

end