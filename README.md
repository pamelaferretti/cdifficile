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

In order to avoid under- or over-estimating *C. difficile* prevalence, only one sample per time series was used in cross-sectional analyses (see Methods section in the preprint for details), in a process here referred to as timeseries dereplication. All downstream analyses are based on this set of data.

### Analyses on CDI datasets

#### 1. *C. difficile* and other antibiotic-associated diarrhea (AAD) species analysis
Here we investigate prevalence and relative abundance of *C. difficile*, as well as other bacterial species known to cause CDI-like symptomatology. We also look at the species richness in CDI patients.

```bash
bin/Rmarkdown src/CDI_analysis/CDI_analysis.Rmd figures/CDI_analysis/CDI_analysis.html
bin/Rmarkdown src/CDI_analysis/CDI_richness.Rmd figures/CDI_analysis/CDI_richness.html
```

#### 2. LASSO model
To identify the microbial signature associated with CDI we trained a series of LASSO-regularised logistic regression models in a leave-one-study-out validation approach.

```bash
Rscript src/LASSO/custom_data_split.R
bin/Rmarkdown src/LASSO/lasso_modelling.Rmd figures/LASSO/lasso_modelling.html
bin/Rmarkdown src/LASSO/lasso_auc.Rmd figures/LASSO/lasso_auc.html
```

#### 3. Linear mixed effect and ANOVA
We then used linear mixed effect model analysis to identify the species significantly enriched or depleted in terms of relative abundance in CDI compared to diseased and healthy controls.

```bash
bin/Rmarkdown src/CDI_analysis/src_rem_testing.Rmd figures/CDI_analysis/src_rem_testing.html  
Rscript src/CDI_analysis/volcano_plot.R   
bin/Rmarkdown src/ANOVA/anova.Rmd figures/ANOVA/anova.html
```

### Analyses on global datasets

#### 4. *C. difficile* prevalence 
Here we track *C. difficile* prevalence over lifetime, across geographical locations, in healthy as well as in diseased subjects. We also investigated *C. difficile* carriage in different host species.

```bash
bin/Rmarkdown src/prevalence/prevalence.Rmd figures/prevalence/prevalence.html
```

#### 5. Alpha diversity 
As shown by the results in point 1. (and previous studies in the literature), *C. difficile* in CDI is associated with significant reduction in the gut microbiome species richness. To assess if this holds true also outside of the CDI context, we looked at species richness and evenness in both healthy and diseased subjects of all ages (0-107 yrs). 

```bash
bin/Rmarkdown src/alpha_diversity/community_analysis.Rmd figures/alpha_diversity/community_analysis.html
```

#### 6. Species co-occurrence with *C. difficile* 
As *C. difficile* prevalence and associated community richness differ by age group and health status, we used Fisher's exact test to identify the species co-occurring with *C. difficile* in a significant manner in each age/status category.    

```bash
bin/Rmarkdown src/co_occurrence/FisherTest_coOccurrence.Rmd figures/co_occurrence/FisherTest_coOccurrence.html
bin/Rmarkdown src/co_occurrence/parsing_plotting.Rmd figures/co_occurrence/parsing_plotting.html
```

#### 7. *C. difficile* appearance in timeseries 
Here we leveraged the available longitudinal data to investigate when *C. difficile* appears for the first time in infancy and early childhood. As using the dereplicated sample set would defy the purpose of this analysis, here we used the full set of samples available from mother-infant couples.

```bash
bin/Rmarkdown src/timeseries_appearance/timeseries_appearance.Rmd figures/timeseries_appearance/timeseries_appearance.html
```

#### 8. Mother-infant microbial similarity
Here we calculated beta diversity (Bray-Curtis index) to identify community similarity between infant-mother pairs, divided by *C. difficile* presence.  

```bash
bin/Rmarkdown src/Bray_Curtis/Bray_Curtis_Cdiff.Rmd figures/Bray_Curtis/Bray_Curtis_Cdiff.html
```


#### Session Info

```
other attached packages:
 [1] colorRamps_2.3       RColorBrewer_1.1-2   ComplexHeatmap_2.1.2 dendextend_1.14.0    gplots_3.0.1.2       reshape2_1.4.3       ggdendro_0.1-20      cowplot_1.0.0        SIAMCAT_1.2.1        phyloseq_1.26.1     
[11] mlr_2.17.0           ParamHelpers_1.13    rsq_2.0              broom_0.7.12         margins_0.3.23       car_3.0-6            carData_3.0-3        vegan_2.5-6          lattice_0.20-38      permute_0.9-5       
[21] forcats_0.5.1        stringr_1.4.0        purrr_0.3.4          readr_2.1.2          tidyr_1.1.4          tibble_3.1.6         tidyverse_1.3.1      rstatix_0.6.0        gridExtra_2.3        ggrepel_0.8.1       
[31] dplyr_1.0.7          ggpubr_0.2.5         magrittr_2.0.2       ggplot2_3.3.5       

loaded via a namespace (and not attached):
  [1] circlize_0.4.8      readxl_1.3.1        backports_1.1.5     fastmatch_1.1-0     corrplot_0.84       plyr_1.8.5          igraph_1.2.4.2      splines_3.5.1       gridBase_0.4-7      foreach_1.4.7      
 [11] viridis_0.5.1       gdata_2.18.0        fansi_0.4.1         checkmate_1.9.4     BBmisc_1.11         cluster_2.1.0       tzdb_0.2.0          openxlsx_4.1.4      Biostrings_2.50.2   modelr_0.1.8       
 [21] matrixStats_0.56.0  colorspace_1.4-1    rvest_1.0.2         haven_2.3.1         xfun_0.12           crayon_1.4.2        jsonlite_1.7.3      lme4_1.1-21         survival_3.1-8      iterators_1.0.12   
 [31] ape_5.3             glue_1.6.1          gtable_0.3.0        zlibbioc_1.28.0     XVector_0.22.0      GetoptLong_0.1.8    Rhdf5lib_1.4.3      shape_1.4.4         BiocGenerics_0.28.0 abind_1.4-5        
 [41] scales_1.1.1        infotheo_1.2.0      DBI_1.1.0           Rcpp_1.0.3          viridisLite_0.3.0   clue_0.3-57         foreign_0.8-75      stats4_3.5.1        prediction_0.3.14   glmnet_2.0-16      
 [51] httr_1.4.2          ellipsis_0.3.2      pkgconfig_2.0.3     dbplyr_2.1.1        utf8_1.1.4          tidyselect_1.1.0    rlang_1.0.0         PRROC_1.3.1         munsell_0.5.0       cellranger_1.1.0   
 [61] tools_3.5.1         cli_3.1.1           generics_0.0.2      ade4_1.7-13         biomformat_1.10.1   knitr_1.27          fs_1.3.1            zip_2.0.4           beanplot_1.2        caTools_1.17.1.1   
 [71] nlme_3.1-143        xml2_1.3.2          compiler_3.5.1      rstudioapi_0.13     png_0.1-7           curl_4.3            ggsignif_0.6.0      reprex_2.0.1        stringi_1.4.5       Matrix_1.2-18      
 [81] nloptr_1.2.1        multtest_2.38.0     vctrs_0.3.8         pillar_1.6.5        lifecycle_1.0.1     GlobalOptions_0.1.1 LiblineaR_2.10-8    data.table_1.14.2   bitops_1.0-6        R6_2.4.1           
 [91] KernSmooth_2.23-16  rio_0.5.16          IRanges_2.16.0      codetools_0.2-16    boot_1.3-24         MASS_7.3-51.5       gtools_3.8.1        assertthat_0.2.1    rhdf5_2.26.2        rjson_0.2.20       
[101] withr_2.4.3         S4Vectors_0.20.1    mgcv_1.8-31         parallel_3.5.1      hms_1.1.1           minqa_1.2.4         parallelMap_1.5.0   pROC_1.16.2         numDeriv_2016.8-1.1 Biobase_2.42.0     
[111] lubridate_1.8.0
```    
