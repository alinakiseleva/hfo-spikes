function plot_chosen_hfo_channels(HFOobj, chosen_channels)

    fs = round(HFOobj(chosen_channels(1)).result.duration / HFOobj(chosen_channels(1)).result.time(end)); 
    dt = 1/fs;
    tt = HFOobj(1).result.time;

    labels = {}; 
    pos = 1; 
    for ch = chosen_channels
        labels(pos,1) = HFOobj(ch).label;
        pos = pos+1;
    end

    figure('units', 'normalized', 'outerposition', [0 0 1 1]); 

    ax(1) = subplot(1,3,1);
        shift = 1000;
        pos = 1;
        for ch = chosen_channels
            plot(tt, detrend(HFOobj(ch).result.signal) - shift*pos, 'k')
            hold on; 
            pos = pos+1;
        end
        ylim([-shift*(pos+1) 0]);
        set(gca, 'YTick', [-shift*(pos-1):shift:-shift], ...
                 'YTicklabel', flipud(labels)); 

    ax(2) = subplot(1,3,2); 
        shift = 40; 
        pos = 1; 
        for ch = chosen_channels
            N_ev =  (find(HFOobj(ch).result.mark ~= 2));
            plot(tt, HFOobj(ch).result.signalFilt - shift*pos,'k')
            hold on; 
            for evin = N_ev
                hfo_samplesin = round(HFOobj(ch).result.autoSta(evin)*fs):round(HFOobj(ch).result.autoEnd(evin)*fs);
                plot(tt(hfo_samplesin), HFOobj(ch).result.signalFilt(hfo_samplesin) - shift*pos, 'r'); 
            end
            pos = pos+1;
        end
        ylim([-shift*(pos+1) 0]);
        set(gca, 'YTick', [-shift*(pos-1):shift:-shift], ...
                 'YTicklabel',flipud(labels)); 

    ax(3) = subplot(1,3,3); 
        shift = 20; 
        pos = 1; 
        for ch = chosen_channels
            N_ev =  (find(HFOobj(ch).result.mark ~=1));
            plot(tt, HFOobj(ch).result.signalFiltFR - shift*pos,'k')
            hold on
            for evin = N_ev
                hfo_samplesin = round(HFOobj(ch).result.autoSta(evin)*fs):round(HFOobj(ch).result.autoEnd(evin)*fs);
                plot(tt(hfo_samplesin), HFOobj(ch).result.signalFiltFR(hfo_samplesin) - shift*pos, 'r')
            end
            pos = pos+1;
        end
        ylim([-shift*(pos+1) 0]);
        set(gca, 'YTick', [-shift*(pos-1):shift:-shift], ...
                 'YTicklabel',flipud(labels)); 

    linkaxes(ax, 'x')
    addScrollbar(ax, 5);
end 