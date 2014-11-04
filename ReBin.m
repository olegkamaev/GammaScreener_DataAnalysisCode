%	function [outbins outcounts] = ReBin(inbins,incounts,compression,scale);
%
%	inbins 		- input x values at centers of bins
%	incounts	- counts or rate to rebin
%	compression - number of bins to compress to one
%					Note: underfilled last bin is droped
%	scale		- = 0 - do not rescale outcounts
%				  = 1 - divide outcounts by compression; used for rates
%
%	outbins		- new values of bin centers
%	outcounts	- new compressed counts or rate
%
%	8-20-97	TS

function [outbins,outcounts]=ReBin(inbins,incounts,compression,scale);

numinbins=length(inbins);
numoutbins=fix(length(inbins)/compression);
drop=rem(numinbins,compression);
if drop>0
	disp(['+++ Dropping ' num2str(drop) ' bins off end of spectrum']);
end

for nb=0:numoutbins-1
	outbins(nb+1)=sum(inbins(nb*compression+1:nb*compression+compression));	
	outcounts(nb+1)=sum(incounts(nb*compression+1:nb*compression+compression));
end;

outbins=outbins/compression;
if scale
	outcounts=outcounts/compression;
end;
