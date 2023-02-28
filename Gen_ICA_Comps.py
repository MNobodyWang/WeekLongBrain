# Analyzes Gaussian Mixture Approach
# Created on 20200924 by Max B Wang

# %%
import numpy as np
import pickle
import random
from scipy import linalg
import matplotlib as mpl
import itertools
import shelve
from sklearn.decomposition import PCA, FastICA
import time
import sys
import os

#MEG_Dir=sys.argv[1]
#MEG_Dir="/bgfs/aghuman/ECOG_Data/"
MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[1]

useFixed=1
aCorr=3
#useFixed=int(sys.argv[2])
#aCorr=int(sys.argv[3])

if aCorr==0:
	append=""
elif aCorr==1:
	append="SACorr"
elif aCorr==2:
	append="ECorr"
elif aCorr==3:
	append="SACorr_Mean"
elif aCorr==4:
	append="ECorr_Mean"

if useFixed==1:
	store_name=MEG_Dir+"/"+subjID+"/ClusCoherence_AllTrials_RoughFixed_"+append+""
elif useFixed==0:
	store_name=MEG_Dir+"/"+subjID+"/ClusCoherence_AllTrials_RoughNonFixed_"+append+""

#trialData=shelve.open(shelf_name)
#trial_feats=trialData['trial_feats']
#trialData.close()

data=np.load(store_name+".npz")
trial_feats=data['trial_feats']

# Remove features that are always zero
trial_feats=trial_feats[:,np.sum(trial_feats,axis=0)!=0]
trial_feats=trial_feats[np.logical_not(np.isnan(np.sum(trial_feats,axis=1))),:]

t=time.time()
ica = FastICA(n_components=40,max_iter=2000,tol=1e-3)
ica.fit(trial_feats)
elapsed=time.time()-t

print(str(elapsed)+" secs")

if not os.path.exists(MEG_Dir+"/"+subjID+"/ICA"):
	os.makedirs(MEG_Dir+"/"+subjID+"/ICA")

if useFixed==1:
	shelf_name=MEG_Dir+"/"+subjID+"/ICA/FastICA_Comp40_RoughFixed_Coherence_"+append+"_shelve.out"
elif useFixed==0:
	shelf_name=MEG_Dir+"/"+subjID+"/ICA/FastICA_Comp40_RoughNonFixed_Coherence_"+append+"_shelve.out"

my_shelf = shelve.open(shelf_name,'n')
my_shelf['ica']=ica
my_shelf.close()
