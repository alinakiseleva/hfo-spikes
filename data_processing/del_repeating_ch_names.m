function chan_names = del_repeating_ch_names(chan_names) 
% del_repeating_ch_names - Remove repeating prefixes in channel names
%
% Syntax:
%   chan_names = del_repeating_ch_names(chan_names)
%
% Description:
%   The `del_repeating_ch_names` function processes a cell array of channel names
%   and removes repeating prefixes.
%
% Inputs:
%   - chan_names: A cell array of channel names.
%
% Outputs:
%   - chan_names: A cell array of channel names with repeating prefixes removed.
%
% Example:
%   chan_names = {'EEG-FP1-FP2', 'EEG-TP7-TP8', 'EEG-FP1-TP7'};
%   chan_names = del_repeating_ch_names(chan_names);

    for i = 1:length(chan_names)
        parts = split(chan_names{i}, '-'); 
        if length(parts) > 1
            base_name = parts{1}(1:max(find(isletter(parts{1})))); 
            parts{2}(strfind(parts{2}, base_name):length(base_name)) = ''; 
            chan_names{i} = [parts{1} '-' parts{2}]; 
        end
    end 
    
end 