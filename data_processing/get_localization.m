function localization = get_localization(localization_path, list_name, coord_system)
% get_localization - Read Channel Localization from an XLSX File
%
% Description:
%   The `get_localization` function reads channel localization information from an
%   XLSX file. It extracts data from the specified sheet and columns based on the
%   coordinate system specified. The output is a table with channel names and
%   their corresponding localization coordinates.
%
% Inputs:
%   - localization_path: Path to the XLSX file containing channel localization data.
%   - list_name: Name of the sheet in the XLSX file to read data from.
%   - coord_system: Coordinate system ('mni' or 'acpc') for extracting
%     localization data.
%
% Output:
%   - localization: A table containing channel localization data for the specified
%     coordinate system.

    if isstring(coord_system) || ischar(coord_system)
        switch coord_system
            case 'mni'
                table_cols = [1, 5:7]; 
            case 'acpc' 
                table_cols = [1:4]; 
            otherwise 
                error("Coordinate system must be 'mni' or 'acpc', but %s was given", string(coord_system));
        end 
    else
        error("Coordinate system must be char or string"); 
    end 

    localization = readtable(localization_path,'Sheet', list_name); 
    localization = localization(:,[table_cols]); 

    localization.Properties.VariableNames = {'channel' 'l1' 'l2' 'l3'};
    localization.l1 = localization.l1;
    localization.l2 = localization.l2;
    localization.l3 = localization.l3;

    localization = table2cell(localization(:, 1:4)); 
    
end 