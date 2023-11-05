function [num_electrodes, num_contacts] = count_electrodes(paths)
% count_electrodes - Count the number of electrodes and contacts based on localization data.
%
% Input:
%   - paths: a struct containing file paths and configurations.
%
% Output:
%   - num_electrodes: the total number of electrodes.
%   - num_contacts: the total number of contacts.

    localization = get_localization(paths.localization_path, paths.list_name, 'acpc'); 

    last_contact = localization{end, 1}; 
    num_electrodes = str2double(last_contact(1:find(isletter(last_contact), 1, 'first')-1)); 

    num_contacts = size(localization, 1); 
    
end 