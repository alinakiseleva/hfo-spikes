function [monopolar_ch_names, use_channels] = bipolar_to_monopolar_ch_names(bipolar_chan_names)
% bipolar_to_monopolar_ch_names - Convert Bipolar Channel Names to Monopolar
%
%   [monopolar_ch_names, use_channels] = bipolar_to_monopolar_ch_names(bipolar_chan_names)
%
% Description:
%   The `bipolar_to_monopolar_ch_names` function is used to convert a list of
%   bipolar channel names to a list of monopolar channel names. 
%
% Input:
%   - bipolar_chan_names: A cell array of bipolar channel names.
%
% Output:
%   - monopolar_ch_names: A cell array of monopolar channel names, derived from the
%     bipolar channel names.
%   - use_channels: A binary array indicating which channels to use. A value of 1
%     represents a channel to use, and 0 indicates exclusion.    

    monopolar_ch_names = []; 

    if size(bipolar_chan_names, 1) < size(bipolar_chan_names, 2)
        bipolar_chan_names = bipolar_chan_names'; 
    end 

    Nch = length(bipolar_chan_names); 

    use_channels = []; 
    prev_ch = ''; 
    prev_num = ''; 
    flag = 1; 
    
    for i = 1:Nch 

        ch_name = strsplit(bipolar_chan_names{i}, '-');

        first_name = ch_name{1}; 
        letters = isletter(first_name);

        base_name = first_name(1:max(find(letters)));
        
        if isempty(strfind(ch_name{2}, base_name))
            second_name = [base_name ch_name{2}];
            second_num = ch_name{2}; 
        else 
            second_name = [ch_name{2}]; 
            ch_name{2}(strfind(ch_name{2}, base_name):strfind(ch_name{2}, base_name)+length(base_name)-1) = '';
            second_num = ch_name{2}; 
        end 
        monopolar_ch_names = [monopolar_ch_names; string(first_name); string(second_name)]; 
        
        first_num  = first_name(max(find(letters))+1:end);
        
        
        if isempty(prev_ch) && isempty(prev_num)
            use_channels = [use_channels; flag]; 
            prev_ch = base_name; 
            prev_num = second_num; 
            if flag == 1 
                flag = 0; 
            else
                flag = 1; 
            end
            
        elseif strcmp(prev_ch, base_name) && strcmp(prev_num, first_num) % same electrode and same el number  
            prev_num = second_num; 
            use_channels = [use_channels; flag]; 
            if flag == 1 
                flag = 0; 
            else
                flag = 1; 
            end
            
        elseif ~strcmp(prev_ch, base_name) || ~strcmp(prev_num, first_num) % new electrode or not same el num 
            flag = 1; 
            use_channels = [use_channels; flag]; 
            prev_ch = base_name; 
            prev_num = second_num; 
            if flag == 1 
                flag = 0; 
            else
                flag = 1; 
            end
            
        else 
            error('Wrong chan names type'); 
        end
    end 
    monopolar_ch_names = unique(monopolar_ch_names, 'stable'); 
end
    

