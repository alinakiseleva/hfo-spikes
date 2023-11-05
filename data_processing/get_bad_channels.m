function [bad_channels_indices, bad_channels_names] = get_bad_channels(bad_channels_path, list_name, chan_names)
% get_bad_channels - Retrieve Indices of Bad Channels from an Excel File
%
% Inputs:
%   - bad_channels_path: The path to the Excel file containing bad channel
%     information.
%   - list_name: The name of the list within the Excel file from which to
%     read bad channel data.
%   - chan_names (optional): A cell array of channel names to match with the
%     bad channels. This parameter is used to find the indices of bad channels
%     in the provided channel names.
%
% Outputs:
%   - bad_channels_indices: A row vector containing the indices of bad
%     channels in the provided `chan_names`.
%   - bad_channels_names: A cell array of bad channel names as listed in the
%     Excel file.

    bad_channels_indices = [];
    [~, patients] = xlsfinfo(bad_channels_path); 

    if any(strcmp(patients, list_name))

        bad_channels = readtable(bad_channels_path, 'Sheet', list_name); %% read bad channels 

        bad_channels_names = bad_channels.channel_name'; 
        bad_channels_indices = []; 

        if exist('chan_names', 'var')

            for i = 1:numel(bad_channels_names)

                bad_channels_indices = [bad_channels_indices; find(strcmp(chan_names, bad_channels_names{i}))]; 

                if sum(strcmp(chan_names, bad_channels_names{i})) == 0
                    disp("Did not find channel " + bad_channels_names{i})
                end 

            end

            bad_channels_indices = bad_channels_indices'; 

        else 
            bad_channels_indices = -1; 
        end 

    else 
        bad_channels_names = []; 
    end 

end
