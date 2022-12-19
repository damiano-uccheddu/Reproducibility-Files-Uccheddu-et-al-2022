
*-----------------------------------------------------------------------------------------------* 
*>> Open the log file
*-----------------------------------------------------------------------------------------------* 

capture log close 
log using "$share_logfile/Data Creation.log", replace


*-----------------------------------------------------------------------------------------------* 
*>> Extract & Recode Variables from HS
*-----------------------------------------------------------------------------------------------* 

*>>	WAVE 3
use "$share_w3_in/sharew3_rel8-0-0_hs.dta" , clear
gen wave=3 // Create wave id 

* 	Defining the label 
label define lab_health ///
   1 "1.Excellent"  	///
   2 "2.Very good" 		///
   3 "3.Good"			///
   4 "4.Fair"			///
   5 "5.Poor"	

*>> Self reported health 
gen srh_paper3 = .
replace srh_paper3 = 1 if sl_ph003_ == 1 //  Excellent
replace srh_paper3 = 2 if sl_ph003_ == 2 //  Very good
replace srh_paper3 = 3 if sl_ph003_ == 3 //  Good     
replace srh_paper3 = 4 if sl_ph003_ == 4 //  Fair     
replace srh_paper3 = 5 if sl_ph003_ == 5 //  Poor     

* 	Labels 
label variable srh_paper3 "Self-report of health"
label values srh_paper3 lab_health


*>> Keep only variables of interest
preserve // preserve the data as it is

keep 		///
mergeid 	/// 
wave 		/// 
sl_hs003_ sl_hs004_ sl_hs005_ sl_hs006_ sl_hs007_

rename sl_hs003_  hs003_ // harmonize the variable names 
rename sl_hs004_  hs004_ // harmonize the variable names 
rename sl_hs005_  hs005_ // harmonize the variable names 
rename sl_hs006_  hs006_ // harmonize the variable names 
rename sl_hs007_  hs007_ // harmonize the variable names 

*>> Dataset Save
save "$share_w3_out\sharew3_hs.dta", replace 
restore  	// restore the data

*	Keep only variables of interest
keep 		///
mergeid 	/// Personal identifier
wave 		/// 
srh_paper3 	

*	Dataset Save
save "$share_w3_out\sharew3_srh_paper3.dta", replace 

*>>	WAVE 7
use "$share_w7_in\sharew7_rel8-0-0_hs.dta" , clear // Open the dataset
gen wave=7 	// Create wave id 

*	Keep only variables of interest
keep 		///
mergeid 	/// Personal identifier
wave 		/// 
hs003_ hs004_ hs005_ hs006_ 

*	Dataset Save
save "$share_w7_out\sharew7_hs.dta", replace 


*-----------------------------------------------------------------------------------------------* 
*>> Extract & Recode Variables from GS
*-----------------------------------------------------------------------------------------------* 

*>>	WAVE 3
use "$share_w3_in\sharew3_rel8-0-0_gs.dta" , clear // Open the dataset
gen wave=3 	// Create wave id 

rename sl_maxgrip maxgrip_paper3

*	Keep only variables of interest
keep 		///
mergeid 	/// Personal identifier
wave 		/// 
maxgrip_paper3

*	Dataset Save
save "$share_w3_out\sharew3_gs.dta", replace 


*>>	WAVE 7
use "$share_w7_in\sharew7_rel8-0-0_gv_health.dta", clear // Open the dataset
gen wave=7 	// Create wave id 

rename maxgrip maxgrip_paper3

preserve 
*	Keep only variables of interest
keep 		///
mergeid 	/// Personal identifier
wave 		/// 
maxgrip_paper3

*	Dataset Save
save "$share_w7_out\sharew7_gs.dta", replace 

restore 

gen srh_paper3 = .
replace srh_paper3 = 1 if sphus == 1 //  Excellent
replace srh_paper3 = 2 if sphus == 2 //  Very good
replace srh_paper3 = 3 if sphus == 3 //  Good     
replace srh_paper3 = 4 if sphus == 4 //  Fair     
replace srh_paper3 = 5 if sphus == 5 //  Poor     

* 	Labels 
label variable srh_paper3 "Self-report of health"
label values srh_paper3 lab_health

*	Keep only variables of interest
keep 		///
mergeid 	/// Personal identifier
wave 		/// 
srh_paper3

*	Dataset Save
save "$share_w7_out\sharew7_srh_paper3.dta", replace 


*-----------------------------------------------------------------------------------------------* 
*>> Extract & Recode Variables from CV_R
*-----------------------------------------------------------------------------------------------* 

*>> WAVE 3
use "$share_w3_in\sharew3_rel8-0-0_cv_r.dta", clear 	// Open the dataset  
gen wave=3												// Create wave id 


*	Personal identifier & keep variables	
keep 		///
country    	/// Country identifier
deceased   	/// Deceased
mobirth    	/// Month of birth
yrbirth    	/// Year of birth
age_int    	/// Age of respondent at the time of interview
partnerinhh	/// Partner in household
hhsize     	/// Household size
interview 	/// 
int_year   	/// Interview year
int_month  	/// Interview month
wave 		///
mergeid 	///
gender 		/// 
yrbirthp  	/// 
mobirthp

lab var hhsize    	"Household size"
lab var int_year  	"Interview year"
lab var int_month 	"Interview month"
lab var partnerinhh "Partner in household"
recode gender 2=1 1=0, gen(female)
lab var female "Gender: female=1, male=0"
lab def female 1 "female" 0 "male"
lab val female female


*	Save
save "$share_w3_out\sharew3_cv_r.dta", replace 


*>> WAVE 7
use "$share_w7_in\sharew7_rel8-0-0_cv_r.dta", clear  	// Open the dataset  
gen wave=7												// Create wave id 

*	Personal identifier & keep variables	
keep 			///
country     	/// Country identifier
mobirth     	/// Month of birth
yrbirth     	/// Year of birth
age_int     	/// Age of respondent at the time of interview
partnerinhh 	/// Partner in household
hhsize      	/// Household size
int_year    	/// Interview year
int_month   	/// Interview month
yrbirthp		/// 
mobirthp 		///
gender 			///
interview 		///
deceased    	/// Deceased
wave 			///
mergeid 		///
hhid7       	/// Household identifier (wave 7)
mergeidp7   	/// Partner identifier (wave 7)  
coupleid7   	//  Couple identifier (wave 7)

*>> Labels 
lab var wave         "Wave"
lab var hhsize       "Household size"
lab var int_year	 "Interview year"
lab var int_month	 "Interview month"
recode gender 2=1 1=0, gen(female)
lab var female "Gender: female=1, male=0"
lab def female 1 "female" 0 "male"
lab val female female

*	Save
save "$share_w7_out\sharew7_cv_r.dta", replace 




*-----------------------------------------------------------------------------------------------* 
*>> Merge modules per wave
*-----------------------------------------------------------------------------------------------* 

*>> Wave 3
use "$share_w3_out\sharew3_cv_r.dta", clear 

	merge 1:1 mergeid using "$share_w3_out\sharew3_gs.dta" 				
	ta _merge
	keep if _merge==3
	drop _merge
	
	merge 1:1 mergeid using "$share_w3_out\sharew3_hs.dta" 		
	ta _merge
	drop _merge

	merge 1:1 mergeid using "$share_w3_out\sharew3_srh_paper3.dta" 		
	ta _merge
	drop _merge

*>> Temporary save for wave 3
save "$share_w3_out\sharew3_merged_a.dta", replace

*>> Wave 7
use "$share_w7_out\sharew7_cv_r.dta", clear 

	merge 1:1 mergeid using "$share_w7_out\sharew7_gs.dta" 				
	ta _merge
	keep if _merge==3
	drop _merge
	
	merge 1:1 mergeid using "$share_w7_out\sharew7_hs.dta" 		
	ta _merge
	drop _merge

	merge 1:1 mergeid using "$share_w7_out\sharew7_srh_paper3.dta" 		
	ta _merge
	drop _merge

*>> Temporary save for wave 7
save "$share_w7_out\sharew7_merged_a.dta", replace



*-----------------------------------------------------------------------------------------------* 
*>> Append waves to panel long format
*-----------------------------------------------------------------------------------------------* 

*	Append single wave files to one long file:
use          "$share_w3_out\sharew3_merged_a.dta", clear
append using "$share_w7_out\sharew7_merged_a.dta"
mdesc 

drop if country == 25 // Israel // The reason for excluding Israel is that this country does not fit into the proposed typology of welfare regimes.



*-----------------------------------------------------------------------------------------------* 
*>> Checks and other
*-----------------------------------------------------------------------------------------------* 

*>>	Illogical variables 
* 	// Check for deviations within gender or isced across waves: 
    // if gender deviates between waves, one information must be wrong
    // as there is no way to know which is the wrong information, both
    // are set to -99 (i.e. implausible value/suspected wrong)

*>> Gender
sort mergeid
egen 	gender_change = sd(gender), by(mergeid)
ta 		gender_change
replace gender = -99 if gender_change > 0 & gender_change < . 
drop 	gender_change 
recode  gender (-99=.)

 

*>> Year of Birth
egen 	yrbirth_change = sd(yrbirth), by(mergeid)
ta 		yrbirth_change
replace yrbirth = -99 if yrbirth_change > 0 & yrbirth_change < . 
drop	yrbirth_change 
recode  yrbirth (-99=.)

*>> Keep only countries that have participated in all the 5 regular waves (!)
ta country wave
ta country wave, nola 


*>> Eligibility
	// In wave 1 all household members born 1954 or earlier are eligible for an interview. Starting in wave 2, for new 
	// countries or refreshment samples, there is only one selected respondent per household who has to be born 1956 or 
	// earlier in wave 2, 1960 or earlier in wave 4, 1962 or earlier in wave 5 and 1964 or earlier in wave 6. In 
	// addition – in all waves – current partners living in the same household are interviewed regardless of their age. //

drop if age_int<50


*>>	Label some variables 

*	Gender
recode gender (1=0 "Men") (2=1 "Women"), gen(sex)
ta gender sex, miss
drop gender
label variable sex "Gender"

*>> Order variables
order mergeid wave int_year int_month yrbirth mobirth age_int country sex 

*	Drop variables we don't needc
drop  			///
interview 		///
female 			///
hs007_ 			///
hhid7 			///
mergeidp7 		///
coupleid7 		///
int_year 		///
int_month 		///
deceased 


*>> Drop country/wave combination (we want a clean/clear sample)
drop if country == 11 & wave==7
drop if country == 12 & wave==7
drop if country == 13 & wave==7
drop if country == 14 & wave==7
drop if country == 15 & wave==7
drop if country == 16 & wave==7
drop if country == 17 & wave==7
drop if country == 18 & wave==7
drop if country == 19 & wave==7
drop if country == 20 & wave==7
drop if country == 23 & wave==7
drop if country == 28 & wave==7
drop if country == 29 & wave==7
drop if country == 30 & wave==7

         
*>> Describe/drop missing cases
mdesc 
drop if mergeid 		== ""
drop if wave 			== .
drop if age_int 		== .
drop if country 		== .
drop if sex 			== .
drop if partnerinhh 	== .
drop if hhsize 			== .
drop if maxgrip_paper3 	== .
drop if hs003_			== .
drop if hs004_			== .
drop if hs005_			== .
drop if hs006_			== .
drop if srh_paper3 		== .
           
       
*>> Final Sort
sort mergeid wave // sorting by personal ID and time points

*>> Check for possible duplicate cases
isid mergeid wave

*>> Drop variables that are all missing (Stata Journal, volume 8, number 4: dm89_1) --> here using dm89_2
missings dropvars, force 

*>> Compress dataset
compress

*>> Remove any notes
notes drop _dta

*-----------------------------------------------------------------------------------------------* 
*>> Final Save
*-----------------------------------------------------------------------------------------------* 

*>> Save the dataset
save "$share_all_out\SHARE_W3_W7_version_8.0.0.dta", replace


*-----------------------------------------------------------------------------------------------* 
*>> Close 
*-----------------------------------------------------------------------------------------------* 

*>> Timer
display "$S_TIME  $S_DATE"
timer off 1
timer list 1

*>> Log file
log close
