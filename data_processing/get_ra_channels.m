function ra_channels_indices = get_ra_channels(ra_channels_path, list_name, chan_names)
% ra_channels_indices - Get Resected Channels Indices from an Excel Sheet
%
% Description:
%   The `get_ra_channels` function reads information about resected channels
%   from an Excel sheet and returns the indices of these channels in the given
%   list of channel names.
%
% Inputs:
%   - ra_channels_path: The path to the Excel file containing resected channel
%     information.
%   - list_name: The name of the list from which to read the resected channels.
%   - chan_names: A cell array with channel names to compare with the resected
%     channels.
%
% Output:
%   - ra_channels_indices: An array of indices representing the positions of
%     resected channels in the `chan_names` array.

    for i = 1:length(chan_names) 
        split_ch = split(chan_names(i), '-'); 
        chan_names(i) = split_ch(1); 
    end 

    ra_channels_indices = [];
    [~, patients] = xlsfinfo(ra_channels_path); 

    if any(strcmp(patients, list_name))
        ra_channels = readtable(ra_channels_path, 'Sheet', list_name); 

        ra_channels_names = ra_channels.resected_channels'; 
        ra_channels_indices = []; 
        for i = 1:numel(ra_channels_names)

            ra_channels_indices = [ra_channels_indices; find(strcmp(chan_names, ra_channels_names{i}))]; 

            if sum(strcmp(chan_names, ra_channels_names{i})) == 0
                disp("Did not find channel " + ra_channels_names{i})
            end 

        end
        
        ra_channels_indices = ra_channels_indices'; 

    end 

end