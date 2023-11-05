function spk_order = get_spike_order(my_rast, chan_names, seq_win)
% get_spike_order - Get Spike Order from a Raster Plot
%
% Description:
%   The `get_spike_order` function calculates the spike order based on a raster
%   plot and associated channel names. It extracts the order of channels where
%   spikes occur within a specified time window.
%
% Inputs:
%   - my_rast: A binary matrix representing a raster plot. Rows correspond to
%     time points, and columns represent channels.
%   - chan_names: A cell array containing the names of channels, corresponding
%     to the columns of the `my_rast` matrix.
%   - seq_win: The time window (in samples) used for calculating spike order.
%
% Output:
%   - spk_order: A cell array containing spike order information.

    locs = cell(1, length(chan_names));
    ovrlp_samples = 0;
    nwins = floor((size(my_rast,1) - seq_win) / (seq_win - ovrlp_samples)) + 1;
    win_ind = nan(nwins, 2);
    win_ind(:) = [((1 : nwins) - 1) * (seq_win-ovrlp_samples) + 1, ...
                  ((1 : nwins) * (seq_win - ovrlp_samples) + ovrlp_samples)]; 
    win_ind = mean(win_ind, 2); 
    spk_chan_thresh = 2;
    
    for l = 1 : length(chan_names) 
        locs{l} = find(my_rast(:,l));
    end
    
    [win_spk_count, ~] = buffer(full(sum(my_rast, 2)), seq_win, ovrlp_samples);
    chans_list = chan_names;
    
    win_spk_count = sum(win_spk_count);
    mult_spk_ind = win_ind(win_spk_count >= spk_chan_thresh); 
    
    if ~isempty(mult_spk_ind)
        
            dist_cent = nan(length(locs), length(mult_spk_ind));
            loc_ind = nan(length(locs), length(mult_spk_ind));

            for l = 1:length(mult_spk_ind)

                [a, b] = cellfun(@(x) min(abs(x - mult_spk_ind(l))), locs', 'uniformoutput', 0);
                a(cellfun(@isempty, a)) = {nan};
                mask = cellfun(@(y) ~isempty(y), b);
                b(mask);
                dist_cent(:,l) = cell2mat(a);
                loc_ind(mask,l) = cell2mat(cellfun(@(x, y) x(y), locs(mask)', b(mask), 'uniformoutput', 0));

            end
        
            loc_ind(dist_cent >= seq_win / 2) = NaN;
           
            if any(sum(~isnan(loc_ind), 1) >= 2) 
                [loc_ind_sort, rank_list] = sort(loc_ind);
                chans_list_rep = repmat(chans_list, 1, length(mult_spk_ind));
                chans_list_rep = chans_list_rep(rank_list);
                chans_list_rep(isnan(loc_ind_sort)) = {''};
               
                temp1 = chans_list_rep(any(~cellfun('isempty', chans_list_rep), 2),:);
                temp2 = [loc_ind_sort(1, :); diff(loc_ind_sort(any(~cellfun('isempty', chans_list_rep), 2), :))];
                
                S = cell(size(temp1, 1), size(temp1, 2) * 2);
                S(:, 1 : 2 : 2 *size(temp1, 2) - 1) = temp1;
                S(:, 2: 2 : 2 * size(temp1, 2)) = num2cell(temp2); 
            else
                S = [];            
            end
    else
            S = [];
    end
    spk_order{5} = S;
    spk_times = locs';
end 