# Filter electrodes and saves them as trial files
# Created on 20201209 by Max B Wang

# %%
from scipy.io import loadmat
from scipy.io import savemat
from scipy import signal
import h5py
import hdf5storage
import numpy as np
import time
import os
import sys
import mne
import glob

# %%
MEG_Dir=sys.argv[1]
#MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[2]
edfInd=int(sys.argv[3])

#MEG_Dir="/bgfs/aghuman/ECOG_Data"
#subjID="EP1155"
#edfInd=4

readDir=MEG_Dir+"/"+subjID+"/"

edfList=glob.glob(readDir+"ElectrodesRaw/*")

electrodePath=edfList[edfInd]+"/"
print("Reading from " + electrodePath)

def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='bandpass')
    return b, a

def butter_bandstop(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='bandstop')
    return b, a

def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = signal.filtfilt(b, a, data)
    return y

def butter_bandstop_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandstop(lowcut, highcut, fs, order=order)
    y = signal.filtfilt(b, a, data)
    return y

print("Loading and Filtering Data")
t=time.time()

if os.path.isfile(electrodePath+"/Electrodes_Raw.mat"):
	annots = hdf5storage.loadmat(electrodePath+"/Electrodes_Raw.mat")
	electrodeData=annots['electrodeData']
	Fs=1/np.min(annots['times'][1:]-annots['times'][0:-1])
else:
	annots=hdf5storage.loadmat(electrodePath+"/electrode_1.mat")
	numElectrodes=len(glob.glob(electrodePath+"/*"))
	filteredData=np.zeros([numElectrodes,annots['electrodeData'].shape[1]])
	Fs=1/np.min(annots['times'][1:]-annots['times'][0:-1])
	
	for eInd in range(0,numElectrodes):
		print(eInd)
		annots=hdf5storage.loadmat(electrodePath+"/electrode_"+str(eInd+1)+".mat")
		filteredData[eInd,:]=butter_bandstop_filter(annots['electrodeData'],57,63,Fs)
		filteredData[eInd,:]=butter_bandpass_filter(filteredData[eInd,:],0.2,115,Fs)

#print("Filtering Data")
#t=time.time()
#filteredData=butter_bandstop_filter(electrodeData,55,65,Fs)
#filteredData=butter_bandpass_filter(filteredData,0.2,115,Fs)

elapsed=time.time()-t
print(str(elapsed)+" secs elapsed")


numTrials=int(np.floor((filteredData.shape[1])/(5*Fs)))
trialLength=int(np.floor(Fs*5))
elapsed=time.time()-t
print(str(elapsed)+" secs elapsed")

print("Saving Data")
t=time.time()
for trial in range(0,numTrials):
	outPath=readDir+"Electrode_Trials/"+edfList[edfInd][-5:]+"/Trial_"+str(trial+1)+"/"
	if not os.path.exists(outPath):
		os.makedirs(outPath)
	
	tStart=int(trial*trialLength)
	tEnd=int(tStart+trialLength)
	
	trialData={}
	trialData[u'trial_Data']=filteredData[:,tStart:tEnd]
	trialData[u'Fs']=Fs
	hdf5storage.write(trialData, '.', outPath+'FilteredTrial.mat', matlab_compatible=True)

elapsed=time.time()-t

time_stamps=annots['times']
np.save(readDir+"Electrode_Trials/"+edfList[edfInd][-5:]+"/TimeStamp.npy",time_stamps)
print(str(elapsed)+" seconds elapsed")
