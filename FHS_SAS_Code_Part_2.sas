/* FHS Project (Part 2) */
/* Descriptive Statistics, Log Linear Models, and Logistic Regression */

/* Import Data */
libname BS853 '/home/u58777110/BS 853/Project';

data FRM;
	set BS853.frmgham;
run;

options ps=60 ls=89 pageno=1 nodate;

/*************************************************/
/* Dataset Overview and Descriptive Statistics   */
/*************************************************/

/* Print First Five Observations */
title "First Five Observations";
proc print data = FRM (obs = 5);
	var randid sex age totchol cursmoke cigpday BMI period prevCHD CVD TimeCVD;
run;
	
/* Summary Statistics */
title1 "Number of Study Subjects";
proc sql;
    select count(distinct randid) as distinct_randid
    from FRM;
quit;

proc sql;
    select Period, count(distinct randid) as distinct_randid
    from FRM
    group by Period;
quit;

title1 "Current Smoking Summary Statistics";
proc freq data = FRM;
	table Period*cursmoke / nocol;
run; 

title1 "Prevalent Coronary Heart Disease Summary Statistics";
proc freq data = FRM;
	table Period*prevCHD / nocol;
run; 

title1 "CVD Summary Statistics";
proc sql;
    select CVD, count(distinct randid) as distinct_randid
    from FRM
    group by CVD;
quit;

title1 "Sex Summary Statistics";
proc freq data = FRM;
	table Period*Sex / nocol;
run; 


title1 "Age Histogram";
proc sgplot data=FRM;
	histogram Age;
	title "Distribution of Age";
	footnote "Framingham Heart Study";
run;

title1 "Age Summary Statistics";
proc means data = FRM mean std maxdec=2;
	var Age;
run;
proc means data = FRM mean std maxdec=2;
	class Period;
	var Age;
run;


title1 "Total Cholesterol Histogram";
proc sgplot data=FRM;
	histogram totchol;
	title "Distribution of Total Cholesterol";
	footnote "Framingham Heart Study";
run;

title1 "Total Cholesterol Summary Statistics";
proc means data = FRM mean std maxdec=2;
	var totchol;
run;
proc means data = FRM mean std maxdec=2;
	class Period;
	var totchol;
run;


title1 "LDL Cholesterol Histogram";
proc sgplot data=FRM;
	histogram LDLC;
	title "Distribution of LDL Cholesterol";
	footnote "Framingham Heart Study";
run;

title1 "LDL Cholesterol Summary Statistics (Only Measured at Period 3)";
proc means data = FRM mean std maxdec=2;
	var LDLC;
run;


/************************/
/*       All Periods    */
/************************/
data FRM;
	set FRM;
	if totchol = "." then chol = .; /* Missing Data */
	else if totchol < 200 then chol = 0; /* Normal */
	else if totchol >= 200 & totchol < 240 then chol = 1; /* Borderline High */
	else if totchol >= 240 then chol = 2; /* High */
run;

/* Determine Counts for Variables of Interest */
proc sql;
    select chol, cursmoke, prevCHD, period, count(*) as total_count
    from FRM
    group by chol, cursmoke, prevCHD, period;
quit;

Title 'Dataset for Generealized Mixed Effects Models';
data loglinear_all; 
input period chol cursmoke CHD Count; 
datalines; 
1 0 0 0 393
2 0 0 0 227
3 0 0 0 333
1 0 0 1 15
2 0 0 1 19
3 0 0 1 42
1 0 1 0 438
2 0 1 0 191
3 0 1 0 210
1 0 1 1 24
2 0 1 1 16
3 0 1 1 23
1 1 0 0 741
2 1 0 0 605
3 1 0 0 618
1 1 0 1 32
2 1 0 1 47
3 1 0 1 81
1 1 1 0 737
2 1 1 0 505
3 1 1 0 339
1 1 1 1 24
2 1 1 1 26
3 1 1 1 31
1 2 0 0 992
2 2 0 0 1118
3 2 0 0 814
1 2 0 1 59
2 2 0 1 107
3 2 0 1 118
1 2 1 0 889
2 2 1 0 862
3 2 1 0 403
1 2 1 1 38
2 2 1 1 64
3 2 1 1 37
; 
run;

/************************/
/* Restrict to Period 1 */
/************************/
data FRM_1;
	set BS853.frmgham;
	where Period = 1; /* Restrict to Period 1 */ 
run;

proc sgplot data = FRM_1;
	histogram totchol;
	title "Distribution of Total Cholesterol (Examination Cycle 1)";
	footnote "Framingham Heart Study";
run;

/*********************************************************************************/
/*  Log Linear Models: Total Cholesterol, Smoking, and CVD (Examination Cycle 1) */
/*********************************************************************************/
/* Create Categorical Variable for Total Cholesterol */
/* https://www.hopkinsmedicine.org/health/treatment-tests-and-therapies/lipid-panel */
data FRM_1;
	set FRM_1;
	if totchol = "." then chol = .; /* Missing Data */
	else if totchol < 200 then chol = 0; /* Normal */
	else if totchol >= 200 & totchol < 240 then chol = 1; /* Borderline High */
	else if totchol >= 240 then chol = 2; /* High */
run;

/* Histogram (Examination Cycle 1) */
proc sgplot data = FRM_1;
	histogram chol;
	title "Distribution of Total Cholesterol (Examination Cycle 1)";
	footnote "Framingham Heart Study";
run;

/* Determine Counts for Variables of Interest (Examination Cycle 1) */
proc sql;
    select chol, cursmoke, prevCHD, count(*) as total_count
    from FRM_1
    group by chol, cursmoke, prevCHD;
quit;

/* Create Dataset to Plot Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 1) */
Title 'Dataset for Plot of Odds of Prevalent CHD vs. Total Cholesterol (Examination Cycle 1)';
data plot_1; 
input chol cursmoke $ 3-12 CHDOdds; 
datalines; 
0 Non-Smoker 0.03817
0 Smoker     0.05479
1 Non-Smoker 0.04318
1 Smoker     0.03256
2 Non-Smoker 0.05948
2 Smoker     0.04274
; 
run;

/* Plot of Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 1) */
title1 'Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 1)';
symbol1 v=dot c=black;
symbol2 v=circle;
axis1 label=('Total Cholesterol Category');
axis2 label=(a=90 'Prevalent CHD Odds') minor=none ;
legend1 label=('Smoking Status');
proc gplot data = plot_1;
	plot CHDOdds*chol = cursmoke/vaxis=axis2 haxis=axis1 legend=legend1;
run;
quit;

/* Create new dataset for log-linear models (Examination Cycle 1) */
Title 'Dataset for Log Linear Models (Examination Cycle 1)';
data loglinear_1; 
input chol cursmoke CHD Count; 
datalines; 
0 0 0 393
0 0 1 15
0 1 0 438
0 1 1 24
1 0 0 741
1 0 1 32
1 1 0 737
1 1 1 24
2 0 0 992
2 0 1 59
2 1 0 889
2 1 1 38
; 
run;

/* Model 1: Saturated Model */
ods select ModelFit;
title 'Model 1: Saturated Model';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke|CHD / dist = Poisson;
run;

/* Model 2: All Two Way Interactions Model */
ods select ModelFit;
title 'Model 2: All Two Way Interactions Model';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD cursmoke|CHD / dist = Poisson;
run;

/* Model 3: Conditional Independence of Cholesterol and Smoking */
ods select ModelFit;
title 'Model 3: Conditional Independence of Cholesterol and Smoking';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke|CHD / dist = Poisson; 
run;

/* Model 4: Conditional Independence of Cholesterol and CHD */
ods select ModelFit;
title 'Model 4: Conditional Independence of Cholesterol and CHD';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke cursmoke|CHD / dist = Poisson; 
run;

/* Model 5: Conditional Independence of Smoking and CHD */
ods select ModelFit;
title 'Model 5: Conditional Independence of Smoking and CHD';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD / dist = Poisson; 
run;

/* Model 6: Joint Independence of (Cholesterol and Smoking) from CHD */
ods select ModelFit;
title 'Model 6: Joint Independence of (Cholesterol and Smoking) from CHD';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke CHD / dist = Poisson; 
run;

/* Model 7: Joint Independence of (Cholesterol and CHD) from Smoking */
ods select ModelFit;
title 'Model 7: Joint Independence of (Cholesterol and CHD) from Smoking';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke / dist = Poisson;
run;

/* Model 8: Joint Independence of (Smoking and CHD) from Cholesterol */
ods select ModelFit;
title 'Model 8: Joint Independence of (Smoking and CHD) from Cholesterol';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = cursmoke|CHD chol / dist = Poisson; 
run;

/* Model 9: Mutual Independence Model */
ods select ModelFit;
title 'Model 9: Mutual Independence Model';
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol cursmoke CHD / dist = Poisson; 
run;

/* Compute p-values using Deviance */
title 'Compute p-values using Deviance (Examination Cycle 1)';
data chi_square;
input Model Deviance df;
datalines;
2  3.3052 2
3 12.9123 4
4  6.5537 4
5  4.6905 3
6  8.0237 5
7 14.3823 5
8 16.2455 6
9 17.7155 7
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(Deviance, df);
run;

proc print data=chi_square;
run;


/* Final Model: (Model 6) Joint Independence of (Cholesterol and Smoking) from CHD (Examination Cycle 1) */
title 'Final Model: (Model 6) Joint Independence of (Cholesterol and Smoking) from CVD (Examination Cycle 1)';
ods select ModelFit ParameterEstimates Obstats;
ods output Obstats=check;
proc genmod data = loglinear_1; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke CHD / dist = Poisson obstats type3; 
run;

ods select plots;
proc univariate data = check normal plot;
	var reschi resdev;
run;



/************************/
/* Restrict to Period 2 */
/************************/
data FRM_2;
	set BS853.frmgham;
	where Period = 2; /* Restrict to Period 2 */ 
run;

proc sgplot data = FRM_2;
	histogram totchol;
	title "Distribution of Total Cholesterol (Examination Cycle 2)";
	footnote "Framingham Heart Study";
run;

/*********************************************************************************/
/*  Log Linear Models: Total Cholesterol, Smoking, and CVD (Examination Cycle 2) */
/*********************************************************************************/
/* Create Categorical Variable for Total Cholesterol */
/* https://www.hopkinsmedicine.org/health/treatment-tests-and-therapies/lipid-panel */
data FRM_2;
	set FRM_2;
	if totchol = "." then chol = .; /* Missing Data */
	else if totchol < 200 then chol = 0; /* Normal */
	else if totchol >= 200 & totchol < 240 then chol = 1; /* Borderline High */
	else if totchol >= 240 then chol = 2; /* High */
run;

/* Histogram (Examination Cycle 2) */
proc sgplot data = FRM_2;
	histogram chol;
	title "Distribution of Total Cholesterol (Examination Cycle 2)";
	footnote "Framingham Heart Study";
run;

/* Determine Counts for Variables of Interest (Examination Cycle 2) */
proc sql;
    select chol, cursmoke, prevCHD, count(*) as total_count
    from FRM_2
    group by chol, cursmoke, prevCHD;
quit;

/* Create Dataset to Plot Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 2) */
Title 'Dataset for Plot of Odds of Prevalent CHD vs. Total Cholesterol (Examination Cycle 2)';
data plot_2; 
input chol cursmoke $ 3-12 CHDOdds; 
datalines; 
0 Non-Smoker 0.08370
0 Smoker     0.08377
1 Non-Smoker 0.07769
1 Smoker     0.05149
2 Non-Smoker 0.09571
2 Smoker     0.07425
; 
run;

/* Plot of Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 2) */
title1 'Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 2)';
symbol1 v=dot c=black;
symbol2 v=circle;
axis1 label=('Total Cholesterol Category');
axis2 label=(a=90 'Prevalent CHD Odds') minor=none ;
legend1 label=('Smoking Status');
proc gplot data = plot_2;
	plot CHDOdds*chol = cursmoke/vaxis=axis2 haxis=axis1 legend=legend1;
run;
quit;

/* Create new dataset for log-linear models (Examination Cycle 2) */
Title 'Dataset for Log Linear Models (Examination Cycle 2)';
data loglinear_2; 
input chol cursmoke CHD Count; 
datalines; 
0 0 0 227
0 0 1 19
0 1 0 191
0 1 1 16
1 0 0 605
1 0 1 47
1 1 0 505
1 1 1 26
2 0 0 1118
2 0 1 107
2 1 0 862
2 1 1 64
; 
run;

/* Model 1: Saturated Model */
ods select ModelFit;
title 'Model 1: Saturated Model';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke|CHD / dist = Poisson;
run;

/* Model 2: All Two Way Interactions Model */
ods select ModelFit;
title 'Model 2: All Two Way Interactions Model';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD cursmoke|CHD / dist = Poisson;
run;

/* Model 3: Conditional Independence of Cholesterol and Smoking */
ods select ModelFit;
title 'Model 3: Conditional Independence of Cholesterol and Smoking';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke|CHD / dist = Poisson; 
run;

/* Model 4: Conditional Independence of Cholesterol and CHD */
ods select ModelFit;
title 'Model 4: Conditional Independence of Cholesterol and CHD';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke cursmoke|CHD / dist = Poisson; 
run;

/* Model 5: Conditional Independence of Smoking and CHD */
ods select ModelFit;
title 'Model 5: Conditional Independence of Smoking and CHD';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD / dist = Poisson; 
run;

/* Model 6: Joint Independence of (Cholesterol and Smoking) from CHD */
ods select ModelFit;
title 'Model 6: Joint Independence of (Cholesterol and Smoking) from CHD';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke CHD / dist = Poisson; 
run;

/* Model 7: Joint Independence of (Cholesterol and CHD) from Smoking */
ods select ModelFit;
title 'Model 7: Joint Independence of (Cholesterol and CHD) from Smoking';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke / dist = Poisson;
run;

/* Model 8: Joint Independence of (Smoking and CHD) from Cholesterol */
ods select ModelFit;
title 'Model 8: Joint Independence of (Smoking and CHD) from Cholesterol';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = cursmoke|CHD chol / dist = Poisson; 
run;

/* Model 9: Mutual Independence Model */
ods select ModelFit;
title 'Model 9: Mutual Independence Model';
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol cursmoke CHD / dist = Poisson; 
run;

/* Compute p-values using Deviance */
title 'Compute p-values using Deviance (Examination Cycle 2)';
data chi_square;
input Model Deviance df;
datalines;
2  0.9077 2
3  2.4885 4
4  4.5467 4
5  5.1749 3
6  8.9204 5
7  6.8622 5
8  6.2340 6
9 10.6077 7
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(Deviance, df);
run;

proc print data=chi_square;
run;

/* Final Model: (Model 9) Mutual Independence (Examination Cycle 2) */
title 'Final Model: (Model 9) Mutual Independence (Examination Cycle 2)';
ods select ModelFit ParameterEstimates Obstats;
ods output Obstats=check;
proc genmod data = loglinear_2; 
  class chol cursmoke CHD;
  model Count = chol cursmoke CHD / dist = Poisson obstats type3; 
run;

ods select plots;
proc univariate data = check normal plot;
	var reschi resdev;
run;



/************************/
/* Restrict to Period 3 */
/************************/
data FRM_3;
	set BS853.frmgham;
	where Period = 3; /* Restrict to Period 3 */ 
run;

/* Create Variable for Triglycerides */
data FRM_3;
	set FRM_3;
	Tri = 5*(totchol - HDLC - LDLC);
run;

proc sgplot data = FRM_3;
	histogram totchol;
	title "Distribution of Total Cholesterol (Examination Cycle 3)";
	footnote "Framingham Heart Study";
run;

proc sgplot data = FRM_3;
	histogram LDLC;
	title "Distribution of LDL Cholesterol (Examination Cycle 3)";
	footnote "Framingham Heart Study";
run;

proc sgplot data = FRM_3;
	histogram HDLC;
	title "Distribution of HDL Cholesterol (Examination Cycle 3)";
	footnote "Framingham Heart Study";
run;

proc sgplot data = FRM_3;
	histogram Tri;
	xaxis label = "Triglyceride Levels mg/dL";
	title "Distribution of Triglyceride Levels (Examination Cycle 3)";
	footnote "Framingham Heart Study";
run;

/************************************************************************/
/*   Log Linear Models: Total Cholesterol, Smoking, and CVD (Period 3)  */
/************************************************************************/
/* Create Categorical Variable for Total Cholesterol */
/* https://www.hopkinsmedicine.org/health/treatment-tests-and-therapies/lipid-panel */
data FRM_3;
	set FRM_3;
	if totchol = "." then chol = .; /* Missing Data */
	else if totchol < 200 then chol = 0; /* Normal */
	else if totchol >= 200 & totchol < 240 then chol = 1; /* Borderline High */
	else if totchol >= 240 then chol = 2; /* High */
run;

/* Histogram */
proc sgplot data = FRM_3;
	histogram chol;
	title "Distribution of Total Cholesterol";
	footnote "Framingham Heart Study";
run;

/* Determine Counts for Variables of Interest */
proc sql;
    select chol, cursmoke, prevCHD, count(*) as total_count
    from FRM_3
    group by chol, cursmoke, prevCHD;
quit;

/* Create Dataset to Plot Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status */
Title 'Dataset for Plot of Odds of Prevalent CHD vs. Total Cholesterol (Examination Cycle 3)';
data plot_3; 
input chol cursmoke $ 3-12 CHDOdds; 
datalines; 
0 Non-Smoker 0.12613
0 Smoker     0.10952
1 Non-Smoker 0.13107
1 Smoker     0.09145
2 Non-Smoker 0.14496
2 Smoker     0.09181
; 
run;

/* Plot of Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status */
title1 'Odds of Prevalent CHD vs. Total Cholesterol by Current Smoking Status (Examination Cycle 3)';
symbol1 v=dot c=black;
symbol2 v=circle;
axis1 label=('Total Cholesterol Category');
axis2 label=(a=90 'Prevalent CHD Odds') minor=none ;
legend1 label=('Smoking Status');
proc gplot data = plot_3;
	plot CHDOdds*chol = cursmoke/vaxis=axis2 haxis=axis1 legend=legend1;
run;
quit;

/* Create new dataset for log-linear models (Examination Cycle 3) */
Title 'Dataset for Log Linear Models (Examination Cycle 3)';
data loglinear_3; 
input chol cursmoke CHD Count; 
datalines; 
0 0 0 333
0 0 1 42
0 1 0 210
0 1 1 23
1 0 0 618
1 0 1 81
1 1 0 339
1 1 1 31
2 0 0 814
2 0 1 118
2 1 0 403
2 1 1 37
; 
run;

/* Model 1: Saturated Model */
ods select ModelFit;
title 'Model 1: Saturated Model';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke|CHD / dist = Poisson;
run;

/* Model 2: All Two Way Interactions Model */
ods select ModelFit;
title 'Model 2: All Two Way Interactions Model';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD cursmoke|CHD / dist = Poisson;
run;

/* Model 3: Conditional Independence of Cholesterol and Smoking */
ods select ModelFit;
title 'Model 3: Conditional Independence of Cholesterol and Smoking';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke|CHD / dist = Poisson; 
run;

/* Model 4: Conditional Independence of Cholesterol and CHD */
ods select ModelFit;
title 'Model 4: Conditional Independence of Cholesterol and CHD';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke cursmoke|CHD / dist = Poisson; 
run;

/* Model 5: Conditional Independence of Smoking and CHD */
ods select ModelFit;
title 'Model 5: Conditional Independence of Smoking and CHD';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke chol|CHD / dist = Poisson; 
run;

/* Model 6: Joint Independence of (Cholesterol and Smoking) from CHD */
ods select ModelFit;
title 'Model 6: Joint Independence of (Cholesterol and Smoking) from CHD';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|cursmoke CHD / dist = Poisson; 
run;

/* Model 7: Joint Independence of (Cholesterol and CHD) from Smoking */
ods select ModelFit;
title 'Model 7: Joint Independence of (Cholesterol and CHD) from Smoking';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol|CHD cursmoke / dist = Poisson;
run;

/* Model 8: Joint Independence of (Smoking and CHD) from Cholesterol */
ods select ModelFit;
title 'Model 8: Joint Independence of (Smoking and CHD) from Cholesterol';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = cursmoke|CHD chol / dist = Poisson; 
run;

/* Model 9: Mutual Independence Model */
ods select ModelFit;
title 'Model 9: Mutual Independence Model';
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = chol cursmoke CHD / dist = Poisson; 
run;

/* Compute p-values using Deviance */
title 'Compute p-values using Deviance (Examination Cycle 3)';
data chi_square;
input Model Deviance df;
datalines;
2  0.8669 2
3  8.1459 4
4  1.2069 4
5  8.6618 3
6  9.1088 5
7 16.0479 5
8  8.5930 6
9 16.4949 7
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(Deviance, df);
run;

proc print data=chi_square;
run;


/* Final Model: (Model 8) Joint Independence of (Smoking and CHD) from Cholesterol (Examination Cycle 3) */
title 'Final Model: (Model 8) Joint Independence of (Smoking and CHD) from Cholesterol (Examination Cycle 3)';
ods select ModelFit ParameterEstimates Obstats;
ods output Obstats=check;
proc genmod data = loglinear_3; 
  class chol cursmoke CHD;
  model Count = cursmoke|CHD chol / dist = Poisson obstats type3; 
run;

ods select plots;
proc univariate data = check normal plot;
	var reschi resdev;
run;



/*******************************************************************/
/*   Log Linear Models: Low Density Cholesterol, Smoking, and CVD  */
/*******************************************************************/
/* Create Categorical Variable for Low Density Cholesterol */
/* https://www.hopkinsmedicine.org/health/treatment-tests-and-therapies/lipid-panel */
data frmgham;
	set BS853.frmgham;
	where Period = 3; /* Restrict to Period 3 */ 
	if LDLC = "." then LDLchol = .; /* Missing Data */
	else if LDLC < 100 then LDLchol = 0; /* Optimal */
	else if LDLC >= 100 & LDLC < 130 then LDLchol = 1; /* Near Optimal */
	else if LDLC >= 130 & LDLC < 160 then LDLchol = 2; /* Borderline High */
	else if LDLC >= 160 & LDLC < 190 then LDLchol = 3; /* High */
	else if LDLC >= 190 then LDLchol = 4; /* Very High */
run;

/* Histogram */
proc sgplot data=frmgham;
	histogram LDLchol;
	title "Distribution of LDL Cholesterol";
	footnote "Framingham Heart Study";
run;

/* Determine Counts for Variables of Interest */
proc sql;
    select LDLchol, cursmoke, prevCHD, count(*) as total_count
    from frmgham
    group by LDLchol, cursmoke, prevCHD;
quit;

/* Create Dataset to Plot Odds of Prevalent CHD vs. LDL Cholesterol by Current Smoking Status */
Title 'Dataset for Plot of Odds of Prevalent CHD vs. LDL Cholesterol (Examination Cycle 3)';
data plot; 
input chol cursmoke $ 3-12 CHDOdds; 
datalines; 
0 Non-Smoker 0.11940
0 Smoker     0.07692
1 Non-Smoker 0.12571
1 Smoker     0.08000
2 Non-Smoker 0.10952
2 Smoker     0.08696
3 Non-Smoker 0.15618
3 Smoker     0.08696
4 Non-Smoker 0.14650
4 Smoker     0.11377
; 
run;

/* Plot of Odds of Prevalent CHD vs. LDL Cholesterol by Current Smoking Status */
title1 'Odds of Prevalent CHD  vs. LDL Cholesterol by Current Smoking Status (Examination Cycle 3)';
symbol1 v=dot c=black;
symbol2 v=circle;
axis1 label=('LDL Cholesterol Category');
axis2 label=(a=90 'Prevalent CHD Odds') minor=none ;
legend1 label=('Smoking Status');
proc gplot data = plot;
	plot CHDOdds*chol = cursmoke/vaxis=axis2 haxis=axis1 legend=legend1;
run;
quit;

/* Create new dataset for log-linear models (LDL Cholesterol) */
Title 'Dataset for Log Linear Models (LDL Cholesterol)';
data LDLloglinear; 
input LDLchol cursmoke CHD Count;
cLDLchol = LDLchol; 
cLDLchol_sq = cLDLchol**2;
datalines; 
0 0 0 67
0 0 1 8
0 1 0 26
0 1 1 2
1 0 0 175
1 0 1 22
1 1 0 125
1 1 1 10
2 0 0 420
2 0 1 46
2 1 0 207
2 1 1 18
3 0 0 461
3 0 1 72
3 1 0 253
3 1 1 22
4 0 0 628
4 0 1 92
4 1 0 334
4 1 1 38
; 
run;

/* Model 1: Saturated Model */
ods select ModelFit;
title 'Model 1: Saturated Model';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|cursmoke|CHD / dist = Poisson;
run;

/* Model 2: All Two Way Interactions Model */
ods select ModelFit;
title 'Model 2: All Two Way Interactions Model';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|cursmoke LDLchol|CHD cursmoke|CHD / dist = Poisson;
run;

/* Model 3: Conditional Independence of LDL Cholesterol and Smoking */
ods select ModelFit;
title 'Model 3: Conditional Independence of LDL Cholesterol and Smoking';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|CHD cursmoke|CHD / dist = Poisson; 
run;

/* Model 4: Conditional Independence of LDL Cholesterol and CVD */
ods select ModelFit;
title 'Model 4: Conditional Independence of LDL Cholesterol and CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|cursmoke cursmoke|CHD / dist = Poisson; 
run;

/* Model 5: Conditional Independence of Smoking and CHD */
ods select ModelFit;
title 'Model 5: Conditional Independence of Smoking and CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|cursmoke LDLchol|CHD / dist = Poisson; 
run;

/* Model 6: Joint Independence of (LDL Cholesterol and Smoking) from CHD */
ods select ModelFit;
title 'Model 6: Joint Independence of (LDL Cholesterol and Smoking) from CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|cursmoke CHD / dist = Poisson; 
run;

/* Model 7: Joint Independence of (LDL Cholesterol and CHD) from Smoking */
ods select ModelFit;
title 'Model 7: Joint Independence of (LDL Cholesterol and CHD) from Smoking';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol|CHD cursmoke / dist = Poisson;
run;

/* Model 8: Joint Independence of (Smoking and CHD) from LDL Cholesterol */
ods select ModelFit;
title 'Model 8: Joint Independence of (Smoking and CHD) from LDL Cholesterol';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = cursmoke|CHD LDLchol / dist = Poisson; 
run;

/* Model 9: Mutual Independence Model */
ods select ModelFit;
title 'Model 9: Mutual Independence Model';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD / dist = Poisson; 
run;

/* Models Treating Low Density Cholesterol as Continuous */
ods select ModelFit;
title 'Model 10: All Two Way Interactions Model';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke and cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke cLDLchol*CHD cLDLchol_sq*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 11: Conditional Independence of Smoking and Heart Disease';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke and cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke cLDLchol*CHD cLDLchol_sq*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 12: All Two Way Interactions Model';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke and a linear interaction term for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke cLDLchol*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 13: Conditional Independence of Smoking and Heart Disease';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke and a linear interaction term for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke cLDLchol*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 14: All Two Way Interactions Model';
title2 'with a linear interaction term for cLDLchol*cursmoke and linear and quadratic interaction terms for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol*CHD cLDLchol_sq*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 15: Conditional Independence of Smoking and Heart Disease';
title2 'with a linear interaction term for cLDLchol*cursmoke and linear and quadratic interaction terms for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol*CHD cLDLchol_sq*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 16: All Two Way Interactions Model';
title2 'with linear interaction terms for cLDLchol*cursmoke and cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 17: Conditional Independence of Smoking and Heart Disease';
title2 'with linear interaction terms for cLDLchol*cursmoke and cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 18: Conditional Independence of LDL Cholesterol and Heart Disease';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 19: Joint Independence of (LDL Cholesterol and Smoking) from Heart Disease';
title2 'with linear and quadratic interaction terms for cLDLchol*cursmoke';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cLDLchol_sq*cursmoke / dist = Poisson;
run;

ods select ModelFit;
title 'Model 20: Conditional Independence of LDL Cholesterol and Smoking';
title2 'with linear and quadratic interaction terms for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*CHD cLDLchol_sq*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 21: Joint Independence of (LDL Cholesterol and Heart Disease) from Smoking';
title2 'with linear and quadratic interaction terms for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*CHD cLDLchol_sq*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 22: Conditional Independence of LDL Cholesterol and Heart Disease';
title2 'with a linear interaction term for cLDLchol*cursmoke';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 23: Joint Independence of (LDL Cholesterol and Smoking) from Heart Disease';
title2 'with a linear interaction term for cLDLchol*cursmoke';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*cursmoke / dist = Poisson;
run;

ods select ModelFit;
title 'Model 24: Conditional Independence of LDL Cholesterol and Smoking';
title2 'with a linear interaction term for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*CHD cursmoke*CHD / dist = Poisson;
run;

ods select ModelFit;
title 'Model 25: Joint Independence of (LDL Cholesterol and Heart Disease) from Smoking';
title2 'with a linear interaction term for cLDLchol*CHD';
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = LDLchol cursmoke CHD cLDLchol*CHD / dist = Poisson;
run;


/* Compute p-values using Deviance */
title 'Compute p-values using Deviance (Examination Cycle 3)';
data chi_square;
input Model Deviance df;
datalines;
2   1.3305 4
3  10.5369 8
4   5.6112 8
5   9.5184 5
6  13.7827 9
7  18.7085 9
8  14.8013 12
9  22.9728 13
10 11.4424 8
11 19.5489 9
12 11.5489 9
13 19.6592 10
14 11.4544 9
15 19.5657 10
16 11.5646 10
17 19.6759 11
18 14.6389 10
19 22.8104 11
20 11.5398 10
21 19.7113 11
22 14.6556 11
23 22.8272 12
24 11.6500 11
25 19.8215 12
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(Deviance, df);
run;

proc print data=chi_square;
run;


/* Initial Selected Model: (Model 8) Joint Independence of (Smoking and CHD) from LDL Cholesterol (Examination Cycle 3) */
title 'Initial Selected Model: (Model 8) Joint Independence of (Smoking and CHD) from LDL Cholesterol (Examination Cycle 3)';
ods select ModelFit ParameterEstimates Obstats;
ods output Obstats=check;
proc genmod data = LDLloglinear; 
  class LDLchol cursmoke CHD;
  model Count = cursmoke|CHD LDLchol / dist = Poisson obstats type3; 
run;

ods select plots;
proc univariate data = check normal plot;
	var reschi resdev;
run;


/*********************************/
/*   Logistic Regression Models  */
/*********************************/
data FRM;
	set FRM;
	where Period = 3;
	if LDLC = "." then LDLchol = .; /* Missing Data */
	else if LDLC < 100 then LDLchol = 0; /* Optimal */
	else if LDLC >= 100 & LDLC < 130 then LDLchol = 1; /* Near Optimal */
	else if LDLC >= 130 & LDLC < 160 then LDLchol = 2; /* Borderline High */
	else if LDLC >= 160 & LDLC < 190 then LDLchol = 3; /* High */
	else if LDLC >= 190 then LDLchol = 4; /* Very High */
run;

/***********************/
/* Models Ignoring Age */
/***********************/
title1 'Model 1: Two Way Interaction Model (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol cursmoke*LDLchol;
run;

title1 'Model 2: Mutual Independence Model (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol;
run;

title1 'Model 3: Two Way Interaction Model (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol cursmoke*LDLchol;
run;

title1 'Model 4: Mutual Independence Model (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol;
run;

/* Compute p-values using -2 log likelihoods (Models Ignoring Age) */
title 'Compute p-values using -2 log likelihoods (Models Ignoring Age)';
data chi_square;
input Model LL df;
datalines;
1 2071.341 0
2 2072.672 4
3 2073.780 6
4 2073.862 7
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(LL-2071.341, df);
run;

proc print data = chi_square;
run;

/* Final Model (NOT Including Age) */
title1 'Final Model (NOT Including Age): Mutual Independence Model (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol;
run;

/************************/
/* Models Including Age */
/************************/
title1 'Model 1: Three Way Interaction Model (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age LDLchol*age cursmoke*LDLchol*age;
run;

title1 'Model 2: All Two Way Interactions Model (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age LDLchol*age;
run;

title1 'Model 3: Conditional Independence of Smoking and LDL Cholesterol (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*age LDLchol*age;
run;

title1 'Model 4: Conditional Independence of Smoking and Age (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol LDLchol*age;
run;

title1 'Model 5: Conditional Independence of LDL Cholesterol and Age (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age;
run;

title1 'Model 6: Joint Independence of (Smoking and LDL Cholesterol) from Age (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol;
run;

title1 'Model 7: Joint Independence of (Smoking and Age) from LDL Cholesterol (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*age;
run;

title1 'Model 8: Joint Independence of (LDL Cholesterol and Age) from Smoking (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age LDLchol*age;
run;

title1 'Model 9: Mutual Independence of Smoking, LDL Cholesterol, and Age (LDL Categorical)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref) LDLchol(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age;
run;

title1 'Model 10: Three Way Interaction Model (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age LDLchol*age cursmoke*LDLchol*age;
run;

title1 'Model 11: All Two Way Interactions Model (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age LDLchol*age;
run;

title1 'Model 12: Conditional Independence of Smoking and LDL Cholesterol (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*age LDLchol*age;
run;

title1 'Model 13: Conditional Independence of Smoking and Age (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol LDLchol*age;
run;

title1 'Model 14: Conditional Independence of LDL Cholesterol and Age (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol cursmoke*age;
run;

title1 'Model 15: Joint Independence of (Smoking and LDL Cholesterol) from Age (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*LDLchol;
run;

title1 'Model 16: Joint Independence of (Smoking and Age) from LDL Cholesterol (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age cursmoke*age;
run;

title1 'Model 17: Joint Independence of (LDL Cholesterol and Age) from Smoking (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age LDLchol*age;
run;

title1 'Model 18: Mutual Independence of Smoking, LDL Cholesterol, and Age (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age;
run;

/* Compute p-values using -2 log likelihoods (Models Including Age) */
title 'Compute p-values using -2 log likelihoods (Models Including Age)';
data chi_square;
input Model LL df;
datalines;
1  1969.512 0
2  1972.335 4
3  1974.256 8
4  1975.911 5
5  1974.813 8
6  1978.428 9
7  1976.916 12
8  1977.599 9
9  1980.322 13
10 1975.817 12
11 1976.010 13
12 1976.488 14
13 1979.447 14
14 1977.515 14
15 1981.061 15
16 1977.760 15
17 1979.979 15
18 1981.248 16
;
run;

data chi_square;
	set chi_square;
	pvalue = 1 - probchi(LL-1969.512, df);
run;

proc print data = chi_square;
run;

/* Final Model (Including Age) */
title1 'Final Model (Including Age): Mutual Independence of Smoking, LDL Cholesterol, and Age (LDL Continuous)';
proc logistic data = FRM;
	class cursmoke(ref = '0' param = ref);
	model prevCHD(event = '1') = cursmoke LDLchol age;
run;



