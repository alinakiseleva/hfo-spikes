function [] = check_dir(path)
% CHECK_DIR Checks if a directory exists, and creates it if it doesn't.
%
% Syntax:
%   check_dir(path)
%
% Description:
%   The `check_dir` function verifies the existence of a directory specified
%   by the `path`. If the directory does not exist, the function creates the
%   it.
%
% Input:
%   - path: A string specifying the path to the directory to check/create.

    if ~exist(path, 'dir')
           mkdir(path)
    end

end 
