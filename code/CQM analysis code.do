
clear all

/*IMPORTANT: CODE WILL ONLY RUN ONCE A FILE DIRECTORY PATH IS ADD IN THE FOLLOWIN TWO COMMAND LINES AS INDICATES
The local directory (dir) must have the following file structure:
dir\figures
dir\tables
dir\raw
dir\process
dir\code

and the file dir\raw must contain the following data files:
consumerSurplus_results_purposework_national_income_no_distBeta_6_25.csv
landuse_and_demographic_attr_tract2010.csv
*/

cd "<input path to local directory here>"
global dir "<input path to local directory here>"

global fig $dir\figures
global tab $dir\tables
global proc $dir\process
global raw $dir\raw
global code $dir\code

***********************Data loading, merging and preparation*******************
clear
import delimited using "$raw\landuse_and_demographic_attr_tract2010.csv", varn(1) stringc(1)
save "$proc\landuse_economic_demographic", replace

clear
import delimited using "$raw\consumerSurplus_results_purposework_national_income_no_distBeta_6_25.csv", varn(1) stringc(21)

drop origingeotype o_demand_microtype o_network_type o_geotype geotype microtype

/*merge land use and economic data with commute quality metric data*/
merge 1:1 geoid using "$proc\landuse_economic_demographic"
drop if _merge==2
drop _merge

/*define bins for transit availability*/
*busavailability metric here is % of destinations that have that mode available
gen transavail="bin1: 0" if busavailability==0
replace transavail="bin2: (0 - 0.30]" if busavailability>0 &  busavailability<=.3
replace transavail="bin3: (0.30 - 0.60]" if busavailability>0.3 &  busavailability<=.6
replace transavail="bin4: (0.60 - 0.90]" if busavailability>0.6 &  busavailability<=.9
replace transavail="bin5: above 0.90" if busavailability>.9 

gen transavail2="bin1: 0" if busavailability==0
replace transavail2="bin2: above 0" if busavailability>0 

/*Define string variables to ensure desired ordering of results in figures, etc.*/
replace networktype="1: Urban 1" if networktype=="Urban 1"
replace networktype="2: Urban 2" if networktype=="Urban 2"
replace networktype="3: Urban 3" if networktype=="Urban 3"
replace networktype="4: Urban 4" if networktype=="Urban 4"
replace networktype="5: Urban 5" if networktype=="Urban 5"
replace networktype="6: Rural 1" if networktype=="Rural 1"
replace networktype="7: Rural 2" if networktype=="Rural 2"
replace networktype="8: Rural 3" if networktype=="Rural 3"

replace microtype="5: Rural agriculture" if microtype=="Rural agriculture"
replace microtype="4: Rural town center" if microtype=="Rural town center"
replace microtype="3: Suburban" if microtype=="Suburban"
replace microtype="2: Urban mixed-use" if microtype=="Urban mixed-use"
replace microtype="1: Urban center" if microtype=="Urban center"

/*encode string variables*/
encode networktype, gen(network_enc)
encode transavail, gen(transavail_enc)
encode microtype, gen(microtype_enc)
encode geotype, gen(geotype_enc)

/*generate dummy variables for some categorical variables*/
gen geo_A=(geotype=="A")
gen geo_B=(geotype=="B")
gen geo_C=(geotype=="C")
gen geo_D=(geotype=="D")


gen micro_1=(microtype_enc==1)
gen micro_2=(microtype_enc==2)
gen micro_3=(microtype_enc==3)
gen micro_4=(microtype_enc==4)
gen micro_5=(microtype_enc==5)


gen urban=(geo_A==1 | geo_B==1)
gen rural=(urban==0)

gen network_U1=(network_enc==1)
gen network_U2=(network_enc==2)
gen network_U3=(network_enc==3)
gen network_U4=(network_enc==4)
gen network_U5=(network_enc==5)
gen network_R1=(network_enc==6)
gen network_R2=(network_enc==7)
gen network_R3=(network_enc==8)

/*define squared transit availability term*/
gen busavailability2=busavailability*busavailability

/*encode state indicator*/
encode st_code, gen(state_enc)

/*encode county indicator*/
gen county=substr(geoid,1,5)
encode county, gen(county_enc)

/*rescale unemployment from rate to percent*/
replace unemployment_rate=unemployment_rate*100

/*keep varibles used in following analysis*/
keep o_geoid cs_baseline microtype networktype geotype geo_A geo_B geo_C geo_D micro_1 micro_2 micro_3 micro_4 micro_5 network_U1 network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 transavail transavail2 urban busavailability busavailability2 geotype_enc microtype_enc network_enc transavail_enc st_code county county_enc frac_age_above_65 edu_above_bs frac_hh_no_veh frac_tenure_renter  frac_below_poverty frac_hh_inc_below_40k frac_hh_inc_above_100k job_density hhmedianincome unemployment_rate

save "$proc\cqm_paper_data_for_regressions", replace
export delimited using "$proc\cqm_paper_data_for_regressions.csv", replace

***********************Primary Analysis*******************
clear all

log using "$tab\log_cqm_paper_analysis", replace
use "$proc\cqm_paper_data_for_regressions"

**summarize data
sum cs_baseline, d
by microtype,s: sum cs_baseline if urban==1, d
by networktype,s: sum cs_baseline if urban==1, d
by geotype,s: sum cs_baseline if urban==1, d
by transavail,s: sum cs_baseline if urban==1, d
by microtype,s: sum cs_baseline if urban==0, d
by networktype,s: sum cs_baseline if urban==0, d
by geotype,s: sum cs_baseline if urban==0, d
by transavail2,s: sum cs_baseline if urban==0, d


** Generate figures for urban regions

/*Generate and save each plot individually*/
cdfplot cs_baseline if urban==1, by(networktype) opt1(lc(orange*1.4 orange*1.2 orange orange*.6 orange*.3) xtitle("Commute Quality Metric" "(b)") legend(lab(1 "Urban 1") lab(2 "Urban 2") lab(3 "Urban 3") lab(4 "Urban 4") lab(5 "Urban 5") position(10) ring(0))) name(network_plot, replace)

cdfplot cs_baseline if urban==1, by(microtype) opt1(lc("22 22 156" blue purple gold dkorange) xtitle("Commute Quality Metric" "(c)") legend(lab(1 "Urban center") lab(2 "Urban mixed-use") lab(3 "Suburban") lab(4 "Rural town center") lab(5 "Rural agriculture") position(10) ring(0))) name(micro_plot, replace)

cdfplot cs_baseline if urban==1, by(geotype) opt1(lc("213 122 100" emerald) xtitle("Commute Quality Metric" "(a)") legend(lab(1 "A") lab(2 "B") position(10) ring(0))) name(geo_plot, replace)

cdfplot cs_baseline if urban==1, by(transavail) opt1(lc(edkblue*.2 edkblue*.4 edkblue*.6 edkblue*.8 edkblue) xtitle("Commute Quality Metric" "(d)") legend(lab(1 "0") lab(2 "0 - 0.30") lab(3 "0.30 - 0.60") lab(4 "0.60 - 0.90") lab(5 "above 0.90") position(10) ring(0))) name(transit_plot, replace)


/*Combine plots into single figure*/
graph combine geo_plot network_plot micro_plot transit_plot, ///
    col(2) row(2) ///
    title("") ///
    ycommon ysize(medium) ///
    xcommon xsize(medium)

/*Export combined figure*/
graph export "$fig\combined_cs_urban.png", replace

** Generate figures for rural regions

/*Generate and save each plot individually*/
cdfplot cs_baseline if urban==0, by(networktype) opt1(lc(emerald*1.2 emerald*.6 emerald*.4) xtitle("Commute Quality Metric" "(b)") legend(lab(1 "Rural 1") lab(2 "Rural 2") lab(3 "Rural 3") position(10) ring(0))) name(network_plot, replace)

cdfplot cs_baseline if urban==0 & microtype!="1: Urban center", by(microtype) opt1(lc(blue purple gold dkorange) xtitle("Commute Quality Metric" "(c)") legend(lab(1 "Urban mixed-use") lab(2 "Suburban") lab(3 "Rural town center") lab(4 "Rural agriculture") position(10) ring(0))) name(micro_plot, replace)

cdfplot cs_baseline if urban==0, by(geotype) opt1(lc("49 67 76" sand) xtitle("Commute Quality Metric" "(a)") legend(lab(1 "C") lab(2 "D") position(10) ring(0))) name(geo_plot, replace)

cdfplot cs_baseline if urban==0, by(transavail2) opt1(lc(edkblue*.4 edkblue) xtitle("Commute Quality Metric" "(d)") legend(lab(1 "0") lab(2 "above 0") position(10) ring(0))) name(transit_plot, replace)

/*Combine plots into single figure*/
graph combine geo_plot network_plot micro_plot transit_plot, ///
    col(2) row(2) ///
    title("") ///
    ycommon ysize(medium) ///
    xcommon xsize(medium)

/*Export combined figure*/
graph export "$fig\combined_cs_rural.png", replace

/*Define global containing all controls included in subsequent step*/
global socioec="frac_age_above_65 edu_above_bs frac_hh_no_veh frac_tenure_renter  frac_below_poverty frac_hh_inc_below_40k frac_hh_inc_above_100k job_density"

/*Define panel data structure with units being counties, and tracts within counties as within-unit observations*/
xtset county_enc o_geoid

*Table 1 Regressions: Regression results for commute quality on location characteristics
outreg2 using "$tab\cs_overall", excel replace: reg cs_baseline i.network_enc,  vce(cl county_enc)
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.microtype_enc,  vce(cl county_enc)
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.geotype_enc,  vce(cl county_enc)
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline busavailability busavailability2,  vce(cl county_enc)
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.network_enc i.microtype_enc i.geotype_enc busavailability busavailability2,  vce(cl county_enc)
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.network_enc i.microtype_enc i.geotype_enc busavailability busavailability2 $socioec,  vce(cl county_enc)

*Table 2 Regressions: Regression results for median household income
outreg2 using "$tab\hhmedianincome", excel replace: xtreg hhmedianincome ///
cs_baseline, fe vce(cl county_enc)
outreg2 using "$tab\hhmedianincome", excel append: xtreg hhmedianincome ///
cs_baseline $socioec unemployment_rate, fe vce(cl county_enc)
outreg2 using "$tab\hhmedianincome", excel append: xtreg hhmedianincome ///
cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome", excel append: xtreg hhmedianincome ///
geo_B geo_C geo_D c.geo_A#c.cs_baseline c.geo_B#c.cs_baseline c.geo_C#c.cs_baseline c.geo_D#c.cs_baseline ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
$socioec  unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome", excel append: xtreg hhmedianincome ///
micro_2 micro_3 micro_4 micro_5 c.micro_1#c.cs_baseline c.micro_2#c.cs_baseline c.micro_3#c.cs_baseline c.micro_4#c.cs_baseline c.micro_5#c.cs_baseline ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
geo_B geo_C geo_D busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)

*Table 2 Regressions: Regression results for unemployment rate
outreg2 using "$tab\unemployment_rate", excel replace: xtreg unemployment_rate ///
cs_baseline, fe vce(cl county_enc)
outreg2 using "$tab\unemployment_rate", excel append: xtreg unemployment_rate ///
cs_baseline $socioec hhmedianincome, fe vce(cl county_enc)
outreg2 using "$tab\unemployment_rate", excel append: xtreg unemployment_rate ///
cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
 $socioec hhmedianincome, fe vce(cl county_enc)

outreg2 using "$tab\unemployment_rate", excel append: xtreg unemployment_rate ///
geo_B geo_C geo_D c.geo_A#c.cs_baseline c.geo_B#c.cs_baseline c.geo_C#c.cs_baseline c.geo_D#c.cs_baseline ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
$socioec  hhmedianincome, fe vce(cl county_enc)

outreg2 using "$tab\unemployment_rate", excel append: xtreg unemployment_rate ///
micro_2 micro_3 micro_4 micro_5 c.micro_1#c.cs_baseline c.micro_2#c.cs_baseline c.micro_3#c.cs_baseline c.micro_4#c.cs_baseline c.micro_5#c.cs_baseline ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
geo_B geo_C geo_D busavailability busavailability2 ///
$socioec hhmedianincome, fe vce(cl county_enc)

log close

