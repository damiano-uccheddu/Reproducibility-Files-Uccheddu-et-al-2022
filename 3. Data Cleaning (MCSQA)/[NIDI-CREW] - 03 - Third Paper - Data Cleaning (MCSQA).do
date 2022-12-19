*-----------------------------------------------------------------------------------------------* 
*>> Preliminary operations 
*-----------------------------------------------------------------------------------------------* 

*>> Clear the screen 
cls 

*>> Close the log 
capture log close 

*>> Open new log file 
log using 	"$share_logfile/Data Cleaning (MCSA).log", replace

*>> Open the dataset 
use 		"$share_all_out/SHARE_long_version_8.0.0.dta", clear 

*>> Describe the dataset 
desc, short 
sort mergeid age 

*>> Describe the missing cases
mdesc

*>> Check the variables needed to create the sequences 
fre kids workstate_ withpartner


*-----------------------------------------------------------------------------------------------* 
*>> Reshape wide 
*-----------------------------------------------------------------------------------------------* 

*>> Select the needed variables
keep mergeid gender age withpartner workstate_ kids 

*>> Reshape wide 
reshape wide	/// 
withpartner 	/// 
workstate_ 		/// 
kids 			/// 
, i(mergeid) j(age)

*>> Sort the dataset 
sort gender mergeid, stable 



*-----------------------------------------------------------------------------------------------* 
*>> Men 
*-----------------------------------------------------------------------------------------------* 

*>> Fertility 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 1 									// Select only men 
		keep mergeid kids*										// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Men_Fertility.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

*>> Employment 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 1 									// Select only men 
		keep mergeid workstate_*								// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Men_Employment.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

*>> Marital 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 1 									// Select only men 
		keep mergeid withpartner*								// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Men_Marital.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

*-----------------------------------------------------------------------------------------------* 
*>> Men 
*-----------------------------------------------------------------------------------------------* 

*>> Fertility 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 2 									// Select only women 
		keep mergeid kids*										// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Women_Fertility.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

*>> Employment 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 2 									// Select only women 
		keep mergeid workstate_*								// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Women_Employment.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

*>> Marital 

		************
		* PRESERVE * 
		************

		preserve 												// Preserve the dataset as it is right now 
		keep if gender == 2 									// Select only women 
		keep mergeid withpartner*								// Keep only variables of interest 
		sort mergeid	 										// Sort the dataset 
		// reshape long 										// Reshape long 
		missings dropvars, force 								// Drop variables that are all missing
		compress 												// compress dataset

		*>> Save the dataset 
		save "$share_all_out/SHARE_for_SA_Women_Marital.dta", replace

		restore 												// Restore the dataset as it was before  

		**************
		* RESTORE(D) *
		**************

log close 

