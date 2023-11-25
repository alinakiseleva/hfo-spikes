function bar_hfo_plot = build_hfo_bar(N_m_ripple, N_m_FR, N_m_RFR, N_m_THRFR, n_recs, label, bad_chs)
    
    if size(label, 2) > size(label, 1) 
        label = label'; 
    end 

    N_m_ripple = sum(N_m_ripple, 1) / n_recs; 
    N_m_FR = sum(N_m_FR, 1)/ n_recs; 
    N_m_RFR = sum(N_m_RFR, 1)/ n_recs; 
    N_m_THRFR = mean(N_m_THRFR, 1); 

    N_m_ripple(bad_chs)= 0;
    N_m_FR(bad_chs)= 0;
    N_m_RFR(bad_chs)= 0;
    N_m_THRFR(bad_chs)= 0;
    
    bar_hfo_plot = figure('units','normalized','outerposition',[0 0 1 1]); 

    subplot(411), bar(N_m_ripple)
    title('Ripples')
    xtickangle(90); 
    set(gca,'xtick',1:1:length(label)); 
    set(gca,'xticklabel',label,'fontsize',12); 
    if ~isempty(bad_chs)
        ticklabels = get(gca,'xticklabel');
        for ii = bad_chs'  
            ticklabels{ii} = ['\color[rgb]{.6350,.0780,.1840}' ticklabels{ii}]; 
        end 
        set(gca, 'xticklabel', ticklabels);
    end

    subplot(412), bar(N_m_FR)
    title('Fast Ripples')
    xtickangle(90); 
    set(gca,'xtick',1:1:length(label)); 
    set(gca,'xticklabel',label,'fontsize',12); 
    if ~isempty(bad_chs)
        ticklabels = get(gca,'xticklabel');
        for ii = bad_chs'  
            ticklabels{ii} = ['\color[rgb]{.6350,.0780,.1840}' ticklabels{ii}]; 
        end 
        set(gca, 'xticklabel', ticklabels);
    end

    subplot(413), bar(N_m_RFR)
    title('Ripples + Fast Ripples')
    xtickangle(90); 
    set(gca,'xtick',1:1:length(label)); 
    set(gca,'xticklabel',label,'fontsize',12); 
    if ~isempty(bad_chs)
        ticklabels = get(gca,'xticklabel');
        for ii = bad_chs'  
            ticklabels{ii} = ['\color[rgb]{.6350,.0780,.1840}' ticklabels{ii}]; 
        end 
        set(gca, 'xticklabel', ticklabels);
    end

    subplot(414), bar(N_m_THRFR)
    title('Threshold')
    xtickangle(90); 
    set(gca,'xtick',1:1:length(label)); 
    set(gca,'xticklabel',label,'fontsize',12); 
    if ~isempty(bad_chs)
        ticklabels = get(gca,'xticklabel');
        for ii = bad_chs'  
            ticklabels{ii} = ['\color[rgb]{.6350,.0780,.1840}' ticklabels{ii}]; 
        end 
        set(gca, 'xticklabel', ticklabels);
    end

    hold on
    subplot(414), plot([1:length(label)], repmat([5], length(label), 1)')
    ylim([0 7])

    han = axes(bar_hfo_plot,'visible','off'); 
    han.Title.Visible='on';
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'Events (per minute)');
    xlabel(han,'Electrodes');


end 
                