# Finds a consistent set of electrodes and their respective indices across several days of ECOG data stored as EDF files
# Created on 20210105 by Max B Wang

import glob
import mne
import shelve
import pyedflib
import numpy as np
import sys
from scipy.io import savemat

#MEG_Dir="/media/mwang/MBW_Drive/"
#MEG_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/"
MEG_Dir="/media/ghumanlab/Passport/ECOG_Copies/"
writeDir=MEG_Dir

#writeDir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[1]
#scanList = [x.strip() for x in open(MEG_Dir+"/"+subjID+"/scanList.txt","r").readlines()]
scanList=glob.glob(MEG_Dir+subjID+"/EDF/*")
electrodeList=[]

def return_indices_of_a(a, b):
  b_set = set(b)
  return [i for i, v in enumerate(a) if v in b_set]

for scan in scanList:
	print("Getting Channel Names for Scan: "+scan)
	#myFileName=glob.glob(MEG_Dir+subjID+"/EDFs/*"+scan+"*")
	#myFileName=glob.glob(MEG_Dir+subjID+"/*"+scan+"*")
	#data=mne.io.read_raw_edf(myFileName[0])
	#channelNames=data.info.ch_names
	channelNames=pyedflib.EdfReader(scan).getSignalLabels()
	
	ekgInds=[i for i, s in enumerate(channelNames) if 'FP1' in s]
	
	if not(ekgInds):
		ekgInds=[i for i, s in enumerate(channelNames) if 'EKG' in s]
	if not(ekgInds):
		ekgInds=[i for i, s in enumerate(channelNames) if 'C113' in s]
	if not(ekgInds):
		ekgInds=[i for i, s in enumerate(channelNames) if 'C127' in s]
	if not(ekgInds):
		ekgInds=[len(channelNames)]
	usedChannelNames=[x.upper() for x in channelNames[0:ekgInds[0]]]
	electrodeList.append(usedChannelNames)

universalElectrodes=electrodeList[0]

for elecs in electrodeList[1:]:
	matchInds=return_indices_of_a(universalElectrodes,elecs)

	universalElectrodes=[universalElectrodes[i] for i in matchInds]

eventInds=[i for i, s in enumerate(universalElectrodes) if 'PATIENT EVENT' in s]
if eventInds:
	del universalElectrodes[eventInds[0]]

scanInds=[]

for elecs in electrodeList:
	matchInds=return_indices_of_a(elecs,universalElectrodes)

	scanInds.append(matchInds)

my_shelf=shelve.open(MEG_Dir+"/"+subjID+"/electrodeIndexing_shelve.out",'n')
my_shelf['universalElectrodes']=universalElectrodes
my_shelf['scanInds']=scanInds
my_shelf['scanList']=scanList
my_shelf.close()

mdic={'universalElectrodes':universalElectrodes,'scanInds':scanInds,'scanList':scanList}
savemat(MEG_Dir+"/"+subjID+"/electrodeIndexing.mat",mdic)

np.savez(writeDir+"/"+subjID+"/electrodeIndexing.npz",scanInds=scanInds)
