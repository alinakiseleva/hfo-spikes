function ch_inds = get_ch_indexes(full_list, chan_names)
% GET_CH_INDEXES Get the indices of channels from a list based on channel names.
%
% Syntax:
%   ch_inds = get_ch_indexes(fullList, chan_names)
%
% Description:
%   The `get_ch_indexes` function finds the indices of channels in `full_list`
%   based on their names provided in the `chan_names` cell array.
%
% Input:
%   - fullList: A cell array containing a list of channel names.
%   - chan_names: A cell array of channel names to search for in `full_list`.
%
% Output:
%   - ch_inds: An array of indices of the channels found in `full_list`.
    
    if size(chan_names, 1) > size(chan_names, 2)
        chan_names = chan_names'; 
    end

    ch_inds = [];       
  
    for chan_name = chan_names               
        ch_inds = [ch_inds; find(strcmp(chan_name, full_list))];      
    end   
    
end     