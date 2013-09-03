TITLE1 "EXAMPLE1.SAS--Power for two sample t-test with overlay plot";

***************************************************************;
* Perform power calculations for a two sample T test,          ;
* replicating the results in "Increasing scientific power with ;
* statistical power", by K.E. Muller and V.A. Benignus,        ;
* Neurotoxicology and Teratology, vol 14, May-June, 1992       ;
* The code reports power for a limited number of predicted     ;
* differences in means, compared to the number of values       ;
* needed for plotting.                                         ;
***************************************************************;

*** Section that computes power values ***;

* Delete data set for power values if it exists *;

PROC DATASETS LIBRARY=WORK;
DELETE PWRDT1;
RUN; QUIT;

PROC IML SYMSIZE=1000 WORKSIZE=2000;
%INCLUDE "&ROOT.\Iml\POWERLIB21.IML"/NOSOURCE2;

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

*** Section that creates plot ***;

PROC CONTENTS DATA=PWRDT1;
RUN;

PROC SORT DATA=PWRDT1 OUT=ONE;
BY BETASCAL SIGSCAL;
RUN;

* Create file for power curves of varying VARIANCE *;

PROC TRANSPOSE DATA=ONE OUT=TWO PREFIX=SIGPWR;
VAR POWER;
BY BETASCAL;
RUN;

* Create ANNOTATE dataset and assign symbols for labeling plots *;

DATA LABELS (KEEP= X Y XSYS YSYS TEXT STYLE SIZE);
LENGTH   TEXT $ 5  STYLE $ 8;
XSYS="2"; YSYS="2";
X=.26;  Y=.95; TEXT="s";     STYLE="CGREEK"; *SIZE=1.0; OUTPUT;
X=.31;  Y=.97; TEXT="2";     STYLE="TRIPLEX"; SIZE=.75; OUTPUT;
X=.50;  Y=.95; TEXT="=0.32"; STYLE="TRIPLEX"; SIZE=1.0; OUTPUT;
X=.76;  Y=.70; TEXT="s";     STYLE="CGREEK";  SIZE=1.0; OUTPUT;
X=.81;  Y=.72; TEXT="2";     STYLE="TRIPLEX"; SIZE=.75; OUTPUT;
X=1.00; Y=.70; TEXT="=1.00"; STYLE="TRIPLEX"; SIZE=1.0; OUTPUT;
X=1.01; Y=.15; TEXT="s";     STYLE="CGREEK";  SIZE=1.0; OUTPUT;
X=1.06; Y=.17; TEXT="2";     STYLE="TRIPLEX"; SIZE=.75; OUTPUT;
X=1.25; Y=.15; TEXT="=2.05"; STYLE="TRIPLEX"; SIZE=1.0; OUTPUT;
RUN;

* The plot will be saved to this file for future inclusion in a document.*;
FILENAME OUT01 "&ROOT.\Examples\EXAMPLE1.png";

GOPTIONS GSFNAME=OUT01 DEVICE=PNG
CBACK=WHITE COLORS=(BLACK) HORIGIN=0IN VORIGIN=0IN
HSIZE=5IN VSIZE=3IN HTEXT=12PT FTEXT=TRIPLEX;

SYMBOL1 I=JOIN V=NONE L=34 W=1.0;
SYMBOL2 I=JOIN V=NONE L=1  W=1.0;
SYMBOL3 I=JOIN V=NONE L=34 W=1.0;
AXIS1 ORDER=(0 TO 1 BY .1)  W=1.5 MINOR=NONE MAJOR=(W=1.5) 
      LABEL=(ANGLE=-90 ROTATE=90);
AXIS2 ORDER=(0 TO 2.5 BY .5) W=1.5 MINOR=NONE MAJOR=(W=1.5); 

* The plot overlays power curves for three different variances *;
TITLE1;
PROC GPLOT DATA=TWO;
PLOT SIGPWR1*BETASCAL=1
     SIGPWR2*BETASCAL=2
     SIGPWR3*BETASCAL=3/OVERLAY VAXIS=AXIS1 HAXIS=AXIS2 ANNOTATE=LABELS;
LABEL SIGPWR1="Power"  SIGPWR2="Power"  SIGPWR3="Power"
      BETASCAL="Mean Difference";
RUN;
QUIT;

