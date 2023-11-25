% ===================================================================================
% *** Function DETECTOR MCGILL

function [sig ] = McGillDetector160422(data, p)
p.limitFrequencyST = p.lp;
p.channel_name = 'XXX';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% reading the signals
display(['%%%%%%%%%%%%% START ANALYSIS ' datestr(now,'dd-mm-yyyy HH-MM-SS') ' %%%%%%%%%%%%%%%%'])
display(' ')

%% read visual markings and filter data
sig=struct;

display(['Length Extracted Data = ' num2str(length(data))])

sig.signal = data;
sig.signalFilt = filtfilt(p.filter.Rb, p.filter.Ra, sig.signal);
sig.signalFiltFR = filtfilt(p.filter.FRb, p.filter.FRa, sig.signal);
sig.duration = p.duration;

%% %%%%%%%%---- AUTOMATIC DETECTION ----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% look for ripples %%%%%%%%%%%%%%%%%%%%%%%%
display('***** Start Ripple Detection *****')
input.BLmu = 0.90; % level for maximum entrophy, threshold for /mu

CDFlevelRMS = 0.95;
CDFlevelRMSFR = 0.7;

CDFlevelFiltR = 0.99;
CDFlevelFiltFR = 0.99;

input.DurThr = 0.99;
input.dur = 30; % in sec

input.CDFlevelRMS = CDFlevelRMS;
input.CDFlevelFilt = CDFlevelFiltR;

input.time_thr = 0.02;
input.maxNoisemuV = 10;

[HFOobj, results] = nbt_doHFO160203(sig,sig.signalFilt, p.hp, 'Ripple', p, input);
      
sig.THR = HFOobj.THR;
sig.THRfiltered = HFOobj.THRfiltered;
sig.baselineLength = length(HFOobj.baselineInd)/p.fs;
sig.env = HFOobj.env;

% Find peaks of HFOs
if exist('results', 'var')==1
    for iDet=1:length(results)
        if iDet==1
            sig.autoSta = results(iDet).start/p.fs;
            sig.autoEnd = results(iDet).stop/p.fs;
            sig.mark = 1;
            
        else
            sig.autoSta = [sig.autoSta results(iDet).start/p.fs];
            sig.autoEnd = [sig.autoEnd results(iDet).stop/p.fs];
            sig.mark = [sig.mark 1];
        end
    end
else
    sig.autoSta=0;
    sig.autoEnd=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% look for FRs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
display('***** Start Fast Ripple Detection *****')
input.time_thr = 0.01;
input.CDFlevelRMS = CDFlevelRMSFR;
input.CDFlevelFilt = CDFlevelFiltFR;

[HFOobj, results] = nbt_doHFO160203(sig,sig.signalFiltFR, p.hpFR, 'FastRipple', p, input);

sig.THRFR = HFOobj.THR;
sig.THRfilteredFR = HFOobj.THRfiltered;
sig.envFR = HFOobj.env;


% Find peaks of HFOs
if exist('results', 'var')==1
    for iDet=1:length(results)
        if iDet==1
            temp.autoSta = results(iDet).start/p.fs;
            temp.autoEnd = results(iDet).stop/p.fs;
            temp.mark = 2;
            
        else
            temp.autoSta = [temp.autoSta results(iDet).start/p.fs];
            temp.autoEnd = [temp.autoEnd results(iDet).stop/p.fs];
            temp.mark = [temp.mark 2];
        end
    end
else
    temp.autoSta=0;
    temp.autoEnd=0;
end

% find the ripples which coincide FR\
clear Ind
Ind=zeros(1,length(sig.autoSta));
for iDetV = 1:length(sig.autoSta)
    Ind(iDetV) = sum((sig.autoSta(iDetV) < temp.autoEnd) & (sig.autoEnd(iDetV) > temp.autoSta));
end
sig.mark((find(Ind>0)))=3;

% find the FR which are not coincide with ripple
clear Ind
for iDetV = 1:length(temp.autoSta)
    Ind(iDetV) = sum((temp.autoSta(iDetV) < sig.autoEnd) & (temp.autoEnd(iDetV) > sig.autoSta));
end
%             find(Ind==0)
[sig.autoSta, sorted_inds] = sort([sig.autoSta temp.autoSta(Ind==0)]);
sig.autoEnd = [sig.autoEnd temp.autoEnd(Ind==0)];
sig.autoEnd  = sig.autoEnd(sorted_inds) ;
sig.mark = [sig.mark temp.mark(Ind==0)];
sig.mark = sig.mark(sorted_inds);

% events: 1-ripple, 2-FR, 3-together

% check the 0 detection
ToDelete = find(sig.autoSta==0);
sig.autoSta(ToDelete)=[];sig.autoEnd(ToDelete)=[];sig.mark(ToDelete)=[];

display(['%%%%%%%%%%%%% END ANALYSIS ' datestr(now,'dd-mm-yyyy HH-MM-SS') ' %%%%%%%%%%%%%%%%'])


if 0 % SAVING RESULTS
folderToSave = 'C:\Burnos_MATLAB\HFO analysis\151124 HFO detection of 20 sleep patients\160222 detector as Birgit\';
save([folderToSave 'pat' p.patient '_' datestr(now,'dd-mm-yyyy')],'Out', 'p');
end

end

% % ===================================================================================
% % *** END of FUNCTION MCGILL DETECTOR
% % ===================================================================================
