% ========================================================================
% For each patient, the full analysis of the data from edf structure to the
% final HFOobj result using McGillDetector160422, which was developted by Fedele T.
% If the HFOobj result exists in the folder, for each HFO event, the function 
% will apply the threshold rule for duration.

function HFO_processing(datadir, resultsdir, folder, patient, detector, bad_channels_path, rereference_flag)

    if detector == 1
        
        display(['preprocessing of raw data - ',num2str(folder(patient).name)])
        
        patient_folder = ['p' folder(patient).name]; 
        
        % preprocessing of raw data - monopolar montage
        raw = dir([datadir,'*']);
        number = find(ismember(cat(1,{raw.name}),{folder(patient).name}));

        list_edf = dir([datadir,raw(number).name,'/Night/','*.edf']);
        list_edf = list_edf(~ startsWith({list_edf.name}, '._'));
        list_edf = natsortfiles({list_edf.name}');
        
        display(['number of raw data files is ',num2str(length(list_edf))])

        hdr = edfread([datadir,raw(number).name,'/Night/',list_edf{1}]); 
        fs = round(hdr.frequency(1),4,'significant');
        new_fs = 64; 
        label = hdr.label';
        
        disp(hdr.patientID);
        
        del_chs= []; 
        % cleaning channel names
        for ch = 1:length(label)
            
            tmp = strfind(label(ch), '?'); 
            tmp_label = label{ch}; 
            tmp_label(tmp{1}) = 'A'; 
            label{ch} = tmp_label;
            
            if ~contains(label(ch), 'EEG')
                del_chs = [del_chs; ch]; 
            end
        end
        
        
        label(del_chs) = ''; 
        
        
        label = trim_ch_names(label, {'EEG', ' ', "'", 'EDFAnnotations', '_', '?', "`"});
        label = del_repeating_ch_names(label);
        label = numerate_channels(label); 
        

        fprintf('\nDate of the recording %s', hdr.startdate); 
        for i = 1:length(list_edf)
            hdr = edfread([datadir,raw(number).name,'/Night/',list_edf{i}]); 
            fprintf('\nFile %d, time of the recording %s', i, hdr.starttime);
            fprintf('\nFile %s, sampling frequency: %d\n', list_edf{i}, round(hdr.frequency(1),4,'significant')); 
        end
        
        % for each patient, transfrom data to find sws
        if any(size(dir([datadir,raw(number).name,'/Night/','*.mat']),1)) == 0

           distalch = distalcontact(label);
           

           ref = distalch - 1; 

           
           for i = 1:length(list_edf)
               
               display(['transfrom raw data ', num2str(i)])

               [~, dataraw] = edfread([datadir,raw(number).name,'/Night/',list_edf{i}],'targetSignals',distalch);
               [~, ref_data] = edfread([datadir,raw(number).name,'/Night/',list_edf{i}],'targetSignals',ref);
               
               if rereference_flag
                    dataraw = dataraw - ref_data; 
               end 
               
               for n = 1:size(dataraw,1)                   
                    V = decimate(dataraw(n,:)',round(fs/new_fs))';
                    dataraw(n,1:length(V)) = V;
               end

               dataraw(:,length(V)+1:end) = [];

               [b,a] = butter(2,30/50);
               dataraw  = filtfilt(b,a,dataraw')';
               save([datadir,raw(number).name,'/Night/','scalpEEG',num2str(i),'_100.mat'],'dataraw');

           end
       
           % for each edf file, visualize raw data
           scalp_EEG_visualizer(datadir,raw,label(distalch)',number, new_fs)
           pause
    
        else

            if exist([datadir,raw(number).name,'/Night/','sws_time.txt'],'file') == 0
                
                distalch = distalcontact(label);
                scalp_EEG_visualizer(datadir,raw,label(distalch)',number, new_fs)
                pause
                close all
            end

        end

        sws_time = importdata([datadir,raw(number).name,'/Night/','sws_time.txt']);
        distalch = distalcontact(label);
        
        disp(sws_time)
        
        [~, patients] = xlsfinfo(bad_channels_path); 
        if any(strcmp(patients, patient_folder))
            bad_channels = readtable(bad_channels_path, 'Sheet', patient_folder);
            bad_channels = bad_channels.channel_name'; 
        else
            bad_channels = {}; 
        end
        
        % vigilant index
%         [vi, ~, sws, num_int] = vigilant_index(datadir,raw,number,list_edf,fs,distalch);

        for j = unique(sws_time(:,1))'
       
            filename = [datadir,folder(patient).name,'/Night/',list_edf{j}];
            sample = sws_time(sws_time(:,1) == j,[2,3])*fs;

            for i = 1:size(sample,1)

                if exist(fullfile(resultsdir,patient_folder,'Block_samples'),'dir') == 0

                    mkdir(fullfile(resultsdir,patient_folder,'Block_samples'));
                    plot = 1;

                else

                    plot = 0;

                end
                
                filter = filterHFO_FIR_builder_fs_Hz(fs);  
                
                [~, HFOobj, bar_hfo_plot] = HFO_analysis(filename, label, sample(i,:), filter, fs, plot, bad_channels, rereference_flag);
                
                disp(fullfile(resultsdir,patient_folder,'Block_samples', ...
                ['HFO_pat_',num2str(patient),'_block_',num2str(j),'_sample_',num2str(i)])); 
            
                save(fullfile(resultsdir,patient_folder,'Block_samples', ...
                ['HFO_pat_',num2str(patient),'_block_',num2str(j),'_sample_',num2str(i)]), ...
                'HFOobj', '-v7.3');

                saveas(bar_hfo_plot, fullfile(resultsdir,patient_folder,'Block_samples', ...
                ['HFO_pat_',num2str(patient),'_block_',num2str(j),'_sample_',num2str(i) '_bar_plot.png'])); 
                
                close(bar_hfo_plot)
            end

        end

    else
        
        display(['applying the threshold for ripple/fr - ',num2str(folder(patient).name)])
        list_mat  = dir([resultsdir,folder(patient).name,'/Block_samples/','*_thr.mat']);
        list_mat = natsortfiles({list_mat.name}');
        
        for se = 1:length(list_mat)
            
            try 
            
                display(['working on HFOobj - ',num2str(se)])
                label = importdata([resultsdir,folder(patient).name,'/hdr_label.txt']);
                load([resultsdir,folder(patient).name,'/Block_samples/',list_mat{se}]);
                se;
                
                for ch = 1:length(HFOobj)
                                        
                    HFOobj(ch) = threshold_duration(HFOobj(ch));
                    
                end
                 
            catch 
                
                continue
                
            end
            
            save(fullfile(resultsdir,patient_folder,'Block_samples',...
                  ['HFO_pat_',num2str(patient),'_number_',num2str(se),'_thr']), ...
                  'HFOobj', '-v7.3');
            
        end
        
    end

end

%% ========================================================================
% For electrodes, returns distal contact to find SWS

function distalch = distalcontact(label)

    n = length(label);
    
    for l = 1:(n-1)
        
        number = extractBefore(label{l},label{l}(isstrprop(label{l},'alpha')));
        
        if length(number(~isletter(number))) == 1

            if (~ strncmp(label{l}(1),label{l+1}(1),1))
            
                if exist('distalch','var') == 0
                
                    distalch = l;
                
                else

                    distalch = [distalch l];
                
                end

            end
            
        elseif length(number(~isletter(number))) == 2
                        
            if (~ strncmp(label{l}([1,2]),label{l+1}([1,2]),2))

              distalch = [distalch l];

            end    
                
        end

    end
    
    distalch = [distalch numel(label)];
    
end

%% ========================================================================

function [vi,out,sws,num_int] = vigilant_index(datadir,raw,number,list_edf,fs,distalch)
     
     for i = 1:length(list_edf)
                                
       [~,dataraw] = edfread([datadir,raw(number).name,'/Night/',list_edf{i}],'targetSignals',distalch);
          
       for k = 1:round(length(dataraw)/(30*fs))

           if k == 1

              interval = dataraw(:,k:30*fs);

           else
               
               if (length(dataraw) - (k-1)*30*fs)/fs >= 30
               
                  interval = dataraw(:,(30*fs*(k-1):30*fs*k));
                  
               else
                   
                   interval = dataraw(:,30*fs*(k-1):end);
                   
               end
                                                    
           end
             
           data_fft = fft(interval,fs,2)./length(interval); 
           data_fft = mean(abs(data_fft(:, 1:fs/2)));
           freq_range = fs/2*linspace(0,1,fs/2);
           bands = [0, 4; 5, 8; 8, 12; 12, 16; 16, 25];

           for b = 1:size(bands,1)

               range = freq_range >= bands(b,1) & freq_range <= bands(b,2);
               data_band(:,b) = mean(data_fft(:,range),2);

           end

           vi = (data_band(1) + data_band(2) + data_band(4))/(data_band(3) + data_band(5));

           if  exist('out','var') ~= 1 & k == 1

               out = [vi; round(length(interval)/fs)];
               num_int = i; 
           else

               out = [out [vi; round(length(interval)/fs) + out(2,end)]];
               num_int = [num_int; i]; 
           end
           
        end
              
     end
     
     outlier = out(1,(abs(out(1,:) - median(out(1,:)))/mad(out(1,:)) > 3));
     out(:,ismember(out(1,:),outlier)) = []; 
     out(1,:) = normalize(out(1,:),'range',[1 100]);
     sws = out(2,out(1,:) > (mean(out(1,:))+2*std(out(1,:)))) - 30;
     
     plot(out(2,:),out(1,:),'color',[0 0.4470 0.7410],'LineWidth',1.5);
     hold on
     plot(out(2,:),ones(1,length(out))*(mean(out(1,:))+std(out(1,:))),'k','LineWidth',1.5);
     ylabel('VI','fontsize',14);
     xlabel('Time, s','fontsize',14);
     title(raw(number).name,'fontsize',14);
     ylim([0 1.2*max(out(1,:))]); 
     
end

%% ========================================================================
% Visualization raw data to detect SWS

function scalp_EEG_visualizer(datadir,raw,scalp_contacts,number, fs)

    list = dir([datadir,raw(number).name,'/Night/','*_100.mat']);
    list = natsortfiles({list.name}');

    for j = 1:size(list)

        load([datadir,raw(number).name,'/Night/',list{j}]);
        figure('units','normalized','outerposition',[0 0 1 1])
        shift = 500;

        ax(1) = subplot(1,1,1);
        plot_ch_list_simple(dataraw,shift,scalp_contacts',64);

        timewindow = 60; 
        if size(dataraw,2) / fs < timewindow
            timewindow = round(size(dataraw,2) / fs) - 1; 
        end 
        addScrollbar(ax,timewindow);
        title(num2str(j));
        aspetta = 1;
      
    end

end

%% ========================================================================
% For channels, returns the bipolar montage and order
% input: a list of channels, which contain the numbers of electorde,
% channel; one or two letters of an electode (for example, '1PA1','1PA2',etc).
% output: a list of bipolar chanels, the order of the bipolar montage
function [bipol_label, bipol] = label_bipolar(label)

    n = length(label);

    change = [];

    for l = 1:(n-1)
        if ~strcmp(label{l}(isletter(label{l})), label{l+1}(isletter(label{l+1}))) 
            change = [change l];
        end
    end

    bipol=[(1:n-1)' (1:n-1)'+1];
    bipol(change,:) = [];

    bipol_label = {}; 

    for bipol_names = bipol'

        bipol_label = [bipol_label; ...
                       strjoin([label(bipol_names(1)), ...
                                label{bipol_names(2)}(find(isletter(label{bipol_names(2)}), 1, 'last')+1:end)], ...
                                '-')]; 

    end 
end 

%% ========================================================================
% For each edf file, transforms monopolar data to bipolr; removes the
% bad-channels; extacts HFO events as HFOobj for all channels based on 
% McGillDetector160422

function [data_bip, HFOobj, bar_hfo_plot] = HFO_analysis(filename,label,sample,filter,fs,plot_flag,bad_chs, rereference_flag)
    
%% extraction data

         cfg            = [];
         cfg.continuous = 'yes';
         cfg.trl        = [sample 0];
         cfg.dataset    = filename;
         
         cfg.channel = 'EEG*'; 
         
         data_baseline  = ft_preprocessing(cfg);
         hdr.label      = data_baseline.label';
         dataraw        = data_baseline.trial{1};
         clear data_baseline                

%% creation of bipolar data
         tmp_label = label; 
         if rereference_flag == 1
             [label,bipol] = label_bipolar(label);             
             for k = 1:length(bipol) 
                 data_bip.x(k,:) = dataraw(bipol(k,1),:) - dataraw(bipol(k,2),:); 
             end
         else 
             data_bip.x = dataraw(1:length(label), :); 
         end
         data_bip.label = label;
        
%% bad channels
        
       if plot_flag == 1
           
            close all
            chs = 1:length(label);
            figure('units','normalized','outerposition',[0 0 1 1]);
            shift = 900;
            ax(1) = subplot(1,1,1);
            plot_ch_list_simple(detrend(data_bip.x(chs,1:300*fs)')',shift,data_bip.label(chs),fs)    
            addScrollbar(ax, 30);
            pause
          
       end
       
       disp(bad_chs)
       bad_chs = find(ismember(label,bad_chs));

%% HFO extraction
        
        p.fs          = fs; % SAMPLING Frequency
        p.duration    = length(data_bip.x); % HOW MANY SECONDS OF DATA TO ANALYZE
        p.filter      = filter;
        p.hp          = 80; % high pass ripple
        p.hpFR        = 250; % high pass FR
        p.lp          = 500; % low pass FR
        dt            = 1/p.fs;

        for ch = 1:length(data_bip.label)
            
            if ~ismember(ch, bad_chs)
                HFOobj(ch).result = McGillDetector160422(data_bip.x(ch,:),p);
            else 
                HFOobj(ch).result.signal = data_bip.x(ch,:); 
                HFOobj(ch).result.signalFilt = 0; 
                HFOobj(ch).result.signalFiltFR = 0;
                HFOobj(ch).result.THR = 0;
                HFOobj(ch).result.THRfiltered = 0; 
                HFOobj(ch).result.baselineLength = 0;
                HFOobj(ch).result.env = 0; 
                HFOobj(ch).result.autoSta = NaN;
                HFOobj(ch).result.autoEnd = NaN; 
                HFOobj(ch).result.mark = NaN; 
                HFOobj(ch).result.THRFR = 0;
                HFOobj(ch).result.THRfilteredFR = 0;
                HFOobj(ch).result.envFR = 0;
            end 
                
            HFOobj(ch).label       = data_bip.label(ch);
            HFOobj(ch).result.time = dt:dt:dt*length(data_bip.x);
            HFOobj(ch)             = threshold_duration(HFOobj(ch));
            
        end
        
        for ch = 1:length(data_bip.label)
            N_m_ripple(ch) = length(find(HFOobj(ch).result.mark ~= 2));
            N_m_FR(ch)     = length(find(HFOobj(ch).result.mark ~= 1));
            N_m_RFR(ch)    = length(find(HFOobj(ch).result.mark == 3));
            N_m_THRFR(ch) =  (HFOobj(ch).result.THRFR); 
        end

        bar_hfo_plot = figure('units','normalized','outerposition',[0 0 1 1]); 
        subplot(411), bar(N_m_ripple)
        title('Ripples')
        xtickangle(90); 
        set(gca,'xtick',1:1:length(label)); 
        set(gca,'xticklabel',label,'fontsize',12); 
        if ~isempty(bad_chs)
            ticklabels = get(gca,'xticklabel');
            for ii = bad_chs'  %%  channels marked as bad will have red labels 
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
            for ii = bad_chs'  %%  channels marked as bad will have red labels 
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
            for ii = bad_chs'  %%  channels marked as bad will have red labels 
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
            for ii = bad_chs'  %%  channels marked as bad will have red labels 
                ticklabels{ii} = ['\color[rgb]{.6350,.0780,.1840}' ticklabels{ii}]; 
            end 
            set(gca, 'xticklabel', ticklabels);
        end

        hold on
        subplot(414), plot([1:length(data_bip.label)], repmat([5], length(data_bip.label), 1)')
        

end

%% ========================================================================
% For each channel, removes events, which exceed the duration's
% threshold; returns a new structure - HFOobj with cleaned sequence of the events

function HFOobj = threshold_duration(HFOobj)
   
   duration = abs(HFOobj.result.autoSta - HFOobj.result.autoEnd);
   
   for event = 1:length(duration)
       
       if HFOobj.result.mark(event) ~= 2 
           
           if duration(event) >= 0.15
               
               HFOobj.result.autoSta(event) = NaN;
               HFOobj.result.autoEnd(event) = NaN;
               HFOobj.result.mark(event) = NaN;
               
           else
               
               continue
               
           end
           
       elseif HFOobj.result.mark(event) == 2
           
           if duration(event) >= 0.05
               
               HFOobj.result.autoSta(event) = NaN;
               HFOobj.result.autoEnd(event) = NaN;
               HFOobj.result.mark(event) = NaN;
               
           else
               
               continue
               
           end
           
       end
       
   end
   
   HFOobj.result.autoSta = HFOobj.result.autoSta(~isnan(HFOobj.result.autoSta));
   HFOobj.result.autoEnd = HFOobj.result.autoEnd(~isnan(HFOobj.result.autoEnd));
   HFOobj.result.mark = HFOobj.result.mark(~isnan(HFOobj.result.mark));

end
