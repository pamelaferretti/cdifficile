# *C. difficile* Meta-Analysis

*Clostridioides difficile* is an urgent threat in hospital-acquired infections world-wide, yet the microbial composition associated with *C. difficile*, in particular in *C. difficile* infection (CDI) cases, remains poorly characterised. Here, we analysed 534 metagenomes from 10 publicly available CDI study populations. While we detected *C. difficile* in only 30% of CDI samples, multiple other toxigenic species capable of inducing CDI-like symptomatology were prevalent, raising concerns about CDI overdiagnosis. We further tracked *C. difficile* in 42,814 metagenomic samples from 253 public studies. We found that *C. difficile* prevalence, abundance and association with other bacterial species is age-dependent. In healthy adults, *C. difficile* is a rare taxon associated with an overall species richness reduction, while in healthy infants *C. difficile* is a common member of the gut microbiome and its presence is associated with a significant increase in species richness. More specifically, we identified a group of species co-occurring with *C. difficile* exclusively in healthy infants, enriched in obligate anaerobes and in species typically found in the gut microbiome of healthy adults. Overall, gut microbiome composition in presence of *C. difficile* in healthy infants is associated with multiple parameters linked to a healthy gut microbiome maturation towards an adult-like state. Our results suggest that *C. difficile* is a commensal in infants, and that its asymptomatic carriage is dependent on the surrounding microbial context.

## Requirements

This project requires R version 3.5.1   
To install all the required packages you can run:

`Rscript requirements.R`

## Workflow

The first part of the analysis workflow focuses on studying *C. difficile* in public metagenomic CDI datasets (n=10, total samples 534). 
The second part aims at investigating *C. difficile* outside of the traditionally studied nosocomial and CDI-related context, by including a much larger set of public metagenomic CDI datasets (n=253, total samples 42,814). 

#### Important preliminary notes
The metadata for the whole set of 42,814 samples is available as `Suppl. table 4` in the preprint and in `/data` under the name `metadata.csv`. 92.86% of these samples passed the initial filtering step on read counts (see Methods section in the preprint for details), leaving 39,502 samples, of which 26,784 were human fecal metagenomes, for downstream analysis.

In order to avoid under- or over-estimating *C. difficile* prevalence, only one sample per time series was used in cross-sectional analyses (see Methods section in the preprint for details), in a process here referred to as timeseries dereplication. The metadata for the filtered samples are available as `Suppl. table 5` in the preprint or in `/data` under the name `metadata_timeseries_dereplicated.csv`. All downstream analyses are based on the timeseries-dereplicated set of samples (aka using `metadata_timeseries_dereplicated.csv` and selecting only samples satysfying the criterium `final_representative=="Yes"`), unless differently specified.  

### Analyses on CDI datasets

#### 1. *C. difficile* and other antibiotic-associated diarrhea (AAD) species analysis
Here we investigate prevalence and relative abundance of *C. difficile*, as well as other bacterial species known to cause CDI-like symptomatology. We also look at the species richness in CDI patients.

`bin/Rmarkdown src/CDI_analysis/CDI_analysis.Rmd`  
`bin/Rmarkdown src/CDI_analysis/CDI_richness.Rmd`

#### 2. LASSO model
To identify the microbial signature associated with CDI we trained a series of LASSO-regularised logistic regression models in a leave-one-study-out validation approach.

`Rscript src/LASSO/custom_data_split.R`  
`bin/Rmarkdown src/LASSO/lasso_modelling.Rmd`  
`bin/Rmarkdown src/LASSO/lasso_auc.Rmd`  

#### 3. Linear mixed effect and ANOVA
We then used linear mixed effect model analysis to identify the species significantly enriched or depleted in terms of relative abundance in CDI compared to diseased and healthy controls.

`bin/Rmarkdown src/CDI_analysis/src_rem_testing.Rmd`  
`Rscript src/CDI_analysis/volcano_plot.R`   
`bin/Rmarkdown src/ANOVA/anova.Rmd`

### Analyses on global datasets

#### 4. *C. difficile* prevalence 
Here we track *C. difficile* prevalence over lifetime, across geographical locations, in healthy as well as in diseased subjects. We also investigated *C. difficile* carriage in different host species.

`bin/Rmarkdown src/prevalence/prevalence.Rmd`

#### 5. Alpha diversity 
As shown by the results in point 1. (and previous studies in the literature), *C. difficile* in CDI is associated with significant reduction in the gut microbiome species richness. To assess if this holds true also outside of the CDI context, we looked at species richness and evenness in both healthy and diseased subjects of all ages (0-107 yrs). 

`bin/Rmarkdown src/alpha_diversity/community_analysis.Rmd`

#### 6. Species co-occurrence with *C. difficile* 
As *C. difficile* prevalence and associated community richness differ by age group and health status, we used Fisher's exact test to identify the species co-occurring with *C. difficile* in a significant manner in each age/status category.    

`bin/Rmarkdown src/co_occurrence/FisherTest_coOccurrence.Rmd`  
`bin/Rmarkdown src/co_occurrence/parsing_plotting.Rmd`

#### 7. *C. difficile* appearance in timeseries 
Here we leveraged the available longitudinal data to investigate when *C. difficile* appears for the first time in infancy and early childhood. As using the dereplicated sample set would defy the purpose of this analysis, here we used the full set of samples available from mother-infant couples.

`bin/Rmarkdown src/timeseries_appearance/timeseries_appearance.Rmd`

#### 8. Mother-infant microbial similarity
Here we calculated beta diversity (Bray-Curtis index) to identify community similarity between infant-mother pairs, divided by *C. difficile* presence.  

`bin/Rmarkdown src/Bray_Curtis/Bray_Curtis_Cdiff.Rmd`


