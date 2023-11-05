function value = get_field_or_empty(structure, field)
% GET_FIELD_OR_EMPTY Get the value of a field in a structure or return an empty value if the field does not exist.
%
% Syntax:
%   value = get_field_or_empty(structure, field)
%
% Description:
%   The `get_field_or_empty` function retrieves the value associated with the specified field in a structure. If the field does not exist in the structure, it returns an empty value.
%
% Input:
%   - structure: A MATLAB structure.
%   - field: A character vector specifying the name of the field to retrieve.
%
% Output:
%   - value: The value of the specified field in the structure. If the field does not exist, an empty value is returned (an empty string in this case).

    if isfield(structure, field)
        value = structure.(field);
    else
        value = '';
    end
end