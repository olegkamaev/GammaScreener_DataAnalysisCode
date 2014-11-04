function sgm = sgmFunc(en)
% sigma for energy of interest (taken from FWHM calibration)
% en should be in keV
%
% Oleg Kamaev - oleg.v.kamaev AT gmail.com

sgm = (0.5494 + 3.89E-2*sqrt(en))/2.3548;

end
