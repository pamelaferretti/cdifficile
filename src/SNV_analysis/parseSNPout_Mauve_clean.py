## C:\Users\maistren\Anaconda2\python.exe parseSNPout_Mauve.py all3GenomesSNP_file.tab


import sys
import re
import csv
import numpy as np
import pandas as pd
import os



snp_inDF=pd.read_csv(sys.argv[1], sep="\t")




snp_inDF[['272563.PRJNA78.AM180355','1408823.PRJNA223331','1151292.PRJNA85757']] = snp_inDF['SNP pattern'].astype(str).apply(lambda x: pd.Series(list(x))).astype(str)
snp_inDF['1408823.PRJNA223331'] = snp_inDF['1408823.PRJNA223331'].str.upper()
snp_inDF['1151292.PRJNA85757'] = snp_inDF['1151292.PRJNA85757'].str.upper()

snp_inDF=snp_inDF[['ref_position','272563.PRJNA78.AM180355','1408823.PRJNA223331','1151292.PRJNA85757']].sort_values(by=['ref_position'])
snp_inDF.drop(snp_inDF.index[snp_inDF['272563.PRJNA78.AM180355'] == '-'], inplace = True)
snp_inDF.drop(snp_inDF.index[snp_inDF['1408823.PRJNA223331'] == 'W'], inplace = True)

print snp_inDF

snp_inDF.to_csv("all3GenomesSNPfromMauveParsed.tab", sep='\t',index=False,header=True)



comparison_column_1408823_PRJNA223331 = np.where(snp_inDF["272563.PRJNA78.AM180355"] == snp_inDF["1408823.PRJNA223331"], 0, 1)
snp_inDF["1408823.PRJNA223331_freq"] = comparison_column_1408823_PRJNA223331

comparison_column_1151292_PRJNA85757 = np.where(snp_inDF["272563.PRJNA78.AM180355"] == snp_inDF["1151292.PRJNA85757"], 0, 1)
snp_inDF["1151292.PRJNA85757_freq"] = comparison_column_1151292_PRJNA85757

snp_inDF['1408823.PRJNA223331_freq'] = np.where(snp_inDF['1408823.PRJNA223331'] == '-', -1, snp_inDF['1408823.PRJNA223331_freq'])
snp_inDF['1151292.PRJNA85757_freq'] = np.where(snp_inDF['1151292.PRJNA85757'] == '-', -1, snp_inDF['1151292.PRJNA85757_freq'])

print snp_inDF




snp_inDF.to_csv("all3GenomesSNPfromMauveParsed_bin.tab", sep='\t',index=False,header=True)


print "all done"
