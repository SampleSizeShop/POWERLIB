OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example11.sas -- Illustrate use of the UPOLY1 module";

PROC IML WORKSIZE=1000 SYMSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_ON  = {GG HF HLT PBT TOTAL_N};
OPT_OFF = {WARN WLK UN COLLAPSE ALPHA SIGSCAL BETASCAL};

ALPHA = .05;
VARIANCE = 1.5;  
RHO = 0.25;
* Create compound symmetric covariance structure *;
SIGMA = VARIANCE#(I(5)#(1-RHO) + J(5,5,RHO)); 

ESSENCEX = I(2);
REPN = {10,20,40};

BETASCAL = 1;
BETA = {0 0 0 0 1,
        1 0 0 0 0};
C = {1 -1};

TIMES ={2 4 6 8 10};
RUN UPOLY1(TIMES  ,"Time", USCORE , SCORENM );
U = USCORE;

RUN POWER;
QUIT;
