/*____/\\\\\\\\\\\___  __/\\\________/\\\_  _____/\\\\\\\\\____  ____/\\\\\\\\\_____  __/\\\\\\\\\\\\\\\_             
* ___/\\\/////////\\\_  _\/\\\_______\/\\\_  ___/\\\\\\\\\\\\\__  __/\\\///////\\\___  _\/\\\///////////__            
*  __\//\\\______\///__  _\/\\\_______\/\\\_  __/\\\/////////\\\_  _\/\\\_____\/\\\___  _\/\\\_____________           
*   ___\////\\\_________  _\/\\\\\\\\\\\\\\\_  _\/\\\_______\/\\\_  _\/\\\\\\\\\\\/____  _\/\\\\\\\\\\\_____          
*    ______\////\\\______  _\/\\\/////////\\\_  _\/\\\\\\\\\\\\\\\_  _\/\\\//////\\\____  _\/\\\///////______         
*     _________\////\\\___  _\/\\\_______\/\\\_  _\/\\\/////////\\\_  _\/\\\____\//\\\___  _\/\\\_____________        
*      __/\\\______\//\\\__  _\/\\\_______\/\\\_  _\/\\\_______\/\\\_  _\/\\\_____\//\\\__  _\/\\\_____________       
*       _\///\\\\\\\\\\\/___  _\/\\\_______\/\\\_  _\/\\\_______\/\\\_  _\/\\\______\//\\\_  _\/\\\\\\\\\\\\\\\_      
*        ___\///////////_____  _\///________\///__  _\///________\///__  _\///________\///__  _\///////////////__     
*                                       __                       _                            _  _           _        
*                                      (_     __    _  \/    _ _|_   |_| _  _  | _|_|_       |_|(_| _  o __ (_|       
*                                      __)|_| | \_/(/_ /    (_) |    | |(/_(_| |  |_| | /    | |__|(/_ | | |__|       
*                                                   _                                         __          _           
*                                       _ __  _|   |_) _ _|_ o  __ _ __  _ __ _|_    o __    |_     __ _ |_) _        
*                                      (_|| |(_|   | \(/_ |_ |  | (/_|||(/_| | |_    | | |   |__|_| | (_)|  (/_*/       
*
*
*	SHARE Release 8.8.0
*
*	Uccheddu, Damiano, Tom Emery, Anne H. Gauthier, and Nardi Steverink. ‘Gendered Work-Family Life Courses and 
*	Late-Life Physical Functioning: A Comparative Analysis from 28 European Countries’. Advances in Life Course 
*	Research 53 (1 September 2022): 100495. https://doi.org/10.1016/j.alcr.2022.100495.

******************************************************************************************************************



*-----------------------------------------------------------------------------------------------* 
*>> Stata Version & Settings
*-----------------------------------------------------------------------------------------------* 

*>> Preliminary operations 
cls
clear
clear matrix
set max_memory .
set logtype text
set more off

*	Debug mode 
pause on 

*	Stata version 
version 17.0 

*	Timer 
display "$S_TIME  $S_DATE"
timer clear
timer on 1

capture program drop timestamp_start
program define timestamp_start
display "$S_TIME  $S_DATE"
timer clear
timer on 1
end

capture program drop timestamp_stop
program define timestamp_stop
display "$S_TIME  $S_DATE"
timer off 1
timer list 1
end

*>> Install packages 
* 	R (version 4.1.2 - November, 2021)
	// cd "C:/ado/plus/g"
	// net install github, from("https://haghish.github.io/github/") replace // https://github.com/haghish/github 
	// github update github
	// github install haghish/rcall, stable replace // if this gives error, just open R and install manually the package called "readstata13"
	// rcall: install.packages("TraMineR"			, repos="http://cran.uk.r-project.org" dependencies=TRUE)
	// rcall: install.packages("readstata13"		, repos="http://cran.uk.r-project.org" dependencies=TRUE)
	// rcall: install.packages("cluster"			, repos="http://cran.uk.r-project.org" dependencies=TRUE)
	// rcall: install.packages("WeightedCluster"	, repos="http://cran.uk.r-project.org" dependencies=TRUE)
	// rcall: install.packages("seqHMM"				, repos="http://cran.uk.r-project.org" dependencies=TRUE)
	// rcall: print(.libPaths())
	//
	// Also needed for R: https://www.graphviz.org/download/ (graphviz-2.49.3 (64-bit) EXE installer)

* 	Stata 
capture ssc install mdesc, replace 
capture ssc install missings, replace 
capture ssc install schemepack, replace
capture ssc install scheme-burd, replace


*-----------------------------------------------------------------------------------------------* 
*>> Macro's for file save locations 
*-----------------------------------------------------------------------------------------------* 

*>> Global macro (insert here the working folder where the replication material is stored)
global working_folder 	"C:/Users/damiano/Dropbox/NIDI/03 - Third paper/NIDI_CREW-Paper_3-Data-Analysis"

*>> Dataset input (insert here the paths where the data is stored)
global share_w2_in 		"A:/Encrypted datasets/Source/SHARE/Release 8.8.0/sharew2_rel8-0-0_ALL_datasets_stata"
global share_w3_in 		"A:/Encrypted datasets/Source/SHARE/Release 8.8.0/sharew3_rel8-0-0_ALL_datasets_stata"
global share_w7_in 		"A:/Encrypted datasets/Source/SHARE/Release 8.8.0/sharew7_rel8-0-0_ALL_datasets_stata"
global job_episodes		"A:/Encrypted datasets/Source/SHARE/Release 8.8.0/sharewX_rel8-0-0_gv_job_episodes_panel_stata"

*>> Log folder
global share_logfile 					"$working_folder/Log folder"

*>> Other do-files
global dataset_creation 				"$working_folder/1. Dataset Creation"
global dataset_cleaning_general			"$working_folder/2. Data Cleaning (General)"
global dataset_cleaning_MCSQA			"$working_folder/3. Data Cleaning (MCSQA)"
global dataset_analysis_MCSQA			"$working_folder/4.1 Data Analysis (MCSQA)"
global dataset_analysis_MCSQA_Chrono	"$working_folder/4.2 Data Analysis (Chronograms)"
global dataset_analysis_main			"$working_folder/4.3 Data Analysis (Main)"

*>> Dataset output 
global share_w3_out 					"$working_folder/Output folder/w3"
global share_w7_out 					"$working_folder/Output folder/w7"
global share_all_out 					"$working_folder/Output folder/W_All" 	// <- Folder for the created datasets
global r_output 						"$working_folder/Output folder/R output"

*>> Tables and Figures
global tables_out  						"$working_folder/Output folder/Tables"
global figure_out 						"$working_folder/Output folder/Figures"


*-----------------------------------------------------------------------------------------------* 
*>> Do files 
*-----------------------------------------------------------------------------------------------* 

*>> Dataset Creation
do "$dataset_creation/[NIDI-CREW] - 03 - Third paper - Dataset Creation.do"

*>> Data Cleaning
do "$dataset_cleaning_general/[NIDI-CREW] - 03 - Third Paper - Data Cleaning (General).do"
do "$dataset_cleaning_MCSQA/[NIDI-CREW] - 03 - Third Paper - Data Cleaning (MCSQA).do"

*>> Data analsyis 
*	Sequence and cluster analysis 
display in red "Run the file '[NIDI-CREW] - 03 - Third Paper - Data Analysis (MCSQA).R' in R 4.1.2 (November, 2021)"
pause

*	Chronograms
do "$dataset_analysis_MCSQA_Chrono/[NIDI-CREW] - 03 - Third Paper - Data Analysis (Chronograms).do"

*	Main (Regression analysis)
do "$dataset_analysis_main/[NIDI-CREW] - 03 - Third Paper - Data Analysis (Main).do"


*-----------------------------------------------------------------------------------------------* 
*>> Closing 
*-----------------------------------------------------------------------------------------------* 

*>> Timer 
display "$S_TIME  $S_DATE"
timer off 1
timer list 1

*>> Log file
capture log close
