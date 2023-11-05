function monop_ch_names = bipol_to_monopol(ch_names)
    
    monop_ch_names = {}; 
    last_el_name = ''; 
    
    for ch = ch_names
        
        monop_ch = split(ch, '-');
        if ~isempty(last_el_name) 
            if str2num(monop_ch{1}(max(find(isletter(monop_ch{1})))+1:end)) ~= str2num(last_el_num)
                monop_ch_names = [monop_ch_names, [last_el_name last_el_num]];
            end
        end 
        
        monop_ch_names = [monop_ch_names, monop_ch(1)]; 
        last_el_num = monop_ch{2}; 
        last_el_name = monop_ch{1}(1:max(find(isletter(monop_ch{1}))));
        
    end 
    monop_ch_names = [monop_ch_names, [last_el_name last_el_num]];
    
end 