function h = add_propagation_markers(mni, ch_pairs, ch_connections, color, position, scale)
% ADD_PROPAGATION_MARKERS Add propagation markers to a 3D plot.
%
% h = add_propagation_markers(mni, ch_pairs, ch_connections) adds propagation
% markers to a 3D plot. The propagation markers represent connections between
% channels as quiver arrows. The function returns a handle (h) to the created
% markers.
%
% Input:
%   - mni: A matrix of MNI (Montreal Neurological Institute) coordinates for
%     each channel. Each row represents a channel, and there should be three
%     columns for x, y, and z coordinates.
%   - ch_pairs: A matrix specifying channel pairs to connect. Each row should
%     contain two indices corresponding to the channels in 'mni' that you want
%     to connect.
%   - ch_connections: A vector specifying the connection strength between each
%     channel pair. The length of this vector should match the number of channel
%     pairs.
%
% Optional Name-Value Pairs:
%   - 'color': The color of the propagation arrows (default: [0.9 0.1 0.1]).
%   - 'position': The position of the arrows relative to the channels (default:
%     'middle'). Choose from 'middle' or 'top'.
%   - 'scale': Scaling factor for arrow lengths (default: 3).
%
% Output:
%   - h: A handle to the created propagation markers.

    if (nargin < 6)
        scale = 3;
    end

    if (nargin < 4)
        color = [0.9 0.1 0.1];
    end

    if isvector(ch_pairs)
        if iscolumn(ch_pairs)
            ch_pairs = ch_pairs';
        end
    end
    assert(size(ch_pairs,2)==2, 'Channel pairs must be 2D vectors');

    if isvector(mni)
        if iscolumn(mni)
            mni = mni';
        end
    end
    assert(size(mni,2)==3, 'Coordinates must be 3D vectors');

    no_marker = size(ch_pairs,1);
    h = zeros(no_marker,1);

    if strcmp(position, 'top') 
        mni(:, 3) = mni(:, 3) + 200;  
    end

    for i = 1:no_marker
        ch_pair = ch_pairs(i, :); 
        dp = mni(ch_pair(2), :) - mni(ch_pair(1), :); 
        h(i) = quiver3(mni(ch_pair(1),1), mni(ch_pair(1),2), mni(ch_pair(1),3), dp(1), dp(2), dp(3), 0, ...
             'color', color, 'LineWidth', scale * ch_connections(i)); 
        hold on 
    end

end 