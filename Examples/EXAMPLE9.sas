OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example9.SAS-- Power within the context of an internal pilot design";

***********************************************************************************;
* From Coffey C.S. and Muller K.E. (2003)                                         *;
* Properties of internal pilots with the univariate approach to repeated measures *;
* Statistics in Medicine, 22(15)                                                  *;
***********************************************************************************;

***************************************************;
* Delete data sets for power values if they exist *;
***************************************************;

PROC DATASETS LIBRARY=WORK NOLIST NODETAILS;
DELETE ONE TWO ONE_S TWO_S;
RUN; QUIT;

**************************************;
* Section that computes power values *;
**************************************;

PROC IML SYMSIZE=1000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

ALPHA = .04;
OPT_ON = {NOPRINT GG HF BOX TOTAL_N  IP_PLAN};
OPT_OFF = {WARN ALPHA  BETASCAL  HLT PBT WLK };
ROUND = 2;

BETASCAL = 1;
THETA = {.25}#{.5 1 -1 .5}; * =Theta(cr) from 1st sentence *after* 
                            *  equation 7, Coffey and Muller (2003); 

* Following from Table II in Coffey and Muller (2003) *;
VARSTARE = {.47960 .01000 .01000 .01000}; * epsilon ~ .28 *; 
VARSTARF = {.34555 .06123 .05561 .04721}; * epsilon ~ .50 *;
VARSTARG = {.23555 .17123 .05561 .04721}; * epsilon ~ .72 *;
VARSTARH = {.12740 .12740 .12740 .12740}; * epsilon = 1 *;
VARSTAR = VARSTARE//VARSTARF//VARSTARG//VARSTARH;

SIGSCAL = {0.50 1.00 2.00}; * <=> gamma in Coffey and Muller (2003) *;

* Log base 2 spacing Clip (2,4,16) and Region(2,8,32) *;
* Get orthonormal U matrices *;
RUN UPOLY2({1 2 4},"A", {1 3 5},"B",
            UA,NMA, UB,NMB, UAB,NMAB);
U = UAB;
C = 1;

ESSENCEX = {1};
REPN = {20};

*************************************;
* Compute power for a non-IP design *;
*************************************;

IP_PLAN=0; *Default, but specified for clarity;

DO IVAR = 1 TO 4 BY 1;
	SIGSTAR = DIAG(VARSTAR[IVAR,*]);
 
	SIGMA = U*SIGSTAR*U`;  * 1st paragraph in section 2.4, Coffey and Muller 2003 *;
	BETA = THETA*U`;       * 1st paragraph in section 2.4, Coffey and Muller 2003 *; 

	RUN POWER;

	HOLDALL = HOLDALL//_HOLDPOWER;
    END;

CREATE ONE VAR _HOLDPOWERLBL;
APPEND FROM HOLDALL;
FREE HOLDALL;

*************************************;
* Compute power within an IP design *;
*************************************;

IP_PLAN=1;
N_IP=10;
RANK_IP=1;

DO IVAR = 1 TO 4 BY 1;
	SIGSTAR = DIAG(VARSTAR[IVAR,*]);
 
	SIGMA = U*SIGSTAR*U`;  * 1st paragraph in section 2.4, Coffey and Muller 2003 *;
	BETA = THETA*U`;       * 1st paragraph in section 2.4, Coffey and Muller 2003 *; 

	RUN POWER;

	HOLDALL = HOLDALL//_HOLDPOWER;
    END;

CREATE TWO VAR _HOLDPOWERLBL;
APPEND FROM HOLDALL;


QUIT;

*****************;
* Print results *;
*****************;

%MACRO PRINT(DATA=);

PROC SORT DATA=&DATA OUT=&DATA._S;
BY SIGSCAL EPSILON;
RUN;

PROC PRINT DATA=&DATA._S UNIFORM NOOBS;
BY TOTAL_N;
TITLE4 "All data in file";
RUN;

PROC PRINT DATA=&DATA._S(RENAME=(SIGSCAL=GAMMA)) UNIFORM NOOBS;
VAR EPSILON GAMMA  POWER_GG POWER_HF ; 
BY  TOTAL_N;
TITLE4 "Table III, Coffey and Muller (2003)";
RUN;

%MEND;

TITLE3 "Power computed for a non-IP design";
%PRINT(DATA=ONE);

TITLE3 "Power computed for an IP design";
%PRINT(DATA=TWO);
