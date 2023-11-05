function h = addScrollbar(ax, varargin)
% ADDSCROLLBAR Add a scrollbar to one or more axes.
%
% Syntax:
%   h = addScrollbar(ax)
%   h = addScrollbar(ax, dx)
%   h = addScrollbar(ax, dx, t)
%
% Description:
%   The `addScrollbar` function adds a scrollbar to one or more axes. This
%   allows you to interactively adjust the X or Y-axis limits of the
%   specified axes.
%
% Input:
%   - ax: A single axes handle or an array of axes handles to which you
%     want to add a scrollbar.
%   - dx (optional): The step size for the scrollbar. This parameter
%     determines how much the X or Y-axis limits change when you move the
%     scrollbar. Default is an automatic calculation.
%   - t (optional): The orientation of the scrollbar. Use 'x' for a
%     horizontal scrollbar (default), or 'y' for a vertical scrollbar.
%
% Output:
%   - h: A handle to the created scrollbar.


t = 'x';
dx = [];
if ~isempty(varargin)
    dx = varargin{1};
    if numel(varargin)>1
        t = varargin{2};
        if ~any(strcmpi(t, {'x','y'}))
            error('Optional argument must be ''x'' or ''y''');
        end
    end
end

set(gcf, 'doublebuffer', 'on');

%Find data-limits
Max = nan; Min = nan;
for i = 1:numel(ax)
    ch = get(ax(i), 'children');
    types = get(ch, 'type');
 
    data = get(ch, sprintf('%sdata',t));

    maxarr = data;
    
    if iscell(data)
        maxarr = cellfun(@max,data);
    end
    
    Max = max(Max, max(maxarr));
    minarr = data;
    if iscell(data)
        minarr = cellfun(@min, data);
    end
    Min = min(Min, min(minarr));
end

if numel(ax) > 1
    pos = cell2mat(get(ax, 'position'));
else
    pos = get(ax, 'position');
end

other = 'x';
if strcmpi(t, 'x')
    other = 'y';
end

lims = get(ax, sprintf('%slim', other));
if ~iscell(lims), lims = {lims}; end

[~, ind] = min(pos(:,2));
pos = pos(ind,:);

if strcmpi(t, 'x')
    Newpos = [pos(1) pos(2)-0.1 pos(3) 0.05];    
else
    Newpos = [pos(1)-0.1 pos(2) 0.05 pos(4)];
end

if isempty(dx)
    dx = (Max-Min)/10;
end
if dx > (Max-Min)
    error('Slider step cannot be larger than the axis limits');
end

c = @(obj,handles)callback(obj,handles,ax,t,dx,lims);
% Creating Uicontrol
h=uicontrol('style','slider',...
            'units','normalized','position',Newpos,...
            'callback',c,'min',Min,'max',Max-dx(1),'value',Min,'SliderStep',[dx,dx]./(Max-Min),...
            'tooltip',get(get(ax(ind),'xlabel'),'string'));
        
c(h, []); %run callback to update current/initial value

function callback(obj, handles, ax, t, dx, lims)

set(ax, sprintf('%slim',t), get(obj,'value')+[0 dx]);
other = 'x';

if strcmpi(t, 'x')
    other = 'y';
end

for i = 1:numel(ax)   
    set(ax(i), sprintf('%slim',other), lims{i});
end


