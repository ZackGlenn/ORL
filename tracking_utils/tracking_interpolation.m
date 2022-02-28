%% Documentation

% Script for using cubic interpolation on tracking solutions
% Created 8/30/21 by Zachary Glenn
% Last modified 2/28/22 by Zachary Glenn

% Inputs:
% -------
% 1) The solution file to interpolate. Should be a csv file in the format
% produced automatically by mtwtesla. Provide the path to the file as a
% character vector.
%
% 2) The name of the file to output to, which must be a csv file. Provide
% the output filename as a characer vector.

% Outputs:
% --------
% 1) A CSV file containing the cubic interpolation of the chosen solution
% file. The output file should be fully ready for mtwtesla to read - just
% paste it in the MTW_Solutions folder and select it from mtwtesla's
% dropdown menu. If mtwtesla crashes after selecting the file, try using
% excel to convert it from a standard CSV file to a CSV (MS-DOS) file. If
% it still crashes, make sure the input file is in exactly the format
% generated automatically by mtwtesla.

% Notes - the following represents my best understanding as of the time of
% writing, some of which is an educated guess on my part. Unfortunately,
% Tesla does not provide much documentation explaining its solution files.
% ------------------------------------------------------------------------
%
% 1) Cubic interpolation:
%
% The solutions created by this script should not be blindly trusted. As
% always, the 'garbage in, garbage out' rule applies - the interpolation is
% only as good as the samples you provide it. It is also possible that the
% true solution varies more quickly than the cubic interpolation can
% capture using the data you provide it. Always check to make sure that the
% interpolated solution accurately reflects the data seen in tracking.
%
% In order to interpolate the rotation values, they are converted to a quaternion. This 
% avoids certain pitfalls with interpolating euler angles directly. I assumed the roll, 
% pitch, and yaw values produced by tesla correspond to rotations about the X, Y, and Z 
% axes respectively. This appears correct judging by the way models are manipulated in 
% tesla, but I cannot guarantee it's correctness. Additionally, it is possible that 
% tesla's left-handed coordinate system breaks some assumption made by MATLAB's 
% quaternion code. Here I have assumed that the internal consistency of this script 
% (euler angles in, and euler angles out) mitigates any such problem.
%
% 2) The MtwTesla solution file
% ------------------------------
% A solution file needs the following columns for tesla to read it and
% show the plot window correctly:
%   Frame, X, Y, Z, Roll, Pitch, Yaw, GreenCorr, RedCorr CombCorr,
%   Iterations, RunMsec
%
% The Frame column lists all of the frames that have solutions. This script
% will create solutions wherever they're missing between the first tracked
% frame of the input and the last tracked frame of the input.
%
% The X, Y, Z, Roll, Pitch, and Yaw columns contain the kinematic data of
% the bone for each solved frame. This section and the Frame column are
% the important parts of what the script generates - the other columns are
% only created so that Tesla will read and display the file correctly.
%
% The GreenCorr, RedCorr, and CombCorr columns are correlation values used
% by tesla for the autotracking features. While this script does perform
% interpolation for these values, they should not be regarded as
% trustworthy - they usually vary too quickly for the interpolation to work
% correctly. The innacuracy is of minimal concern, because Tesla
% will automatically generate the correct values for a given frame whenever
% a new solution is saved for that frame.
%
% The Iterations and RunMsec columns are for data related to Tesla's
% autotracking - the number of iterations performed and the amount of time
% it took to perform them, respectively. In both cases, Tesla uses the
% value -1 to indicate that autotracking wasn't used for a given frame. For
% simplicity's sake, this script uses -1 for all frames.

%% Main script

% clear MATLAB's workspace to avoid potential problems with pre-existing
% variables
clear

% ask the user for the name of the solution file to interpolate and the
% name of the file to output to
data_filename = input('Enter the name of the data file ');
output_filename = input('Enter the name for the output file ');

% perform cubic interpolation on the provided data
output_table = interpolate_tracking(data_filename);

% output the results to a csv file
writetable(output_table, output_filename)

%% interpolation function

function out = interpolate_tracking(datafile)
    % read the input file, separating it into numeric fields and text fields
    [tracked_data, txt] = xlsread(datafile);

    % extract the tracked frames, the corresponding solutions, and the column
    % headers
    tracked_frames = tracked_data(:, 1);
    tracked_soln = tracked_data(:, 2:10);
    column_names = txt(1, 1:12);

    % determine the frames which need interpolation
    interp_frames = tracked_frames(1):tracked_frames(end);

    % separate the position, rotation, and correlation data so the rotation data can be 
    % handled separately
    tracked_pos = tracked_soln(:, 1:3);
    tracked_rot = tracked_soln(:, 4:6);
    tracked_cor = tracked_soln(:, 7:9);

    % convert the roll, pitch, and yaw values to quaternions so the interpolation will 
    % be correct
    tracked_quat = eul2quat(tracked_rot, "XYZ");

    % perform interpolation
    interp_pos = interp1(tracked_frames, tracked_pos, interp_frames, 'pchip');
    interp_quat = interp1(tracked_frames, tracked_quat, interp_frames, 'pchip');
    interp_cor = interp1(tracked_frames, tracked_cor, interp_frames, 'pchip');

    % convert the rotation back into roll, pitch, and yaw
    interp_rot = quat2eul(interp_quat, "XYZ");

    % collect the interpolated data into a single matrix
    interp_soln = [interp_pos, interp_rot, interp_cor];

    % create an vector of -1's to fill the Interations and RunMsec columns
    flags = -ones(size(interp_frames))';

    % return a table representing the completed output file
    out = array2table(...
        [interp_frames' interp_soln flags flags], 'VariableNames', column_names ...
    );
end
