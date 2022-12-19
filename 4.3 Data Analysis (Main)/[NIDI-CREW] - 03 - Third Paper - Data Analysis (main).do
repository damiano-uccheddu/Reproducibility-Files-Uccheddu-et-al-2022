*-----------------------------------------------------------------------------------------------* 
* Preliminary operations
*-----------------------------------------------------------------------------------------------* 

capture log close
log using "$share_logfile/Data Analysis (main).log", replace 
set more off
set scheme white_tableau

*-----------------------------------------------------------------------------------------------* 
* Prepare the dataset for the analysis
*-----------------------------------------------------------------------------------------------* 

*>> SHARE Wave 2: Take isced, income, and wealth from the SHARE imputation module
use 	"$share_w2_in/sharew2_rel8-0-0_gv_imputations.dta", clear 
keep if implicat==1 
gen wave = 3
keep mergeid country wave thinc2 isced
sort mergeid 
save 	"$share_all_out/sharew2_imputations.dta", replace  

*>> SHARE Wave 7: Take isced, income, wealth, and number of children from the SHARE imputation module (wave 7)
use 	"$share_w7_in/sharew7_rel8-0-0_gv_imputations.dta", clear 
keep if implicat==1 
gen wave = 7
keep mergeid country wave thinc2 isced nchild
sort mergeid 
save 	"$share_all_out/sharew7_imputations.dta", replace  

*>> SHARE long: Drop fictitious cases 
use 	"$share_all_out/SHARE_long_version_8.0.0.dta", clear 	
keep if age == 15
sort mergeid 
save 	"$share_all_out/SHARE_for_analysis.dta", replace 	

*-----------------------------------------------------------------------------------------------* 
*>> Merge 
*-----------------------------------------------------------------------------------------------* 

*>> Merge life course clusters with remaining variables 
use 					"$share_all_out/sharew2_imputations.dta", clear
merge 1:1 mergeid using "$share_all_out/sharew7_imputations.dta", keepusing(mergeid country wave thinc2 isced nchild) nogen
merge m:1 mergeid using "$r_output/cluster_men_12.dta"			, nogen  
merge m:1 mergeid using "$r_output/cluster_women_15.dta"		, nogen  
merge 1:1 mergeid using "$share_all_out/SHARE_for_analysis.dta"	, nogen 

*>> Check the clusters (both genders)
bys gender: fre cluster_*


*-----------------------------------------------------------------------------------------------* 
*>> Prepare the data 
*-----------------------------------------------------------------------------------------------* 

*>> Rename gender/sex
tab gender sex 
rename gender gender_old 
rename sex gender 
drop gender_old 

*>> Keep only the necessary variables 
keep          	/// 
mergeid       	/// 
cluster_*	  	/// 
country       	/// 
wave          	/// 
age_int       	/// 
gender        	/// 
partnerinhh   	/// 
hhsize        	/// 
maxgrip_paper 	/// 
hs003_        	/// 
hs004_        	/// 
hs005_        	/// 
thinc2        	///
isced         	///                     
hs006_        	///
yrbirth 		/// 
nchild  

*>> Describe the missing cases 
mdesc 

*>> Rename health in childhood
rename hs003_ ch_health_status
rename hs004_ ch_missed_school
rename hs005_ ch_confined_bed
rename hs006_ ch_hospital

*>> Recode health in childhood
recode ch_* 			(-1 -2 6 = .) 	// Missing 
recode ch_missed_school (5=0)			// 5 = 0 (No), 1 = Yes
recode ch_confined_bed 	(5=0)			// 5 = 0 (No), 1 = Yes
recode ch_hospital 		(5=0)			// 5 = 0 (No), 1 = Yes

*>> Labels (yes/no)
label drop yesno
label define yesno 	///
   0 "No"  			///
   1 "Yes" 
label values ch_missed_school ch_confined_bed ch_hospital  yesno 

*>> Generate level of education variable 
recode isced (0 1 2 = 0 "Low") (3 4 = 1 "Medium") (5 6 = 2 "High"), gen(education)

*>> Generate welfare clusters variable
recode country 	(13 18 55 				 	= 0 "Social Democratic") 	/// Social Democratic (Denmark, Finland, and Sweden)
				(20 30  					= 1 "Liberal") 				/// Liberal (Ireland and Switzerland) 
				(11 12 14 17 23	31			= 2 "Conservative")  		/// Conservative (Austria, Belgium, France, Germany, Luxembourg, and the Netherlands)
				(15 16 19 33 53 59			= 3 "Southern European") 	/// Southern European (Cyprus, Greece, Italy, Malta, Portugal, and Spain)
				(35 48 57  				 	= 4 "Baltic")		 	  	/// Baltic (Estonia, Latvia, and Lithuania)
				(28 29 32 34 63 47 51 61 	= 5 "CEE"),				  	/// Central and Eastern European (CEE) (Bulgaria, Croatia, Czech Republic, Hungary, Poland, Romania, Slovakia, and Slovenia)
generate(welfare)

*>> Check the new variable 
ta country welfare, miss


*-----------------------------------------------------------------------------------------------* 
* Sample selection 
*-----------------------------------------------------------------------------------------------* 

*>> Drop missing cases
drop if ch_confined_bed 	 == 	.
drop if ch_health_status	 == 	.
drop if ch_hospital 		 == 	.
drop if ch_missed_school	 == 	.
drop if country				 ==		.
drop if country 			 == 25		// Israel 
drop if isced 				 == 	.
drop if maxgrip 			 ==	-1
drop if cluster_12 			 == 	. & cluster_15 	== . 
drop if cluster_12 			 == 	. & gender 		== 0
drop if cluster_15 			 == 	. & gender 		== 1
drop if thinc2 				 == 	.
drop if wave 				 == 	. & country		== .
drop if country == 11 & wave == 7
drop if country == 12 & wave == 7
drop if country == 13 & wave == 7
drop if country == 14 & wave == 7
drop if country == 15 & wave == 7
drop if country == 16 & wave == 7
drop if country == 17 & wave == 7
drop if country == 18 & wave == 7
drop if country == 19 & wave == 7
drop if country == 20 & wave == 7
drop if country == 23 & wave == 7
drop if country == 28 & wave == 7
drop if country == 29 & wave == 7

*>> Describe the missing cases
mdesc 

*>> Final analytic sample 
fre gender 
display ((40320-38129)/40320)*100
 
*>> Generate quartiles of income 
egen income = xtile(thinc2), by(country wave gender) nq(4) // <- Quartiles
fre income 


*-----------------------------------------------------------------------------------------------* 
*>> Recode the work-family clusters (LC = life course)
*-----------------------------------------------------------------------------------------------* 

*>> Men 
* 	Create/recode/order the clusters 
gen lcmen = . 
replace lcmen = 8	if cluster_12 == 1	& gender==0
replace lcmen = 7	if cluster_12 == 2	& gender==0
replace lcmen = 1	if cluster_12 == 3	& gender==0
replace lcmen = 2	if cluster_12 == 4	& gender==0
replace lcmen = 4	if cluster_12 == 5	& gender==0
replace lcmen = 6	if cluster_12 == 6	& gender==0
replace lcmen = 11	if cluster_12 == 7	& gender==0
replace lcmen = 10	if cluster_12 == 8	& gender==0
replace lcmen = 3	if cluster_12 == 9	& gender==0
replace lcmen = 5	if cluster_12 == 10	& gender==0
replace lcmen = 12	if cluster_12 == 11	& gender==0
replace lcmen = 9	if cluster_12 == 12	& gender==0


* 	Attribute the labels 		  
label define lcmen_label										/// 
			1  	"Work FT, Childless, Partnered" 				/// 
			2  	"Work FT, Childless, Single" 					/// 
			3  	"Work FT, Small Family, Partnered" 				/// 
			4  	"Work FT, Small Family Late, Partnered" 		/// 
			5  	"Work FT, Large Family, Unstable Partnership" 	/// 
			6  	"Work FT, Late Family Formation" 				/// 
			7  	"Work FT, Large Family Early, Partnered" 		/// 
			8  	"Work FT, Large Family Late, Partnered" 		/// 
			9  	"Work FT, Delayed Family Transitions" 			/// 
			10 	"Extended Education, Large Family, Partnered" 	/// 
			11 	"Unstable Work, Large Family, Partnered" 		/// 
			12 	"Work PT, Large Family, Unstable Partnership"
label values lcmen lcmen_label


*>> Women 
* 	Create/recode/order the clusters 
gen lcwomen = . 
replace lcwomen = 7 	if cluster_15 == 1 	& gender==1
replace lcwomen = 3 	if cluster_15 == 2 	& gender==1
replace lcwomen = 1 	if cluster_15 == 3 	& gender==1
replace lcwomen = 6 	if cluster_15 == 4 	& gender==1
replace lcwomen = 4 	if cluster_15 == 5 	& gender==1
replace lcwomen = 15 	if cluster_15 == 6 	& gender==1
replace lcwomen = 2 	if cluster_15 == 7 	& gender==1
replace lcwomen = 10 	if cluster_15 == 8 	& gender==1
replace lcwomen = 13 	if cluster_15 == 9 	& gender==1
replace lcwomen = 5 	if cluster_15 == 10	& gender==1
replace lcwomen = 14 	if cluster_15 == 11	& gender==1
replace lcwomen = 11 	if cluster_15 == 12	& gender==1
replace lcwomen = 8 	if cluster_15 == 13	& gender==1
replace lcwomen = 12 	if cluster_15 == 14	& gender==1
replace lcwomen = 9 	if cluster_15 == 15	& gender==1

* 	Attribute the labels 		  
* 	Labels 
label define lcwomen_label															///
			1	"Work FT, Childless, Partnered" 									///
			2	"Work FT, Childless, Single" 										///
			3	"Work FT, Small Family Early, Partnered" 							///
			4	"Work FT, Small Family, Partnered" 									///
			5	"Work FT, Small Family Late, Partnered" 							///
			6	"Work FT, Small Family, Unstable Partnership" 						///
			7	"Family Care, Large Family Early, Partnered" 						///
			8	"Family Care, Large Family Late, Partnered" 						///
			9 	"Work Break, Large Family, Partnered" 								///
			10 	"Drop-out into Family Care, Large Family, Partnered" 				///
			11 	"Drop-out into PT, Large Family, Partnered" 						///
			12	"Drop-out into Out of Labour, Large Family, Partnered" 				///
			13 	"Weak Labour Market Attachment, Large Family, Unstable Partnership" ///
			14 	"Out of Labour, Large Family, Partnered" 							///
			15 	"Unemployed, Large Family, Partnered"
label values lcwomen lcwomen_label


*-----------------------------------------------------------------------------------------------* 
*>> Descriptive statistics 
*-----------------------------------------------------------------------------------------------* 

*>> Table 1

*>> Other variables (Whole population)
sum maxgrip_paper age_int 
tab gender 
tab education
tab income 
tab partnerinhh
tab wave 
tab welfare 
tab ch_health_status 
tab ch_missed_school 
tab ch_confined_bed 
tab ch_hospital 

*>> Other variables (Men) 
sum maxgrip_paper age_int 	if gender == 0
tab gender  				if gender == 0
tab education 				if gender == 0
tab income  				if gender == 0
tab partnerinhh 			if gender == 0
tab wave  					if gender == 0
tab welfare  				if gender == 0
tab ch_health_status 		if gender == 0
tab ch_missed_school 		if gender == 0
tab ch_confined_bed 		if gender == 0
tab ch_hospital 			if gender == 0

*>> Other variables (Women) 
sum maxgrip_paper age_int  	if gender == 1
tab gender  				if gender == 1
tab education 				if gender == 1
tab income  				if gender == 1
tab partnerinhh 			if gender == 1
tab wave  					if gender == 1
tab welfare  				if gender == 1
tab ch_health_status 		if gender == 1
tab ch_missed_school 		if gender == 1
tab ch_confined_bed 		if gender == 1
tab ch_hospital 			if gender == 1


*>> Table 2
*	Work-family clusters 
fre lcmen
fre lcwomen


*>> Table 3. 
*	Percentage distribution over the work-family life course types, by welfare cluster (column percentages).
 
* 	Men 
tab lcmen welfare
tab lcmen welfare, col nofre

* 	Women 
tab lcwomen welfare
tab lcwomen welfare, col nofre


*-----------------------------------------------------------------------------------------------* 
*>> Change the reference category of the life course clusters
*-----------------------------------------------------------------------------------------------* 

*>> MEN: Change the reference category of the life course clusters
recode lcmen 	(3  = 0 ) /// Ref. 
				(4  = 3 ) /// 
				(5  = 4 ) /// 
				(6  = 5 ) /// 
				(7  = 6 ) /// 
				(8  = 7 ) /// 
				(9  = 8 ) /// 
				(10 = 9 ) /// 
				(11 = 10) /// 
				(12 = 11), gen(lcmen_ref)

* 	Labels 
capture label drop lcmen_ref_label
label define lcmen_ref_label								/// 
0  	"Work FT, Small Family, Partnered"						///
1  	"Work FT, Childless, Partnered"							///
2  	"Work FT, Childless, Single"							///
3  	"Work FT, Small Family Late, Partnered"					///
4  	"Work FT, Large Family, Unstable Partnership"			///
5  	"Work FT, Late Family Formation"						///
6  	"Work FT, Large Family Early, Partnered"				///
7  	"Work FT, Large Family Late, Partnered"					///
8  	"Work FT, Delayed Family Transitions"					///
9 	"Extended Education, Large Family, Partnered"			///
10 	"Unstable Work, Large Family, Partnered"				///
11 	"Work PT, Large Family, Unstable Partnership"
label values lcmen_ref lcmen_ref_label

*	Tabulate 
fre lcmen*



*>> WOMEN: Change the reference category of the life course clusters
recode lcwomen 	(3  = 0 ) 	/// Ref. 
				(4  = 3 ) 	/// 
				(5  = 4 ) 	/// 
				(6  = 5 ) 	/// 
				(7  = 6 ) 	/// 
				(8  = 7 ) 	/// 
				(9  = 8 ) 	/// 
				(10 = 9 ) 	/// 
				(11 = 10) 	/// 
				(12 = 11)	/// 
				(13 = 12) 	///
				(14 = 13)	///
				(15 = 14), gen(lcwomen_ref)

* 	Labels 
capture label drop lcwomen_ref_label
label define lcwomen_ref_label											/// 
0	"Work FT, Small Family Early, Partnered"							///
1	"Work FT, Childless, Partnered"										///
2	"Work FT, Childless, Single"										///
3	"Work FT, Small Family, Partnered"									///
4	"Work FT, Small Family Late, Partnered"								///
5	"Work FT, Small Family, Unstable Partnership"						///
6	"Family Care, Large Family Early, Partnered"						///
7	"Family Care, Large Family Late, Partnered"							///
8 	"Work Break, Large Family, Partnered"								///
9 	"Drop-out into Family Care, Large Family, Partnered"				///
10 	"Drop-out into PT, Large Family, Partnered"							///
11	"Drop-out into Out of Labour, Large Family, Partnered"				///
12 	"Weak Labour Market Attachment, Large Family, Unstable Partnership"	///
13 	"Out of Labour, Large Family, Partnered"							///
14 	"Unemployed, Large Family, Partnered"
label values lcwomen_ref lcwomen_ref_label

*	Tabulate 
fre lcwomen*


*-----------------------------------------------------------------------------------------------* 
*>> Main analyses (Regression models)
*-----------------------------------------------------------------------------------------------* 

*>> Macros for the regressions
global 		xvarsmen i.lcmen_ref age_int i.education i.income i.partnerinhh i.wave i.welfare 		///
			i.ch_health_status i.ch_missed_school i.ch_confined_bed i.ch_hospital 

global 		xvarsmen_interaction i.lcmen_ref i.lcmen_ref#i.welfare age_int i.education i.income 	///
			i.partnerinhh i.wave i.welfare i.ch_health_status i.ch_missed_school 					/// 
			i.ch_confined_bed i.ch_hospital 

global 		xvarswomen i.lcwomen_ref age_int i.education i.income i.partnerinhh i.wave i.welfare 	///
			i.ch_health_status i.ch_missed_school i.ch_confined_bed i.ch_hospital 

global 		xvarswomen_interaction i.lcwomen_ref i.lcwomen_ref#i.welfare age_int i.education 		///
			i.income i.partnerinhh i.wave i.welfare i.ch_health_status i.ch_missed_school 			/// 
			i.ch_confined_bed i.ch_hospital 



*>> Regression models  
eststo clear

*>> Men (Table 4)

	* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarsmen if gender==0, vce(robust)

eststo: reg maxgrip_paper $xvarsmen_interaction if gender==0, vce(robust)
margins r.lcmen_ref, over(welfare) atmeans contrast(nowald effects)

*	Figure 3
marginsplot, by(welfare) horiz recast(scatter) xline(0) 	/// 
	title("") xtitle(`"{bf:Grip strength (Men)}"', size()) 	/// 
	ytitle(`"{bf:Life course type}"', size()) 				/// 
	ylabel(, labsize(vsmall)) 								/// 
	xlabel(-10(5)10, labsize(vsmall)) ysc(reverse)
 
gr_edit title.text = {}
gr_edit plotregion1.yaxis1[1].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[1].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 3 3		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 4 4		`"Work FT, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 5 5		`"Work FT, Late Family Formation"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 6 6		`"Work FT, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 7 7		`"Work FT, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 8 8		`"Work FT, Delayed Family Transitions"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 9 9		`"Extended Education, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 10 10	`"Unstable Work, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 11 11	`"Work PT, Large Family, Unstable Partnership"', tickset(major)
 		
gr_edit plotregion1.yaxis1[4].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[4].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 3 3		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 4 4		`"Work FT, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 5 5		`"Work FT, Late Family Formation"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 6 6		`"Work FT, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 7 7		`"Work FT, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 8 8		`"Work FT, Delayed Family Transitions"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 9 9		`"Extended Education, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 10 10	`"Unstable Work, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 11 11	`"Work PT, Large Family, Unstable Partnership"', tickset(major)

gr_edit style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle fillcolor(gs15) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle linestyle(color(gs15)) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
gr_edit legend.style.editstyle boxstyle(linestyle(color(gs15))) editcopy
gr_edit legend.style.editstyle boxstyle(shadestyle(color(gs15))) editcopy
gr_edit legend.Edit, keepstyles

graph save 		"$figure_out/Men_GS", replace
graph export 	"$figure_out/Men_GS.png", as(png) replace
graph export 	"$figure_out/Men_GS.svg", as(svg) replace


*>> Women (Table 5)

		* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarswomen if gender==1, vce(robust)

eststo: reg maxgrip_paper $xvarswomen_interaction if gender==1, vce(robust)
margins r.lcwomen_ref, over(welfare) atmeans contrast(nowald effects)

*	Figure 4
marginsplot, by(welfare) horiz recast(scatter) xline(0) 		/// 
	title("") xtitle(`"{bf:Grip strength (Women)}"', size())  	/// 
	ytitle(`"{bf:Life course type}"', size()) 					/// 
	ylabel(, labsize(vsmall)) 									/// 
	xlabel(-10(5)10, labsize(vsmall)) ysc(reverse)
 
gr_edit title.text = {}
gr_edit plotregion1.yaxis1[1].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[1].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 3 3		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 4 4		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 5 5		`"Work FT, Small Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 6 6		`"Family Care, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 7 7		`"Family Care, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 8 8		`"Work Break, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 9 9		`"Drop-out into Family Care, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 10 10	`"Drop-out into PT, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 11 11	`"Drop-out into Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 12 12	`"Weak Labour Market Attachment, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 13 13	`"Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 14 14	`"Unemployed, Large Family, Partnered"', tickset(major)

gr_edit plotregion1.yaxis1[4].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[4].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 3 3		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 4 4		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 5 5		`"Work FT, Small Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 6 6		`"Family Care, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 7 7		`"Family Care, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 8 8		`"Work Break, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 9 9		`"Drop-out into Family Care, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 10 10	`"Drop-out into PT, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 11 11	`"Drop-out into Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 12 12	`"Weak Labour Market Attachment, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 13 13	`"Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 14 14	`"Unemployed, Large Family, Partnered"', tickset(major)

gr_edit style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle fillcolor(gs15) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle linestyle(color(gs15)) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
gr_edit legend.style.editstyle boxstyle(linestyle(color(gs15))) editcopy
gr_edit legend.style.editstyle boxstyle(shadestyle(color(gs15))) editcopy
gr_edit legend.Edit, keepstyles

graph save 		"$figure_out/Women_GS", replace
graph export 	"$figure_out/Women_GS.png", as(png) replace
graph export 	"$figure_out/Women_GS.svg", as(svg) replace


*>> Save the tables 
esttab using "$tables_out/paper3_regression_models.txt", 										/// 
		tab replace plain star(+ 0.10 * 0.05  **  0.01 *** 0.001) b(3) ci(3) wide not notes 	///
		label constant obslast  aic bic sca(r2 N)


************************************************************************************************* 
* Additional analyses for the Peer-Review                                                       *
************************************************************************************************* 

pause 

*>> SHARE Wave 2: Take isced, income, and wealth from the SHARE imputation module
use 	"$share_w2_in/sharew2_rel8-0-0_gv_imputations.dta", clear 
keep if implicat==1 
gen wave = 3
keep mergeid country wave thinc2 isced
sort mergeid 
save 	"$share_all_out/sharew2_imputations.dta", replace  

*>> SHARE Wave 7: Take isced, income, and wealth from the SHARE imputation module (wave 7)
use 	"$share_w7_in/sharew7_rel8-0-0_gv_imputations.dta", clear 
keep if implicat==1 
gen wave = 7
keep mergeid country wave thinc2 isced
sort mergeid 
save 	"$share_all_out/sharew7_imputations.dta", replace  

*>> SHARE long: Drop fictitious cases 
use 	"$share_all_out/SHARE_long_version_8.0.0.dta", clear 	
keep if age == 15
sort mergeid 
save 	"$share_all_out/SHARE_for_analysis.dta", replace 	

*-----------------------------------------------------------------------------------------------* 
*>> Merge 
*-----------------------------------------------------------------------------------------------* 

*>> Merge life course clusters with remaining variables 
use 					"$share_all_out/sharew2_imputations.dta", clear
merge 1:1 mergeid using "$share_all_out/sharew7_imputations.dta", keepusing(mergeid country wave thinc2 isced) nogen
merge m:1 mergeid using "$r_output/cluster_men_12.dta"			, nogen  
merge m:1 mergeid using "$r_output/cluster_women_15.dta"		, nogen  
merge 1:1 mergeid using "$share_all_out/SHARE_for_analysis.dta"	, nogen 

*>> Check the clusters (both genders)
bys gender: fre cluster_*
 
*-----------------------------------------------------------------------------------------------* 
*>> Prepare the data 
*-----------------------------------------------------------------------------------------------* 

*>> Rename gender/sex
tab gender sex 
rename gender gender_old 
rename sex gender 
drop gender_old 

*>> Keep only the necessary variables 
keep          /// 
mergeid       /// 
cluster_*	  /// 
country       /// 
wave          /// 
age_int       /// 
gender        /// 
partnerinhh   /// 
hhsize        /// 
maxgrip_paper /// 
hs003_        /// 
hs004_        /// 
hs005_        /// 
thinc2        ///
isced         ///                     
hs006_        ///
yrbirth

*>> Describe the missing cases 
mdesc 

*>> Rename health in childhood
rename hs003_ ch_health_status
rename hs004_ ch_missed_school
rename hs005_ ch_confined_bed
rename hs006_ ch_hospital

*>> Recode health in childhood
recode ch_* 			(-1 -2 6 = .) 	// Missing 
recode ch_missed_school (5=0)			// 5 = 0 (No), 1 = Yes
recode ch_confined_bed 	(5=0)			// 5 = 0 (No), 1 = Yes
recode ch_hospital 		(5=0)			// 5 = 0 (No), 1 = Yes

*>> Labels (yes/no)
label drop yesno
label define yesno 	///
   0 "No"  			///
   1 "Yes" 
label values ch_missed_school ch_confined_bed ch_hospital  yesno 

*>> Generate level of education variable 
recode isced (0 1 2 = 0 "Low") (3 4 = 1 "Medium") (5 6 = 2 "High"), gen(education)

*>> Generate welfare clusters variable
recode country 	(13 18 55 				 	= 0 "Social Democratic") 	/// Social Democratic (Denmark, Finland, and Sweden)
				(20 30  					= 1 "Liberal") 				/// Liberal (Ireland and Switzerland) 
				(11 12 14 17 23	31			= 2 "Conservative")  		/// Conservative (Austria, Belgium, France, Germany, Luxembourg, and the Netherlands)
				(15 16 19 33 53 59			= 3 "Southern European") 	/// Southern European (Cyprus, Greece, Italy, Malta, Portugal, and Spain)
				(35 48 57  				 	= 4 "Baltic")		 	  	/// Baltic (Estonia, Latvia, and Lithuania)
				(28 29 32 34 63 47 51 61 	= 5 "CEE"),				  	/// Central and Eastern European (CEE) (Bulgaria, Croatia, Czech Republic, Hungary, Poland, Romania, Slovakia, and Slovenia)
generate(welfare)

*>> Check the new variable 
ta country welfare, miss


*-----------------------------------------------------------------------------------------------* 
* Sample selection 
*-----------------------------------------------------------------------------------------------* 

*>> Drop missing cases
drop if ch_confined_bed 	 == 	.
drop if ch_health_status	 == 	.
drop if ch_hospital 		 == 	.
drop if ch_missed_school	 == 	.
drop if country				 ==		.
drop if country 			 == 25 			// Israel 
drop if isced 				 == 	.
drop if maxgrip 			 ==	-1
drop if cluster_12 			 == 	. & cluster_15 	== . 
drop if cluster_12 			 == 	. & gender 		== 0
drop if cluster_15 			 == 	. & gender 		== 1
drop if thinc2 				 == 	.
drop if wave 				 == 	. & country		== .
drop if country == 11 & wave == 7
drop if country == 12 & wave == 7
drop if country == 13 & wave == 7
drop if country == 14 & wave == 7
drop if country == 15 & wave == 7
drop if country == 16 & wave == 7
drop if country == 17 & wave == 7
drop if country == 18 & wave == 7
drop if country == 19 & wave == 7
drop if country == 20 & wave == 7
drop if country == 23 & wave == 7
drop if country == 28 & wave == 7
drop if country == 29 & wave == 7

*>> Describe the missing cases
mdesc 

*>> Final analytic sample 
fre gender 
display ((40320-38129)/40320)*100
 

*>> Generate quartiles of income 
egen income = xtile(thinc2), by(country wave gender) nq(4) // <- Quartiles
fre income 


*-----------------------------------------------------------------------------------------------* 
*>> Recode the work-family clusters (LC = life course)
*-----------------------------------------------------------------------------------------------* 

*>> Men 
* 	Create/recode/order the clusters 
gen lcmen = . 
replace lcmen = 8	if cluster_12 == 1	& gender==0
replace lcmen = 7	if cluster_12 == 2	& gender==0
replace lcmen = 1	if cluster_12 == 3	& gender==0
replace lcmen = 2	if cluster_12 == 4	& gender==0
replace lcmen = 4	if cluster_12 == 5	& gender==0
replace lcmen = 6	if cluster_12 == 6	& gender==0
replace lcmen = 11	if cluster_12 == 7	& gender==0
replace lcmen = 10	if cluster_12 == 8	& gender==0
replace lcmen = 3	if cluster_12 == 9	& gender==0
replace lcmen = 5	if cluster_12 == 10	& gender==0
replace lcmen = 12	if cluster_12 == 11	& gender==0
replace lcmen = 9	if cluster_12 == 12	& gender==0


* 	Attribute the labels 		  
label define lcmen_label										/// 
			1  	"Work FT, Childless, Partnered" 				/// 
			2  	"Work FT, Childless, Single" 					/// 
			3  	"Work FT, Small Family, Partnered" 				/// 
			4  	"Work FT, Small Family Late, Partnered" 		/// 
			5  	"Work FT, Large Family, Unstable Partnership" 	/// 
			6  	"Work FT, Late Family Formation" 				/// 
			7  	"Work FT, Large Family Early, Partnered" 		/// 
			8  	"Work FT, Large Family Late, Partnered" 		/// 
			9  	"Work FT, Delayed Family Transitions" 			/// 
			10 	"Extended Education, Large Family, Partnered" 	/// 
			11 	"Unstable Work, Large Family, Partnered" 		/// 
			12 	"Work PT, Large Family, Unstable Partnership"
label values lcmen lcmen_label


*>> Women 
* 	Create/recode/order the clusters 
gen lcwomen = . 
replace lcwomen = 7 	if cluster_15 == 1 	& gender==1
replace lcwomen = 3 	if cluster_15 == 2 	& gender==1
replace lcwomen = 1 	if cluster_15 == 3 	& gender==1
replace lcwomen = 6 	if cluster_15 == 4 	& gender==1
replace lcwomen = 4 	if cluster_15 == 5 	& gender==1
replace lcwomen = 15 	if cluster_15 == 6 	& gender==1
replace lcwomen = 2 	if cluster_15 == 7 	& gender==1
replace lcwomen = 10 	if cluster_15 == 8 	& gender==1
replace lcwomen = 13 	if cluster_15 == 9 	& gender==1
replace lcwomen = 5 	if cluster_15 == 10	& gender==1
replace lcwomen = 14 	if cluster_15 == 11	& gender==1
replace lcwomen = 11 	if cluster_15 == 12	& gender==1
replace lcwomen = 8 	if cluster_15 == 13	& gender==1
replace lcwomen = 12 	if cluster_15 == 14	& gender==1
replace lcwomen = 9 	if cluster_15 == 15	& gender==1

* 	Attribute the labels 		  
* 	Labels 
label define lcwomen_label															///
			1	"Work FT, Childless, Partnered" 									/// 
			2	"Work FT, Childless, Single" 										/// 
			3	"Work FT, Small Family Early, Partnered" 							/// 
			4	"Work FT, Small Family, Partnered" 									/// 
			5	"Work FT, Small Family Late, Partnered" 							/// 
			6	"Work FT, Small Family, Unstable Partnership" 						/// 
			7	"Family Care, Large Family Early, Partnered" 						/// 
			8	"Family Care, Large Family Late, Partnered" 						/// 
			9 	"Work Break, Large Family, Partnered" 								/// 
			10 	"Drop-out into Family Care, Large Family, Partnered" 				/// 
			11 	"Drop-out into PT, Large Family, Partnered" 						/// 
			12	"Drop-out into Out of Labour, Large Family, Partnered" 				/// 
			13 	"Weak Labour Market Attachment, Large Family, Unstable Partnership" /// 
			14 	"Out of Labour, Large Family, Partnered" 							/// 
			15 	"Unemployed, Large Family, Partnered"
label values lcwomen lcwomen_label



*>> Macros for the regressions
global 	xvarsmen ib3.lcmen age_int i.education i.income i.partnerinhh i.wave 			///
		i.welfare i.ch_health_status i.ch_missed_school i.ch_confined_bed i.ch_hospital 

global 	xvarsmen_interaction ib3.lcmen ib3.lcmen#i.welfare age_int i.education 			///
		i.income i.partnerinhh i.wave i.welfare i.ch_health_status i.ch_missed_school 	/// 
		i.ch_confined_bed i.ch_hospital 

global 	xvarswomen ib3.lcwomen age_int i.education i.income i.partnerinhh i.wave 		///
		i.welfare i.ch_health_status i.ch_missed_school i.ch_confined_bed i.ch_hospital 

global 	xvarswomen_interaction ib3.lcwomen ib3.lcwomen#i.welfare age_int 				///
		i.education i.income i.partnerinhh i.wave i.welfare i.ch_health_status 			///
		i.ch_missed_school i.ch_confined_bed i.ch_hospital 


*-----------------------------------------------------------------------------------------------* 
*>> Cohort differences 
*-----------------------------------------------------------------------------------------------* 

*>> Generate 2 cohorts
gen cohort = .
replace cohort = 0 if yrbirth <= 1945
replace cohort = 1 if yrbirth >  1945

*>> Regression models by cohort
eststo clear

* Men 
	* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarsmen		if gender==0 & cohort == 0, vce(robust)
eststo: reg maxgrip_paper $xvarsmen		if gender==0 & cohort == 1, vce(robust)

* Women 
	* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarswomen	if gender==1 & cohort == 0, vce(robust)
eststo: reg maxgrip_paper $xvarswomen	if gender==1 & cohort == 1, vce(robust)

*>> Save the tables 
esttab using "$tables_out/paper3_regression_models_cohort.txt", 							/// 
		tab replace plain star(+ 0.10 * 0.05  **  0.01 *** 0.001) b(3) ci(3) wide not notes	///
		label constant obslast  aic bic sca(r2 N) 

*-----------------------------------------------------------------------------------------------* 
*>> Mean and Binary Contrasts 
*-----------------------------------------------------------------------------------------------* 

*>> Models for men 
eststo clear

	* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarsmen if gender==0, vce(robust)
binarycontrast lcmen

eststo: reg maxgrip_paper $xvarsmen_interaction if gender==0, vce(robust)
margins gw.lcmen@welfare, contrast(nowald effects)
 
marginsplot, by(welfare) horiz recast(scatter) xline(0) 	/// 
	title("") xtitle(`"{bf:Grip strength (Men)}"', size()) 	/// 
	ytitle(`"{bf:Life course type}"', size()) 				/// 
	ylabel(, labsize(vsmall)) 								/// 
	xlabel(-10(5)10, labsize(vsmall)) ysc(reverse)

gr_edit title.text = {}
gr_edit plotregion1.yaxis1[1].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[1].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 3 3		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 4 4		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 5 5		`"Work FT, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 6 6		`"Work FT, Late Family Formation"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 7 7		`"Work FT, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 8 8		`"Work FT, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 9 9		`"Work FT, Delayed Family Transitions"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 10 10	`"Extended Education, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 11 11	`"Unstable Work, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 12 12	`"Work PT, Large Family, Unstable Partnership"', tickset(major)
 		
gr_edit plotregion1.yaxis1[4].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[4].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 3 3		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 4 4		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 5 5		`"Work FT, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 6 6		`"Work FT, Late Family Formation"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 7 7		`"Work FT, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 8 8		`"Work FT, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 9 9		`"Work FT, Delayed Family Transitions"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 10 10	`"Extended Education, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 11 11	`"Unstable Work, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 12 12	`"Work PT, Large Family, Unstable Partnership"', tickset(major)

gr_edit plotregion1.subtitle[1].text = {}
gr_edit plotregion1.subtitle[1].text.Arrpush Social Democratic
gr_edit plotregion1.subtitle[2].text = {}
gr_edit plotregion1.subtitle[2].text.Arrpush Liberal
gr_edit plotregion1.subtitle[3].text = {}
gr_edit plotregion1.subtitle[3].text.Arrpush Conservative
gr_edit plotregion1.subtitle[4].text = {}
gr_edit plotregion1.subtitle[4].text.Arrpush Southern European
gr_edit plotregion1.subtitle[5].text = {}
gr_edit plotregion1.subtitle[5].text.Arrpush Baltic
gr_edit plotregion1.subtitle[6].text = {}
gr_edit plotregion1.subtitle[6].text.Arrpush CEE

gr_edit style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle fillcolor(gs15) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle linestyle(color(gs15)) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
gr_edit legend.style.editstyle boxstyle(linestyle(color(gs15))) editcopy
gr_edit legend.style.editstyle boxstyle(shadestyle(color(gs15))) editcopy
gr_edit legend.Edit, keepstyles

graph save 		"$figure_out/Mean_Contrasts_Men_GS", replace
graph export 	"$figure_out/Mean_Contrasts_Men_GS.png", as(png) replace
graph export 	"$figure_out/Mean_Contrasts_Men_GS.svg", as(svg) replace


*>> Models for women 

		* GRIP STRENGTH
eststo: reg maxgrip_paper $xvarswomen if gender==1, vce(robust)
binarycontrast lcwomen

eststo: reg maxgrip_paper $xvarswomen_interaction if gender==1, vce(robust)
margins gw.lcwomen@welfare, contrast(nowald effects)

marginsplot, by(welfare) horiz recast(scatter) xline(0) 		/// 
	title("") xtitle(`"{bf:Grip strength (Women)}"', size())  	/// 
	ytitle(`"{bf:Life course type}"', size()) 					/// 
	ylabel(, labsize(vsmall)) 									/// 
	xlabel(-10(5)10, labsize(vsmall)) ysc(reverse)

gr_edit title.text = {}
gr_edit plotregion1.yaxis1[1].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[1].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 3 3		`"Work FT, Small Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 4 4		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 5 5		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 6 6		`"Work FT, Small Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 7 7		`"Family Care, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 8 8		`"Family Care, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 9 9		`"Work Break, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 10 10	`"Drop-out into Family Care, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 11 11	`"Drop-out into PT, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 12 12	`"Drop-out into Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 13 13	`"Weak Labour Market Attachment, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 14 14	`"Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[1].edit_tick 15 15	`"Unemployed, Large Family, Partnered"', tickset(major)

gr_edit plotregion1.yaxis1[4].major.num_rule_ticks = 0
gr_edit plotregion1.yaxis1[4].edit_tick 1 1		`"Work FT, Childless, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 2 2		`"Work FT, Childless, Single"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 3 3		`"Work FT, Small Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 4 4		`"Work FT, Small Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 5 5		`"Work FT, Small Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 6 6		`"Work FT, Small Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 7 7		`"Family Care, Large Family Early, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 8 8		`"Family Care, Large Family Late, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 9 9		`"Work Break, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 10 10	`"Drop-out into Family Care, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 11 11	`"Drop-out into PT, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 12 12	`"Drop-out into Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 13 13	`"Weak Labour Market Attachment, Large Family, Unstable Partnership"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 14 14	`"Out of Labour, Large Family, Partnered"', tickset(major)
gr_edit plotregion1.yaxis1[4].edit_tick 15 15	`"Unemployed, Large Family, Partnered"', tickset(major)

gr_edit plotregion1.subtitle[1].text = {}
gr_edit plotregion1.subtitle[1].text.Arrpush Social Democratic
gr_edit plotregion1.subtitle[2].text = {}
gr_edit plotregion1.subtitle[2].text.Arrpush Liberal
gr_edit plotregion1.subtitle[3].text = {}
gr_edit plotregion1.subtitle[3].text.Arrpush Conservative
gr_edit plotregion1.subtitle[4].text = {}
gr_edit plotregion1.subtitle[4].text.Arrpush Southern European
gr_edit plotregion1.subtitle[5].text = {}
gr_edit plotregion1.subtitle[5].text.Arrpush Baltic
gr_edit plotregion1.subtitle[6].text = {}
gr_edit plotregion1.subtitle[6].text.Arrpush CEE

gr_edit style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle fillcolor(gs15) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle linestyle(color(gs15)) editcopy
gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
gr_edit legend.style.editstyle boxstyle(linestyle(color(gs15))) editcopy
gr_edit legend.style.editstyle boxstyle(shadestyle(color(gs15))) editcopy
gr_edit legend.Edit, keepstyles

graph save 		"$figure_out/Mean_Contrasts_Women_GS", replace
graph export 	"$figure_out/Mean_Contrasts_Women_GS.png", as(png) replace
graph export 	"$figure_out/Mean_Contrasts_Women_GS.svg", as(svg) replace


*>> Save the tables 
esttab using "$tables_out/paper3_regression_models_Reviewers.txt", /// 
		tab replace plain star(+ 0.10 * 0.05  **  0.01 *** 0.001) b(3) ci(3) wide not notes 	///
		label constant obslast  aic bic sca(r2 N)


*-----------------------------------------------------------------------------------------------* 
*>> Create variables with information on time spent in each of the state between age 15 and 49
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset 
use "$share_all_out\SHARE_long_version_8.0.0.dta", clear 
merge m:1 mergeid using "$r_output/cluster_men_12.dta"
keep if _merge == 3
drop _merge

sort mergeid age 

*>> Reshape wide 
reshape wide	/// 
withpartner 	/// 
workstate_ 		/// 
kids 			/// 
, i(mergeid) j(age)

*>> Sort the dataset 
sort gender mergeid, stable 

*>> Men 
* 	Create/recode/order the clusters 
gen lcmen = . 
replace lcmen = 8	if cluster_12 == 1	
replace lcmen = 7	if cluster_12 == 2	
replace lcmen = 1	if cluster_12 == 3	
replace lcmen = 2	if cluster_12 == 4	
replace lcmen = 4	if cluster_12 == 5	
replace lcmen = 6	if cluster_12 == 6	
replace lcmen = 11	if cluster_12 == 7	
replace lcmen = 10	if cluster_12 == 8	
replace lcmen = 3	if cluster_12 == 9	
replace lcmen = 5	if cluster_12 == 10	
replace lcmen = 12	if cluster_12 == 11	
replace lcmen = 9	if cluster_12 == 12	


* 	Attribute the labels 		  
label define lcmen_label										/// 
			1  	"Work FT, Childless, Partnered" 				/// 
			2  	"Work FT, Childless, Single" 					/// 
			3  	"Work FT, Small Family, Partnered" 				/// 
			4  	"Work FT, Small Family Late, Partnered" 		/// 
			5  	"Work FT, Large Family, Unstable Partnership" 	/// 
			6  	"Work FT, Late Family Formation" 				/// 
			7  	"Work FT, Large Family Early, Partnered" 		/// 
			8  	"Work FT, Large Family Late, Partnered" 		/// 
			9  	"Work FT, Delayed Family Transitions" 			/// 
			10 	"Extended Education, Large Family, Partnered" 	/// 
			11 	"Unstable Work, Large Family, Partnered" 		/// 
			12 	"Work PT, Large Family, Unstable Partnership"
label values lcmen lcmen_label

*>> Men 
* 	Cohabitation 
order withpartner15 withpartner16 withpartner17 withpartner18 withpartner19 withpartner20 withpartner21 withpartner22 withpartner23 withpartner24 withpartner25 ///
withpartner26 withpartner27 withpartner28 withpartner29 withpartner30 withpartner31 withpartner32 withpartner33 withpartner34 withpartner35 withpartner36 withpartner37 ///
withpartner38 withpartner39 withpartner40 withpartner41 withpartner42 withpartner43 withpartner44 withpartner45 withpartner46 withpartner47 withpartner48 withpartner49 
cumuldur withpartner15-withpartner49, cd(y_withpartnerstate) nstates(2)
sum y_withpartnerstate*
graph bar y_withpartnerstate*,  by(lcmen, title("Mean years spent in different cohabitation states (age 15-49), by life course type (men)", size(small)) note("")) ///
		legend(order (1 "Not Cohabiting" 2 "Cohabiting") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_withpartnerstate_men.svg", as(svg) replace
table lcmen, statistic(mean y_withpartnerstate2) 

* 	Employment 
order workstate_15 workstate_16 workstate_17 workstate_18 workstate_19 workstate_20 workstate_21 workstate_22 workstate_23 workstate_24 workstate_25 		///
workstate_26 workstate_27 workstate_28 workstate_29 workstate_30 workstate_31 workstate_32 workstate_33 workstate_34 workstate_35 workstate_36 workstate_37 ///
workstate_38 workstate_39 workstate_40 workstate_41 workstate_42 workstate_43 workstate_44 workstate_45 workstate_46 workstate_47 workstate_48 workstate_49 
cumuldur workstate_15-workstate_49, cd(y_workstate_state) nstates(6)
sum y_workstate_state*
graph bar y_workstate_state*,  by(lcmen, title("Mean years spent in different employment states (age 15-49), by life course type (men)", size(small)) note("")) ///
		legend(order (1 "Working Full-Time (FT)" 2 "Working Part-Time (PT)" 3 "Unemployed" 4 "Home or Family Work" 5 "In Education" 6 "Other") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_workstate_state_men.svg", as(svg) replace
table lcmen, statistic(mean y_workstate_state5) 

* 	Kids 
order kids15 kids16 kids17 kids18 kids19 kids20 kids21 kids22 kids23 kids24 kids25 	///
kids26 kids27 kids28 kids29 kids30 kids31 kids32 kids33 kids34 kids35 kids36 kids37 ///
kids38 kids39 kids40 kids41 kids42 kids43 kids44 kids45 kids46 kids47 kids48 kids49 
cumuldur kids15-kids49, cd(y_kidstate) nstates(5)
sum y_kidstate*
graph bar y_kidstate*,  by(lcmen, title("Mean years spent in different parenthood states (age 15-49), by life course type (men)", size(small)) note("")) ///
		legend(order (1 "Childless" 2 "No Children <7" 3 "1 Child <7" 4 "2 Children <7" 5 "3+ Children <7") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_kidstate_men.svg", as(svg) replace
table lcmen, statistic(mean y_kidstate1) 


*>> Open the dataset 
use "$share_all_out\SHARE_long_version_8.0.0.dta", clear 
merge m:1 mergeid using "$r_output/cluster_women_15.dta"
keep if _merge == 3
drop _merge

sort mergeid age 

*>> Reshape wide 
reshape wide	/// 
withpartner 	/// 
workstate_ 		/// 
kids 			/// 
, i(mergeid) j(age)

*>> Sort the dataset 
sort gender mergeid, stable 


*>> Women 
* 	Create/recode/order the clusters 
gen lcwomen = . 
replace lcwomen = 7 	if cluster_15 == 1 	
replace lcwomen = 3 	if cluster_15 == 2 	
replace lcwomen = 1 	if cluster_15 == 3 	
replace lcwomen = 6 	if cluster_15 == 4 	
replace lcwomen = 4 	if cluster_15 == 5 	
replace lcwomen = 15 	if cluster_15 == 6 	
replace lcwomen = 2 	if cluster_15 == 7 	
replace lcwomen = 10 	if cluster_15 == 8 	
replace lcwomen = 13 	if cluster_15 == 9 	
replace lcwomen = 5 	if cluster_15 == 10	
replace lcwomen = 14 	if cluster_15 == 11	
replace lcwomen = 11 	if cluster_15 == 12	
replace lcwomen = 8 	if cluster_15 == 13	
replace lcwomen = 12 	if cluster_15 == 14	
replace lcwomen = 9 	if cluster_15 == 15	

* 	Attribute the labels 		  
* 	Labels 
label define lcwomen_label															///
			1	"Work FT, Childless, Partnered" 									///
			2	"Work FT, Childless, Single" 										///
			3	"Work FT, Small Family Early, Partnered" 							///
			4	"Work FT, Small Family, Partnered" 									///
			5	"Work FT, Small Family Late, Partnered" 							///
			6	"Work FT, Small Family, Unstable Partnership" 						///
			7	"Family Care, Large Family Early, Partnered" 						///
			8	"Family Care, Large Family Late, Partnered" 						///
			9 	"Work Break, Large Family, Partnered" 								///
			10 	"Drop-out into Family Care, Large Family, Partnered" 				///
			11 	"Drop-out into PT, Large Family, Partnered" 						///
			12	"Drop-out into Out of Labour, Large Family, Partnered" 				///
			13 	"Weak Labour Market Attachment, Large Family, Unstable Partnership" ///
			14 	"Out of Labour, Large Family, Partnered" 							///
			15 	"Unemployed, Large Family, Partnered"
label values lcwomen lcwomen_label

*>> Women 
* 	Cohabitation 
order withpartner15 withpartner16 withpartner17 withpartner18 withpartner19 withpartner20 withpartner21 withpartner22 withpartner23 withpartner24 withpartner25 		///
withpartner26 withpartner27 withpartner28 withpartner29 withpartner30 withpartner31 withpartner32 withpartner33 withpartner34 withpartner35 withpartner36 withpartner37 ///
withpartner38 withpartner39 withpartner40 withpartner41 withpartner42 withpartner43 withpartner44 withpartner45 withpartner46 withpartner47 withpartner48 withpartner49 
cumuldur withpartner15-withpartner49, cd(y_withpartnerstate) nstates(2)
sum y_withpartnerstate*
graph bar y_withpartnerstate*,  by(lcwomen, title("Mean years spent in different cohabitation states (age 15-49), by life course type (women)", size(small)) note("")) ///
		legend(order (1 "Not Cohabiting" 2 "Cohabiting") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_withpartnerstate_women.svg", as(svg) replace
table lcwomen, statistic(mean y_withpartnerstate2) 

* 	Employment 
order workstate_15 workstate_16 workstate_17 workstate_18 workstate_19 workstate_20 workstate_21 workstate_22 workstate_23 workstate_24 workstate_25 		///
workstate_26 workstate_27 workstate_28 workstate_29 workstate_30 workstate_31 workstate_32 workstate_33 workstate_34 workstate_35 workstate_36 workstate_37 ///
workstate_38 workstate_39 workstate_40 workstate_41 workstate_42 workstate_43 workstate_44 workstate_45 workstate_46 workstate_47 workstate_48 workstate_49 
cumuldur workstate_15-workstate_49, cd(y_workstate_state) nstates(6)
sum y_workstate_state*
graph bar y_workstate_state*,  by(lcwomen, title("Mean years spent in different employment states (age 15-49), by life course type (women)", size(small)) note("")) ///
		legend(order (1 "Working Full-Time (FT)" 2 "Working Part-Time (PT)" 3 "Unemployed" 4 "Home or Family Work" 5 "In Education" 6 "Other") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_workstate_state_women.svg", as(svg) replace
table lcwomen, statistic(mean y_workstate_state5) 

* 	Kids 
order kids15 kids16 kids17 kids18 kids19 kids20 kids21 kids22 kids23 kids24 kids25 	///
kids26 kids27 kids28 kids29 kids30 kids31 kids32 kids33 kids34 kids35 kids36 kids37 ///
kids38 kids39 kids40 kids41 kids42 kids43 kids44 kids45 kids46 kids47 kids48 kids49 
cumuldur kids15-kids49, cd(y_kidstate) nstates(5)
sum y_kidstate*
graph bar y_kidstate*,  by(lcwomen, title("Mean years spent in different parenthood states (age 15-49), by life course type (women)", size(small)) note("")) ///
		legend(order (1 "Childless" 2 "No Children <7" 3 "1 Child <7" 4 "2 Children <7" 5 "3+ Children <7") size(vsmall)) scheme(s2color)  
gr_edit plotregion1.subtitle[5].style.editstyle size(vsmall) editcopy
graph export 	"$figure_out/y_kidstate_women.svg", as(svg) replace
table lcwomen, statistic(mean y_kidstate1) 



*-----------------------------------------------------------------------------------------------* 
*>> Close 
*-----------------------------------------------------------------------------------------------* 

*>> Close the log file
capture log close
