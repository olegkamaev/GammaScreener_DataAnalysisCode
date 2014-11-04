function y = fig(fhandle);
% y = fig(fhandle);
%
% pretty much like the figure command only it preserves the visibility
% state

if ~exist('fhandle')
  fhandle = 1;
  while ishandle(fhandle)
    fhandle = fhandle+1;
  end
end

if ishandle(fhandle)
  vis = strcmp(get(fhandle,'Visible'),'on');
else
  vis = 1;
end

if vis
  figure(fhandle);
else
  set(0,'CurrentFigure',fhandle);
end
