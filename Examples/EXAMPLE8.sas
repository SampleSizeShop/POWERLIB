OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example8.sas -- Point estimate for power of a UNIREP test based on estimated Sigma ";

LIBNAME IN01 "&ROOT.\Data\";

***************************************************;
* Delete data sets for power values if they exist *;
***************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE ONE TWO THREE;
RUN; QUIT;


PROC IML SYMSIZE=2000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_ON = {GG HF BOX UN TOTAL_N ORTHU NOPRINT SIGTYPE};
OPT_OFF={WARN ALPHA WLK PBT HLT};

USE IN01.EX7;
READ ALL VAR {ANT LEFT POST RIGHT} WHERE(_TYPE_ = "COV") INTO INSIGMA;	*Importing covariance matrix of data*;

* Rounding and viewing covariance matrix *;

RNM={ANT LEFT POST RIGHT};
ALPHA = .05/6;
SIGMA = ROUND(INSIGMA,.0001);
PRINT SIGMA[FORMAT=11.5 COLNAME=RNM];

* Define input matrices for power calcuations *;

ESSENCEX = I(10);
REPN =DO(2,10,2);

P = 4;
Q = 2;
* Pattern of means for Gender by Region *;
BETARG= J(2,4, 3.2) + {.30}#({ -1  0 1  0,
                               -1  0 1  0}) ;	
PRINT BETARG[COLNAME=RNM];
BETASCAL={1};

C = {1 -1} @ J(1,5,1);

REGION = {1,2,3,4};
RUN UPOLY1(REGION,"REGION",U1,REGU);
U=U1;

**************************************;
* Compute power based on fixed sigma *;
**************************************;

SIGTYPE=0; *Default, but specified for clarity;

DO DELTA=0 TO .20 BY .05;
  * Creation of Beta matrix based on varying Gender differences *;
  BETARGD=BETARG + (J(2,2,0)||(DELTA//(-DELTA))||J(2,1,0));	
  * Final Beta matrix with age groups added *;
  BETA= BETARGD @ J(5,1,1) ;					
  RUN POWER;
  HOLDALL=HOLDALL//( _HOLDPOWER||J(NROW(_HOLDPOWER),1,DELTA) );
END;

NAMES={"SIGSC" "BETASC" "N" "SIGTYPE" "EPS" "EXEPS_UN" "P_UN" "EXEPS_HF" "P_HF" "EXEPS_GG" "P_GG" "EXEPS_BOX" "P_BOX" "DELTA"};
CREATE ONE FROM HOLDALL [COLNAME = NAMES]; 
APPEND FROM HOLDALL;
CLOSE ONE;
FREE HOLDALL;

******************************************;
* Compute power based on estimated sigma *;
******************************************;

SIGTYPE=1; 
N_EST = 21;     *# Obs for variance estimate*;
RANK_EST = 1;   *# Model DF for study giving variance estimate*;

DO DELTA=0 TO .20 BY .05;
  * Creation of Beta matrix based on varying Gender differences *;
  BETARGD=BETARG + (J(2,2,0)||(DELTA//(-DELTA))||J(2,1,0));	
  * Final Beta matrix with age groups added *;
  BETA= BETARGD @ J(5,1,1) ;					
  RUN POWER;
  HOLDALL=HOLDALL//( _HOLDPOWER||J(NROW(_HOLDPOWER),1,DELTA) );
END;

NAMES={"SIGSC" "BETASC" "N" "SIGTYPE" "EPS" "EXEPS_UN" "P_UN" "EXEPS_HF" "P_HF" "EXEPS_GG" "P_GG" "EXEPS_BOX" "P_BOX" "DELTA"};
CREATE TWO FROM HOLDALL [COLNAME = NAMES]; 
APPEND FROM HOLDALL;
CLOSE TWO;

QUIT;

*****************;
* Print results *;
*****************;

*Stack datasets;
DATA THREE;
SET ONE TWO;
RUN;

PROC SORT DATA=THREE;
BY SIGSC BETASC DELTA N SIGTYPE;
RUN;

TITLE3 "Compare power with fixed (SIGTYPE=0) and estimated (SIGTYPE=1) Sigma";
PROC PRINT DATA=THREE NOOBS;
BY SIGSC BETASC DELTA;
RUN;
