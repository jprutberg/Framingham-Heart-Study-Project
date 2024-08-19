/* Jason Rutberg Project (BS 805) */

/* Question 1: Data Import */
libname BS805 '/home/u58777110/BS 805/Project';

proc format;
	value periodf 1 = 'Period 1'  2 = 'Period 2'  3 = 'Period 3';
    value sexf 1 = 'Male'  2 = 'Female';
	value cursmokef 1 = 'Current Smoker'  0 = 'Not Current Smoker';
	value diabetesf 1 = 'Diabetic'  0 = 'Not Diabetic';
	value bpmedsf 1 = 'Currently Using'  0 = 'Not Currently Using';
run;

/* Check PROC TRANSPOSE */
data FRM;
	set BS805.frmgham2023;
	keep randid period sex totchol age sysbp diabp cursmoke cigpday bmi diabetes bpmeds heartrte glucose ldlc hdlc;
	format period periodf. sex sexf. cursmoke cursmokef. diabetes diabetesf. bpmeds bpmedsf.;
	label randid = "Unique Identification Number";
	label period = "Examination Cycle";
	label sex = "Participant Sex";
	label totchol = "Serum Total Cholesterol (mg/dL)";
	label age = "Age at exam (years)";
	label sysbp = "Systolic Blood Pressure (mean of last two of three measurements) (mmHg)";
	label diabp = "Diastolic Blood Pressure (mean of last two of three measurements) (mmHg)";
	label cursmoke = "Current Cigarette Smoking Status at Exam";
	label cigpday = "Number of Cigarettes Smoked per Day";
	label bmi = "Body Mass Index, weight in kilograms/height meters squared";
	label diabetes = "Diabetic according to criteria of first exam treated or first exam with casual glucose of 200 mg/dL or more";
	label bpmeds = "Use of Anti-hypertensive medication at exam";
	label heartrte = "Heart rate (Ventricular rate) in beats/min";
	label glucose = "Casual serum glucose (mg/dL)";
	label ldlc = "Low Density Lipoprotein Cholesterol (mg/dL)";
	label hdlc = "High Density Lipoprotein Cholesterol (mg/dL)";
run;


/***********************/


/* Question 2: Descriptive Statistics */
data FRM_Period1;
	set FRM;
	where period = 1;
run;

title "Question 2: Descriptive Statistics for Continuous Variables";
proc means data = FRM_Period1 maxdec = 2 n mean std median min max q1 q3;
	var totchol age sysbp diabp cigpday bmi heartrte glucose;
run;

title "Question 2: Descriptive Statistics for Categorical Variables";
proc freq data = FRM_period1;
	table sex cursmoke diabetes bpmeds;
run;


/***********************/


/* Question 3: Framingham Risk Score (FRS) Computation */
data FRM_Period3;
	set FRM;
	where period = 3;
run;

/* Age Risk Points */
data FRM_Period3;
	set FRM_Period3;
	
	/* Age Points */
	if age = . then age_points = .;
	else if sex = 1 and age >= 30 and age < 35 then age_points = -1;
	else if sex = 1 and age >= 35 and age < 40 then age_points = 0;
	else if sex = 1 and age >= 40 and age < 45 then age_points = 1;
	else if sex = 1 and age >= 45 and age < 50 then age_points = 2;
	else if sex = 1 and age >= 50 and age < 55 then age_points = 3;
	else if sex = 1 and age >= 55 and age < 60 then age_points = 4;
	else if sex = 1 and age >= 60 and age < 65 then age_points = 5;
	else if sex = 1 and age >= 65 and age < 70 then age_points = 6;
	else if sex = 1 and age >= 70 then age_points = 7;
	else if sex = 2 and age >= 30 and age < 35 then age_points = -9;
	else if sex = 2 and age >= 35 and age < 40 then age_points = -4;
	else if sex = 2 and age >= 40 and age < 45 then age_points = 0;
	else if sex = 2 and age >= 45 and age < 50 then age_points = 3;
	else if sex = 2 and age >= 50 and age < 55 then age_points = 6;
	else if sex = 2 and age >= 55 and age < 60 then age_points = 7;
	else if sex = 2 and age >= 60 and age < 65 then age_points = 8;
	else if sex = 2 and age >= 65 and age < 70 then age_points = 8;
	else if sex = 2 and age >= 70 then age_points = 8;
	
	/* LDLC Points */
	if ldlc = . then ldlc_points = .;
	else if sex = 1 and ldlc < 100 then ldlc_points = -3;
	else if sex = 1 and ldlc >= 100 and ldlc < 130 then ldlc_points = 0;
	else if sex = 1 and ldlc >= 130 and ldlc < 160 then ldlc_points = 0;
	else if sex = 1 and ldlc >= 160 and ldlc < 190 then ldlc_points = 1;
	else if sex = 1 and ldlc >= 190 then ldlc_points = 2;
	else if sex = 2 and ldlc < 100 then ldlc_points = -2;
	else if sex = 2 and ldlc >= 100 and ldlc < 130 then ldlc_points = 0;
	else if sex = 2 and ldlc >= 130 and ldlc < 160 then ldlc_points = 0;
	else if sex = 2 and ldlc >= 160 and ldlc < 190 then ldlc_points = 2;
	else if sex = 2 and ldlc >= 190 then ldlc_points = 2;
	
	/* HDLC Points */
	if hdlc = . then hdlc_points = .;
	else if sex = 1 and hdlc < 35 then hdlc_points = 2;
	else if sex = 1 and hdlc >= 35 and hdlc < 45 then hdlc_points = 1;
	else if sex = 1 and hdlc >= 45 and hdlc < 50 then hdlc_points = 0;
	else if sex = 1 and hdlc >= 50 and hdlc < 60 then hdlc_points = 0;
	else if sex = 1 and hdlc >= 60 then hdlc_points = -2;
	else if sex = 2 and hdlc < 35 then hdlc_points = 5;
	else if sex = 2 and hdlc >= 35 and hdlc < 45 then hdlc_points = 2;
	else if sex = 2 and hdlc >= 45 and hdlc < 50 then hdlc_points = 1;
	else if sex = 2 and hdlc >= 50 and hdlc < 60 then hdlc_points = 0;
	else if sex = 2 and hdlc >= 60 then hdlc_points = -2;
	
	/* Blood Pressure Points */
	if sysbp = . or diabp = . then bp_points = .;
	else if sex = 1 and sysbp < 120 and diabp < 85 then bp_points = 0;
	else if sex = 1 and sysbp < 120 and diabp >= 85 and diabp < 90 then bp_points = 1;
	else if sex = 1 and sysbp < 120 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 1 and sysbp < 120 and diabp >= 100 then bp_points = 3;
	else if sex = 1 and sysbp >= 120 and sysbp < 130 and diabp < 85 then bp_points = 0;
	else if sex = 1 and sysbp >= 120 and sysbp < 130 and diabp >= 85 and diabp < 90 then bp_points = 1;
	else if sex = 1 and sysbp >= 120 and sysbp < 130 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 1 and sysbp >= 120 and sysbp < 130 and diabp >= 100 then bp_points = 3;
	else if sex = 1 and sysbp >= 130 and sysbp < 140 and diabp < 90 then bp_points = 1;
	else if sex = 1 and sysbp >= 130 and sysbp < 140 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 1 and sysbp >= 130 and sysbp < 140 and diabp >= 100 then bp_points = 3;
	else if sex = 1 and sysbp >= 140 and sysbp < 160 and diabp < 100 then bp_points = 2;
	else if sex = 1 and sysbp >= 140 and sysbp < 160 and diabp >= 100 then bp_points = 3;
	else if sex = 1 and sysbp >= 160 then bp_points = 3;
	else if sex = 2 and sysbp < 120 and diabp < 80 then bp_points = -3;
	else if sex = 2 and sysbp < 120 and diabp >= 80 and diabp < 90 then bp_points = 0;
	else if sex = 2 and sysbp < 120 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 2 and sysbp < 120 and diabp >= 100 then bp_points = 3;
	else if sex = 2 and sysbp >= 120 and sysbp < 130 and diabp < 90 then bp_points = 0;
	else if sex = 2 and sysbp >= 120 and sysbp < 130 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 2 and sysbp >= 120 and sysbp < 130 and diabp >= 100 then bp_points = 3;
	else if sex = 2 and sysbp >= 130 and sysbp < 140 and diabp < 90 then bp_points = 0;
	else if sex = 2 and sysbp >= 130 and sysbp < 140 and diabp >= 90 and diabp < 100 then bp_points = 2;
	else if sex = 2 and sysbp >= 130 and sysbp < 140 and diabp >= 100 then bp_points = 3;
	else if sex = 2 and sysbp >= 140 and sysbp < 160 and diabp < 100 then bp_points = 2;
	else if sex = 2 and sysbp >= 140 and sysbp < 160 and diabp >= 100 then bp_points = 3;
	else if sex = 2 and sysbp >= 160 then bp_points = 3;
	
	
	/* Diabetes Points */
	if diabetes = . then diabetes_points = .;
	else if sex = 1 and diabetes = 0 then diabetes_points = 0;
	else if sex = 1 and diabetes = 1 then diabetes_points = 2;
	else if sex = 2 and diabetes = 0 then diabetes_points = 0;
	else if sex = 2 and diabetes = 1 then diabetes_points = 4;
	
	/* Smoking Points */
	if cursmoke = . then smoking_points = .;
	else if sex = 1 and cursmoke = 0 then smoking_points = 0;
	else if sex = 1 and cursmoke = 1 then smoking_points = 2;
	else if sex = 2 and cursmoke = 0 then smoking_points = 0;
	else if sex = 2 and cursmoke = 1 then smoking_points = 2;
	
	/* Total Points */
	if age_points = . or ldlc_points = . or hdlc_points = . or bp_points = .
	or diabetes_points = . or smoking_points = . then total_points = .;
	else total_points = age_points + ldlc_points + hdlc_points + bp_points
						+ diabetes_points + smoking_points;
						
	/* 10-Year Probability of CHD */
	if total_points = . then prob = .;
	else if sex = 1 and total_points <= -3 then prob = 0.01;
	else if sex = 1 and total_points = -2 then prob = 0.02;
	else if sex = 1 and total_points = -1 then prob = 0.02;
	else if sex = 1 and total_points = 0 then prob = 0.03;
	else if sex = 1 and total_points = 1 then prob = 0.04;
	else if sex = 1 and total_points = 2 then prob = 0.04;
	else if sex = 1 and total_points = 3 then prob = 0.06;
	else if sex = 1 and total_points = 4 then prob = 0.07;
	else if sex = 1 and total_points = 5 then prob = 0.09;
	else if sex = 1 and total_points = 6 then prob = 0.11;
	else if sex = 1 and total_points = 7 then prob = 0.14;
	else if sex = 1 and total_points = 8 then prob = 0.18;
	else if sex = 1 and total_points = 9 then prob = 0.22;
	else if sex = 1 and total_points = 10 then prob = 0.27;
	else if sex = 1 and total_points = 11 then prob = 0.33;
	else if sex = 1 and total_points = 12 then prob = 0.40;
	else if sex = 1 and total_points = 13 then prob = 0.47;
	else if sex = 1 and total_points >= 14 then prob = 0.56;
	else if sex = 2 and total_points <= -2 then prob = 0.01;
	else if sex = 2 and total_points = -1 then prob = 0.02;
	else if sex = 2 and total_points = 0 then prob = 0.02;
	else if sex = 2 and total_points = 1 then prob = 0.02;
	else if sex = 2 and total_points = 2 then prob = 0.03;
	else if sex = 2 and total_points = 3 then prob = 0.03;
	else if sex = 2 and total_points = 4 then prob = 0.04;
	else if sex = 2 and total_points = 5 then prob = 0.05;
	else if sex = 2 and total_points = 6 then prob = 0.06;
	else if sex = 2 and total_points = 7 then prob = 0.07;
	else if sex = 2 and total_points = 8 then prob = 0.08;
	else if sex = 2 and total_points = 9 then prob = 0.09;
	else if sex = 2 and total_points = 10 then prob = 0.11;
	else if sex = 2 and total_points = 11 then prob = 0.13;
	else if sex = 2 and total_points = 12 then prob = 0.15;
	else if sex = 2 and total_points = 13 then prob = 0.17;
	else if sex = 2 and total_points = 14 then prob = 0.20;
	else if sex = 2 and total_points = 15 then prob = 0.24;
	else if sex = 2 and total_points = 16 then prob = 0.27;
	else if sex = 2 and total_points >= 17 then prob = 0.32;
	
	/* FRS Score */
	if prob = . then FRS = .;
	else FRS = prob*100;
run;

/* FRS Summary Statistics */
proc sort data = FRM_Period3; by sex; run; 

title "Question 3: FRS Summary Statistics by Sex";
proc means data = FRM_Period3 maxdec = 2 n mean std median min max q1 q3;
	var FRS;
	by sex;
run;

title "Figure 1: Framingham Risk Score (FRS) Histograms by Sex";
proc sgplot data = FRM_Period3;
	histogram FRS / group = sex scale = Percent transparency = 0.65 binwidth = 3 binstart = 0;
	density FRS / group = sex type = normal;
	keylegend / location = inside position = topright across = 2;
run;


/***********************/


/* Question 4: Outcome of Interest */
data FRM;
	set FRM;
	pulse_pressure = sysbp - diabp;
	label pulse_pressure = "SBP - DBP (mmHg)";
run;

data FRM_Period3;
	set FRM_Period3;
	pulse_pressure = sysbp - diabp;
	label pulse_pressure = "SBP - DBP (mmHg)";
run;


/***********************/


/* Question 5: Create representative components of FRS */
proc sort data = FRM; by randid; run;

title "Question 5: Create Representative Components of FRS";
proc means data = FRM noprint;
	by randid sex;
	var cigpday bmi heartrte glucose totchol;
	output out = FRS_components mean = cigpday_avg bmi_avg heartrte_avg d e max = a b c glucose_max totchol_max;
run;

data FRS_components; set FRS_components; drop a b c d e; run;

title "Question 5: FRS Representative Components Summary Statistics";
proc means data = FRS_components maxdec = 2 n mean std median min max q1 q3;
	var cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max;
run;

/* Two Sample T Tests */
proc sort data = FRS_components; by sex; run;

title "Question 5: Two Sample T Tests";
proc ttest data = FRS_components;
	var cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max;
	class sex;
run;

/* Histograms */
title "Figure 2A: Average Cigarettes Smoked per Day Histogram";
proc sgplot data = FRS_components;
	histogram cigpday_avg / group = sex scale = Percent transparency = 0.65;
run;

title "Figure 2B: Average Body Mass Index (BMI) Histogram";
proc sgplot data = FRS_components;
	histogram bmi_avg / group = sex scale = Percent transparency = 0.65;
run;

title "Figure 2C: Average Heart Rate Histogram";
proc sgplot data = FRS_components;
	histogram heartrte_avg / group = sex scale = Percent transparency = 0.65;
run;

title "Figure 2D: Maximum Blood Glucose Histogram";
proc sgplot data = FRS_components;
	histogram glucose_max / group = sex scale = Percent transparency = 0.65 binwidth = 10;
run;

title "Figure 2E: Maximum Total Cholesterol Histogram";
proc sgplot data = FRS_components;
	histogram totchol_max / group = sex scale = Percent transparency = 0.65 binwidth = 20;
run;


/***********************/


/* Question 6: Regression of Pulse Pressure and FRS */
title "Figure 3: Pulse Pressure at Period 3 Histogram";
proc sort data = FRM_Period3; by sex; run; 
proc sgplot data = FRM_Period3;
	histogram pulse_pressure / scale = Percent group = sex scale = Percent transparency = 0.65;
run;

title "Question 6: Regression of Pulse Pressure and FRS";
proc reg data = FRM_Period3;
	model pulse_pressure = FRS;
run;

/* Transform Outcome Variable */
data FRM_Period3;
	set FRM_Period3;
	log_pulse_pressure = log(pulse_pressure);
run;

title "Question 6: Simple Linear Regression Fit Metrics";
proc glmselect data = FRM_Period3;
	class sex;
	model pulse_pressure = FRS / stats = BIC details = summary;
run;

/* Model with log(Pulse Pressure) as the outcome
title "Question 6: Regression of log(Pulse Pressure) and FRS";
proc reg data = FRM_Period3;
	model log_pulse_pressure = FRS;
run; */
	
	
/***********************/


/* Question 7: Regression of Pulse Pressure and FRS components */
/* Merge FRM_Period3 and FRS_components Datasets */
proc sort data = FRM_Period3; 
	by randid;
run;

proc sort data = FRS_components; 
	by randid;
run;

data Q7;
     merge FRM_Period3 FRS_components;
     by randid;
     log_pulse_pressure = log(pulse_pressure); /* Transform Outcome Variable */
     keep randid pulse_pressure age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max log_pulse_pressure;
run;

/* Full Model */
title "Question 7: Full Model";
proc reg data = Q7;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max / vif stb scorr2;
run;

/* Selection using AIC */
title "Question 7: Model Selection Using AIC";
proc glmselect data = Q7;
	class sex;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max 
	/ select = AIC selection = stepwise stats = AIC details = summary;
run;

/* Selection using BIC */
title "Question 7: Model Selection Using BIC";
proc glmselect data = Q7;
	class sex;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max 
	/ select = BIC selection = stepwise stats = BIC details = summary;
run;

/* Selection using Mallows C(p) */
title "Question 7: Model Selection Using Mallows C(p)";
proc glmselect data = Q7;
	class sex;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max 
	/ select = CP selection = stepwise stats = CP details = summary;
run;

/* Selection using Adjusted R-Squared */
title "Question 7: Model Selection Using Adjusted R-Squared";
proc glmselect data = Q7;
	class sex;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max 
	/ select = adjrsq selection = stepwise stats = ADJRSQ details = summary;
run;

/* Final Model */
title "Question 7: Final Model";
proc reg data = Q7;
	model pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max / vif stb scorr2;
run;


/***********************/


/* Selection using AIC with log(Pulse Pressure) as the outcome
proc glmselect data = Q7;
	class sex;
	model log_pulse_pressure = age sex cigpday_avg bmi_avg heartrte_avg glucose_max totchol_max 
	/ select = AIC selection = stepwise stats = AIC details = all;
run; */

/* Selected Model with log(Pulse Pressure) as the outcome
proc reg data = Q7;
	model log_pulse_pressure = age bmi_avg heartrte_avg glucose_max / stb scorr2;
run; */






