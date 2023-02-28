# Save ICA cleaned data as mats with some useful companion information
# Created on 20210607 by Max B Wang

import numpy as np
import pickle
from scipy import linalg
import matplotlib as mpl
#mpl.use('Agg')
import matplotlib.pyplot as plt
import itertools
import shelve
import sys
import statsmodels.api as sm
import statsmodels.tsa as tsa
from statsmodels.tsa.api import VAR,VECM
import statsmodels.stats.diagnostic as sm_diag
import os
import time
#from visbrain.gui import Brain
#from visbrain.objects import SourceObj, ConnectObj
#from visbrain.io import download_file
from scipy import io

# EP1155 EP1156 EP1165 EP1166 EP1184_A EP1184_B EP1188
#ECOG_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/"
ECOG_Dir="/media/mwang/easystore/Processed_Data/"

#subjID="EP1155"
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

if useFixed==0:
	if resolution==0:
		shelf_name=ECOG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_CoarNonFixed_Eps_shelve.out"
	elif resolution==1:
		shelf_name=ECOG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_RoughNonFixed_Eps_shelve.out"

elif useFixed==1:
	if resolution==0:
		shelf_name=ECOG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_CoarFixed_Eps_shelve.out"
	elif resolution==1:
		shelf_name=ECOG_Dir+subjID+"/ClusCoherence_Cleaned_AllTrials_RoughFixed_"+append+".npz"

cleanedData=np.load(shelf_name)
trial_feats=cleanedData['ica_corrected_feats']

bandList=["theta","alpha","beta_l","beta_u","gamma"]
band_feats=np.zeros(len(bandList))
bandClusters=np.zeros(len(bandList))

for bInd in range(0,len(bandList)):
	if useFixed==1:
		if resolution==0:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",delimiter=",")
	elif useFixed==0:
		if resolution==0:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/"+bandList[bInd]+"GlobalModularityCommunities_Coherence_Coarse.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/"+bandList[bInd]+"GlobalModularityCommunities_Coherence_Rough.csv",delimiter=",")
	numClusters=int(np.max(communityAssignments))+1
	bandClusters[bInd]=numClusters
	band_feats[bInd]=int((np.square(numClusters)-numClusters)/2+numClusters)

bandAverages=np.zeros([trial_feats.shape[0],len(band_feats)])
bandNetworks=[]
intraBandNetworks=[]

for bInd in range(0,len(band_feats)):
	bStart=int(np.sum(band_feats[0:bInd]))
	bEnd=int(bStart+band_feats[bInd])
	
	bandNetworks.append(trial_feats[:,bStart:bEnd])
	intraNetInds=np.array([0])
	step=bandClusters[bInd]

	for i in range(1,int(bandClusters[bInd])):
		intraNetInds=np.append(intraNetInds,np.int(intraNetInds[i-1]+step))
		step=step-1

	intraBandNetworks.append(bandNetworks[bInd][:,intraNetInds])

features=np.concatenate(intraBandNetworks,axis=1)
presentIdx=np.sum(features,axis=0)!=0
bandNames=["Theta","Alpha","Beta_l","Beta_u","Gamma"]

if useFixed==1:
	modifier="Fixed"
elif useFixed==0:
	modifier="NonFixed"

if resolution==0:
	resMod="Coarse"
elif resolution==1:
	resMod="Rough"

# Generate visualization of features
feature_coefs=[]
bandNames=["theta","alpha","beta_l","beta_u","gamma"]

featClass=2

if featClass==0:
	# Band Averaged Features
	
	communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence_"+append+".csv",delimiter=",")
	numClusters=np.int(np.max(communityAssignments)+1)
	numElectrodes=len(communityAssignments)
	
	for bInd in range(0,5):
		feature_coefs.append(np.zeros([5,numElectrodes,numElectrodes]))
		feature_coefs[bInd][bInd,:,:]=1
elif featClass==1:
	# Band Feats

	if resolution==0:
		resMod=""
	elif resolution==1:
		resMod="_Rough"

	if useFixed==1:
		communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence"+resMod+"_"+append+".csv",delimiter=",")
	elif useFixed==0:
		communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/"+bandNames[bandSelector]+"GlobalModularityCommunities_Coherence"+resMod+".csv",delimiter=",")

	numClusters=np.int(np.max(communityAssignments)+1)
	numElectrodes=len(communityAssignments)
	
	rowIndices=np.zeros([numClusters,numClusters])
	colIndices=np.zeros([numClusters,numClusters])

	for cInd in range(0,numClusters):
		rowIndices[cInd,:]=cInd
		colIndices[:,cInd]=cInd

	rowIdx=rowIndices[np.triu_indices(numClusters)]
	colIdx=colIndices[np.triu_indices(numClusters)]
	
	for compInd in range(0,len(rowIdx)):
		feature_coefs.append(np.zeros([5,numElectrodes,numElectrodes]))
		cI=communityAssignments==rowIdx[compInd]
		cJ=communityAssignments==colIdx[compInd]
		template=np.zeros([numElectrodes,numElectrodes])
		template[np.ix_(cI,cJ)]=1
		template[np.ix_(cJ,cI)]=1
		feature_coefs[compInd][bandSelector,:,:]=template
elif featClass==2:
	if resolution==0:
		resMod=""
	elif resolution==1:
		resMod="_Rough"
	
	for bInd in range(0,5):
		if useFixed==1:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence"+resMod+"_"+append+".csv",delimiter=",")
		elif useFixed==0:
			communityAssignments=np.genfromtxt(ECOG_Dir+subjID+"/Communities/"+bandNames[bInd]+"GlobalModularityCommunities_Coherence"+resMod+".csv",delimiter=",")
		numClusters=np.int(np.max(communityAssignments)+1)
		numElectrodes=len(communityAssignments)
		
		for cInd in range(0,numClusters):
			cI=communityAssignments==cInd
			template=np.zeros([numElectrodes,numElectrodes])
			template[np.ix_(cI,cI)]=1
			bandTemp=np.zeros([5,numElectrodes,numElectrodes])
			bandTemp[bInd,:,:]=template
			feature_coefs.append(bandTemp)

feature_coefs=[feature_coefs[i] for i in np.where(presentIdx)[0]]
features=features[:,presentIdx]

mdic={"endog": features, "feature_coefs": feature_coefs}
io.savemat(ECOG_Dir+subjID+"/ICA_Cleaned_"+append+"_Features.mat",mdic)
