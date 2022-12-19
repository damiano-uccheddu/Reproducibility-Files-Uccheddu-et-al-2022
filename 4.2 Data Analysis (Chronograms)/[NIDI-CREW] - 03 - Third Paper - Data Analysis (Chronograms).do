*-----------------------------------------------------------------------------------------------* 
*>> Preliminary operations 
*-----------------------------------------------------------------------------------------------* 

*>> Log 
capture log close 
log using "$share_logfile/Data Analysis (Chronograms).log", replace


*-----------------------------------------------------------------------------------------------* 
*>> Define a program for reordering the clusters (Men)
*-----------------------------------------------------------------------------------------------* 

capture program drop order_clusters_men
program define order_clusters_men

			* 	Recode the variable 
			recode cluster_12 	/// 
			(1 	= 8)			/// 
			(2 	= 7)			/// 
			(3 	= 1)			/// 
			(4 	= 2)			/// 
			(5 	= 4)			/// 
			(6 	= 6)			/// 
			(7 	= 11)			/// 
			(8 	= 10)			/// 
			(9 	= 3)			/// 
			(10 = 5)			/// 
			(11 = 12)			/// 
			(12 = 9)

			* 	Attribute the labels 		  
			label define cluster_12_label 						///
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

			* 	Label the variable 
			label values cluster_12 cluster_12_label 
end 

*-----------------------------------------------------------------------------------------------* 
*>> Define a program for modifying the subtitles in the graphs (Men)
*-----------------------------------------------------------------------------------------------* 

capture program drop subtitle_mod_men
program define subtitle_mod_men
			gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
			gr_edit style.editstyle margin(vsmall) editcopy
			gr_edit legend.Edit , style(row_gap(minuscule)) keepstyles 
			gr_edit plotregion1.subtitle[1].text = {}
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"{bf:Childless, Partnered}"'
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"(n = 1,023)"'
			gr_edit plotregion1.subtitle[2].text = {}
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"{bf:Childless, Single}"'
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"(n = 812)"'
			gr_edit plotregion1.subtitle[3].text = {}
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"{bf:Small Family, Partnered}"'
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"(n = 4,758)"'
			gr_edit plotregion1.subtitle[4].text = {}
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"{bf:Small Family Late, Partnered}"'
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"(n = 1,220)"'
			gr_edit plotregion1.subtitle[5].text = {}
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"{bf:Large Family, Unstable Partnership}"'
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"(n = 761)"'
			gr_edit plotregion1.subtitle[6].text = {}
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"{bf:Late Family Formation}"'
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"(n = 3,408)"'
			gr_edit plotregion1.subtitle[7].text = {}
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"{bf:Large Family Early, Partnered}"'
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"(n = 1814)"'
			gr_edit plotregion1.subtitle[8].text = {}
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"{bf:Large Family Late, Partnered}"'
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"(n = 2057)"'
			gr_edit plotregion1.subtitle[9].text = {}
			gr_edit plotregion1.subtitle[9].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[9].text.Arrpush 	`"{bf:Delayed Family Transitions}"'
			gr_edit plotregion1.subtitle[9].text.Arrpush 	`"(n = 482)"'
			gr_edit plotregion1.subtitle[10].text = {}
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"{bf:Extended Education,}"'
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"(n = 1,074)"'
			gr_edit plotregion1.subtitle[11].text = {}
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"{bf:Unstable Work,}"'
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"(n = 561)"'
			gr_edit plotregion1.subtitle[12].text = {}
			gr_edit plotregion1.subtitle[12].text.Arrpush	`"{bf:Work PT,}"'
			gr_edit plotregion1.subtitle[12].text.Arrpush	`"{bf:Large Family, Unstable Partnership}"'
			gr_edit plotregion1.subtitle[12].text.Arrpush	`"(n = 87)"'
end


*-----------------------------------------------------------------------------------------------* 
*>> Define a program for reordering the clusters (Women)
*-----------------------------------------------------------------------------------------------* 

capture program drop order_clusters_women
program define order_clusters_women

			* 	Recode the variable 
			recode cluster_15 	/// 
			(1 	= 7) 			/// 
			(2 	= 3) 			/// 
			(3 	= 1) 			/// 
			(4 	= 6) 			/// 
			(5 	= 4) 			/// 
			(6 	= 15) 			/// 
			(7 	= 2) 			/// 
			(8 	= 10) 			/// 
			(9 	= 13)			/// 
			(10 = 5) 			/// 
			(11 = 14)  			/// 
			(12 = 11) 			/// 
			(13 = 8) 			/// 
			(14 = 12) 			/// 
			(15 = 9) 

 			* 	Attribute the labels 		  
			label define cluster_15_label											///
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

			* 	Label the variable 
			label values cluster_15 cluster_15_label  
end 

*-----------------------------------------------------------------------------------------------* 
*>> Define a program for modifying the subtitles in the graphs (Women)
*-----------------------------------------------------------------------------------------------* 

capture program drop subtitle_mod_women
program define subtitle_mod_women
			gr_edit plotregion1.subtitle[1].style.editstyle size(small) editcopy
			gr_edit style.editstyle margin(vsmall) editcopy
			gr_edit legend.Edit , style(row_gap(minuscule)) keepstyles 
			gr_edit plotregion1.subtitle[1].text = {}
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"{bf:Childless, Partnered}"'
			gr_edit plotregion1.subtitle[1].text.Arrpush 	`"(n = 775)"'
			gr_edit plotregion1.subtitle[2].text = {}
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"{bf:Childless, Single}"'
			gr_edit plotregion1.subtitle[2].text.Arrpush 	`"(n = 1080)"'
			gr_edit plotregion1.subtitle[3].text = {}
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"{bf:Small Family Early, Partnered}"'
			gr_edit plotregion1.subtitle[3].text.Arrpush 	`"(n = 5,191)"'
			gr_edit plotregion1.subtitle[4].text = {}
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"{bf:Small Family, Partnered}"'
			gr_edit plotregion1.subtitle[4].text.Arrpush 	`"(n = 3,792)"'
			gr_edit plotregion1.subtitle[5].text = {}
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"{bf:Small Family Late, Partnered}"'
			gr_edit plotregion1.subtitle[5].text.Arrpush 	`"(n = 1,938)"'
			gr_edit plotregion1.subtitle[6].text = {}
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"{bf:Work FT,}"'
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"{bf:Small Family, Unstable Partnership}"'
			gr_edit plotregion1.subtitle[6].text.Arrpush 	`"(n = 1,488)"'
			gr_edit plotregion1.subtitle[7].text = {}
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"{bf:Family Care,}"'
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"{bf:Large Family Early, Partnered}"'
			gr_edit plotregion1.subtitle[7].text.Arrpush 	`"(n = 1,473)"'
			gr_edit plotregion1.subtitle[8].text = {}
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"{bf:Family Care,}"'
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"{bf:Large Family Late, Partnered}"'
			gr_edit plotregion1.subtitle[8].text.Arrpush 	`"(n = 782)"'
			gr_edit plotregion1.subtitle[9].text = {}
			gr_edit plotregion1.subtitle[9].text.Arrpush	`"{bf:Work Break,}"'
			gr_edit plotregion1.subtitle[9].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[9].text.Arrpush	`"(n = 468)"'
			gr_edit plotregion1.subtitle[10].text = {}
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"{bf:Drop-out into Family Care,}"'
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[10].text.Arrpush	`"(n = 413)"'
			gr_edit plotregion1.subtitle[11].text = {}
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"{bf:Drop-out into PT,}"'
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[11].text.Arrpush	`"(n = 1,216)"'
			gr_edit plotregion1.subtitle[12].text = {}
			gr_edit plotregion1.subtitle[12].text.Arrpush 	`"{bf:Drop-out into Out of Labour,}"'
			gr_edit plotregion1.subtitle[12].text.Arrpush 	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[12].text.Arrpush 	`"(n = 589)"'
			gr_edit plotregion1.subtitle[13].text = {}
			gr_edit plotregion1.subtitle[13].text.Arrpush	`"{bf:Weak Labour Market Attachment,}"'
			gr_edit plotregion1.subtitle[13].text.Arrpush	`"{bf:Large Family, Unstable Partnership}"'
			gr_edit plotregion1.subtitle[13].text.Arrpush	`"(n = 274)"'
			gr_edit plotregion1.subtitle[14].text = {}
			gr_edit plotregion1.subtitle[14].text.Arrpush	`"{bf:Out of Labour,}"'
			gr_edit plotregion1.subtitle[14].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[14].text.Arrpush	`"(n = 362)"'
			gr_edit plotregion1.subtitle[15].text = {}
			gr_edit plotregion1.subtitle[15].text.Arrpush	`"{bf:Unemployed,}"'
			gr_edit plotregion1.subtitle[15].text.Arrpush	`"{bf:Large Family, Partnered}"'
			gr_edit plotregion1.subtitle[15].text.Arrpush	`"(n = 231)"'
end


************************************************************************************************* 
* Chronograms for Men                                                                           * 
************************************************************************************************* 

*>> How many clusters for men? 
global number "12" // set a macro 

*>> Start a loop 
foreach number in $number {

*-----------------------------------------------------------------------------------------------* 
*>> Employment
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset with the employment histories and merge 
use "$r_output/cluster_men_`number'.dta", clear 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_Men_Employment.dta", nogen

*>> Re-order the clusters 
order_clusters_men

*>> Produce the chronogram 
	chronogram workstate_15-workstate_49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 	/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 		///
	legend(size(vsmall) row(1)) scheme(white_tableau)

*>> Modify the subtitles 
subtitle_mod_men

*>> Save the graphs 
graph save 		"$figure_out/chrono_men_emp_`number'", replace
graph export 	"$figure_out/chrono_men_emp_`number'.svg", as(svg)  replace
graph export 	"$figure_out/chrono_men_emp_`number'.png", as(png)  replace

pause 

*-----------------------------------------------------------------------------------------------* 
*>> Fertility
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset with the Fertility histories and merge 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_Men_Fertility.dta", nogen



*>> Produce the chronogram 
	chronogram kids15-kids49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 				/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49	, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 	///
	legend(size(vsmall) row(1)) scheme(white_viridis)

*>> Modify the subtitles 
subtitle_mod_men

*>> Save the graphs 
graph save 		"$figure_out/chrono_men_fert_`number'", replace
graph export 	"$figure_out/chrono_men_fert_`number'.svg", as(svg)  replace
graph export 	"$figure_out/chrono_men_fert_`number'.png", as(png)  replace

pause 

*-----------------------------------------------------------------------------------------------* 
*>> Marital
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset with the Marital histories and merge 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_Men_Marital.dta", nogen

*>> Produce the chronogram 
	chronogram withpartner15-withpartner49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 	/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49	, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 		/// 
	legend(size(vsmall) row(1)) scheme(white_tableau)

*>> Modify the subtitles 
subtitle_mod_men

*>> Save the graphs 
graph save 		"$figure_out/chrono_men_marit_`number'", replace
graph export 	"$figure_out/chrono_men_marit_`number'.svg", as(svg)  replace
graph export 	"$figure_out/chrono_men_marit_`number'.png", as(png)  replace

pause 
}



************************************************************************************************* 
* Chronograms for Women                                                                         * 
************************************************************************************************* 

*>> How many clusters for women? 
global number "15" // set a macro 

*>> Start a loop 
foreach number in $number {

*-----------------------------------------------------------------------------------------------* 
*>> Employment
*-----------------------------------------------------------------------------------------------* 


*>> Open the dataset with the employment histories and merge 
use "$r_output/cluster_women_`number'.dta", clear 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_women_Employment.dta", nogen

*>> Re-order the clusters 
order_clusters_women

*>> Produce the chronogram 
	chronogram workstate_15-workstate_49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 	/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49	, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 	/// 
	legend(size(vsmall) row(1)) scheme(white_tableau)
	
*>> Modify the subtitles 
subtitle_mod_women

*>> Save the graphs 
	graph save 		"$figure_out/chrono_women_emp_`number'", replace
	graph export 	"$figure_out/chrono_women_emp_`number'.svg", as(svg)  replace
	graph export 	"$figure_out/chrono_women_emp_`number'.png", as(png)  replace

pause 

*-----------------------------------------------------------------------------------------------* 
*>> Fertility
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset with the Fertility histories and merge 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_women_Fertility.dta", nogen


*>> Produce the chronogram 
	chronogram kids15-kids49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 				/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49	, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 	/// 
	legend(size(vsmall) row(1)) scheme(white_viridis)
	
*>> Modify the subtitles 
subtitle_mod_women

*>> Save the graphs 
	graph save 		"$figure_out/chrono_women_fert_`number'", replace
	graph export 	"$figure_out/chrono_women_fert_`number'.svg", as(svg)  replace
	graph export 	"$figure_out/chrono_women_fert_`number'.png", as(png)  replace
pause 

*-----------------------------------------------------------------------------------------------* 
*>> Marital
*-----------------------------------------------------------------------------------------------* 

*>> Open the dataset with the Marital histories and merge 
merge 1:1 mergeid using "$share_all_out/SHARE_for_SA_women_Marital.dta", nogen

*>> Produce the chronogram 
	chronogram withpartner15-withpartner49,  prop by(cluster_`number',  legend(on) note("") rows(3)) 	/// 
	ylab(				/// 
	0 		"0%" 		/// 
	0.25 	"25%"		/// 
	0.5 	"50%"		/// 
	0.75 	"75%" 		/// 
	1 		"100%"		/// 
	, labsize(vsmall)) 	/// 
	xlab(15 20 25 30 35 40 45 49	, labsize(vsmall)) xtitle("Age (15-49 years)", size(vsmall)) 		/// 
	legend(size(vsmall) row(1)) scheme(white_tableau)
	
*>> Modify the subtitles 
subtitle_mod_women

*>> Save the graphs 
	graph save 		"$figure_out/chrono_women_marit_`number'", replace
	graph export 	"$figure_out/chrono_women_marit_`number'.svg", as(svg)  replace
	graph export 	"$figure_out/chrono_women_marit_`number'.png", as(png)  replace

pause 
}


*>> Combine the graphs 
* 	Men 
graph combine   					///
"$figure_out/chrono_men_emp_12" 	/// 
"$figure_out/chrono_men_fert_12" 	/// 
"$figure_out/chrono_men_marit_12" 	/// 
, altshrink col(1)  ysize(10) graphregion(margin(zero))


*	Save the graph 
*	Figure 1
	graph save 		"$figure_out/comb_chrono_men", replace
	graph export 	"$figure_out/comb_chrono_men.svg", as(svg)  replace
	graph export 	"$figure_out/comb_chrono_men.png", as(png)  replace

* 	Women 
graph combine   					///
"$figure_out/chrono_women_emp_15" 	/// 
"$figure_out/chrono_women_fert_15" 	/// 
"$figure_out/chrono_women_marit_15" /// 
, altshrink col(1)  ysize(10) graphregion(margin(zero))


*	Save the graph 
*	Figure 2
	graph save 		"$figure_out/comb_chrono_women", replace
	graph export 	"$figure_out/comb_chrono_women.svg", as(svg)  replace
	graph export 	"$figure_out/comb_chrono_women.png", as(png)  replace


*-----------------------------------------------------------------------------------------------* 
*>> Close 
*-----------------------------------------------------------------------------------------------* 

capture log close 


