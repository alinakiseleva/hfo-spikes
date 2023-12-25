function sws_intervals_time = date_time_sws(name, patient, datadir, xlsx_filename)

    folder(patient).name = char(string(name))
    patient_folder = ['p' folder(patient).name]; 

    % preprocessing of raw data - monopolar montage
    raw = dir([datadir, '*']);
    number = find(ismember(cat(1,{raw.name}),{folder(patient).name}));

    list_edf = dir(fullfile(datadir,raw(number).name,'Night','*.edf'));
    list_edf = list_edf(~ startsWith({list_edf.name}, '._'));
    list_edf = natsortfiles({list_edf.name}');

    display(['number of raw data files is ', num2str(length(list_edf))])

    hdr = edfread(fullfile(datadir,raw(number).name,'Night',list_edf{1})); 

    sws_time = importdata(fullfile(datadir,raw(number).name,'Night','sws_time.txt'));

    sws_intervals_time = []; 
    
    for j = unique(sws_time(:,1))'

        filename = fullfile(datadir,folder(patient).name,'Night',list_edf{j});
        hdr = edfread(filename); 
        sample = sws_time(sws_time(:,1) == j,[2,3]);
        start_time = duration(strrep(hdr.starttime, ".", ":")); 

        for i = 1:size(sample,1)
            sws_intervals_time = [sws_intervals_time; ...
                                    string(datetime(hdr.startdate)), ...
                                    string(start_time + seconds(sample(i,:)))]; 
        end 
    end 
    
    if exist('xlsx_filename', 'var')
        writematrix(sws_intervals_time, xlsx_filename, ...
                    'Sheet', folder(patient).name); 
    end 
    
end 
