function aligned_spikes = get_aligned_spikes(patientStruct, spikes, delta, align_interval)
% get_aligned_spikes - Align Detected Spikes in EEG Data
%
% Syntax:
%   aligned_spikes = get_aligned_spikes(patientStruct, spikes, delta, align_interval)
%
% Description:
%   This function aligns detected spike events in EEG data to improve the accuracy 
%   of spike detection. It operates based on the characteristics of peaks 
%   in a specified time window around each spike.
%
% Input:
%   - patientStruct: A structure containing iEEG data. 
%
%   - spikes: An array of detected spike positions. Each row should represent a
%     spike event, with the first column indicating the channel number and the
%     second column indicating the original time of the spike in samples.
%
%   - delta: A threshold value used for peak detection.
%
%   - align_interval: The alignment interval in samples. It defines the
%     time window around each spike within which peak analysis and alignment
%     will occur. 
%
% Output:
%   - aligned_spikes: An array of aligned spike positions. Each row represents a
%     spike event, with the first column indicating the channel number, and the
%     second column indicating the adjusted time of the spike in samples.

    aligned_spikes = spikes; 
    
    Fs = patientStruct.epochsList.Fs; 
    
    for i = 1:length(aligned_spikes)
        
        if spikes(i,2)-align_interval > 0 && spikes(i,2)+align_interval < length(patientStruct.epochsList.X_raw)
            
            interval = patientStruct.epochsList.X_raw(spikes(i, 1), spikes(i, 2) - align_interval : spikes(i,2) + align_interval);
            interval = custom_lowpass(interval, 40, Fs); 
    
            [maxtab, mintab] = peakdet(interval, delta);
    
            peak = align_interval; 
    
            if ~isempty([maxtab; mintab])
                
                sequence = sortrows([maxtab; mintab], 1);
       
                % amplitude difference 
                sequence(1:end-1,3) = abs(sequence(1:end-1, 2) - sequence(2:end, 2)); % find diff in amplitude with the next peak   
                sequence(sequence(:,3)<mean(sequence(:,3)), 3) = 0; % clear peaks with diff smaller than mean  
    
                if ~all(sequence(:, 3) == 0)
                    
                    % find cluster 
                    temp_seq = cumsum(sequence(:,3)); 
                    [tmp,idx] = sort(temp_seq);
                    idp = diff(tmp) > 0;
                    seq_ind = idx([true;idp]&[idp;true])'; 
    
                    % if no sequence left - take max amplitude change 
                    if isempty(seq_ind)
                        peak = sequence(find(sequence(:,3) == max(sequence(:,3))), 1); 
    
                    % check if one complete sequence left and take first peak from it 
                    elseif  length(seq_ind) == length([seq_ind(1):seq_ind(end)]) && all(seq_ind == [seq_ind(1):seq_ind(end)]) 
                        peak = sequence(seq_ind(1), 1); 
    
                    else % if more than one sequence -> threshold by seq time difference 
    
                        sequence(sequence(:,3) < mean(sequence(:,3)), 3) = nan;
                        sequence(1:end-1,4) = abs(sequence(1:end-1, 1) -sequence(2:end, 1)); % time difference 
                        sequence(sequence(:,4) > mean(sequence(:,4)), 4) = nan; 
                        sequence(:,3) = sequence(:,3) + sequence(:,4); 
    
                        if ~all(isnan(sequence(:, 3)))
                            peak = sequence(~isnan(sequence(:, 3)), 1);
                            peak = peak(1,1); 
                        end 
                    end 
                end 
            end         
            aligned_spikes(i, 2) = spikes(i,2) - align_interval + peak; 
        end 
    end 

end 
