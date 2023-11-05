function [tf2, tf_real_modif, sigma_real_N, Q] = z_H0( tf, Fs, artefact_bln)
%%% Reference: Roehri N, Lina JM, Mosher JC, Bartolomei F, Benar CG. 
% Time-Frequency Strategies for Increasing High-Frequency Oscillation Detectability in Intracerebral EEG. 
% IEEE Trans Biomed Eng. 2016 Dec; 63(12):2595-2606. doi: 10.1109/TBME.2016.2556425. PMID: 27875125; PMCID: PMC5134253.

if size(tf,2) > size(tf,1) 
    tf = tf';
end

w = single(tukeywin(size(tf,1),0.25*Fs/size(tf,1))*ones(1,size(tf,2)));

tf_real_modif = real(tf);
tf_imag_modif = imag(tf);
tf2 = abs(tf).^2;
tf = [];
Nf = size(tf_real_modif,2);

sigma_real_N = zeros(1,Nf,'single');
Q = 0;

tf_stat = tf_real_modif;
tf_stat(artefact_bln,:) = []; 
N = size(tf_stat,1);

if N > 16000
    decimate = floor(linspace(Fs,N-Fs,15000));
else
    decimate = Fs:N-Fs;
end
tf_stat = tf_stat(decimate,:);
K = 1.5;

for i = 1:Nf
    b = tf_stat(:,i);
    IQR = iqr(b);
    q = quantile(b, [1/4 3/4]) + [-K*IQR K*IQR];
    b(b<q(1) | b>q(2)) = [];
        pd = fitdist(b,'Normal');
    
    tf_real_modif(:,i) = tf_real_modif(:,i)/pd.sigma;
    tf_imag_modif(:,i) = tf_imag_modif(:,i)/pd.sigma;
    sigma_real_N(1,i) = pd.sigma;
end