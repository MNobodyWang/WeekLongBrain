# Gets frequency specific z-scores for 1/f normalization
# Created on 20210513 by Max B Wang

# %%
from scipy.io import loadmat
from scipy import signal
import h5py
import numpy as np
import mne
import time
import os
from matplotlib import pyplot as plt
import sys
import glob
import hdf5storage
from random import sample
from sklearn.metrics.pairwise import euclidean_distances
from sklearn.linear_model import LinearRegression

# %%
MEG_Dir=sys.argv[1]
#MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[2]
recordInd=int(sys.argv[3])
recordList=glob.glob(MEG_Dir+"/"+subjID+"/Electrode_Trials/*")

readDir=recordList[recordInd]+"/"

print("Reading from " + readDir)

import os

outPath=MEG_Dir+"/"+subjID+"/Trial_Coherence/"

if not os.path.exists(outPath):
	os.makedirs(outPath)

outfile = outPath + "/Spatial_Autocorrelation_Mean.npz"

eI_Data=np.load(MEG_Dir+"/"+subjID+"/electrodeIndexing.npz")
scanInds=eI_Data["scanInds"]
	
eLocData=loadmat("/media/qSTORAGE/homes/mwang/ECOG_Data/"+subjID+"/universalElectrodes_MNI.mat")
mni_coords=eLocData["mni_electrode_coordinates"]
eDist=euclidean_distances(mni_coords, mni_coords)
np.fill_diagonal(eDist,100)

if os.path.exists(outfile):
	print("Already Done")
else:
	numTrials=len(next(os.walk(readDir))[1])

	annots = hdf5storage.loadmat(readDir+"/Trial_1/FilteredTrial.mat")
	trialData=np.array(annots['trial_Data'])
	numSteps=np.size(trialData,axis=1)

	numElectrodes=np.size(scanInds,axis=1)
	
	electrodeData=np.zeros([int(numElectrodes),int(numTrials*numSteps)])

	for tInd in range(0,numTrials):
		myTrial=tInd

		print("Loading Trial: ",tInd," of ",numTrials)
		t=time.time()
		
		annots = hdf5storage.loadmat(readDir+"/Trial_"+str(myTrial+1)+"/FilteredTrial.mat")
		trialData=np.array(annots['trial_Data'])
		tStart=numSteps*tInd
		tEnd=tStart+numSteps

		electrodeData[:,tStart:tEnd]=trialData[scanInds[recordInd],:]
	
	# Determine spatial auto-correlation of each electrode
	spatialCoefs=np.zeros([numElectrodes,numElectrodes])
	
	for eInd in range(0,numElectrodes):
		print("Calculating Auto-Correlation for Electrode: "+str(eInd))
		eMask=eDist[eInd,:]<0.02

		if np.sum(eMask)>0:
			aveSignal=np.mean(electrodeData[eMask,:],axis=0)
			#reg = LinearRegression().fit(electrodeData[eMask,:], electrodeData[eInd,:])
			reg = LinearRegression().fit(aveSignal.reshape(1,-1).T, electrodeData[eInd,:])
			spatialCoefs[eInd,eMask]=reg.coef_

	np.savez(outfile,spatialCoefs=spatialCoefs)
