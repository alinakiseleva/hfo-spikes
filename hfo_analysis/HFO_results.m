%% ========================================================================
% For each patient, obtains the results based on HFO:
% 1. the distribution of rates for Ripples, FRs, and RFRs across chaneels;
% the threshold values for each channel. The SOZ and RA are also shown on
% the distribution.
% 2. the sequence of events on raw, filteredR, filteredFR signals to check
% the quality of the events.
% 3. the spatial distribution of the HFO channels.

function [] = HFO_results(resultsdir,folder,patient)

    display(['working on ', num2str(folder(patient).name)]);

    list_mat  = dir([resultsdir,'p' folder(patient).name,'/Block_samples/','*_block_*.mat']);
    list_mat = natsortfiles({list_mat.name}');
            
    if any(size(dir([resultsdir,folder(patient).name,'/Block_samples/','*_rate_thr.mat']),1)) == 0

        for se = (length(list_mat)):-1:1

            display(['loading HFOobj - ',num2str(se)]);
            
            load([resultsdir,'p' folder(patient).name,'/Block_samples/',list_mat{se}]);
            se;
                                                
            for ch = 1:length(HFOobj)

                N_m_ripple(se,ch) = length(find(HFOobj(ch).result.mark ~= 2));
                N_m_FR(se,ch)     = length(find(HFOobj(ch).result.mark ~= 1));
                N_m_RFR(se,ch)    = length(find(HFOobj(ch).result.mark == 3));
                N_m_THRFR(se,ch)  = HFOobj(ch).result.THRFR;

            end
            
        end
        
        display(['saving the rate-thr - ',folder(patient).name]);
        
        save([resultsdir,'p' folder(patient).name,'/Block_samples/','HFO_pat_',num2str(patient),'_rate_thr.mat'],...
                                              'N_m_ripple','N_m_FR','N_m_RFR','N_m_THRFR');
    else
        
        display(['loading HFOobj and rate-thr - ',folder(patient).name]);
        
        load([resultsdir,folder(patient).name,'/Block_samples/','HFO_pat_',num2str(patient),'_rate_thr.mat']);
        
        load([resultsdir,folder(patient).name,'/Block_samples/',list_mat{1}]);
                                    
    end

end

