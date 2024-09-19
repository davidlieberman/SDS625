# Background

## Connecticut Crime Data Repository 

The first set of data was statewide, and had location data at the planning 
region, town, jurisdiction, and census tract levels. Time data for these crimes
was by year, and limited variables like time of day (limited to day vs night), 
and day of the week. After producing the how-to guides for Monday (9/16) and 
Wednesday (9/18), we decided to pivot to a different data set. 

## New Haven Police Department CompStat

The second set of data was from the New Haven Police Department, and consists
of biweekly pdf reports of crime data, from the police department website. 
Clear advantages of this data include address-level location data and time data 
to the resolution of the hour. 

On the other hand, the data is in pdf format and is distributed across multiple
files. To actually obtain the data, one would have to first obtain each pdf 
manually (there is no API or bulk download, and the files are hosted via 
javascript applets -- there isn't a url that links directly to the files). 
Once the pdfs have been obtained, to obtain the data tables, we would have to 
parse the pdfs by either reading the pdf binaries, or using optical character 
recognition (OCR). While there are packages that can obtain the table text from
the pdf binaries, the data is not in a clean tabular format, and would require
writing a custom parser to extract variables from text. The final problem is 
that the table format is not consistent across pdfs, so we would need to create
a parser for each table format. 

## Hartford CrimeView Incidents

In contrast, we have managed to find a third set of data, in tabular form, 
of Hartford crime data. This data also includes address-level location data and
time data to the resolution of the hour. Location data includes also the 
latitude and longitude allowing us to skip the geocoding step of the data 
processing pipeline. Whereas the New Haven data only goes back to 2019, the 
Hartford data goes back to 2005. The only possible downside is that the data 
is not as relevant to us, but this is minor and irrelevant to the objective of
this case study. As such, this data is superior to the New Haven data in
every conceivable way.

Given the data's numerous advantages over the previous option, and the fact
that it allows us to leverage the parcel data much better than the initial 
option, we will base our investigation on this data moving forward. 

# Hypotheses

There are several directions we could move toward:

1. Do house prices depend on crime? If they do, how do they depend on crime?
2. Does house price depend more or less on current vs historic crime? 

Other hypotheses can be explored in time -- these are simply good initial 
questions.

# Models

To test these hypotheses, we will need to build models. Given the spatial 
nature of our data, we will need to consider spatial models. A good initial 
step is to consider a linear regression model, and generate different spatial
features to include in the model. 

We could, for each parcel, compute an average distance to the nearest $k$ 
crimes, thereby obtaining a KNN-like feature. We can also perform kernel 
density estimation on the crime data, and obtain a probability density function
for particular geographic points, and for different crime types. The densities
at each parcel can be used as features in the model.

Other options include more sophisticated models, like geographically weighted
regression, spatial error models, and spatial lagged y-models. These models 
take the geographic nature of the data into account, and can provide an 
increased level of accuracy, as well as a better adjustment to the natural 
spatial autocorellaton.

# Data Cleaning 

