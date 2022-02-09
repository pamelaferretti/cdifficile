## paseMetaSNV_freq.py

##### C:\Users\maistren\Anaconda2\python.exe paseMetaSNV_freq_add_extraGenomesOutgroup.py


import sys
import re
import csv
import numpy as np
import pandas as pd
import os

print "new script iteration"

print "read snp from outgroup and ref genome"

snpFileRef_outgroup=pd.read_csv("all3GenomesSNPfromMauveParsed_bin.tab", sep="\t")


print snpFileRef_outgroup



inDF=pd.read_csv("272563.filtered.freq", sep="\t")


inDF[['contig','c1','position','allelesRefAlt','c2']] = inDF['Unnamed: 0'].str.split(':',expand=True)
del inDF['c1']
del inDF['c2']
inDF[['refAllele','altAllele']] = inDF['allelesRefAlt'].str.split('>',expand=True)

del inDF['contig']


inDF['position'] = inDF['position'].apply(str)
snpFileRef_outgroup['ref_position'] = snpFileRef_outgroup['ref_position'].apply(str)

inDF=pd.merge(inDF, snpFileRef_outgroup, how='left', left_on=['position'], right_on=['ref_position'])


inDF['1408823.PRJNA223331_freq']=inDF['1408823.PRJNA223331_freq'].fillna(-1)
inDF['1151292.PRJNA85757_freq']=inDF['1151292.PRJNA85757_freq'].fillna(-1)

inDF = inDF[inDF['1408823.PRJNA223331_freq'] != -1]
inDF.to_csv("temp.tab", sep='\t',index=False,header=True)
print inDF



del inDF['position']
del inDF['allelesRefAlt']
del inDF['Unnamed: 0']
del inDF['1151292.PRJNA85757']
del inDF['ref_position']
del inDF['272563.PRJNA78.AM180355']
del inDF['1408823.PRJNA223331']


inDF['272563.PRJNA78.AM180355']=0


df1 = inDF.pop('refAllele') # remove column b and store it in df1 	

df2 = inDF.pop('altAllele') # remove column x and store it in df2
inDF['refAllele']=df1 # add b series as a 'new' column.
inDF['altAllele']=df2 # add b series as a 'new' column.





print inDF

inDFrep=inDF



inDFrep.iloc[0, 0] = 0 # So we can check the == 0 condition 

lsCol=inDFrep.columns
lsCol=lsCol[:-2]


nucl = ['-', inDFrep['refAllele'], inDFrep['altAllele']]


inDFrep.to_csv("inDFrepInput_tempoBeforeCleanUp_outgroup_filt.tab", sep='\t',index=False,header=True)

print inDFrep
for cc in lsCol:
	print cc
#	print inDFrep[cc]
	conditions = [inDFrep[cc] == -1, inDFrep[cc] <=0.50, inDFrep[cc]>0.50]
	inDFrep[cc] = np.select(conditions, nucl, default=np.nan)


del inDFrep['refAllele']
del inDFrep['altAllele']
inDFrep=inDFrep.T


print inDFrep
print inDFrep.shape


list2Delete=[]

lsCol2=inDFrep.columns
for cc in lsCol2:
	print cc
#	print inDFrep[cc]
	print set(inDFrep[cc])
	if (len(set(inDFrep[cc]))<3 and ('-' in set(inDFrep[cc]))):
		print len(set(inDFrep[cc]))
		list2Delete.append(cc)
		print "to delete"

inDFrep = inDFrep.drop(list2Delete, axis=1)

inDFrep.to_csv("inDFrep_freq_272563.filtered_outgroup_filt.tab", sep='\t',index=True,header=True)


print inDFrep
print "number of samples"
print inDFrep.shape[0]
print "length of pseudo-alignment"
print inDFrep.shape[1]


inDFrep['col1'] = inDFrep[inDFrep.columns[0:]].apply(
    lambda x: ''.join(x.dropna().astype(str)),
    axis=1)

inDFrep=inDFrep['col1']

inDFrep.to_csv("Freq_272563_PHY.filtered_outgroup_filt.tab", sep='\t',index=True,header=False)



print "done cdif freq parser"

