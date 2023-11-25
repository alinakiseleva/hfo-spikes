function filter = filterHFO_FIR_builder_fs_Hz(Fs) 

    %R

    fStop1 = 70; %Hz, 
    fPass1 = 80; %Hz, 
    fPass2 = 240; %Hz, 
    fStop2 = 250; %Hz, 

    D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', fStop1, fPass1, fPass2, fStop2, 60, 1, 60, Fs);
    H = design(D, 'equiripple'); % H is a DFILT
    filter.Rb = H.Numerator;
    filter.Ra = 1;

    %FR

    fStop1 = 240; %Hz, 
    fPass1 = 250; %Hz, 
    fPass2 = 490; %Hz, 
    fStop2 = 500; %Hz, 

    D = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', fStop1, fPass1, fPass2, fStop2, 60, 1, 60, Fs);
    H = design(D, 'equiripple'); % H is a DFILT
    filter.FRb = H.Numerator;
    filter.FRa = 1;
end

