load_and_clean_data <- function(
    f  = 'https://florida-voters.s3-us-west-1.amazonaws.com/subset_finalAnalysisFile20170711.csv',
    nrows = Inf) {

    require(data.table)

    ## load file of all voters for comparison of treatment voters vs. others
    d  <- fread(f, nrows = nrows)

    ## Because the analysis data is taken from a voter extract /after/
    ## the election, it contains a small number of people who
    ## registered after the election. Exclude these people; none of them
    ## (a) could have been assigned to treatment; or, (b) have had their
    ## behavior changed by messaging.
    ##
    ## Also exclude people whose voter status is anything but active; this
    ## is a very small proportion of the analytic sample for this paper:
    ## 0.0033 in each of the treatment assignment conditions. 
    
    d <- d[registered_prior == TRUE & voterStatus == 'ACT']
    
    ## Store race as a factor variable, with white as the baseline factor.
    d[ , race9 := factor(
             race,
             levels = c(1,2,3,4,5,6,7,9),
             labels = c(
                 "Indian", "Asian", "Black",
                 "Latino", "White", "Other",
                 "Multi", "Unknown") )]
    d[ , race9 := relevel(race9, ref = "White")]

    ## create three group indicator: black, latino, white, and others 
    d[race == 3, race3 := "Black"]
    d[race == 4, race3 := "Latino"]
    d[race == 5, race3 := "White"]
    d[!(race %in% 3:5), race3 := "Other"]

    d[ , race3 := factor(race3)]
    d[ , race3 := relevel(race3, ref = "White")]

    ## Create an outcome variable that records whether someone
    ## voted by mail (absentee)
    d[ , voteByMail := 0L]
    d[ , voteByMail := 1*(historyCode2016 == 'A')]
    
    ## Create an indicator for receiving any message 
    d[ , any_message := NA]
    d[treat == 0, any_message := 0]
    d[treat %in% 1:4, any_message :=1]

    return(d)
}

