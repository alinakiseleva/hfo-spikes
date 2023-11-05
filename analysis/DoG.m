function [wt, freqlist] = DoG(sig,Oct,NbVoi,VanMom,Nexp,Fs,scaling)
% CWT:	Continuous wavelet transform
% usage:	wt = cwt(sig,Oct,NbVoi,VanMom)
%%% Reference: Roehri N, Lina JM, Mosher JC, Bartolomei F, Benar CG. 
% Time-Frequency Strategies for Increasing High-Frequency Oscillation Detectability in Intracerebral EEG. 
% IEEE Trans Biomed Eng. 2016 Dec; 63(12):2595-2606. doi: 10.1109/TBME.2016.2556425. PMID: 27875125; PMCID: PMC5134253.

sig = sig(:);
siglength = length(sig);
fff = (0:(siglength-1))*2*pi/siglength;

Cst = 4*VanMom/(pi*pi);
fsig = fft(sig);
NbOct = length(Oct(1):Oct(2))-1;

wt = complex(zeros(NbOct*NbVoi,siglength,'single'));
freqlist=zeros(NbOct*NbVoi,1,'single');

j=1;
for oct = Oct(1):(Oct(2)-1)
    for voi = 0:(NbVoi-1)
        scale = 2^(oct + voi/NbVoi);
        freqlist(j)=Fs/(4*scale);
        tmp = scale * fff;
        psi = (tmp.^VanMom).* exp(-Cst*tmp.^Nexp/2);
        fTrans = fsig .* psi';
        if scaling
            wt(j,:) = ifft(fTrans)';
        else
            wt(j,:) = sqrt(scale)*ifft(fTrans)';
        end
        j=j+1;
    end
end

wt = flipud(wt)';
freqlist = flip(freqlist);