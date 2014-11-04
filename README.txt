README for GammaScreener_DataAnalysisCode

Oleg Kamaev - oleg.v.kamaev AT gmail.com

========================================

This directory contains original analysis code written in MATLAB to analyze data collected by the high-purity germanium (HPGe) detector with the goal to estimate the contamination level for various samples from the collected gamma spectrum. The code analyzes data files collected by the Gamma Screener together with the output files from Monte Carlo simulations to calculate contamination level in Bq/kg for a sample. This data analysis package fits experimental data as well as Monte Carlo simulations, does all necessary calculations and automatically generates all plots and tables with results. Provided template web-page with JavaScript allows to examine all plots and tables.         

To analyze data, run "do_main.m" which is a master file for the package. It calls other files and functions. You can set path, data directories, and other parameters in "do_main.m".  

The code was successfully tested in UNIX environments, Mac OS and Linux.

========================================

"example" directory:

To illustrate the output produced by the analysis code, sample input data are provided as an example.

"example/data":
For the provided example, Gamma Screener data are located in *.txt files inside "example/data" directory. These files are produced by Genie2K data acquisition software and contain collected gamma spectrum in the form of counts per channel. The list of all good data files that will be chained together is saved in *.list file.

"example/background":
Contains HPGe gamma background file.

"example/results":
Results are reported in "index.html" which is a template web-page with JavaScript to examine all generated plots and tables. Tables are saved in "results" directory, whereas plots are saved in "example/results/figs".   
   
 

  
