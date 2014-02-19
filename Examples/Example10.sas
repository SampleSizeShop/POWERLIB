OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example10.sas -- Power for high dimension low sample size data";

*********************************************************;
* From Chi YY, Gribbin MJ, Johnson JJ, Muller KE (2013) *;
* Power calculation for overall hypothesis testing      *;
* with high-dimensional commensurate outcomes           *;
* Statistics in Medicine                                *;
* Section 4: Study of Vitamin B6 Deficiency             *;
*********************************************************;

LIBNAME IN01 "&ROOT.\Data\";

PROC IML SYMSIZE=1000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;
RESET FUZZ SPACES=2;

USE IN01.EX10;
READ ALL VAR _NUM_ INTO SIGMA;

BETA=J(1,19,0.14);
N_EST=12;
RANK_EST=1;
SIGTYPE=1;
C=1;
REPN={10,15};
ESSENCEX={1};
U=I(19);

OPT_ON={ORTHU UNIFORCE CM};
OPT_OFF={ WARN GG UN BOX WLK HLT PBT SIGMA BETA ESSENCEX RHO U CBETAU C};

TITLE3 "Power when all amino acids exhibit mean difference = 0.14 log(umol/L)";
RUN POWER;

BETA=J(1,19,0);
BETA[1,17]=0.55;

TITLE3 "Power when mean difference in cystathionine = 0.55 log(umol/L)";
RUN POWER;

run; quit;
