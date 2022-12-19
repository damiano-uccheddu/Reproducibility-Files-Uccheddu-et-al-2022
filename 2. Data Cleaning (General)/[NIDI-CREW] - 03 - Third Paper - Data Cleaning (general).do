*>> Log file
capture log close 
log using "$share_logfile/Data Cleaning (general).log", replace

*>> Open the original SHARE job episodes panel dataset. 
use "$job_episodes/sharewX_rel8-0-0_gv_job_episodes_panel.dta", clear 

* 	Sort the dataset
sort mergeid age* 

* 	Keep only useful variables 
keep 	situation 	 	///
		nchildren 	 	/// Having children is coded in an inclusive way, including biological, step-, and adopted children
		age_youngest 	/// The variable is missing when nchildren == 0
		withpartner	 	///
		gender			/// 
		mergeid 		/// 
		age 			///
		working_hours 


*-----------------------------------------------------------------------------------------------* 
*>> Create the states: Employment
*-----------------------------------------------------------------------------------------------* 

*>> Employment
fre situation 
recode situation 		(1 4 								= 0 "Employed or Self-employed") 	/// 
						(2 3 								= 3 "Unemployed") 					/// 
						(6 									= 4 "Home or family work") 			/// 
						(9 10 								= 5 "In education or training")  	/// 
						(5 7 8 11 12 13 14 15 16 17 97 		= 6 "Other")						/// 
																								///
						/// "Other" category:
						/// 
						/// Sick or disabled ; Leisure, travelling or doing nothing ; 
						/// Retired from work ; Military services, war prisoner or equivalent ; 
						/// Managing your assets ; Voluntary or community work ; 
						/// Forced labour or in jail ; Exiled or banished ; 
						/// Labor camp ; Concentration camp ; Other
						(else = . ), gen(workstate_)


* 	Check the new and the old variable 
tab situation workstate_, miss 

*>> Full-time and part-time 
replace workstate_ = 1 if working_hours == 1 & workstate_ == 0 // Always full-time
replace workstate_ = 2 if working_hours == 2 & workstate_ == 0 // Always part-time

tab situation workstate_, miss 

capture lab drop workstate_lab
label define workstate_lab 					/// 
0 "Employed (but missing working hours)" 	/// 
1 "Working Full-Time (FT)"					/// 
2 "Working Part-Time (PT)"					/// 
3 "Unemployed" 								/// 
4 "Home or Family Work" 					/// 
5 "In Education"			  				/// 
6 "Other" 
label values workstate_ workstate_lab
lab var workstate_ "Work situation"

// list mergeid workstate_ working_hours age, sepby(mergeid) 
// browse if mergeid=="Ih-318213-01" // check at age 24 & 25

*>> Replace if changes in working hours 
*	In case of "Changed once from full-time to part-time", full-time is assigned before the change to part-time 
bys mergeid: replace 	workstate_ 			=  1 	/// Working full-time 
if 						working_hours 		== 3 	/// Changed once from full-time to part-time
& 						workstate_ 			== 0 	/// Employed (but missing working hours) 
& 						workstate_[_n-1] 	== 1 	//  Working full-time at time t-1

*	In case of "Changed once from part-time to full-time", part-time is assigned before the change to part-time 
bys mergeid: replace 	workstate_ 			=  2 	/// Working part-time
if 						working_hours 		== 4 	/// Changed once from part-time to full-time
& 						workstate_ 			== 0 	/// Employed (but missing working hours) 
& 						workstate_[_n-1] 	== 2 	//  Working part-time at time t-1

* Check 
// browse if mergeid=="Ih-318213-01" // check at age 24 & 25

*>> Replace when multiple changes in working hours 
*	In case of "multiple changes" full-time is assumed before the change to part-time and part-time thereafter
bys mergeid: replace 	workstate_ 			=  1 	/// Working full-time 
if 						working_hours 		== 5 	/// Changed once from full-time to part-time
& 						workstate_ 			== 0 	/// Employed (but missing working hours) 
& 						workstate_[_n-1] 	== 1 	//  Working full-time at time t-1

*	In case of "multiple changes" part-time is assumed before the change to full-time and full-time thereafter
bys mergeid: replace 	workstate_ 			=  2 	/// Working part-time
if 						working_hours 		== 5 	/// Changed once from part-time to full-time
& 						workstate_ 			== 0 	/// Employed (but missing working hours) 
& 						workstate_[_n-1] 	== 2 	//  Working part-time at time t-1

* 	Drop this variable because we don't need it anymore
drop situation


*-----------------------------------------------------------------------------------------------* 
*>> Create the states: Fertility 
*-----------------------------------------------------------------------------------------------* 

gen kids = . 
replace kids = 1 if nchildren == 0 						// Childless
replace kids = 2 if nchildren != 0 & age_youngest >=7  	// No kids younger than 7
replace kids = 3 if nchildren == 1 & age_youngest < 7  	// 1  Kids 
replace kids = 4 if nchildren == 2 & age_youngest < 7  	// 2  Kids
replace kids = 5 if nchildren >= 3 & age_youngest < 7  	// 3+ Kids

* 	Attribute the Labels
label define lab_kids	///
   1 "Childless"       	/// 
   2 "No Children <7"   ///
   3 "1 Child <7"       ///
   4 "2 Children <7"    ///
   5 "3+ Children <7"   

label values kids lab_kids

* 	Check the new and the old variable 
tab nchildren kids, miss

* 	Drop these variables because we don't need it anymore
drop age_youngest nchildren


*-----------------------------------------------------------------------------------------------* 
*>> Create the states: Cohabitation 
*-----------------------------------------------------------------------------------------------* 

rename withpartner withpartner_temp
recode withpartner_temp 		(0 	= 1 "Not Cohabiting"	)	/// 
				 				(1 	= 2 "Cohabiting"		)	/// 
				 				(else = .						), gen(withpartner)

* 	Drop some variables we don't need anymore
drop withpartner_temp 
drop working_hours


*-----------------------------------------------------------------------------------------------* 
*>> Reshape wide 
*-----------------------------------------------------------------------------------------------* 

*>> Reshape wide (this is necessary for the 1:1 merge and also the sequence analysis)
reshape wide 			///
withpartner@ 			/// 
workstate_@ 			/// 
kids@ 					/// 
, i(mergeid) j(age)

*>> Sort the dataset 
sort mergeid

*-----------------------------------------------------------------------------------------------* 
*>> Merge with other (health and other) data from SHARE 
*-----------------------------------------------------------------------------------------------* 

*>> Merge the job episodes panel with the harmonized SHARE long. 
merge 1:1 mergeid using "$share_all_out\SHARE_W3_W7_version_8.0.0.dta"

*>> Keep only merged 
keep if _merge==3

*>> Original sample 
fre gender 			// The original SHARE sample consisted of 51,257 cases (43.76% men and 56.24% women) 
fre country 		// from 28 countries
tab country wave 	// 14 from the third SHARELIFE wave (Austria, Belgium, Czech Republic, 
					// Denmark, France, Germany, Greece, Ireland, Italy, Netherlands, 
					// Poland, Spain, Sweden, and Switzerland) and 14 from the seventh 
					// SHARELIFE wave (Bulgaria, Croatia, Cyprus, Estonia, Finland, Hungary, 
					// Latvia, Lithuania, Luxembourg, Malta, Portugal, Romania, Slovakia, and Slovenia). 

*-----------------------------------------------------------------------------------------------* 
* Standardization of Sequences 
*-----------------------------------------------------------------------------------------------* 

*>> Reshape in long format 
reshape long 

*>> Sort again 
sort mergeid

*>> Generate an id variable which counts the number of years of age of the individuals 
bys mergeid: gen nr=_n

*>> Compare old and new variable 
compare nr age
fre nr age

*-----------------------------------------------------------------------------------------------* 
*>> Upper bound 
*-----------------------------------------------------------------------------------------------* 

keep if nr<=50 		& workstate_ !=. & kids !=. & withpartner !=. 
// list mergeid gender situation nchildren married withpartner age nr, sepby(mergeid)

egen nrmax=max(nr), by(mergeid)  
// list mergeid gender situation nchildren married withpartner age nr nrmax, sepby(mergeid)
// ta nrmax

keep if nrmax==50 	& workstate_ !=. & kids !=. & withpartner !=. 
// list mergeid gender situation nchildren married withpartner age nr nrmax, sepby(mergeid)

*-----------------------------------------------------------------------------------------------* 
*>> Lower bound
*-----------------------------------------------------------------------------------------------* 

*>> Delete the first artificial year  
drop if nr == 1 
replace age = age-1

keep if age>14
// list mergeid gender situation nchildren married withpartner age nr nrmax, sepby(mergeid)



*-----------------------------------------------------------------------------------------------* 
*>> Drop the missing cases 
*-----------------------------------------------------------------------------------------------* 

*>> Fertility <<*  

* 	I drop the cases in which we don't have information on the fertility histories 
egen npositive = total(kids > 0 & kids < .), by(mergeid)
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)
 
keep if npositive == 35 // 15+35=50
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)

drop npositive



*>> Employment <<* 

*>> I drop the cases in which we don't have information on the employment histories 
egen npositive = total(workstate_ > 0 & workstate_ < .), by(mergeid)
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)

keep if npositive == 35 // 15+35=50
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)

drop npositive



*>> Cohabitation <<*

*>> I drop the cases in which we don't have information on the cohabitation histories 
egen npositive = total(withpartner > 0 & withpartner < .), by(mergeid)
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)

keep if npositive == 35 // 15+35=50
// list mergeid gender situation nchildren married withpartner age nr npositive, sepby(mergeid)


*>> Drop variables that are all missing 
missings dropvars, force // (Stata Journal, volume 8, number 4: dm89_1) --> here using dm89_2



*-----------------------------------------------------------------------------------------------* 
*>> Other 
*-----------------------------------------------------------------------------------------------* 

*>> Compress the dataset
compress

*>> Remove any notes
notes drop _dta

*>> Describe 
desc, short 

*>> Rename two variables 
rename maxgrip_paper3 maxgrip_paper
rename srh_paper3  srh_paper

*>> Drop superfluous variables 
drop _merge 
drop nr


 
*-----------------------------------------------------------------------------------------------* 
*>> Save the dataset 
*-----------------------------------------------------------------------------------------------* 

*>> Save the dataset
save "$share_all_out/SHARE_long_version_8.0.0.dta", replace

*>> Close the log file
log close
