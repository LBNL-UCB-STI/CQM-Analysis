
clear all

/*
The local directory (dir) must have the following file structure:
dir\figures
dir\tables
dir\raw
dir\process
dir\code

and the file dir\raw must contain the following data file:
cqm_analysis_data.dta

IMPORTANT: CODE WILL ONLY RUN ONCE A FILE DIRECTORY PATH IS ADDED IN THE FOLLOWING TWO COMMAND LINES WHERE IT SAYS "<input path to local directory here>" 
*/

cd "C:\Users\caspurlock\Documents\GitHub\CQM-Analysis"
global dir "C:\Users\caspurlock\Documents\GitHub\CQM-Analysis"

global fig $dir\figures
global tab $dir\tables
global proc $dir\process
global raw $dir\raw
global code $dir\code

***********************Data loading and preparation*******************
clear
use "$raw\cs_analysis_data"

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
keep o_geoid cs_baseline microtype networktype geotype geo_A geo_B geo_C geo_D micro_1 micro_2 micro_3 micro_4 micro_5 network_U1 network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 transavail transavail2 urban busavailability busavailability2 geotype_enc microtype_enc network_enc transavail_enc st_code county county_enc frac_age_above_65 edu_above_bs frac_hh_no_veh frac_tenure_renter  frac_below_poverty frac_hh_inc_below_40k frac_hh_inc_above_100k job_density pop_density hhmedianincome unemployment_rate cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike

/*generate an indicator for observations where the cs_baseline is between the .05 percentile and the 99.95 percentile in order to be able to generate plots without more extreme outliers - this tags 0.1% of the data (72 observations) as outliers*/
egen lower_outlier=pctile(cs_baseline), p(.05)
egen upper_outlier=pctile(cs_baseline), p(99.95)
gen cs_baseline_nooutliers=1
replace cs_baseline_nooutliers=0 if cs_baseline<lower_outlier
replace cs_baseline_nooutliers=0 if cs_baseline>upper_outlier
drop lower_outlier upper_outlier

save "$proc\cs_paper_data_for_regressions", replace
export delimited using "$proc\cs_paper_data_for_regressions.csv", replace

***********************Primary Analysis*******************
clear all

log using "$tab\log_cs_paper_analysis", replace
use "$proc\cs_paper_data_for_regressions"

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

** generate figures

/*Generate and save each plot individually*/
cdfplot cs_baseline if cs_baseline_nooutliers==1, by(networktype) opt1(lc(orange*1.4 orange*1.2 orange orange*.6 orange*.3 emerald*1.2 emerald*.6 emerald*.4) ytitle("Cumulative % Distribution") xtitle("CS Metric" "(b)") legend(lab(1 "Urban 1") lab(2 "Urban 2") lab(3 "Urban 3") lab(4 "Urban 4") lab(5 "Urban 5") lab(6 "Rural 1") lab(7 "Rural 2") lab(8 "Rural 3") position(10) ring(0))) name(network_plot, replace)

cdfplot cs_baseline if cs_baseline_nooutliers==1, by(microtype) opt1(lc("22 22 156" blue purple gold dkorange) xtitle("CS Metric" "(c)") legend(lab(1 "Urban center") lab(2 "Urban mixed-use") lab(3 "Suburban") lab(4 "Rural town center") lab(5 "Rural agriculture") position(10) ring(0))) name(micro_plot, replace)

cdfplot cs_baseline if cs_baseline_nooutliers==1, by(geotype) opt1(lc("213 122 100" emerald dknavy sand) xtitle("CS Metric" "(a)") legend(lab(1 "A") lab(2 "B") lab(3 "C") lab(4 "D") position(10) ring(0))) name(geo_plot, replace)


/*Combine plots into single figure*/
graph combine geo_plot network_plot micro_plot, ///
    col(2) row(2) ///
    title("") ///
    ycommon ///
    xcommon iscale(*.88)

/*Export combined figure*/
graph export "$fig\combined_cs.png", replace

/*Define global containing all controls included in subsequent step*/
global socioec="c.frac_age_above_65 c.edu_above_bs c.frac_hh_no_veh c.frac_tenure_renter  c.frac_below_poverty c.frac_hh_inc_below_40k c.frac_hh_inc_above_100k c.job_density c.pop_density"

/*Tabl 1: Geotype Regressions*/

outreg2 using "$tab\cs_overall", excel replace: reg cs_baseline i.geotype_enc
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.microtype_enc
outreg2 using "$tab\cs_overall", excel append: reg cs_baseline i.network_enc

outreg2 using "$tab\cs_overall", ct(Geo A) excel append: reg cs_baseline i.microtype_enc i.network_enc if geo_A==1
outreg2 using "$tab\cs_overall", ct(Geo B)  excel append: reg cs_baseline i.microtype_enc i.network_enc if geo_B==1
outreg2 using "$tab\cs_overall", ct(Geo C)  excel append: reg cs_baseline i.microtype_enc i.network_enc if geo_C==1
outreg2 using "$tab\cs_overall", ct(Geo D)  excel append: reg cs_baseline i.microtype_enc i.network_enc if geo_D==1

/*Tabl 2: ANOVA Analysis*/

*robustness check
anova cs_baseline c.job_density c.pop_density
estat esize

*main ANOVA
anova cs_baseline i.microtype_enc i.network_enc if geo_A==1
estat esize
anova cs_baseline i.microtype_enc i.network_enc if geo_B==1
estat esize
anova cs_baseline i.microtype_enc i.network_enc if geo_C==1 
estat esize
anova cs_baseline i.microtype_enc i.network_enc if geo_D==1
estat esize

/*Define panel data structure with units being counties, and tracts within counties as within-unit observations*/
xtset county_enc o_geoid

*Table 3 Regressions: Regression results for median household income
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
c.micro_1#urban#c.cs_baseline c.micro_2#urban#c.cs_baseline c.micro_3#urban#c.cs_baseline c.micro_4#urban#c.cs_baseline c.micro_5#urban#c.cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome", excel append: xtreg hhmedianincome ///
c.network_U1#c.cs_baseline c.network_U2#c.cs_baseline c.network_U3#c.cs_baseline c.network_U4#c.cs_baseline c.network_U5#c.cs_baseline ///
c.network_R1#c.cs_baseline c.network_R2#c.cs_baseline c.network_R3#c.cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)


replace hhmedianincome=hhmedianincome/1000
replace pop_density=pop_density/1000
replace job_density=job_density/1000

*Table 4 Regressions: Regression results for unemployment rate
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
c.micro_1#urban#c.cs_baseline c.micro_2#urban#c.cs_baseline c.micro_3#urban#c.cs_baseline c.micro_4#urban#c.cs_baseline c.micro_5#urban#c.cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec hhmedianincome, fe vce(cl county_enc)

outreg2 using "$tab\unemployment_rate", excel append: xtreg unemployment_rate ///
c.network_U1#c.cs_baseline c.network_U2#c.cs_baseline c.network_U3#c.cs_baseline c.network_U4#c.cs_baseline c.network_U5#c.cs_baseline ///
c.network_R1#c.cs_baseline c.network_R2#c.cs_baseline c.network_R3#c.cs_baseline ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec hhmedianincome, fe vce(cl county_enc)

***Validation comparison with cummulative accessibility***

replace cummulative_acc45_auto=cummulative_acc45_auto/10000
replace cummulative_acc45_bus=cummulative_acc45_bus/1000
replace cummulative_acc45_bike=cummulative_acc45_bike/1000

corr cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike

preserve

collapse (mean) cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, by(geotype)

graph bar cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, over(geotype) legend(lab(1 "CS metric") lab(2 "Cumulative Accessibility (10,000)") lab(3 "Cumulative Bus Accessibility (1,000)") lab(4 "Cumulative Bike Accessibility (1,000)"))
save "$fig\cumulative_geo.png", replace

restore

preserve

collapse (mean) cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, by(microtype)

graph bar cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, over(microtype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cumulative Accessibility (10,000)") lab(3 "Cumulative Bus Accessibility (1,000)") lab(4 "Cumulative Bike Accessibility (1,000)"))
save "$fig\cumulative_micro.png", replace

restore 

preserve

collapse (mean) cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, by(networktype)

graph bar cs_baseline cummulative_acc45_auto cummulative_acc45_bus cummulative_acc45_bike, over(networktype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cumulative Auto Accessibility (10,000)") lab(3 "Cumulative Bus Accessibility (1,000)") lab(4 "Cumulative Bike Accessibility (1,000)")) 
save "$fig\cumulative_network.png", replace

restore
/*
graph bar cs_baseline cummulative_acc45_auto, over(geotype) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (10,000)"))
save $fig\cummulative_auto_geo.png, replace
graph bar cs_baseline cummulative_acc45_auto, over(microtype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (10,000)")) 
save $fig\cummulative_auto_micro.png, replace
graph bar cs_baseline cummulative_acc45_auto, over(networktype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (10,000)")) 
save $fig\cummulative_auto_network.png, replace

graph bar cs_baseline cummulative_acc45_bus, over(geotype) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)"))
save $fig\cummulative_bus_geo.png, replace

graph bar cs_baseline cummulative_acc45_bus, over(microtype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)")) 
save $fig\cummulative_bus_micro.png, replace

graph bar cs_baseline cummulative_acc45_bus, over(networktype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)")) 
save $fig\cummulative_bus_network.png, replace

graph bar cs_baseline cummulative_acc45_bike, over(geotype) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)"))
save $fig\cummulative_bike_geo.png, replace

graph bar cs_baseline cummulative_acc45_bike, over(microtype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)")) 
save $fig\cummulative_bike_micro.png, replace

graph bar cs_baseline cummulative_acc45_bike, over(networktype, lab(angle(45))) legend(lab(1 "CS metric") lab(2 "Cummulative Accessibility (1,000)")) 
save $fig\cummulative_bike_network.png, replace


replace cummulative_acc45_auto=cummulative_acc45_auto/100

outreg2 using "$tab\hhmedianincome_cummulativeacc", excel replace: xtreg hhmedianincome ///
cummulative_acc45_auto, fe vce(cl county_enc)
outreg2 using "$tab\hhmedianincome_cummulativeacc", excel append: xtreg hhmedianincome ///
cummulative_acc45_auto $socioec unemployment_rate, fe vce(cl county_enc)
outreg2 using "$tab\hhmedianincome_cummulativeacc", excel append: xtreg hhmedianincome ///
cummulative_acc45_auto ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome_cummulativeacc", excel append: xtreg hhmedianincome ///
geo_B geo_C geo_D c.geo_A#c.cummulative_acc45_auto c.geo_B#c.cummulative_acc45_auto c.geo_C#c.cummulative_acc45_auto c.geo_D#c.cummulative_acc45_auto ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 ///
micro_2 micro_3 micro_4 micro_5 busavailability busavailability2 ///
$socioec  unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome_cummulativeacc", excel append: xtreg hhmedianincome ///
c.micro_1#urban#c.cummulative_acc45_auto c.micro_2#urban#c.cummulative_acc45_auto c.micro_3#urban#c.cummulative_acc45_auto c.micro_4#urban#c.cummulative_acc45_auto c.micro_5#urban#c.cummulative_acc45_auto ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)

outreg2 using "$tab\hhmedianincome_cummulativeacc", excel append: xtreg hhmedianincome ///
c.network_U1#c.cummulative_acc45_auto c.network_U2#c.cummulative_acc45_auto c.network_U3#c.cummulative_acc45_auto c.network_U4#c.cummulative_acc45_auto c.network_U5#c.cummulative_acc45_auto ///
c.network_R1#c.cummulative_acc45_auto c.network_R2#c.cummulative_acc45_auto c.network_R3#c.cummulative_acc45_auto ///
geo_B geo_C geo_D ///
network_U2 network_U3 network_U4 network_U5 network_R1 network_R2 network_R3 ///
micro_2 micro_3 micro_4 micro_5 ///
busavailability busavailability2 ///
$socioec unemployment_rate, fe vce(cl county_enc)
*/


log close



