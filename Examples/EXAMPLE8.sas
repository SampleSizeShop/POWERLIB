TITLE1 "EXAMPLE8.SAS--Illustrate use of the UPOLY3 module";
TITLE2 "Factorial design, repeated measures: A, B, C between, D, E, F within";

*** Section that creates contrast matrices without UPOLY3 module***;

TITLE3 "UPOLY3 module not used";
PROC IML SYMSIZE=1000 WORKSIZE=2000;
RESET FUZZ NOAUTONAME FW=6 LINESIZE=80;
%INCLUDE "&ROOT.\Iml\POWERLIB21.IML"/NOSOURCE2;

ALPHA = .05;

* Choose dimensions of design *;
GA = 3; * =# groups for between factor A *;
GB = 3; * =# groups for between factor B *;
GC = 3; * =# groups for between factor C *;
TD = 3; * =#Times for within factor D *;
TE = 3; * =#Times for within factor E *;
TF = 3; * =#Times for within factor F *;

P = TD#TE#TF;
Q = GA#GB#GC;
ESSENCEX = I(Q);
BETA = J(Q,P,0);
BETA[1,1] = 1;

SIGMA=DIAG(DO(1,P,1));* Variances are 1,2,3,...p *;

* Get orthonormal submatrices for U matrices *;
POLYD = ORPOL(1:TD);  
UD1 = POLYD[,2:NCOL(POLYD)]`;
POLYE = ORPOL(1:TE);  
UE1 = POLYE[,2:NCOL(POLYE)]`;
POLYF = ORPOL(1:TF);  
UF1 = POLYF[,2:NCOL(POLYF)]`;

* U matrix for Main effect D *;
UD = (UD1 @ J(1,TE,1) @ J(1,TF,1))`;

* U matrix for Main effect E *;
UE = (J(1,TD,1) @ UE1 @ J(1,TF,1))`;

* U matrix for Main effect F *;
UF = (J(1,TD,1) @ J(1,TE,1) @ UF1)`;

* U matrix for DxE interaction *;
UDE = HDIR(UD,UE);

* U matrix for DxExF interaction *;
UDEF = HDIR(UDE,UF);

* Get submatrices for between factors *;
CA1 = J(GA-1,1,-1)||I(GA-1);
CB1 = J(GB-1,1,-1)||I(GB-1);
CC1 = J(GC-1,1,-1)||I(GC-1);

* Main effect A *;
CA = CA1 @ J(1,GB,1) @ J(1,GC,1);

* Main effect B *;
CB = J(1,GA,1) @ CB1 @ J(1,GC,1);

* Main effect C[FORMAT=2.] *;
CC = J(1,GA,1) @ J(1,GB,1) @ CC1;

* AxB interaction *;
CAB = (HDIR(CA`,CB`))`;

* AxBxC interaction *;
CABC = (HDIR(CAB`,CC`))`;

BETASCAL = {9 18 27};
ROUND = 4;
OPT_ON = {NOPRINT  GG HF UN  PBT HLT WLK};
OPT_OFF = {WARN SIGSCAL ALPHA};
BUG = " ";

C = CA;
U = UD;
  DO REPN = 2 TO 12 BY 2;
  RUN POWER;
  HOLDA=HOLDA//_HOLDPOWER;
  END;
PRINT / "AxD";
PRINT HOLDA[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

C = CAB;
U = UDE;
  DO REPN=2 TO 12 BY 2;
  RUN POWER;
  HOLDABDE=HOLDABDE//_HOLDPOWER;
  END;
PRINT / "AxB x DxE Interaction";
PRINT HOLDABDE[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

C = CABC;
U = UDEF;
  DO REPN=2 TO 12 BY 2;
  RUN POWER;
  HABCDEF=HABCDEF//_HOLDPOWER;
  END;
PRINT / "AxBxC x DxExF Interaction";
PRINT HABCDEF[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

QUIT;

*** Section that creates contrast matrices with UPOLY3 module ***;

TITLE3 "UPOLY3 module used to create contrast matrices";

PROC IML SYMSIZE=1000 WORKSIZE=2000;
RESET FUZZ NOAUTONAME FW=6 LINESIZE=80;
%INCLUDE "&ROOT.\Iml\POWERLIB21.IML"/NOSOURCE2;

ALPHA = .05;

* Choose dimensions of design *;
GA = 3; * =# groups for between factor A *;
GB = 3; * =# groups for between factor B *;
GC = 3; * =# groups for between factor C *;
TD = 3; * =#Times for within factor D *;
TE = 3; * =#Times for within factor E *;
TF = 3; * =#Times for within factor F *;

P = TD#TE#TF;
Q = GA#GB#GC;
ESSENCEX = I(Q);
BETA = J(Q,P,0);
BETA[1,1] = 1;

SIGMA = DIAG(DO(1,P,1)); * Variances are 1,2,3,...p *;

* Get orthonormal U matrices *;
CALL UPOLY3 ( (1:TD),"D", (1:TE),"E",  (1:TF),"F",
		          UD,UDLBL,   UE,UELBL,    UF,UFLBL, 
                 UDE,UDELBL, UDF,UDFLBL,  UEF,UEFLBL,  UDEF,UDEFLBL );
 
* Get orthonormal C matrices *;
CALL UPOLY3 ((1:GA),"A" , (1:GB),"B" , (1:GC),"C",
		         U1,CALBL,    U2,CBLBL,    U3,CCLBL,
                U12,CABLBL, U13,CACLBL,   U23,CBCLBL,  U123,CABCLBL);

BETASCAL = {9 18 27};
ROUND = 4;
OPT_ON = {NOPRINT  GG HF UN  PBT HLT WLK};
OPT_OFF = {WARN SIGSCAL ALPHA};
BUG=" ";

C = U1`;
U = UD;
  DO REPN = 2 TO 12 BY 2;
  RUN POWER;
  HOLDA=HOLDA//_HOLDPOWER;
  END;
PRINT / "AxD";
PRINT HOLDA[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

C = U12`;
U = UDE;
  DO REPN = 2 TO 12 BY 2;
  RUN POWER;
  HOLDABDE = HOLDABDE//_HOLDPOWER;
  END;
PRINT / "AxB x DxE Interaction";
PRINT HOLDABDE[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

C = U123`;
U = UDEF;
  DO REPN = 2 TO 12 BY 2;
  RUN POWER;
  HABCDEF = HABCDEF//_HOLDPOWER;
  END;
PRINT / "AxBxC x DxExF Interaction";
PRINT HABCDEF[COLNAME=_HOLDPOWERLBL ROWNAME=BUG];

QUIT;
