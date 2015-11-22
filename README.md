# Getting and Cleaning Data Course Project

This repository contains all the files required for the Getting and Cleaning Data Course Project.

- The script *run_analysis.R* can be used to generate the final summary table output required by the summary
    + To execute, at a terminal navigate to the working directory containing the *run_analysis.R* file.
    + Start an R session and execute
            source('run_analysis.R')
    + The script will download and unzip the dataset if not already present; read in and manipulate the data and output the summary table.
- The file *CodeBook.md* is a markdown file, containing explanation of the source data, data manipulation procedure and output data format.
- The file *CodeBook.Rmd* is an R markdown file used to generate the *.md* file and contains code snippets extracted from *run_analysis.R*