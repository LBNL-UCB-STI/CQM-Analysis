<p><b>Project Title:</b> Pathways to productivity: mapping the relationship between multimodal transportation infrastructure, commute quality, and economic vitality for the United States workforce</p>

<p><b>Authors:</b> [redacted during double blind review process… will be added in upon publication]</p>

<p><b>Contact:</b> [redacted during double blind review process… will be added in upon publication]</p>

<p><b>Description:</b> </p>
<p>This repository contains the data and code necessary to reproduce the primary analysis and figures for the manuscript “Pathways to productivity: mapping the relationship between multimodal transportation infrastructure, commute quality, and economic vitality for the United States workforce”. The analysis demonstrates a newly defined commute quality metric (CQM) characterizing the quality, as a monetized consumer surplus, of travel for the purpose of work for every census tract in the continental United States. The analysis additionally demonstrates the correlation of that CQM with key economic vitality indicators. Specifically median household income and unemployment rate. </p>

<p>The code and data necessary for generation of the CQM itself relies on data that is restricted and cannot be made public due to the terms of the data access agreement governing the access to those data for the researchers. Specifically, the National Household Travel Data (NHTS) data from 2017 were provided with the census tract, in 2010 census geographies, of home location, and the origin and destination of all trips, was provided under this data access agreement. These data are necessary for estimation of the mode choice and destination choice models underpinning the CQM. The data and code provided in this repository uses the generated census tract level CQM output from the pipeline dependent on the proprietary data, and includes the code used to generate the figures and regression results presented in the main results section of the manuscript.</p>

<p><b>Repository Content:</b></p>
<p>\code - contains the STATA .do file that conducts the analysis.</p>
<p>\raw - contains the initial dataset </p>
<p>\process - contains interim data generated over the course of the analysis</p>
<p>\figures - contains the results figures generated from running the analysis code</p>
<p>\tables - contains the regression results and log output generated from running the analysis code</p>

<p><b>System Requirements & Dependencies</b></p>
<p>This section is critical for reproducibility. List all software dependencies and their versions.</p>
<p>Programming Language: Stata/MP 18.0</p>
<p>Key libraries/packages: the requirements.do file saved in the code/ directory can be run to install the two user-developed packages used in the primary code file for the analysis.</p>

<p><b>Installation</b></p>
<p>Clone the repository</p>
<p>Navigate to the directory</p>
<p>Create and the environment, ensuring that the file structure aligns with the instructions in the code/CQM analysis code.do</p>
<p>Open the code/CQM analysis code.do file in Stata and enter the local directory path in the two lines of the code where instructed</p>

<p><b>Instructions for Reproduction:</b></p>
<p>Execute the code/requirements.do file in Stata</p>
<p>Execute the code/CQM analysis code.do file in Stata</p>

<p><b>Data Description & Availability:</b></p>
<p>The code and data necessary for generation of the CQM itself relies on data that is restricted and cannot be made public due to the terms of the data access agreement governing the access to those data for the researchers. Specifically, the National Household Travel Data (NHTS) data from 2017 were provided with the census tract, in 2010 census geographies, of home location, and the origin and destination of all trips, was provided under this data access agreement. These data are necessary for estimation of the mode choice and destination choice models underpinning the CQM. The data and code provided in this repository uses the generated census tract level CQM output from the pipeline dependent on the proprietary data, and includes the code used to generate the figures and regression results presented in the main results section of the manuscript.</p>

<p><b>Data Dictionary:</b> A data_dictionary.xls inside the raw/ folder is made available. It includes a description of each column in the initial dataset in the raw/ folder.</p>


<p><b>Other Essential Files:</b></p>
<p>LICENSE: [TO BE ADDED]</p>
<p>CITATION.cff: [TO BE ADDED ONCE CITATION IS AVAILABLE - FOR NOW PLEASE DO NOT CITE]</p>

