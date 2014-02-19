OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example1.sas -- Power for two sample t-test with overlay plot";

***************************************************************;
* Perform power calculations for a two sample T test,          ;
* replicating the results in "Increasing scientific power with ;
* statistical power", by K.E. Muller and V.A. Benignus,        ;
* Neurotoxicology and Teratology, vol 14, May-June, 1992       ;
* The code reports power for a limited number of predicted     ;
* differences in means, compared to the number of values       ;
* needed for plotting.                                         ;
***************************************************************;

*************************************************;
* Delete data set for power values if it exists *;
*************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE PWRDT1;
RUN; QUIT;

**************************************;
* Section that computes power values *;
**************************************;

PROC IML SYMSIZE=1000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML" / NOSOURCE2;

* Define inputs to power program *;

SIGMA = {1};
SIGSCAL = {0.32 1.00 2.05};

ESSENCEX = I(2);
REPN = {10};

BETA = {0 1}`;
BETASCAL = DO(0,2.5,0.05);
C = {1 -1};

OPT_OFF = {C U};
OPT_ON = {DS};
* The DS option creates a SAS file with the power calculation results.;
* Since no dataset name was specified, WORK.PWRDT1 is created.;

RUN POWER;

*********************************;
* Section that creates the plot *;
*********************************;

PROC CONTENTS DATA=PWRDT1;
RUN;

PROC SORT DATA=PWRDT1 OUT=ONE;
BY BETASCAL SIGSCAL;
RUN;

*Create file for power curves of varying VARIANCE;
PROC TRANSPOSE DATA=ONE OUT=TWO PREFIX=SIGPWR;
VAR POWER;
BY BETASCAL;
RUN;

ODS GRAPHICS / IMAGENAME="Example1" ;
ODS LISTING GPATH="&ROOT.\Examples" ;

TITLE1;
PROC SGPLOT DATA=TWO ;
PBSPLINE Y=SIGPWR1 X=BETASCAL / LINEATTRS=(COLOR=BLACK PATTERN=4) NOMARKERS
							  NAME="PWR1" LEGENDLABEL="0.32";
PBSPLINE Y=SIGPWR2 X=BETASCAL / LINEATTRS=(COLOR=BLACK PATTERN=1) NOMARKERS
							  NAME="PWR2" LEGENDLABEL="1";
PBSPLINE Y=SIGPWR3 X=BETASCAL / LINEATTRS=(COLOR=BLACK PATTERN=8) NOMARKERS
							  NAME="PWR3" LEGENDLABEL="2.05";
LABEL SIGPWR1="Power" BETASCAL="Mean Difference" ;
XAXIS VALUES=(0 TO 2.5 BY .5) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
YAXIS VALUES=(0 TO 1 BY 0.1) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
KEYLEGEND "PWR1" "PWR2" "PWR3"/ TITLE="Variance" VALUEATTRS=(SIZE=12PT) 
	TITLEATTRS=(SIZE=12PT);
RUN;



