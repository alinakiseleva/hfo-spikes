function merged_struct = merge_params(defaults, params)
% MERGE_PARAMS Merge parameter values from two structures.
%
% Syntax:
%   merged_struct = merge_params(defaults, params)
%
% Description:
%   The `merge_params` function combines parameter values from two structures, `defaults` and `params`, into a single structure `merged_struct`. It assigns values from `params` if they exist, and uses `defaults` for any missing parameters.
%
% Input:
%   - defaults: A structure containing default parameter values.
%   - params: A structure with user-defined parameter values.
%
% Output:
%   - merged_struct: A structure with merged parameter values.

    merged_struct = struct(defaults);
    paramFields = fieldnames(params);
    for i = 1:numel(paramFields)
        merged_struct.(paramFields{i}) = params.(paramFields{i});
    end
end
