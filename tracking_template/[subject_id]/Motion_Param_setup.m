%% Parameters Setup
% For creating file structure and parameters files in 4_Markerless_tracking
% Created 8/5/19 by Zachary Glenn
% Last edited 8/5/19 by Zachary Glenn

% Notes:
%   Trial file names must end in '_C1.cine' or  '_C2.cine'
%   Script must be run from the 4_Markerless_tracking folder

% Inputs (required):
%   Distortion-corrected trial tiff stacks
%   CT voxel sizes from [subject_ID]_CTdataInput_for_mtwtesla.xlsx
%   SID values from 3_Marker_tracking/Parameters.csv
%   Parameters_template.csv

% Outputs:
%    Folder for each trial within 4_Markerless_tracking
%    Scapula folder and Humerus folder for each trial
%    Complete parameters files for both bones for each trial

% Steps:
%   1) Read Trial file names from fluoro tiff stacks
%   2) Read in voxel sizes from [Subject_ID]_CTdataInput_for_mtwtesla.xlsx
%   3) Loop over trials
%       i)   Create folder for trial
%       ii)  Create Humerus folder with parameters file
%       iii) Create Scapula folder with parameters file

%% 1) Read in trial file names

% Check that current folder is correct
if ~endsWith(pwd,'4_Markerless_tracking')
    error('Current folder is incorrect. Navigate to 4_Markerless_tracking.')
end

% Read trial names off tiff stacks
cd('..\1_Cines_Dist_Corr')
TiffFiles = dir('*.tif');
clear('TrialNames') % Pre-existing TrialNames variable causes issues if not erased
CreatedTrialNames = false;
for n = 1:length(TiffFiles)
    if (~endsWith(TiffFiles(n).name,'_C2.tif')...
            && ~contains(TiffFiles(n).name,'Calb')...
            && ~contains(TiffFiles(n).name,'Move'))
        if ~CreatedTrialNames
            TrialNames{1} = erase(TiffFiles(n).name,'_C1.tif');
            CreatedTrialNames = true;
        else
            TrialNames{end+1} = erase(TiffFiles(n).name,'_C1.tif'); %#ok<SAGROW>
        end
    end
end

%% 2) Read in voxel sizes and SIDs

cd('..')
ExcelFiles = dir('*.xlsx');

% Look for excel file with correct name, read voxel sizes from it
FoundCtDataFile = false;
for n = 1:length(ExcelFiles)
    if contains(ExcelFiles(n).name,'CTdata_Input_for_mtwtesla')
        CtDataFile = ExcelFiles(n).name;
        VoxelSizeHumerus = xlsread(CtDataFile,'D8:F8');
        VoxelSizeScapula = xlsread(CtDataFile,'G8:I8');
        FoundCtDataFile = true;
        break
    end
end
if ~FoundCtDataFile
    error('CT data file not found')
end

cd('./3_Marker_tracking')
RedSID = xlsread('Parameters.csv','B5:B5');
GreenSID = xlsread('Parameters.csv','B13:B13');
cd('..')

%% 3) Loop over trials

% Create paths to Humerus and Scapula CT tiff stacks
CtFileHumerus = cellstr('..\..\..\..\CT\for_mtwtesla\Humerus\Humerus.tif');
CtFileScapula = cellstr('..\..\..\..\CT\for_mtwtesla\Scapula\Scapula.tif');

% Create paths to C1 and C2 tiff stacks
RedMovieFileNames = strcat('..\..\..\1_Cines_Dist_Corr\',TrialNames,'_C1.tif');
GreenMovieFileNames = strcat('..\..\..\1_Cines_Dist_Corr\',TrialNames,'_C2.tif');

cd('.\4_Markerless_tracking')
for n = 1:length(TrialNames)
    
    % Check for pre-existing trial folder
    % If one doesn't exist, make one
    if ~exist(strcat('.\',TrialNames{n}),'dir')
        mkdir(TrialNames{n})
        addpath(strcat('.\',TrialNames{n}))
    end
    cd(TrialNames{n})
    
    % Check for pre-existing Humerus folder
    % If one doesn't exist, make one
    if ~exist('.\Humerus','dir')
        mkdir('Humerus')
        addpath('Humerus')
    end
    cd('Humerus')
    
    % Check for pre-existing parameters file
    % If one doesn't exist, create it and populate necessary fields
    if ~exist('.\Parameters.csv','file')
        copyfile('.\..\..\Parameters_template.csv','Parameters.csv')
        xlswrite('Parameters.csv',RedMovieFileNames(n),'B18:B18')
        xlswrite('Parameters.csv',GreenMovieFileNames(n),'B35:B35')
        xlswrite('Parameters.csv',CtFileHumerus,'B2:B2')
        xlswrite('Parameters.csv',VoxelSizeHumerus,'B4:D4')
        xlswrite('Parameters.csv',RedSID,'B23:B23')
        xlswrite('Parameters.csv',GreenSID,'B40:B40')
    end
    
    % Check for pre-existing Scapula folder
    % If one doesn't exist, make one
    cd('..')
    if ~exist('.\Scapula','dir')
        mkdir('Scapula')
        addpath('Scapula')
    end
    cd('Scapula')
    
    % Check for pre-existing parameters file
    % If one doesn't exist, create it and populate necessary fields
    if ~exist('.\Parameters.csv','file')
        copyfile('.\..\..\Parameters_template.csv','Parameters.csv')
        xlswrite('Parameters.csv',RedMovieFileNames(n),'B18:B18')
        xlswrite('Parameters.csv',GreenMovieFileNames(n),'B35:B35')
        xlswrite('Parameters.csv',CtFileScapula,'B2:B2')
        xlswrite('Parameters.csv',VoxelSizeScapula,'B4:D4')
        xlswrite('Parameters.csv',RedSID,'B23:B23')
        xlswrite('Parameters.csv',GreenSID,'B40:B40')
    end
    
    cd('..\..')
end