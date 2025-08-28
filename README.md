**Project Title:</b> Pathways to productivity: mapping the relationship between multimodal transportation infrastructure, commute quality, and economic vitality for the United States workforce**

**Authors:** [redacted during double blind review process… will be added upon publication]

**Contact:** [redacted during double blind review process… will be added upon publication]

**Description:**
This repository contains the data and code necessary to reproduce the primary analysis and figures for the manuscript “Pathways to productivity: mapping the relationship between multimodal transportation infrastructure, commute quality, and economic vitality for the United States workforce”. The analysis demonstrates a newly defined commute quality metric (CQM) characterizing the quality, as a monetized consumer surplus, of travel for the purpose of work for every census tract in the continental United States. The analysis additionally demonstrates the correlation of that CQM with key economic vitality indicators. Specifically median household income and unemployment rate.

The code and data necessary for generation of the CQM itself relies on data that is restricted and cannot be made public due to the terms of the data access agreement governing the access to those data for the researchers. Specifically, the National Household Travel Data (NHTS) data from 2017 with the census tract, in 2010 census geographies, of home location, and the origin and destination of all trips, were provided under this data access agreement. These data are necessary for estimation of the mode choice and destination choice models underpinning the CQM. The data and code provided in this repository uses the generated census tract level CQM output from the pipeline dependent on the proprietary data, and includes the code used to generate the figures and regression results presented in the second part of the main results section of the manuscript.

**Repository Content:**
- \code - contains the STATA .do file that conducts the analysis.
- \raw - contains the initial dataset
- \process - contains interim data generated over the course of the analysis
- \figures - contains the results figures generated from running the analysis code
- \tables - contains the regression results and log output generated from running the analysis code

**System Requirements & Dependencies**
- Programming Language: Stata/MP 18.0
- Key libraries/packages: the requirements.do file saved in the code/ directory can be run to install the two user-developed packages used in the primary code file for the analysis.

**Installation**
- Clone the repository to a local computer with Stata installed
- Navigate to the local directory
- Ensure the repository's directory structure (/code, /raw, etc.) is maintained, as the analysis script relies on these relative paths. Instructions to this effect are provided in the code/CQM analysis code.do as well
- Open the code/CQM analysis code.do file in Stata and enter the local directory path in the two lines of the code where instructed
```
cd "<input path to local directory here>"
global dir "<input path to local directory here>"
```

**Instructions for Reproduction:**
- Execute the code/requirements.do file in Stata
- Execute the code/CQM analysis code.do file in Stata

**Expected Output:** 
The \figures and \tables directories in this repository contain the two figures and three tables (in both .txt and .xml format) as well as a log file that will be generated in these directories locally when the code is executed as instructed. These output files can be separately downloaded from GitHub or saved in separate directories to directly compare to the output you generate when you execute the analysis to ensure your results reproduce these results.

**Data Description & Availability:**
The code and data necessary for generation of the CQM itself relies on data that is restricted and cannot be made public due to the terms of the data access agreement governing the access to those data for the researchers. Specifically, the National Household Travel Data (NHTS) data from 2017 with the census tract, in 2010 census geographies, of home location, and the origin and destination of all trips, were provided under this data access agreement. These data are necessary for estimation of the mode choice and destination choice models underpinning the CQM. The data and code provided in this repository uses the generated census tract level CQM output from the pipeline dependent on the proprietary data, and includes the code used to generate the figures and regression results presented in the second part of the main results section of the manuscript.

**Data Dictionary:** 
A data_dictionary.xls inside the raw/ folder is made available. It includes a description of each column in the initial dataset in the raw/ folder.

**How to Cite:**
If you use the data or code from this repository in your research, please cite the following manuscript:
[FULL CITATION TO BE ADDED UPON PUBLICATION]

**Other Essential Files:**
- LICENSE: [TO BE ADDED]
- CITATION.cff: [TO BE ADDED ONCE CITATION IS AVAILABLE - FOR NOW PLEASE DO NOT CITE]

