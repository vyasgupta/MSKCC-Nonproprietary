%% Usage/Documentation

% Iterates through the given folder and modifies each file's metadata such
% that there are consistent Series Instance UIDs and Study Instance UIDs
% and sequential and unique Instance Numbers. This enables the user to then
% provide this folder of DICOM images as an import folder to MIM, which
% will recognize the files as part of one series.

% This file's use comes about when import a folder into MIM originally will
% result in X seperate series rather than ONE series with X slices.

% NOTE: This code assumes that your files are ordered alphabetically.
% Otherwise, unless your instance numbers are correct, you would have to
% hand correct each image. In case they are correct, comment out the line
% that modifies instance number in the correction section.

% The structure of the folder is as follows:
% (+) data_set_dir
%  ----- (+) subfolder_to_correct
%  -------------- (-) IM001
%  -------------- (-) IM002
%  -------------- (-) IM003
%  -------------- (-) ... (alphabetically ordered slices in DICOM format)

%% User Configuration

% This section defines configuration variables. Read through the comments
% to understand what each variable requires, otherwise running this might
% not work.

% data_set_directory is the folder containing all the DICOM data for a
% patient and subfolder to connect is the specific series of data that will
% not properly import into MIM
data_set_dir = 'B:\George\Vyas_Gupta\rawdata\V8';
subfolder_to_correct = '\BHI_highR\';

% dicom_files_name is the generic naming convention used to name your dicom
% files - for instance, files in the directory could be IM0001, IM0002,
% IM0034, etc., so dicom_files_name would be 'IM*' ('*' implies to look for
% all files starting with 'IM', regardless of what follows in the file
% name)
dicom_files_name = 'IM*';

% If you would like to set various metadata of the series to something
% else, you can set that here. Otherwise, please COMMENT OUT the line.
patient_name = '4DMRI_v10';
patient_id = '.';
slice_thickness = 2;

%% Correction Code - Do not modify unless you are changing the use case

% Concatenates paths to contruct full path to directory.
directory = fullfile(data_set_dir, subfolder_to_correct);

% Fetches all DICOM files in directory.
dicom_files = dir(fullfile(directory, dicom_files_name));

% Fetches the metadata from the alphabetically first file - pieces of this 
% metadata will be copied to all other subsequent files so that all values 
% are consistent.
dicom_info = dicominfo(fullfile(directory, dicom_files(1).name));

% Creates blank container to hold image while processing (needed during
% rewrite portion)
image = zeros(dicom_info.Rows, dicom_info.Columns);

% Iterates through to each image, loads into environment and saves the
% image immediately, but with slight adjustments to the metadata so that it
% can be imported into MIM
for j = 1:numel(dicom_files)
    
    % sets the path for the jth file
    temp_file_path = fullfile(directory, dicom_files(j).name);
    
    % reads jth image and copies its metadata
    image = dicomread(temp_file_path);
    temp_dicom_info = dicominfo(temp_file_path);
    
    % changes metadata such that StudyInstanceUID and SeriesInstanceUID are
    % consistent with the first file of the series
    temp_dicom_info.StudyInstanceUID = dicom_info.StudyInstanceUID;
    temp_dicom_info.SeriesInstanceUID = dicom_info.SeriesInstanceUID;
    
    % Sets the jth file's instance number to j
    % FROM TOP SECTION - If your files are not alphabetically ordered and 
    % your instance numbers are correct, comment the below line and the 
    % code should work as intended.
    temp_dicom_info.InstanceNumber = j;
    
    % Checks if patient_name exists in the workspace. If it does, the
    % series is given that patient name.
    if exist('patient_name' , 'var') 
       temp_dicom_info.PatientName = patient_name; 
    end
    
    if exist('patient_id' , 'var')
        temp_dicom_info.PatientID = patient_id;
    end
    
    if exist('slice_thickness' , 'var') 
       temp_dicom_info.SliceThickness = slice_thickness; 
       temp_dicom_info.SpacingBetweenSlices = slice_thickness;
       temp_dicom_info.SliceLocation = j * slice_thickness;
       ipp_temp = zeros([1 3]);
       ipp_temp(2) = j * slice_thickness;
       temp_dicom_info.ImagePositionPatient = ipp_temp;
    end
    
    % writes the image with the corrected metadata to the original file
    dicomwrite(image, temp_file_path, temp_dicom_info, 'ObjectType' , ... 
        'MR Image Storage');
    
end

disp('Finished processing files.');






