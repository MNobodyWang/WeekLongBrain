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
import traceback
from random import sample

# %%
#MEG_Dir=sys.argv[1]
MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[1]
recordInd=int(sys.argv[2])
aCorr=int(sys.argv[3])
aveCortex=int(sys.argv[4])
startInd=int(sys.argv[5])

dirList=glob.glob(MEG_Dir+subjID+"/Electrode_Trials/*")
groupList = [os.path.basename(x) for x in dirList]
readDir=MEG_Dir+subjID+"/Electrode_Trials/"+groupList[recordInd]+"/"

print("Reading from " + readDir)

import os
numTrials=len(next(os.walk(readDir))[1])

def multiCoherence(signals, fs=1.0, window='hann', nperseg=None, noverlap=None,nfft=None, detrend='constant', axis=-1):
	numElectrodes=np.size(signals,axis=0)
	
	freqs,_ = signal.welch(signals[0,:], fs=fs, window=window, nperseg=nperseg,noverlap=noverlap, nfft=nfft, detrend=detrend,axis=axis)
	numSegs=len(freqs)

	cohMat=np.zeros([numSegs,numElectrodes,numElectrodes])
	P_sigs=np.zeros([numElectrodes,numSegs])

	for eInd in range(0,numElectrodes):
		freqs, P_sigs[eInd,:] = signal.welch(signals[eInd,:], fs=fs, window=window, nperseg=nperseg,noverlap=noverlap, nfft=nfft, detrend=detrend,axis=axis)
	
	for e1 in range(0,numElectrodes):
		for e2 in range(e1+1,numElectrodes):
			_, Pxy = signal.csd(signals[e1,:],signals[e2,:],fs=fs, window=window, nperseg=nperseg,noverlap=noverlap, nfft=nfft, detrend=detrend,axis=axis)
			cohMat[:,e1,e2]=np.abs(Pxy)**2 / P_sigs[e1,:] / P_sigs[e2,:]
			cohMat[:,e2,e1]=cohMat[:,e1,e2]
	return freqs, cohMat
#numTrials=1

write_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data"
outPath=write_Dir+"/"+subjID+"/Trial_Coherence/"+groupList[recordInd][-5:]

spatialAutoPath=MEG_Dir+"/"+subjID+"/Trial_Coherence/"

if aCorr==2:
	aCorrAnnot=np.load(spatialAutoPath+"/Electrode_Autocorrelation.npz")
	spatialCoefs=aCorrAnnot['spatialCoefs']
elif aCorr==3:
	aCorrAnnot=np.load(spatialAutoPath+"/Spatial_Autocorrelation_Mean.npz")
	spatialCoefs=aCorrAnnot['spatialCoefs']
elif aCorr==4:
	aCorrAnnot=np.load(spatialAutoPath+"/Electrode_Autocorrelation_Mean.npz")
	spatialCoefs=aCorrAnnot['spatialCoefs']

eI_Data=np.load(MEG_Dir+"/"+subjID+"/electrodeIndexing.npz")
scanInds=eI_Data["scanInds"]

#lowerFreqBand=[3.5,8,12.5,16.5,20.5,30];
#upperFreqBand=[7.5,13,16,20,28,70];
lowerFreqBand=[4,8,14,20,30];
upperFreqBand=[8,12,20,30,70];

if aCorr==3:
	eMaskLen=np.sum(spatialCoefs>0,axis=1)
	eMaskLen[eMaskLen==0]=1

	spatialCoefs=(spatialCoefs.T/eMaskLen).T
if aCorr==4:
	eMaskLen=np.sum(spatialCoefs>0,axis=1)
	eMaskLen[eMaskLen==0]=1

	spatialCoefs=(spatialCoefs.T/eMaskLen).T

for myTrial in range(startInd,numTrials):
	print("Computing Connectivity of Trial: ",myTrial," of ",numTrials)
	t=time.time()

	try:
		annots = hdf5storage.loadmat(readDir+"/Trial_"+str(myTrial+1)+"/FilteredTrial.mat")
		rawData=np.array(annots['trial_Data'])
		Fs=np.array(annots['Fs'])

		if aCorr!=1:
			trialData=rawData[scanInds[recordInd],:]-np.dot(spatialCoefs,rawData[scanInds[recordInd],:])

		numElectrodes=np.size(trialData,axis=0)
		
		f, cohMat=multiCoherence(trialData,fs=Fs,nperseg=Fs/2)
		
		if aveCortex==0:
			bandMat=np.zeros((len(lowerFreqBand),numElectrodes,numElectrodes))

			for myBand in range(0,len(lowerFreqBand)):
				l_Find=np.argmax(f>=lowerFreqBand[myBand])
				u_Find=np.argmax(f>=upperFreqBand[myBand])-1
				bandMat[myBand,:,:]=np.mean(cohMat[l_Find:u_Find,:,:],axis=0)
		elif aveCortex==1:
			bandMat=np.zeros(200)

			for fInd in range(0,200):
				bandMat[fInd]=np.mean(cohMat[fInd,:,:])

			freqs=f[0:200]
	except Exception:
		traceback.print_exc()

		freqs=np.nan
		bandMat=np.nan
		cohMat=np.nan

		print("Error found, skipping trial and logging")

		os.system("echo 'Record "+str(recordInd)+", Trial "+str(myTrial)+" Group "+groupList[recordInd]+"' >> /home/mwang/EDF_Processing/Logs/"+subjID+"_Errors.txt")

	outPath=write_Dir+"/"+subjID+"/Trial_Coherence/"+groupList[recordInd][-5:]+"/"+"Trial_"+str(myTrial+1)

	if aveCortex==0:
		aveAppend=""
	elif aveCortex==1:
		aveAppend="_CortexAveraged"

	if aCorr==2:
		outfile = outPath + "/Trial_Coherence_ElectrodeACorr"+aveAppend+".npz"
	elif aCorr==3:
		outfile = outPath + "/Trial_Coherence_SpatialACorr_Mean"+aveAppend+".npz"
	elif aCorr==4:
		outfile = outPath + "/Trial_Coherence_ElectrodeACorr_Mean"+aveAppend+".npz"

	if not os.path.exists(outPath):
		os.makedirs(outPath)
	
	if aveCortex==0:
		np.savez(outfile, bandMat=np.single(bandMat), lowerFreqBand=lowerFreqBand, upperFreqBand=upperFreqBand,cohMat=np.single(cohMat))
	elif aveCortex==1:
		np.savez(outfile, bandMat=bandMat, lowerFreqBand=lowerFreqBand, upperFreqBand=upperFreqBand,freqs=freqs)

	elapsed=time.time()-t
	print(str(elapsed)+" secs elapsed")

