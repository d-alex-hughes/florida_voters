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

sem <- function(data) {
    sqrt(var(data, na.rm = TRUE) / sum(!(is.na(data))))
}

felm_rses <- function(mod) { 
    ## convienience function to pull robust standard errors 
    ## from a felm object for reporting 
    mod$STATS$outcome$rse
}

ols_rses <- function(mod) { 
    ## convienience function to pull robust standard errors 
    ## from ols models
    sqrt(diag(vcovHC(mod, type = 'HC3')))
    
} 

felm_robust_ci <- function(model, level=0.95) {
    crit_val = qt((1-(1-level)/2), df=model$df)
    ci <- coef(model) + t(c(-crit_val, crit_val) %o% felm_rses(model))
    return(ci)
} 

plot_message <- function(model, make_pdf = FALSE, file = NULL) {
    c = coef(model)[1:4]
    ci.low    = felm_robust_ci(model, level = 0.95)[1:4 , 1]
    ci.high   = felm_robust_ci(model, level = 0.95)[1:4 , 2]
    ci.low90  = felm_robust_ci(model, level = 0.9)[1:4 , 1]
    ci.high90 = felm_robust_ci(model, level = 0.9)[1:4 , 2]

    p_df = 100 * cbind(c, ci.low, ci.high, ci.low90, ci.high90)
    p_df = data.frame(p_df)
    
    if(make_pdf) {
        pdf(paste0('../tables-figures/', file), height = 5, width = 10)
    }

    source('/home/rstudio/src/pubPlot.R')
    par(mar = c(5,7,4,2) + 0.1)
    xlocs = 1:4
    plot(
        x = xlocs, 
        y = p_df$c,
        pch = 18,
        ylim = c(-4.5,1.25), xlim = c(1, max(xlocs)+.5),
        xlab = '', xaxt = 'n',
        ylab = '', yaxt = 'n',
        cex = 3, 
        axes = FALSE, ann = FALSE,
        )
    for(i in 1:4) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i], 
            y0 = p_df$ci.low[i], 
            y1 = p_df$ci.high[i], 
            length = 0)
    }
    for(i in 1:4) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i], 
            y0 = p_df$ci.low90[i], 
            y1 = p_df$ci.high90[i], 
            length = 0, lwd = 4)
    }
    
    abline(h=0, lty = 3, col = 'grey80')
    axis(2)
    title(ylab = "Percentage Point Change", line = 4.5)
    title(main = "Email Contact Reduces Turnout\nMessage Effects")
    axis(
        1, at = 1:4, 
        labels = c(
            "Baseline", "General\nS. Norm", 
            "Ethnic\nS. Norm 1", "Ethnic\nS. Norm 2"), 
        tick = FALSE, cex.axis = 1
    )
    
    if(make_pdf) {
        dev.off()
    } 
} 


plot_subgroup <- function(
    model_all, model_white, model_black, model_latino, 
    make_pdf = FALSE, file = NULL) {

    ## 1. Make Data for Plots 
    coefs <- c(
        coef(model_all)[1],
        coef(model_white)[1],
        coef(model_latino)[1],
        coef(model_black)[1])
    ci.low  = c(
        felm_robust_ci(model_all)[1, 1],
        felm_robust_ci(model_white)[1, 1],
        felm_robust_ci(model_latino)[1, 1],
        felm_robust_ci(model_black)[1, 1])
    ci.high  = c(
        felm_robust_ci(model_all)[1, 2],
        felm_robust_ci(model_white)[1, 2],
        felm_robust_ci(model_latino)[1, 2],
        felm_robust_ci(model_black)[1, 2])
    ci.low90  = c(
        felm_robust_ci(model_all, level=0.90)[1, 1],
        felm_robust_ci(model_white, level=0.90)[1, 1],
        felm_robust_ci(model_latino, level=0.90)[1, 1],
        felm_robust_ci(model_black, level=0.90)[1, 1])
    ci.high90  = c(
        felm_robust_ci(model_all, level=0.90)[1, 2],
        felm_robust_ci(model_white, level=0.90)[1, 2],
        felm_robust_ci(model_latino, level=0.90)[1, 2],
        felm_robust_ci(model_black, level=0.90)[1, 2])

    p_df = 100 * cbind(coefs, ci.low, ci.high, ci.low90, ci.high90)
    p_df = data.frame(p_df)

    ## 2. Build Plots

    if(make_pdf) {
        pdf(paste0('../tables-figures/', file), height = 5, width = 7.5)
    } 
    source('/home/rstudio/src/pubPlot.R')
    par(mar = c(5,7,4,2) + 0.1)
    xlocs = 1:4 + 0.5
    plot(
        x=xlocs, y=p_df$coefs,
        pch = 18,
        ylim = c(-3.5,1.25), xlim = c(1, max(xlocs)+.5),
        xlab = '', xaxt = 'n', 
        cex = 3, 
        axes = FALSE, ann = FALSE
    )
    polygon(
        x = c(1, 1, 2, 2),
        y = c(-3.5, 1.25, 1.25, -3.5),
        col = rgb(0,0,0,0.1),
        border = FALSE
    )
    for(i in 1:4) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i],
            y0 = p_df$ci.low[i], y1 = p_df$ci.high[i],
            length = 0
        )
    }
    for(i in 1:4) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i],
            y0 = p_df$ci.low90[i],
            y1 = p_df$ci.high90[i],
            length = 0, lwd = 4
        )
    }

    abline(h=0, lty = 3)
    axis(2)
    title(ylab = 'Percentage Point Change', line = 4.5)
    title(main = 'Email Contact Reduces Turnout')
    axis(1,
         at = xlocs,
         labels = c('All', 'White', 'Latino', 'Black'),
         tick = FALSE, cex.axis = 1.5)
    if(make_pdf) {
        dev.off()
    } 
} 

plot_message_by_subgroup <- function(model_1, model_2, model_3, make_pdf, file) {

    ## 1. Make Data for Plots 
    coefs <- c(
        coef(model_1)[1:4],
        coef(model_2)[1:4],
        coef(model_3)[1:4] )

    ci.low  = c(
        felm_robust_ci(model_1)[1:4, 1],
        felm_robust_ci(model_2)[1:4, 1],
        felm_robust_ci(model_3)[1:4, 1] )
    ci.high  = c(
        felm_robust_ci(model_1)[1:4, 2],
        felm_robust_ci(model_2)[1:4, 2],
        felm_robust_ci(model_3)[1:4, 2] )
    ci.low90  = c(
        felm_robust_ci(model_1, level=0.90)[1:4, 1],
        felm_robust_ci(model_2, level=0.90)[1:4, 1],
        felm_robust_ci(model_3, level=0.90)[1:4, 1] )
    ci.high90  = c(
        felm_robust_ci(model_1, level=0.90)[1:4, 2],
        felm_robust_ci(model_2, level=0.90)[1:4, 2],
        felm_robust_ci(model_3, level=0.90)[1:4, 2] )

    p_df = 100 * cbind(coefs, ci.low, ci.high, ci.low90, ci.high90)
    p_df = data.frame(p_df)

    ## 2. Build Plots

    if(make_pdf) {
        pdf(paste0('../tables-figures/', file), height = 5, width = 10)
    } 
    source('/home/rstudio/src/pubPlot.R')
    par(mar = c(5,7,4,2) + 0.1)
    xlocs = c(1:4, 7:10, 13:16)
    plot(
        x=xlocs, y=p_df$coefs,
        pch = rep(c(21, 16, 17, 18), 3),
        ylim = c(-4.5,1.25), xlim = c(1, max(xlocs)+.5),
        xlab = '', xaxt = 'n', 
        cex = 3, 
        axes = FALSE, ann = FALSE,
        main = 'Email Contact Reduces Turnout'
    )
    for(i in 1:12) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i],
            y0 = p_df$ci.low[i], y1 = p_df$ci.high[i],
            length = 0
        )
    }
    for(i in 1:12) { 
        arrows(
            x0 = xlocs[i], x1 = xlocs[i],
            y0 = p_df$ci.low90[i],
            y1 = p_df$ci.high90[i],
            length = 0, lwd = 4
        )
    }
    abline(h=0, lty = 3, col = 'grey80')
    axis(2)
    title(ylab = 'Percentage Point Change', line = 4.5)
    title(main = 'Email Contact Reduces Turnout\nGroup-by-Message Interactions')
    axis(1, at = c(2.5, 8.5, 14.5), labels = c('White', 'Latino', 'Black'), tick = FALSE, cex.axis = 1.5)
    legend(
        'bottomleft',
        legend = c(
            'Baseline', 'General Descriptive Norm',
            'Ethnic Descriptive Norm 1', 'Ethnic Descriptive Norm 2'),
        pch = c(21, 16, 17, 18))
    if(make_pdf) {
        dev.off()
    } 
} 

check_power <- function(nsims, p_1, p_2, n_1, n_2) { 
    reject <- rep(NA, nsims) 
    for(i in 1:nsims) {
        sim_control <- rbinom(n_1, 1, p_1)
        sim_treat   <- rbinom(n_2, 1, p_2)
        
        reject[i] <- t.test(sim_control, sim_treat)$p.value
    }
    power_ <- mean(reject < 0.05)
    return(power_)
}

plot_power <- function(power, effect_size, treat_size, main, file) {
    color_palatte <- c('darkred', 'darkgreen')
    
    pdf(file = file)
    plot(
        x = effect_size * 100, y = power, type = 'p', 
        main = main, 
        xlab = 'Percentage Point Difference',
        ylab = 'Realized Power',
        col = color_palatte[(power > 0.8) + 1],
        pch = 19
    )
    polygon(
        x = c(0, 4, 4, 0),
        y = c(.8, .8, 1, 1),
        col = rgb(0, 1, 0, alpha = 0.2),
        border = FALSE
    )
    polygon(
        x = c(0, 4, 4, 0),
        y = c(.8, .8, 0, 0),
        col = rgb(1, 0, 0, alpha = 0.2),
        border = FALSE
    )
    abline(v = treat_size * 100)
    dev.off()
} 
