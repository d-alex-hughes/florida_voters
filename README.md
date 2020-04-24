This repository builds a compute environment, and executes code
against data in support of the publication _Email Mobilization
Messages Suppress Turnout Among Black and Latino Voters: Experimental
Evidence From the 2016 General Election_.  The paper was published in
the Journal of Experimental Political Science in 2020. Once a
citation is issued by the journal, it will be included here.

# Repository Structure
This repository contains the same data that is included in the most
current version of the Dataverse data repository, which is available
[here](http:dataverse.harvard.edu).

The repository works in the following way:

- The `Dockerfile` builds the compute
- The description of the data used in the paper is included in `./data/` 
- The analysis and Supplimentary Information Analysis is in the
  `./analysis/` folder 

```
.
├── Dockerfile
├── README.org
├── analysis
│   ├── SI.Rmd
│   ├── SI.pdf
│   ├── analysis.Rmd
│   ├── analysis.md
│   ├── analysis_files
│   └── references.bib
├── data
│   ├── Voter\ Information\ as\ a\ Public\ Record\ -\ Division\ of\ Elections\ -\ Florida\ Department\ of\ State.pdf
│   ├── data_description.Rmd
│   └── data_description.md
├── kitematic
├── src
│   ├── functions.R
│   ├── load_and_clean_data.R
│   └── pubPlot.R
├── tables-figures
│   ├── appendix_hte.tex
│   ├── cue1.png
│   ├── literature_table.tex
│   ├── message-by-subgroup.pdf
│   ├── message_effects.pdf
│   ├── power_plot.pdf
│   ├── power_plot_by_condition.pdf
│   ├── power_plot_by_group_black.pdf
│   ├── power_plot_by_group_black_by_condition.pdf
│   ├── power_plot_by_group_latino.pdf
│   ├── power_plot_by_group_latino_by_condition.pdf
│   ├── power_plot_by_group_white.pdf
│   ├── power_plot_by_group_white_by_condition.pdf
│   ├── stimulus.tex
│   ├── subgroup_effects.pdf
│   ├── treatment_table.tex
│   └── tuned_table1.tex
└── text
    ├── FL_GOTV_Main.pdf
    ├── FL_GOTV_Main.tex
    └── references.bib
```

# Building Compute

This repository furnishes a version of the compute that produces all
tables and figures that are reported in both the published article and
the SI. This compute begins from an Rstudio image built by the Rstudio
rocker team, and adds three packages and their dependencies.

You can also conduct this analysis on an Rstudio version that you
manage. To produce all the analysis you will need the following
software and its dependencies. 

- R version 3.6.3 (2020-02-29) -- "Holding the Windsock"
- Rstudio version 1.2.x -- "Orange Blossom" 
- `data.table` [here](https://github.com/Rdatatable/data.table/wiki)
- `lfe` [CRAN Link](https://cran.r-project.org/web/packages/lfe/index.html)
- `sandwich` [CRAN Link](https://cran.r-project.org/web/packages/sandwich/index.html)
- `stargazer` [CRAN Link](https://cran.r-project.org/web/packages/stargazer/index.html)
- `knitr` [CRAN Link](https://cran.r-project.org/web/packages/knitr/index.html)
- `bookdown` [CRAN Link](https://cran.r-project.org/web/packages/bookdown/index.html)

Unfortunately, we cannot support you building this on your own
computer, but we have build and provided a Docker image that you can
build that will resolve all of these dependencies. 

## Dockerhub 

The preferred method of building the compute is to work from the
Docker image provided on the Dockerhub. We would have also liked to
provide a Binder link to provide the interested scientist one-click
access to the compute and analysis, but Binder resources are not
capable of executing this analysis.

Follow these steps to start the compute environment.

1. Download the codebase for the project. A version is hosted on
   GitHub, and a version has also been placed in the Dataverse. The
   GitHub version will have the most up-to-date code; the Dataverse
   will freeze the analysis that was conducted at the time of
   publication.
2. Launch the Docker Desktop application. If you do not have this
   application installed, you can download it from [this link](https://www.docker.com). Note
   that this analysis will require considerable memory resources. We
   set Docker to have access to 12GB memory, and the Disk Image size
   cap to 24GB.
3. Make sure Docker is running before you move on to the next step.
4. In a terminal window, navigate to the directory housing the project
   files that you downloaded in step 1. For example, if these files
   are in your downloads folder, in terminal change directory to
   downloads by issuing the following command: `cd ~/Downloads/florida_voters/`
5. Run the Docker image that conducts this analysis from DockerHub. To
   do so, issue the following command in the terminal window (on a Unix/Linux
   machine. E.g. Apple computers are Unix computers). Please remember to replace `<SET A PASSWORD>` with the
   password you chose. Note that your password
   should also replace the `<` and `>`. (Instructions for non
   Linux / Unix machines can be found at the end of the readme
   document; the only difference is how the current directory is identified.)

```
docker run --rm \
      -v $(pwd):/home/rstudio \
      -e PASSWORD=<SET A PASSWORD> \
      -p 8787:8787 \
      dalexhughes/florida_voters:tex
```

1. After running this command, open a web browser and navigate to
   `localhost:8787`. Here you will be prompted to enter a username and
   password for Rstudio. The username is `rstudio`, the password is
   what you set. Next, navigate into the file tree to conduct the
   analysis.   
2. To close the analysis:
   1. Logout of Rstudio where you are conducting the analysis.
   2. Issue a `KILL` command in the terminal by pressing
      Control-C. This will stop and remove the Docker image.
   3. Close the Docker engine. This will give these resources back to
      your computer. 
      

## What does the docker run command above do? 

- `docker run --rm` run the docker image, remove it when completed
- `-v $(pwd):/home/rstudio` load the local volume where this project
  is stored to be accessed by the Docker image. Note that your
  directory naming structure needs to be Unix/Linux conformable --
  that is without the characters: `/ > < | : &`. As well, to use this
  code as written, there cannot be whitespace in your directory
  name. For example `/Users/researchername/myprojects` will work
  `/Users/researcher name/my projects` will not work.  (This is
  because the `$(pwd)` fails to grok this into the Docker image.) If
  you have white space in your directory names, you can replace the
  `$(pwd)` with your directory names.
- `-e PASSWORD=<SET A PASSWORD>` this will set a password for the user
  in Rstudio. Note that you should replace `<SET A PASSWORD>` with a
  password of your choice. Note, too, that your password should also
  replace the `<` and `>`.
- `-p 8787:8787` this will connect your local computer to the Docker
  image through port 8787 on both devices.
- `dalexhughes/florida_voters:tex` this is the docker image, hosted on
  DockerHub that conducts the analysis. If you have not run this
  before, it will pull from the dockerhub.

# Alternative Way to Aquire Data 
The code is designed to read the data from Amazon Web Services
(AWS). Once you download the docker image, if you follow the code as
written, the data will be read from AWS without any futher effort. If
instead, you prefer to download the data directly from Dataverse, once
you download the docker image, you will need to change the analysis
and SI code to read the data from your local machine instead of AWS.


# Instructions for non Linux / Unix Machines 
If you are on a Windows computer using PowerShell, you /should/ be
able to build this compute by issuing the following command (not
tested). Note the only difference is in the parentheses vs. braces on
the `pwd` variable. 

```
docker run -rm \ 
      -v ${pwd}:/home/rstudio/ \
      - e PASSWORD=<SET A PASSWORD> \
      - p 8787:8787 \
      dalexhughes/florida_voters:tex 
```
                    
1.  After running this command, open a web browser and navigate to
   `localhost:8787`. Here you will be prompted to enter a username and
   password for Rstudio. The username is `rstudio`, the password is
   what you set. Next, navigate into the file tree to conduct the analysis.   
