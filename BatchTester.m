%% Important Notes

% Author: Vyas Gupta
% Date: August 13, 2019
% Contact at: vyas100gupta@gmail.com

% Purpose: This code is meant to automatically test code/software against
% various datasets, making code development more efficient and robust. It
% will record an error, if one were to occur and will record the time
% efficiency of code.

%% FAQ/Important Information

% Please ensure that your function to be tested does not 'clear all'/
% clearvars at the beginning.

% You must give the location of the directory containing all the data in
% the CONFIG subfunction at the bottom of this document underneath the key
% 'data_dir'. This tester expects that the structure of the folder at
% CONFIG('data_dir') is as follows:
% (+) Directory with ONLY and ALL data sets
%       (+) Data Set Directory 1
%       (+) Data Set Directory 2
%       (+) Data Set Directory 3
%       (+) ... more Data Sets as necessary
%       (-) Any number of NON-DIRECTORY files - will not be considered in
%           the program unless you configure it to do so

% Refer to the CONFIG subfunction at the bottom for the basic configurables
% of this tester.

% You must provide the name of the function that you will be testing
% in the CONFIG section under the key 'program_name'. Note that your
% BatchTester.m script copy must reside in the same directory as the
% function you intend to test.

% After going through the above steps, you should be ready to test! Please
% refer to the BatchTester Protocol for more information (if needed) at 
% '\\imph9026\b\George\Vyas_Gupta\Protocols\BatchTesterFramework.docx'.

% Please note that much of this code can be configurable for different
% functions or uses, but some editing would need to be done. For instance,
% refer to the spine segmentation project at
% 'B:\George\Vyas_Gupta\Shell-cavity\SpineProject\TestSegmentationBatch.m'
% for modifications including the addition of a dice coefficient
% calculation and a function to print all the results following testing.

%% Configuration Area

% clears the command window, variables from workspace and closes
% graphs/figures
clc
clearvars
close all

% sets value to the function you would like to run
func = CONFIG('program_name');

% finds all patient and volunteer folders within the directory for data provided
% (removes '.' and '..' directories). if there are more directories that
% you wouldn't like to include, add them like how '.' and '..' are added.
files = dir(CONFIG('data_dir'));
data_sets = files([files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..'));

% fetches configurations for the function to be tested
config = CONFIG('prog_config');

% tracks the runs that have successfully 
completed_runs = true(size(data_sets));

%% Initial logging in Performance Log

% opens up the performance log document and either looks to append or
% overwrites depending on the configurations.
fid1 = fopen(CONFIG('log_name'), CONFIG('log_behavior'));

% if the performance log cannot be opened, a warning is printed
% to the command window
if fid1 < 0
    
    disp(datetime)
    warning('Performance Log cannot be opened.')
    fid1 = 1; % outputs everything to command window so user can copy
    fid2 = 2; % if we cannot establish file descriptor, we send errors to stderr
    
else
    fid2 = fid1; % if established, we want errors printing to performance log
end

% if writing over, not appending, this includes a small header
if CONFIG('log_behavior') == 'w'
    fprintf(fid1, "Performance Log:\n");
end

% prints the header for the new testing log
fprintf(fid1, "\n********* Begin testing...: *********\n");
start_time = datetime;
fprintf(fid1, "Batch Start time: %s\n\n" , datestr(start_time));


%% Iterating through and running scripts

% starting time measurement
tic;

% iterates through all the data sets to run the function for each one
for data_set_ind = 1:length(data_sets)
    
    save('config_temp');
    
    data_set = data_sets(data_set_ind);
    
    % below try catch will run the scripts provided in the configuration
    % area log any errors that occur into a text file. outputs are found
    % within each script.
    try 
        % runs and logs in performance log

        fprintf(fid1, "Timestamp: %s Running for %s...\n" , ...
            datestr(datetime), data_set.name);
        tic;
        
        % this line up until catch scriptError can be configurable as you
        % please depending on how you would like to use the output of your
        % function
        output = func([data_set.folder '\' data_set.name], config);
 
        fprintf(fid1, "Function output stored at: %s\n", output);
        fprintf(fid1, "Time Elapsed for %s (minutes): %f\n\n", ...
            data_set.name, toc / 60);
        
    catch scriptError
        % if an error occurs, it is caught and logged in the error log 
        fprintf(fid1, "Error Caught for %s (minutes): %f\n",  ... 
            data_set.name, toc / 60); % catches time at which it fails
        
        % logs the failure
        completed_runs(data_set_ind) = false;
        save('config_temp', 'completed_runs', '-append');
        
        % display script error using a function from framework testing - we
        % either print to performance log or standard error
        
        fprintf(fid2, "\nERROR Description: %s\n\n" , matlab.unittest.diagnostics. ...
            ConstraintDiagnostic.getDisplayableString(scriptError));
        
        fprintf(fid2, "Error Location on Stack: %s\n\n" , matlab.unittest.diagnostics. ...
            ConstraintDiagnostic.getDisplayableString(scriptError.stack(1)));
    end
    
    clearvars
    close all
    
    load('config_temp');
    
end

% adds the time elapsed information
end_time = datetime; 
fprintf(fid1, "Batch End Time: %s\n" , datestr(datetime));
fprintf(fid1, "Total Time Elapsed (minutes): %f\n", ...
    seconds(end_time - start_time) / 60);

% records completed and incomplete runs
names = {data_sets.name};
fprintf(fid1, "Ran Succesfully: %s\n" , strjoin(names(completed_runs), ', '));
fprintf(fid1, "Ran Unsuccessfully (ERROR OCCURRED): %s\n", ...
    strjoin(names(~completed_runs), ', '));

fclose('all'); % closes all open files

if ~isempty(data_sets)
    delete config_temp.mat % deletes the temp config file
end

%% testing configuration subfunction

function [configuration] = CONFIG(name)
%CONFIG returns the configuration information requested
%   Using a switch to compare the name with various configurations, and
%   returns a value accordingly.

switch char(name)
    case 'log_name'
        configuration = 'performance_log.txt';
    case 'data_dir'
        configuration = 'B:\George\Vyas_Gupta\rawdata';
    case 'program_name'
        configuration = @segment_images_placeholder;
    case 'prog_config'
        configuration.a = 0;
    case 'log_behavior'
        configuration = 'w'; % 'w' for write over, 'a' for append to
    otherwise
        warning('Configuration requested not found!')
end

end