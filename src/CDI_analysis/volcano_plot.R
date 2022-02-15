
library("tidyverse")
library("ggrepel")

df.res <- read_tsv('data/CDI/random_effect_model_results.tsv')
feat.rel.filt <- read.table('data/CDI/filtered_data.tsv', sep='\t',
                            stringsAsFactors = FALSE, check.names = FALSE,
                            quote = '', comment.char = '') %>% 
  as.matrix()

df.res <- df.res %>% 
  mutate(highlight=case_when(str_detect(species, 'perfringens')~'Causing CDI-like diarrhea',
                             str_detect(species, 'innocuum')~'Causing CDI-like diarrhea',
                             str_detect(species, 'faecalis')~'Causing CDI-like diarrhea',
                             str_detect(species, 'oxytoca')~'Causing CDI-like diarrhea',
                             str_detect(species, 'fragilis')~'Causing CDI-like diarrhea',
                             str_detect(species, 'faecalis')~'Causing CDI-like diarrhea',
                             str_detect(species, 'aeruginosa')~'Causing CDI-like diarrhea',
                             str_detect(species, 'amalonaticus')~'Causing CDI-like diarrhea',
                             str_detect(species, 'cloacae')~'Causing CDI-like diarrhea',
                             str_detect(species, 'aureus')~'Causing CDI-like diarrhea',
                             #str_detect(species, 'ref_mOTU_v2_0036')~'Causing CDI-like diarrhea',
                             str_detect(species, 'difficile')~'Causing CDI-like diarrhea',
                             effect.size.without.cdiff > 0.1 & p.val.without.cdiff < 0.01 ~ 'Enriched in CDI',
                             effect.size.without.cdiff < -0.1 & p.val.without.cdiff < 0.01 ~ 'Depleted in CDI',
                             TRUE~'other')) %>% 
  mutate(label=case_when(highlight%in%c('Causing CDI-like diarrhea', 'Cdiff', 'Enriched in CDI')~
                           str_remove(species, '\\[(ref|meta)_mOTU_v2_[0-9]{4}\\]'),
                         effect.size.without.cdiff < -0.25 & -log10(p.val.without.cdiff)>2 ~  #p.adj < 0.0001 = -4
                           str_remove(species, '\\[(ref|meta)_mOTU_v2_[0-9]{4}\\]'),
                         TRUE~'')) %>% 
  mutate(color_positive=p.val.without.cdiff < 0.01 & effect.size.without.cdiff > 0.125) %>% 
  mutate(highlight=factor(highlight, 
                          levels = c('Cdiff', 'Causing CDI-like diarrhea', 'Enriched in CDI', 
                                     'Depleted in CDI', 'Other')))

df.res <- df.res %>% 
  filter(species != "Azospirillum sp. CAG:239 [meta_mOTU_v2_5386]" & species != "Bradyrhizobium sp. BTAi1 [ref_mOTU_v2_3893]" & species != "Proteus mirabilis [ref_mOTU_v2_0546]" & species != "Staphylococcus epidermidis [ref_mOTU_v2_0007]")

g <- df.res %>% 
  ggplot(aes(x=effect.size.without.cdiff, y=-log10(p.val.without.cdiff))) + 
  geom_hline(yintercept = 2, colour='darkgrey', lty=2) + 
  geom_vline(xintercept = c(-0.1, 0.1), colour='darkgrey', lty=2) + 
  geom_point(col='lightgrey') + 
  geom_point(data=df.res %>% filter(highlight!='Other'),
             aes(col=highlight)) +
  geom_text_repel(aes(label=label), size = 2) + 
  theme_bw() + 
  theme(panel.grid.minor=element_blank()) + 
  xlab('LME model effect size') + 
  ylab('-log10(adj. P-value)') + 
  scale_colour_manual(
    values=c('#8246AF', '#FFA300', '#307FE2', 'lightgrey'), 
    #values=c('#E40046', '#8246AF', '#FFA300', '#307FE2', 'lightgrey'), 
    labels=c('Causing CDI-like diarrhea', 'Enriched in CDI', 
             'Depleted in CDI','Other'), name='')

ggsave(g, filename = 'figures/CDI/lme_volcano_noCDIcdiffPos.pdf', 
       width = 12, height = 8,
       useDingbats=FALSE)

