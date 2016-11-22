# R Script - dplyr predominant
# Author: leerssej
# Date: 21 NOV 2016
# Desc: create geo-ovoid distance matrix
# Desc: select locationID's that fall within threshold
# Desc: concatenate a name-list of the cluster grouping

options(stringsAsFactors = FALSE)
library(magrittr) 
library(tidyverse)
library(geosphere)

######### GeoMatrixWithLanderModule_10 #geomatrix already added
# Original Author: lamberp6 [Peter Lambert] (& Jian Dai)
# leerssej adjusted the geocode data to be compatible and wired Peter's code up to it.
load("RctComplt_v8gcPrecise")
dat <- RctComplt_v8gcPrecise
names(dat)

# compress
dat %<>% subset(!is.na(rctGmLat))
## for testing ## carve off a manageable slice
# dat %<>% slice(1:70)

# create matrix of distance between all addresses
dm <- distm(dat[2:3])
# load("GeoMatrix53k")

# name the rows and columns
rownames(dm) <- dat$ADDR_ID 
colnames(dm) <- dat$ADDR_ID

# ##shut this off if GeoMatrixLander is being used
# #save out the matrix for examination
# save(dm, file = "GeoMatrixPrecise")

# function to gather up into 1 name all the sites location within the threshold
close_sites <- function(id, thresh) {
    sites <- names(dm[id,][dm[id, ] < thresh])
    sites <- sort(sites[!is.na(sites)])
    paste(sites, collapse = '+')
}

# Apply that function
dat$close_sites <- sapply(dat$ADDR_ID, close_sites, 1)

# order by cluster
dat <- dat[order(dat$close_sites), ]

# Write down the result
save(dat, file = "GeoCdDat")
write.csv(dat, na = "", row.names = FALSE, file=paste0("GeoCdDat", gsub(":","",Sys.time()),".csv"))
