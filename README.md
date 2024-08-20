# Framingham Heart Study: Pulse Pressure and Cardiovascular Risk Analysis

## Introduction
The Framingham Heart Study, initiated between 1956 and 1968, is one of the most comprehensive studies on cardiovascular health. This project analyzes data from a subset of 4,434 participants who underwent three examination cycles approximately six years apart. The first part of the analysis focuses on calculating the Framingham Risk Score (FRS) for each participant, which estimates the ten-year probability of developing coronary heart disease (CHD). The primary outcome of interest is pulse pressure, defined as the difference between systolic and diastolic blood pressure. For this portion of the project, SAS procedures such as `PROC MEANS`, `PROC FREQ`, `PROC REG`, `PROC GLMSELECT`, and `PROC SGPLOT` were used for descriptive statistics, regression modeling, model selection, and data visualization. The second part of the analysis extended the modeling approach by employing Generalized Linear Models (GLMs) using `PROC GENMOD`, allowing for a more flexible and robust examination of the relationships between coronary heart disease status and cardiovascular risk factors. Additional SAS procedures including `PROC SQL`, `PROC UNIVARIATE`, and `PROC LOGISTIC` were used for data filtering, model diagnostics, and logistric regression models, respectively.

## Purpose
The objective of this project is twofold: Part 1 focuses on using descriptive statistics and linear regression models to explore these relationships and to quantify the impact of traditional cardiovascular risk factors on pulse pressure. Part 2 shifts focus to identifying the key predictors of coronary heart disease (CHD) risk using generalized linear models, including log-linear models and logistic regression, to provide a more comprehensive understanding of cardiovascular risk factors. Together, these analyses aim to provide a comprehensive and accurate assessment of the factors influencing pulse pressure and coronary heart disease, contributing to better cardiovascular risk assessment and potentially informing clinical decision-making.

## Significance
Pulse pressure is a critical indicator of cardiovascular health, with elevated levels being associated with an increased risk of heart disease and stroke. The significance of this project lies in its comprehensive approach to understanding the factors that influence pulse pressure. In Part 1, the use of descriptive statistics and linear regression models provides valuable insights into the traditional risk factors, such as age, cholesterol levels, and smoking habits, that contribute to cardiovascular risk. Part 2 enhances this analysis by employing Generalized Linear Models (GLMs), which allow for the exploration of more complex relationships and ensure that the findings remain robust even when the assumptions of linear regression are not fully met. Together, these findings have significant implications for public health, particularly in the development of strategies to prevent heart disease and manage cardiovascular risk in diverse populations.

## Project Overview
### Data Source: 
Data from the Framingham Heart Study, including measurements from three examination cycles.

### Part 1: Descriptive Statistics and Linear Regression:
1. Descriptive Statistics: `PROC MEANS` and `PROC FREQ` were used to summarize the baseline characteristics of the study population, including continuous and categorical variables.
2. Framingham Risk Score Calculation: The FRS was calculated for each participant at the third examination cycle, incorporating factors such as age, cholesterol levels, blood pressure, diabetes status, and smoking habits.
3. Simple Linear Regression: A simple linear regression model was initially conducted with pulse pressure as the outcome and FRS as the predictor using `PROC REG`.
4. Multiple Linear Regression and Model Selection: A more complex model was developed using multiple linear regression, with representative components of the FRS as predictors. `PROC GLMSELECT` was employed to perform stepwise model selection, optimizing the model based on various criteria including AIC, BIC, and adjusted R-squared.

### Part 2: Generalized Linear Models:
5. Generalized Linear Models (GLMs): The second part of the project extended the analysis by employing generalized linear models to explore the relationship between coronary heart disease status and a set of predictor variables (smoking status, LDL cholesterol, and age). GLMs are particularly advantageous when dealing with non-normal response variables, allowing for a broader application of statistical models. The models were implemented using `PROC GENMOD`, which offers the flexibility to specify different distributions and link functions.
6. Log-Linear Models: A log-linear model was applied to examine the relationship between coronary heart disease status, smoking status, and LDL cholesterol.
7. Logistic Regression Models: Logistic regression was employed to model the probability of heart disease as a function of the same predictors. Logistic regression, implemented through `PROC GENMOD`, is particularly effective in cases where the outcome is binary or categorical.

## Findings and Conclusions
### Key Predictors: 
The final multiple linear regression model identified age, sex, average cigarettes smoked, average body mass index (BMI), average heart rate, and maximum serum glucose as significant predictors of pulse pressure. The final logistic regression model found age to be the most important predictor of coronary heart disease status.

### Gender Differences: 
Significant differences in FRS and its components were observed between males and females, with males generally exhibiting higher risk scores but lower pulse pressure.

### Model Performance: 
The combination of multiple linear regression and GLMs provided a comprehensive understanding of the factors influencing pulse pressure and coronary heart disease status, though the overall model fits suggested that other unmeasured factors might also play a role.

## References
This project utilized SAS for statistical analysis, with key procedures including `PROC MEANS`, `PROC FREQ`, `PROC REG`, `PROC GLMSELECT`, `PROC SQL`, `PROC UNIVARIATE`, `PROC LOGISTIC`, and `PROC GENMOD`. Full code and output are available in the repository. Note that Part 1 of the project uses the dataset `frmgham2023.sas7bdat` while Part 2 of the project uses the dataset `frmgham.sas7bdat`.
