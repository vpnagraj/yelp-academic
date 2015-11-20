# Yelp Academic

This repository contains R code for topic modeling the [Yelp Academic Dataset](https://www.yelp.com/academic_dataset).

The data preparation and analysis procedures are split among several scripts. 

Follow these steps to use the scripts:

1. Create a /data directory
2. Download and unzip the Yelp Academic Dataset as a subdirectory within /data
3. ```source('prep.R')```
4. ```source('modeltopics.R')```
5. ```source('getadjectives.R')```
6. ```source('plotadjectives.R')```