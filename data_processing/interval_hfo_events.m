function HFO_events = interval_hfo_events(HFOobj, bad_channels, marker, resample_frequency)

    switch marker 
        case 1
            freq_range = 'filt'; 
        case {2, 3}
            freq_range = 'filtFR'; 
    end
    
    patient_Struct_FR = build_patientStruct_from_HFOobj(HFOobj, freq_range); 
    
    HFO_events = []; 
    n_rfr = zeros(1, length(HFOobj)); 
    for i = 1:length(HFOobj)
        rfr_inds = find(HFOobj(i).result.mark == marker); 
        if ~isempty(rfr_inds) && ~any(ismember(bad_channels, i))
            n_rfr(i) = sum(rfr_inds); 
            HFO_events(i).RFR = [ ...
                                 HFOobj(i).result.autoSta(rfr_inds)*resample_frequency; ...
                                 HFOobj(i).result.autoEnd(rfr_inds)*resample_frequency  ...
                                 ]'; 
        else
            HFO_events(i).RFR = [];
        end 
    end

end