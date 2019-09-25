function [data, extra ,xform ,saveName, mrQ_struc] = mrQ_initSEIR_phantom(mrQ_struc,SEIRdir,complexFlag,useAbs,niilistFM)
%
% [data extra xform] = mrQ_initSEIR(SEIRdir,alignFlag,complexFlag,useAbs)
%
% Loads all dicom data found within 'SEIRdir' into a single matrix
% ('data'), aligns each series to the first, rearranges the 'data' matrix
% and generates a SEIR_Dat.mat file containing all the DICOM image data in
% the variable 'data' (4-D double) as well as the transform used to align
% the SEIR series in the variable 'xform'. Also in the .mat file is the
% variable 'extra' which contains 'tVec' - (1xN) the inversion times for
% each series (N) and 'T1Vec' - [1:5000]. Each of these variables are
% returned.
%
% INPUTS:
%       SEIRdir     - The directory containing your SEIR epi data,
%                     organized in seperate folders containg the raw dicom
%                     images from each of the SEIR EclcPI acquisitions.
%
%       alignFlag   - Set to 1 if you want to align the SEIR slices. - If
%                     the SEIR data has more than a few slices it is a good
%                     idea to try to align them.
%
%       complexFlag - Set to 1 if using complex numbers, else empty or 0.
%
%       useAbs      - Set to 1 if you want to use the complex the data as
%                     absolute data.
%     niilistFM       -  A list of Nii or nii gz file of the data this is
%                     usful when other operation like field mapping was done on the raw
%                     data. the niilist is a structure the size (i) is the number of
%                     different images niilist{i}='nmaeofFile' niilist{i+1}='nmae
%
% OUTPUTS:
%                     ** (Check with Aviv to make sure this is correct) **
%       data        - matrix with all the dicom data
%
%       extra:      - tVec:  [2400 1200 400 50] = Inversion time for each
%                                                 series.
%                   - T1Vec: [1x5000 double] = ?
%
%       xform       - The transform computed to align the SEIR slices to
%                     the first. Returned from relaxAlignAll
%
%       saveName    - path to the saved data file
%
% USAGE NOTES:
%       Note that this function works only with dicoms. The different
%       inversion time dicoms need to be under a directory called "data".
%       The data directory should be under the SEIR path, then the SEIRdir.
%       this function is just a  modification made by aviv mazer in june
%       2011 on  the getData.m that was written by J. Barral, M.
%       Etezadi-Amoli, E. Gudmundson, and N. Stikov, 2009
%
% EXAMPLE USAGE:
%       SEIRdir   = '/baseDir/QI/20110622_0582/SEIR_epi_1';
%       alignFlag = 1;
%
%       [data extra xform] = mrQ_initSEIR(SEIRdir,alignFlag);
%
%
% WEB RESOURCES
%       http://white.stanford.edu/newlm/index.php/Quantitative_Imaging
%
%
% (C) Stanford University, VISTA
%


%% Check INPUTS

if notDefined('SEIRdir') || ~exist(SEIRdir,'dir')
    SEIRdir = uigetdir(pwd,'Select your base data directory');
end


% Can we auto-detect the presence of complex data? and set the flag by
% defaut to something reasonable?
if notDefined('complexFlag') || isempty(complexFlag)
    complexFlag = 0;
end

if notDefined('useAbs') || isempty(useAbs)
    useAbs = 0;
end


% Set the path to the directory containing the data folders


% Set the name of the file that we will save the results to in SEIRdir.
saveName = fullfile(SEIRdir, 'SEIR_Dat');


%% Load raw DICOM data into a single structure (d)

if isfield(mrQ_struc.seir,'inputdata_seir') %infut of list of nifti file and the relevant scan parameters
    d=mrQ_input2Stuck(mrQ_struc.seir.inputdata_seir);
elseif  isfield(mrQ_struc.seir,'SEIR_raw_strac')
    load(mrQ_struc.seir.SEIR_raw_strac)
else
    d     = dicomLoadAllSeries(SEIRdir);
    xform = d(1).imToScanXform; % We don't seem to use this anywhere.
    
    
    %to do i think that the siemens and the other nifti need to be used
    %with the genral nifti case inputdata_seir
    if isfield(mrQ_struc.seir,'siemens');
        if (mrQ_struc.seir.siemens==1);
            % Get the path to each of the dicom directories (d)
            dd = genpath(SEIRdir);
            if(isempty(dd)), error(['Dicom dir "' dd '" not found or empty.']); end
            if(isunix), dd = explode(':',genpath(SEIRdir));
            else dd = explode(';',genpath(SEIRdir)); end
            
            
            % The first and last entries in d are the root and an empty matrix
            % (resp), so we get rid of those so that d is now simply the
            % directories contating the dicom/niftis.
            dd = dd(2:end-1);
            
            
            % Check to see is there is a nifti file in each of the SPGR
            % directories. If there is then status = 0 - a bit hacky.
            cmd = ['ls -R ' SEIRdir '/*/*nii.gz'];
            [status,~] = system(cmd);
            
            
            % Nifti files are in the dicom directories - load from there.
            if status == 0
                % Loop over 'd' to get the nifi paths DO THIS EARLIER - OUTSIDE OF THIS
                % STATEMENT
                for ii = 1:numel(dd)
                    ni = dir(fullfile(dd{ii},'*nii.gz'));
                    niiFiles = [dd{ii},'/' ni(1).name];
                    tmp1=readFileNifti(niiFiles);
                    d(ii).imData=tmp1.data;
                    d(ii).imToScanXform=tmp1.sto_xyz;
                    % 'niiFiles' now contains all the paths to the nifti files and can
                    % be passed into mrQ_multicoil_Weights
                end
            end
        end
    end
    
    
    
    %to use the nii file like the output of field map let insert them to ther
    %raw data structure
  if exist('niilistFM','var')
        for i=1:length(niilistFM)
            tmp=readFileNifti(niilistFM{i});
            for jj=1:d(i).dims(3);
                tmp1=rot90(tmp.data(:,:,jj));
                tmp1=flipdim(tmp1,1);
                d(i).imData(:,:,jj)=tmp1;
            end
        end
   end
    
end

% seriesDescription maybe missing so we will add it. otherwise part of code
% will brack
for ii=1:length(d)
    if isempty(d(ii).seriesDescription); d(ii).seriesDescription='SEIR';end
end


% Determine number of rows (nRows) number of Columns (nCol) and number of
% slices (nSlice) and number of series (nSeries) and initialize the data
% matrix and extra structure.
nRow    = size(d(1).imData, 1);
nCol    = size(d(1).imData, 2);
nSlice  = size(d(1).imData, 3);
nSeries = length(d);

data       = zeros(nRow,nCol,nSlice,nSeries);
extra.tVec = zeros(1,nSeries); % One series corresponds to one TI (SEIR)

% Populate 'data' with image data in 'd(k)'
for k = 1:nSeries
    dataTmp = d(k).imData;
    dataTmp = double(squeeze(dataTmp));
    
    for ss = 1:nSlice
        
        if complexFlag
            % Handle complex data...
            % Replaced complex i with 1i (11/16/2011)
            data(:,:,ss,k) = dataTmp(:,:,3 + (ss-1) * 4) ...
                + 1i * dataTmp(:,:,4 + (ss-1) * 4);
        else
            data(:,:,ss,k) = dataTmp(:,:,ss);
            % data(:,:,ss,k) = dataTmp(:,:,1+(ss-1)*4); Magnitude A.M
            % 7/8/2010: I think it is wrong and not getting the right
            % slices so i changed it. i don't get the reasoning in the
            % original code.
        end
    end
    extra.tVec(k) = d(k).inversionTime;
end




% This is where you would correct the phase of certain datapoints (if
% Prescan had been used between scans) e.g., data(:,:,3) = -data(:,:,3);
%    or data(:,:,:,3) = -data(:,:,:,3); if you have more than one slice
% !!! (:,:,1) corresponds to the first series acquired, not to the smallest
% TI !!!


%% Save the data out to a file

extra.T1Vec = 1:5000; % This can be reduced to speed up the code

% TI = extra.tVec; % Not returned or used
  for ii=1:length(extra.tVec)
      TII=extra.tVec(ii); TII=int2str(TII);
      saveName_nii=fullfile(SEIRdir, TII)
      
  dtiWriteNiftiWrapper(data(:,:,:,ii),xform, saveName_nii );
  end
save(saveName,'data','extra','xform')


end