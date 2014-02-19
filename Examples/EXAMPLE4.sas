OPTIONS NODATE NONUMBER PS=55 LS=95;
TITLE1 "Example4.sas -- Power for a test of the interaction" ;
TITLE2 "of between and within factors in a multivariate model";
TITLE3 "Compares power of tests when SIGMA most favorable to UN";

PROC IML SYMSIZE=1000 WORKSIZE=2000;
%INCLUDE "&ROOT.\IML\POWERLIB22.IML"/NOSOURCE2;

OPT_OFF={ALPHA};
OPT_ON = {ORTHU UN HF GG BOX HLT PBT WLK MMETHOD UMETHOD MMETHOD};
* Specifying the option ORTHU in OPT_ON allows the program to provide;
* an orthonormal U matrix if one is not given by the user;
* This is the case for the following code;

* Create contrast matrices C and U (non-orthonormal) *;
P = 3;
Q = 4;
C = J(Q-1,1,1)||(-I(Q-1));
U = ( J(P-1,1,1)||(-I(P-1)) )`;

ALPHA = .01;

VARIANCE = 1;  
RHO = 0.4;
SIGMA = VARIANCE#(I(P)#(1-RHO) + J(P,P,RHO)); *Compound symmetry;
SIGSCAL = {1, 2};

ESSENCEX = I(Q); 
REPN = {5,10};
BETA = J(Q,P,0);
BETA[1,1] = 1;
BETASCAL = DO(0, 2.0 , 0.50);

MMETHOD = {4,4,4}; * Two moment null approximations + OBrien and Shieh (1992) 
					 noncentrality multiplier ON;

UCDF = {4,2,2,2,4};  * UN and Box (4):
					 Exact via Davies' algorithm (1980), as in Muller, 
					 Edwards, Simpson, and Taylor (2007). If exact fails, 
					 then switch to approximation 2, MEST (2007);
                   * HF, CM, GG (2): 
					 Muller, Edwards, Simpson, and Taylor (2007) 
					 approximation;

RUN POWER;

QUIT;
