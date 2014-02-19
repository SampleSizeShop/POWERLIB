OPTIONS NODATE NONUMBER PS=55 LS=95;
GOPTIONS RESET=ALL;
TITLE1 "Example3.sas -- Power for a t-test with 3 dimensional plot";

*************************************************;
* Delete data set for power values if it exists *;
*************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE PWRDT1;
RUN; QUIT;

**************************************;
* Section that computes power values *;
**************************************;

PROC IML WORKSIZE=1000 SYMSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_OFF = {WARN ALPHA};
OPT_ON = {NOPRINT DS};
* Output not printed to screen since NOPRINT option ON *;

ROUND = 6;
ALPHA = {.01};
SIGMA = {.068};  
SIGSCAL = {1} ;
BETA = {0 1}`;
C = {-1 1};
ESSENCEX = I(2);
REPN = DO(3,18,3);
BETASCAL = DO(0,.75,.05);
RUN POWER;

QUIT;

*********************************;
* Section that creates the plot *;
*********************************;

FILENAME OUT01 "&ROOT.\Examples\Example3.png";

TITLE1;
PROC G3GRID DATA=PWRDT1 OUT=ONE;
GRID  BETASCAL*TOTAL_N=POWER /SPLINE NAXIS1=16 NAXIS2=11 ;
GOPTIONS GSFNAME=OUT01 DEVICE=PNG  CBACK=WHITE COLORS=(BLACK) 
	HSIZE=6.67IN VSIZE=5IN HTEXT=12PT;
RUN;

PROC G3D DATA=ONE GOUT=OUT01;
PLOT BETASCAL*TOTAL_N=POWER/
     ZMIN=0 ZMAX=1 ZTICKNUM=6   YTICKNUM=4    XTICKNUM=6   SIDE;
LABEL TOTAL_N ="N" BETASCAL="Delta" POWER="Power" ;
RUN;


