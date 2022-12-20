# Reproducibility Files

# [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7462105.svg)](https://doi.org/10.5281/zenodo.7462105)

### Uccheddu, Damiano, Tom Emery, Anne H. Gauthier, and Nardi Steverink. ‘Gendered Work-Family Life Courses and Late-Life Physical Functioning: A Comparative Analysis from 28 European Countries’. *Advances in Life Course Research* 53 (2022): 100495. https://doi.org/10.1016/j.alcr.2022.100495.


# Instructions: 
1. Download the data (SHARE Release 7.0.0) from https://releases.sharedataortal.eu/users/login
2. Unzip the downloaded compressed (zipped) folders
3. Open the master do-file "[NIDI-CREW] - 03 - Third Paper - Master do-file.do"
4. Change all the paths to match your own computer's paths (rows from 92 to 119 in this master the do-file) and create the appropriate folders if necessary. 
5. Run the do-file "[NIDI-CREW] - 03 - Third Paper - Master do-file.do" to perform the data analysis. 
6. An intermediate step involves running the code contained in the folder '4.1 Data Analysis (MCSQA)' on R version 4.1.2 (November, 2021)


# Notes: 
- The do-file contained in the folder "0. Master do-file" contains the commands to create all the datasets and run the analysis. 
- The do-file contained in the folder "1. Dataset Creation" contains the commands to create the datasets
- The do-file contained in the folder "2. Data Cleaning (General)" reshapes the datasets and merges SHARE wave 3, SHARE wave 7, and the SHARE job episodes panel dataset. 
- The do-file contained in the folder "3. Data Cleaning (MCSQA)" prepares the datasets for the sequence analysis to be done with R
- The .R file contained in the folder "4.1 Data Analysis (MCSQA)" performs the sequence and cluster analysis in R
- The do-file contained in the folder "4.2 Data Analysis (Chronograms)" produces Figures 1 and 2. 
- The do-file contained in the folder "5. Data Analysis (Main)" produces the remaining tables and figures (from descriptive statistics and regression analyses)
