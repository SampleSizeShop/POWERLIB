OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example7.sas -- Confidence limits for a UNIREP test in a multivariate model with plots";

LIBNAME IN01 "&ROOT.\Data\";

***************************************************;
* Delete data sets for power values if they exist *;
***************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE ONE ONECL ;
RUN; QUIT;

**************************************;
* Section that computes power values *;
**************************************;

PROC IML SYMSIZE=2000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_ON = {GG HF BOX UN TOTAL_N ORTHU NOPRINT};
OPT_OFF={WARN ALPHA};

USE IN01.EX7;
READ ALL VAR {ANT LEFT POST RIGHT} WHERE(_TYPE_ = "COV") INTO INSIGMA;	*Importing covariance matrix of data*;

* Rounding and viewing covariance matrix *;

RNM={ANT LEFT POST RIGHT};
ALPHA = .05/6;
SIGMA = ROUND(INSIGMA,.0001);
PRINT SIGMA[FORMAT=11.5 COLNAME=RNM];

* Define input matrices for power calcuations *;

ESSENCEX = I(10);
REPN =DO(1,10,1);

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

DO DELTA=0 TO .20 BY .0008;
  * Creation of Beta matrix based on varying Gender differences *;
  BETARGD=BETARG + (J(2,2,0)||(DELTA//(-DELTA))||J(2,1,0));	
  * Final Beta matrix with age groups added *;
  BETA= BETARGD @ J(5,1,1) ;					
  RUN POWER;
  HOLDALL=HOLDALL//( _HOLDPOWER||J(NROW(_HOLDPOWER),1,DELTA) );
END;

**************************************************************;
* Create dataset without confidence limits                   *;
* Create dataset manually so can appropriately label columns *;
**************************************************************; 

NAMES={"SIGSC" "BETASC" "N" "P_MULT" "EPS" "EXEPS_UN" "P_UN" "EXEPS_HF" "P_HF" "EXEPS_GG" "P_GG" "EXEPS_BOX" "P_BOX" "DELTA"};
CREATE ONE FROM HOLDALL [COLNAME = NAMES]; 
APPEND FROM HOLDALL;
CLOSE ONE;

OPT_OFF={UN BOX HF WLK PBT HLT WARN ALPHA CLTYPE BETASCAL SIGSCAL ALPHA_CL ALPHA_CU};
OPT_ON={GG ORTHU NOPRINT};

REPN={2,4,8};

****************************************************;
* Create dataset with values for confidence limits *;
****************************************************;

CLTYPE = 1;     *Estimated variance only, with fixed means*;
N_EST = 21;     *# Obs for variance estimate*;
RANK_EST = 1;   *# Model DF for study giving variance estimate*;
ALPHA_CL = .025;   	*Lower confidence limit tail size*;
ALPHA_CU = .025;   	*Upper confidence limit tail size*;

FREE HOLDALL;
DO DELTA=0 TO .20 BY .0008;
  * Creation of Beta matrix based on varying Gender differences *;
  BETARGD=BETARG + (J(2,2,0)||(DELTA//(-DELTA))||J(2,1,0));	
  * Final Beta matrix with age groups added *;
  BETA= BETARGD @ J(5,1,1) ;					
  RUN POWER;
  HOLDALL=HOLDALL//( _HOLDPOWER||J(NROW(_HOLDPOWER),1,DELTA) );
END;

NAMES = _HOLDPOWERLBL || "DELTA";
CREATE ONECL FROM HOLDALL [COLNAME = NAMES]; 
APPEND FROM HOLDALL;
CLOSE ONECL;

QUIT;

************************************;
* Section that creates the 3D plot *;
************************************;

DATA TWO;
N=100; DELTA=0; P_GG=0;		*Create 'dummy' entry for graph*;
RUN;

DATA THREE;	
SET ONE TWO;
KEEP N P_GG DELTA;
RUN;

*Delete any existing graphs;
PROC DATASETS LIBRARY=WORK MEMTYPE=CATALOG NOLIST NODETAILS;
DELETE GSEG ;
RUN; QUIT;

FILENAME OUT01 "&ROOT.\Examples\Example7A.png";
GOPTIONS GSFNAME=OUT01 DEVICE=PNG  CBACK=WHITE COLORS=(BLACK) 
	HSIZE=6.67IN VSIZE=5IN HTEXT=16PT;

%MACRO G3GRID(VAR1=, VAR2=, VAR3=);

TITLE1;
PROC G3GRID DATA = THREE OUT = FOUR;
	GRID &VAR1*&VAR2 = &VAR3/
		SPLINE NAXIS1=16 NAXIS2=11;
RUN;

%MEND;

%MACRO G3D(VAR1=, VAR2=, VAR3=, ZMAX=, ZTICKNUM=, XTICKNUM=, SIDE=);

TITLE1;
PROC G3D DATA = FOUR GOUT = FIVE;
	PLOT &VAR1*&VAR2 = &VAR3/
		ZMIN=0 ZMAX=&ZMAX ZTICKNUM=&ZTICKNUM YTICKNUM=5 XTICKNUM=&XTICKNUM &SIDE;
	LABEL P_GG = "Power" DELTA="Delta";
RUN;

%MEND;

*Each PROC G3GRID call takes a few minutes to run;

*Plot 1 of 3;
%G3GRID(VAR1=DELTA, VAR2=N, VAR3=P_GG);
%G3D(VAR1=DELTA, VAR2=N, VAR3=P_GG, ZMAX=1.0, ZTICKNUM=6, XTICKNUM=5);

*Plot 2 of 3;
%G3GRID(VAR1=DELTA, VAR2=P_GG, VAR3=N);
%G3D(VAR1=DELTA, VAR2=P_GG, VAR3=N, ZMAX=100, ZTICKNUM=6, XTICKNUM=6, SIDE=SIDE);

*Plot 3 of 3;
%G3GRID(VAR1=N, VAR2=P_GG, VAR3=DELTA);
%G3D(VAR1=N, VAR2=P_GG, VAR3=DELTA, ZMAX=0.2, ZTICKNUM=5, XTICKNUM=6, SIDE=SIDE);

PROC GREPLAY IGOUT=FIVE TC=TEMPCAT NOFS;
TDEF TEMP2BY2 DES="2 rows, 2 columns (3 plots)"
 1/LLX= 25 ULX= 25 LRX= 75 URX= 75   LLY=50 ULY=100 LRY=50 URY=100
 2/LLX= 0 ULX= 0 LRX= 50 URX= 50   LLY=0 ULY=50 LRY=0 URY=50
 3/LLX= 50 ULX= 50 LRX= 100 URX= 100   LLY=0 ULY=50 LRY=0 URY=50;
TEMPLATE TEMP2BY2;
TREPLAY 1:G3D  2:G3D1 3:G3D2;
RUN;QUIT; 

*********************************************************************************************;
* Section that creates a plot of values of gender*region differences that achieve 90% power *;
*********************************************************************************************;

FILENAME OUT01 "&ROOT.\Examples\EXAMPLE6B.png";

*Extracts data with GG power >= 0.89;
DATA SIX;
SET THREE;
IF N = 100 AND P_GG >= 0.89;
KEEP N P_GG DELTA;
RUN;

*Creates dataset for Beta plot;
PROC IML SYMSIZE=2000 WORKSIZE=2000;

USE SIX;
READ ALL VAR {DELTA} INTO INDELTA;

BETARG= J(2,4, 3.2) + {.30}#({ -1  0 1  0,
                               -1  0 1  0});

DELTA = INDELTA[1,1]; * Value of delta for which power is approx. 90% *;
BETARGD=(BETARG + (J(2,2,0)||(DELTA//(-DELTA))||J(2,1,0)))`;
HOLD1= BETARGD[,1]//BETARGD[,2];
HOLD2=((DO(1,4,1))`) // ((DO(1,4,1))`) ;
HOLD3=J(4,1,1)//J(4,1,2);
HOLD=HOLD1||HOLD2||HOLD3;
HNAMES={"SOAM1" "IREGION" "GENDER"};
CREATE SEVEN FROM HOLD [COLNAME = HNAMES];
APPEND FROM HOLD;
CLOSE SEVEN;

QUIT;

PROC FORMAT;
VALUE IREGION 1="Ant" 2="LMid" 3="Post" 4="RMid";
VALUE GENDER 1="Male" 2="Female";
RUN;

ODS GRAPHICS / IMAGENAME="Example7B";
ODS LISTING GPATH="&ROOT.\Examples";

TITLE1;
PROC SGPLOT DATA=SEVEN;
  SERIES Y=SOAM1 X=IREGION/ GROUP=GENDER MARKERS
							MARKERATTRS=(SIZE=12PT);
LABEL IREGION="Region of the Brain" GENDER="Gender";
FORMAT IREGION IREGION. GENDER GENDER.;
XAXIS VALUES=(1 TO 4 BY 1) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
YAXIS VALUES=(2.75 TO 3.75 BY 0.25) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
KEYLEGEND /TITLE="Gender" VALUEATTRS=(SIZE=12PT) TITLEATTRS=(SIZE=12PT);
RUN;
QUIT;

************************************************************************;
* Section that creates an overlay plot of power for three sample sizes *;
************************************************************************;

FILENAME OUT01 "&ROOT.\Examples\EXAMPLE6C.png";

PROC SORT DATA=ONE OUT=EIGHT;
BY N DELTA;
RUN;

DATA NINE;
MERGE EIGHT( WHERE=(N=20) RENAME=(P_GG=P20) )
	EIGHT( WHERE=(N=40) RENAME=(P_GG=P40) )
	EIGHT( WHERE=(N=80) RENAME=(P_GG=P80) );
RUN;
        
ODS GRAPHICS / IMAGENAME="Example7C";
ODS LISTING GPATH="&ROOT.\Examples" ;

TITLE1;
PROC SGPLOT DATA=NINE ;
PBSPLINE Y=P20 X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=8) NOMARKERS
							  NAME="P20" LEGENDLABEL="20";
PBSPLINE Y=P40 X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=4) NOMARKERS
							  NAME="P40" LEGENDLABEL="40";
PBSPLINE Y=P80 X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=1) NOMARKERS
							  NAME="P80" LEGENDLABEL="80";
LABEL P20="Power" DELTA="Delta" ;
XAXIS VALUES=(0 TO .2 BY .05) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
YAXIS VALUES=(0 TO 1 BY 0.2) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
KEYLEGEND "P20" "P40" "P80"/ TITLE="Total Sample Size" VALUEATTRS=(SIZE=12PT) 
	TITLEATTRS=(SIZE=12PT);
RUN;

***********************************************************************;
* Section that creates plot with confidence limits for power for N=40 *;
***********************************************************************;

ODS GRAPHICS / IMAGENAME="Example7D";
ODS LISTING GPATH="&ROOT.\Examples" ;

TITLE1;
PROC SGPLOT DATA=ONECL NOAUTOLEGEND;
WHERE TOTAL_N=40;
SERIES Y=POWER_GG X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=1) ;
SERIES Y=POWER_GG_L X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=4) ;
SERIES Y=POWER_GG_U X=DELTA / LINEATTRS=(COLOR=BLACK PATTERN=4) ;
LABEL POWER_GG="Power" DELTA="Delta" ;
XAXIS VALUES=(0 TO .2 BY .05) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
YAXIS VALUES=(0 TO 1 BY 0.2) VALUEATTRS=(SIZE=12PT)
	LABELATTRS=(SIZE=12PT);
RUN;
