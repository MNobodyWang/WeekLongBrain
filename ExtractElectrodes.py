# Converts electrode data from edfs into .mat files
# Created on 20200609 by Max B Wang

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
import pyedflib
import mne
import glob

# %%

Data_Dir=sys.argv[1]
subjID=sys.argv[2]
edfInd=int(sys.argv[3])

readDir=Data_Dir+"/"+subjID+"/"
writeDir="/media/mwang/easystore/Processed_Data/"+subjID+"/"

print("Reading from " + readDir)
t=time.time()
edfList=glob.glob(readDir+"EDF/*")

#myEDF=pyedflib.EdfReader(edfList[edfInd])
data=mne.io.read_raw_edf(edfList[edfInd])
#data.load_data()

ekgInds= [i for i, s in enumerate(data.info.ch_names) if 'EKG' in s]

if not(ekgInds):
	ekgInds=[i for i, s in enumerate(data.info.ch_names) if 'C127' in s]
if not(ekgInds):
	ekgInds=[len(data.info.ch_names)]

#matFileData={}
#matFileData[u'electrodeData'],matFileData[u'times']=data.get_data(np.arange(0,ekgInds[0]),return_times=True)

outPath=writeDir+"/ElectrodesRaw/"+edfList[edfInd][-9:-4]+"/"

if not os.path.exists(outPath):
	os.makedirs(outPath)

eStart=0

if os.path.exists(outPath+"electrode_1.mat"):
	eStart=len(os.listdir(outPath))-1

#hdf5storage.write(matFileData, '.', outPath+'Electrodes_Raw.mat', matlab_compatible=True)

for elecInd in range(eStart,ekgInds[0]):
	print("Starting Electrode "+str(elecInd+1)+" of "+str(ekgInds[0]-1))
	if os.path.exists(outPath+"electrode_"+str(elecInd+1)+".mat"):
		os.remove(outPath+"electrode_"+str(elecInd+1)+".mat")
	eTime=time.time()
	elecData={}
	elecData[u'electrodeData'],elecData[u'times']=data.get_data(picks=elecInd,return_times=True)
	hdf5storage.write(elecData, '.', outPath+'electrode_'+str(elecInd+1)+'.mat', matlab_compatible=True)
	eElapsed=time.time()-eTime
	print("Electrode finished, "+str(eElapsed)+" secs elapsed")

elapsed=time.time()-t
print(str(elapsed)+" seconds elapsed")
