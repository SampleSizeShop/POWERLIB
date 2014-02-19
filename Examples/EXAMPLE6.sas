OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example6.sas -- Confidence limits for a univariate model test";

******************************************************************************;
* Creates Figure 1 in Taylor and Muller, 1995, Amer Statistician, 49, p43-47 *;
******************************************************************************;

****************************************************;
* Delete data sets for power values if they exists *;
****************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE PWRDT1 PWRDT2 PWRDT3;
RUN; QUIT;

**************************************;
* Section that computes power values *;
**************************************;

PROC IML WORKSIZE=1000 SYMSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_OFF = {ALPHA};   
OPT_ON  = {NOPRINT DS}; 

ESSENCEX = I(2);  *Balanced two group t test, cell mean coding;
REPN = {12};

BETA = {0 1}`;
BETASCAL = DO(0,.75,.01);

ALPHA={.01}; 
C    ={1 -1}; 

SIGMA  = {.068}; 
SIGSCAL = {1}   ; 

* Statements to create two-sided confidence limits *;

CLTYPE = 1;
N_EST = 24;        *# Obs for variance estimate;
RANK_EST = 2;      *# model df for study giving variance estimate;
ALPHA_CL = .025;   *Lower confidence limit tail size;
ALPHA_CU = .025;   *Upper confidence limit tail size;
*Since no dataset name was specified, WORK.PWRDT1 is created.;

RUN POWER; 

* Statements to create one-sided lower confidence limits *;

CLTYPE = 1;
N_EST = 24;        *# Obs for variance estimate;
RANK_EST = 2;      *# model df for study giving variance estimate;
*Above three statements could have been omitted here since they duplicate 
those for two sided confidence limits*;

ALPHA_CL = 0.05;   *Lower confidence limit tail size;
ALPHA_CU =   0;    *Upper confidence limit tail size;
*Since WORK.PWRDT1 already exists, WORK.PWRDT2 is created.;

RUN POWER;

* Statements to create one-sided upper confidence limits *;

ALPHA_CL = 0;      *Lower confidence limit tail size;
ALPHA_CU = 0.05;   *Upper confidence limit tail size;
*Since WORK.PWRDT1 and WORK.PWDT2 already exist, WORK.PWRDT3 is created.;

RUN POWER;

QUIT;

**********************************;
* Section that creates the plotS *;
**********************************;

%MACRO GRAPH(DATA=, NAME=, TITLE2=);

ODS GRAPHICS / IMAGENAME="&NAME";
ODS LISTING GPATH="&ROOT.\Examples";

TITLE1;
PROC SGPLOT DATA=&DATA NOAUTOLEGEND;
PBSPLINE Y=POWER_L X=BETASCAL / NOMARKERS LINEATTRS=(COLOR=BLACK PATTERN=4);
PBSPLINE Y=POWER X=BETASCAL / NOMARKERS LINEATTRS=(COLOR=BLACK PATTERN=1);
PBSPLINE Y=POWER_U X=BETASCAL / NOMARKERS LINEATTRS=(COLOR=BLACK PATTERN=4);
LABEL POWER_L="Power"  POWER  ="Power"  POWER_U="Power" 
	BETASCAL="Mean Difference, 1/Cr (dL/mg)";
YAXIS VALUES=(0 TO 1 BY .2) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
XAXIS VALUES=(0 TO .75 BY .25) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
REFLINE 0.5 / AXIS=X ;
RUN;

%MEND;


%GRAPH(DATA=PWRDT1, NAME=Example6A, TITLE2=Two-sided confidence limits);
%GRAPH(DATA=PWRDT2, NAME=Example6B, TITLE2=One-sided lower confidence limits);
%GRAPH(DATA=PWRDT3, NAME=Example6C, TITLE2=One-sided upper confidence limits);
