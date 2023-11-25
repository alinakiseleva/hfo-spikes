function chan_names = numerate_channels(chan_names)

    ch_num = 1; 
    for ch = 1:length(chan_names)-1
        
        split_ch_name = split(chan_names{ch+1}, '-'); 
        
        if strcmp(chan_names{ch}(isletter(chan_names{ch})), chan_names{ch+1}(isletter(chan_names{ch+1}))) ...
                 && str2num(split_ch_name{1}(max(find(isletter(split_ch_name{1})))+1:end)) ~= 1 
            chan_names{ch} = [char(string(ch_num)) chan_names{ch}]; 
        else 
            chan_names{ch} = [char(string(ch_num)) chan_names{ch}]; 
            ch_num = ch_num + 1; 
        end 
    end
    chan_names{ch+1} = [char(string(ch_num)) chan_names{ch+1}]; 
    
end

