Analysis Memo
================

This README provides the necessary context in terms of compute and data
understanding to produce the analysis that is submitted for review.

# Compute Context

The compute for this was conducted on the following system

``` 
platform       x86_64-apple-darwin15.6.0   
arch           x86_64                      
os             darwin15.6.0                
system         x86_64, darwin15.6.0        
status                                     
major          3                           
minor          5.1                         
year           2018                        
month          07                          
day            02                          
svn rev        74947                       
language       R                           
version.string R version 3.5.1 (2018-07-02)
nickname       Feather Spray               
```

The analysis depends on three libraries.

1.  `data.table` version 1.11.9
2.  `lfe` version 2.8-2
3.  `stargazer` 5.2.2

# Data Context

The data for this project was generated from the June 14, 2017 extract
of the Florida Voter File that is produced by the Florida Secretary of
State. The following steps have been performed to move the raw data
provided by the Florida SOS into an analysis file for use in this
analysis.

1.  The Florida SOS provides two collections of files;
2.  **Voter Details** that contain demographic information about voters
    like their age, location, county, etc. This is keyed by a Florida
    Voter ID.
3.  **Voter Histories** that contain a positive record for every
    election that a voter has participated.

The details and histories have been merged to create a single .csv file
that contains a single row for each registered voter, and a column for
each variable that will be used in the analysis.

[This
page](https://dos.myflorida.com/elections/for-voters/voter-registration/voter-information-as-a-public-record/),
accessed on April 16, 2020, describes the Florida Division of Elections
use of this data.

## Variable Definitions

1.  `voterID` unique identifier provided by Florida SOS
2.  `countyCode` an indicator of the county provided by Florida SOS
3.  `gender` an indicator of self-reported gender provided by Florida
    SOS
4.  `race` voter race and ethnicity self-report, provided by Florida SOS
5.  `dob` date of birth provided by Florida SOS
6.  `registrationDate` date of registration provided by Florida SOS
7.  `congressionalDistrict` voter congressional district provided by
    Florida SOS
8.  `houseDistrict` voter house district provided by Florida SOS
9.  `senateDistrict` voter senate district provided by Florida SOS
10. `email` voter email provided by Florida SOS. Because email contact
    was necessary to conduct this experiment, and because the Florida
    SOS makes no effort to “clean” or “sanitize” these email, *before
    assigning treatment* the authors audited these emails, and corrected
    obvious errors in how emails were recorded. For example, emails that
    were identified as belonging to the domain `[voter]@comast.net`
    (very likely a misspelling of the “Comcast”) were re-mapped to
    `[voter]@comcast.com`.
11. `general16` did the voter vote in the 2016 General Election. **This
    is the primary outcome variable of interest.**
12. `historyCode2016` what method did the voter use to vote in 2016.
    This is provided by Florida SOS. The *Analytic Sample* throughout
    excludes people who **could not have voted on election day**. That
    is, it excludes people who voted Absentee, Absentee with a Ballot
    that did not count, or who Voted Early. These individuals could not
    have received our treatment before casting their ballots.
    1.  `A`: Absentee
    2.  `B`: Absentee Ballot NOT Counted
    3.  `E`: Voted Early
    4.  `N`: Did Not Vote
    5.  `P`: Cast a Provisional Ballot that was Not Counted
    6.  `Y`: Voted at Polls
13. `treat` this is the experimental feature, and have five levels.
    These specific language for these stimulus is included in the
    manuscript.
    1.  `0`: Control
    2.  `1`: Election Information
    3.  `2`: Social Pressure
    4.  `3`: Native Threat
    5.  `4`: Latino Group Threat.
14. `major_party` a three level recoding of the `party` variable.
    1.  `1`: Democrat
    2.  `2`: Republican
    3.  `3`: Other Party, including No Party Affiliation.
