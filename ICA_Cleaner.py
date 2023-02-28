# Runs Factor Analysis
# Created on 20201025 by Max B Wang

# %%
import numpy as np
import pickle
import random
from scipy import linalg
import matplotlib as mpl
import itertools
import shelve
from sklearn.decomposition import FactorAnalysis,FastICA
import time
import sys
import os

#MEG_Dir="/bgfs/aghuman/ECOG_Data/"
MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[1]

useFixed=1
resolution=1
aCorr=3

#useFixed=int(sys.argv[2])
#resolution=int(sys.argv[3]) # 0: Coarse, 1: Rough
#aCorr=int(sys.argv[4])

if aCorr==0:
	append=""
elif aCorr==1:
	append="SACorr"
elif aCorr==2:
	append="ECorr"
elif aCorr==3:
	append="SACorr_Mean"

if useFixed==1:
	fAppend="Fixed"
elif useFixed==0:
	fAppend="NonFixed"

if useFixed==1:
	if aCorr==3:
		if subjID=="EP1155":
			artifact_channels=[]
		elif subjID=="EP1156":
			artifact_channels=[16]

shelf_name=MEG_Dir+subjID+"/ClusCoherence_AllTrials_Rough"+fAppend+"_"+append+".npz"
dataFeats=np.load(shelf_name)
trial_feats=dataFeats["trial_feats"]

presentIdx=np.sum(trial_feats,axis=0)!=0
trial_feats=trial_feats[:,presentIdx]
samplePresent=np.logical_not(np.isnan(np.sum(trial_feats,axis=1)))
numTrials=trial_feats.shape[0]

shelf_name=MEG_Dir+"/"+subjID+"/ICA/FastICA_Comp40_Rough"+fAppend+"_Coherence_"+append+"_shelve.out"
my_shelf = shelve.open(shelf_name)
ica=my_shelf['ica']
my_shelf.close()

print("Cleaning ICA Data")

if artifact_channels:
	ica_feats=ica.transform(trial_feats[samplePresent,:])
	artifact_ica=np.zeros(ica_feats.shape)
	artifact_ica[:,artifact_channels]=ica_feats[:,artifact_channels]
	artifact_feats=ica.inverse_transform(artifact_ica)

	ica_corrected_feats=np.copy(trial_feats)
	ica_corrected_feats[samplePresent,:]=trial_feats[samplePresent,:]-artifact_feats+ica.mean_
	#ica_feats[:,artifact_channels]=0

	#ica_corrected_feats=trial_feats
	#ica_corrected_feats[samplePresent]=ica.inverse_transform(ica_feats)
else:
	ica_corrected_feats=trial_feats

if useFixed==0:
	if resolution==0:
		shelf_name=MEG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_CoarNonFixed_Eps_shelve.out"
	elif resolution==1:
		shelf_name=MEG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_RoughNonFixed_Eps_shelve.out"

elif useFixed==1:
	if resolution==0:
		shelf_name=MEG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_CoarFixed_Eps_shelve.out"
	elif resolution==1:
		shelf_name=MEG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_RoughFixed_"+append+".npz"

print("Saving Feats")
#my_shelf = shelve.open(shelf_name,'n')
#my_shelf['ica_corrected_feats']=ica_corrected_feats
#my_shelf.close()
np.savez(shelf_name,ica_corrected_feats=ica_corrected_feats)
