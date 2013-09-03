TITLE1 "EXAMPLE4.SAS -- Confidence limits for a univariate model test";
TITLE2 "Creates Figure 1 in Taylor and Muller, 1995, Amer Statistician, 49, p43-47";

*** Section that computes power values ***;

* Delete data sets for power values if they exist *;

PROC DATASETS LIBRARY=WORK;
DELETE PWRDT1 PWRDT2 PWRDT3;
RUN; QUIT;

PROC IML WORKSIZE=1000 SYMSIZE=2000;
%INCLUDE "&ROOT.\Iml\POWERLIB21.IML"/NOSOURCE2;

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

*** Section that creates plot for two-sided confidence limits ***;

FILENAME OUT01 "&ROOT.\Examples\EXAMPLE4A.png";

GOPTIONS GSFNAME=OUT01 DEVICE=PNG 
CBACK=WHITE COLORS=(BLACK) HORIGIN=0IN VORIGIN=0IN
HSIZE=5IN VSIZE=3IN HTEXT=12PT FTEXT=TRIPLEX;

SYMBOL1 I=SPLINE V=NONE L=34 W=2;
SYMBOL2 I=SPLINE V=NONE L= 1 W=2;
SYMBOL3 I=SPLINE V=NONE L=34 W=2;
AXIS1 ORDER=(0 TO 1 BY .2)    W=3 MINOR=NONE MAJOR=(W=2) 
      LABEL=(ANGLE=-90 ROTATE=90);
AXIS2 ORDER=(0 TO .75 BY .25) W=3 MINOR=NONE MAJOR=(W=2)
      LABEL=("Mean Difference, 1/Cr (dL/mg)");

TITLE1;
PROC GPLOT DATA=PWRDT1;
PLOT (POWER_L POWER POWER_U)*BETASCAL/ OVERLAY NOFRAME HREF=.5
       VZERO VAXIS=AXIS1 HZERO HAXIS=AXIS2 NOLEGEND;
LABEL POWER_L="Power"  POWER  ="Power"  POWER_U="Power" ;
RUN; QUIT;

*** Section that creates plot for one-sided lower confidence limits ***;

FILENAME OUT01 "&ROOT.\Examples\EXAMPLE4B.png";

GOPTIONS GSFNAME=OUT01 DEVICE=PNG 
CBACK=WHITE COLORS=(BLACK) HORIGIN=0IN VORIGIN=0IN
HSIZE=5IN VSIZE=3IN HTEXT=12PT FTEXT=TRIPLEX;

SYMBOL1 I=SPLINE V=NONE L=34 W=2;
SYMBOL2 I=SPLINE V=NONE L= 1 W=2;
SYMBOL3 I=SPLINE V=NONE L=34 W=2;
AXIS1 ORDER=(0 TO 1 BY .2)    W=3 MINOR=NONE MAJOR=(W=2) 
      LABEL=(ANGLE=-90 ROTATE=90);
AXIS2 ORDER=(0 TO .75 BY .25) W=3 MINOR=NONE MAJOR=(W=2)
      LABEL=("Mean Difference, 1/Cr (dL/mg)");

TITLE1;
PROC GPLOT DATA=PWRDT2;
PLOT (POWER_L POWER POWER_U)*BETASCAL/ OVERLAY NOFRAME HREF=.5
       VZERO VAXIS=AXIS1 HZERO HAXIS=AXIS2 NOLEGEND;
LABEL POWER_L="Power"  POWER  ="Power"  POWER_U="Power";
RUN; QUIT;


*** Section that creates plot for one-sided lower confidence limits ***;

FILENAME OUT01 "&ROOT.\Examples\EXAMPLE4C.png";

GOPTIONS GSFNAME=OUT01 DEVICE=PNG 
CBACK=WHITE COLORS=(BLACK) HORIGIN=0IN VORIGIN=0IN
HSIZE=5IN VSIZE=3IN HTEXT=12PT FTEXT=TRIPLEX;

SYMBOL1 I=SPLINE V=NONE L=34 W=2;
SYMBOL2 I=SPLINE V=NONE L= 1 W=2;
SYMBOL3 I=SPLINE V=NONE L=34 W=2;
AXIS1 ORDER=(0 TO 1 BY .2)    W=3 MINOR=NONE MAJOR=(W=2) 
      LABEL=(ANGLE=-90 ROTATE=90);
AXIS2 ORDER=(0 TO .75 BY .25) W=3 MINOR=NONE MAJOR=(W=2)
      LABEL=("Mean Difference, 1/Cr (dL/mg)");

TITLE1;
PROC GPLOT DATA=PWRDT3;
PLOT (POWER_L POWER POWER_U)*BETASCAL/ OVERLAY NOFRAME HREF=.5
       VZERO VAXIS=AXIS1 HZERO HAXIS=AXIS2 NOLEGEND;
LABEL POWER_L="Power"  POWER  ="Power"  POWER_U="Power" ;
RUN; QUIT;

