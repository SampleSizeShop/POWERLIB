OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example2.sas -- Power for a paired t-test";

PROC IML SYMSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

ESSENCEX = I(1);
SIGMA = {2 1, 1 2};
BETA = {0 1};
C = {1};
U = {1 -1}`;

SIGSCAL = {1};
BETASCAL = DO(0,2.5,0.5);
REPN = { 10 };
OPT_ON = {COLLAPSE};
OPT_OFF= {C U};

RUN POWER;
QUIT;

*******************************************;
* Section with difference scores          *;
* Provides output equivalent to the above *;
*******************************************;

PROC IML SYMSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

ESSENCEX = I(1);
SIGMA = {2}; * Variance of Difference of Means *;
BETA = {1};
C = {1};
U = {1};

SIGSCAL= {1};
BETASCAL = DO(0,2.5,0.5);
REPN = { 10 };
OPT_ON = {COLLAPSE};
OPT_OFF= {C U};

RUN POWER;
QUIT;
