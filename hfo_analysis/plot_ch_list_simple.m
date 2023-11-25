function plot_ch_list_simple(data, shift, labels, fs)

dt = 1/ fs;
t = (dt:dt:dt*length(data)) ;

n_ch = size(data,1);

 for i = 1:n_ch
                  
     plot(t, detrend(data(i,:))-i*shift,'k')
     hold on
     
 end
        
axis([t(1) t(end) -shift*(n_ch+1) 0]);
set(gca,'YTick',[-shift*(n_ch):shift:-shift],'YTicklabel',flipud(labels))

end 

