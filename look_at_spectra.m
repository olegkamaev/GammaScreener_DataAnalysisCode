function [enr, dh, ltsec] = look_at_spectra(dpath, dfile,...
                            bpath, bfile, pllog, savefigs, figdir)
% Script to plot gamma spectrum for visual inspection
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

res = '150';

ext = '.dat';

load([dpath, dfile, ext]);
load([bpath, bfile, ext]);

eval(['dt(:,1)=', bfile,';']);
eval(['dt(:,2)=', dfile,';']);

rb = 4;
if pllog
    [enr, dh, ltsec, xst, ymaxst] =...
                plot_tka16_stairs(dt, 2, rb);
else
    [enr, dh, ltsec, xst, ymaxst] =...
                plot_tka16_stairs(dt, 1, rb);
end

if savefigs
    print('-dpng',['-r' res],[figdir,...
        'spectra_rb',num2str(rb),'_all.png']);
    set(gca,'YScale','lin');
    axis tight
    print('-dpng',['-r' res],[figdir,...
        'spectra_rb',num2str(rb),'_all_lin.png']);

    for j = 1:length(ymaxst)
        axis([xst(j) xst(j+1) 0 1.3*ymaxst(j)]);
        print('-dpng',['-r' res],[figdir,...
            'spectra_rb',num2str(rb),'_rg',num2str(xst(j)),'.png']);
    end
end

end
