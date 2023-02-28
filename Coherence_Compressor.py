# Generates similarity matrices to pre-compute DeltaCon network distances
# Created on 20200918 by Max B Wang

# %%
import numpy as np
import os
import sys
import time
import shelve
import sys
# %%
#MEG_Dir="/bgfs/aghuman/ECOG_Data/"+subjID+"/"


#commList=["theta","alpha","beta1","beta2","beta3"]
commList=["theta","alpha","beta_l","beta_u","gamma"]
bandList=["theta","alpha","beta_l","beta_u","gamma"]

# Get list of all trial directories to peruse

subjID=sys.argv[1]

# Where to find previously generated files
read_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/"+subjID+"/"

# Where to write the new 
write_Dir="/media/mwang/easystore/Processed_Data/"+subjID+"/"

fixedCommunities=1
resolution=1
aCorr=3
#fixedCommunities=int(sys.argv[2]) # 0: non-fixed, 1: fixed
#resolution=int(sys.argv[3]) # 0: coarse, 1: rough, 2: fine
#aCorr=int(sys.argv[4]) # none=0, spatial=1, electrode=2, spatial_mean=3, electrode_mean=4

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


if subjID=="EP1155":
	groupList=["04cf8","33c02","e6a6d","b2b99","521ec"]
	breakLength=[15,22,23,22,0]
elif subjID=="EP1156":
	groupList=["57f05","ad4c2","1c6c6","d2bdb","e0123","ccc2b","a1710"]
	breakLength=[23,24,1954,701,24,24,0]

trialList=[]
groupInd=[]

eI_Data=np.load(write_Dir+"electrodeIndexing.npz")
scanInds=eI_Data["scanInds"]

for gInd in range(0,len(groupList)):
	numGroupTrials=len(next(os.walk(read_Dir+"Trial_Coherence/"+groupList[gInd]+"/"))[1])
	
	for myTrial in range(1,numGroupTrials+1):
		trialList.append(read_Dir+"Trial_Coherence/"+groupList[gInd]+"/Trial_"+str(myTrial))
		groupInd.append(gInd)
	
	for blankTrial in range(0,breakLength[gInd]):
		trialList.append("Empty")
		groupInd.append(gInd)

numTrials=len(trialList)

# Get number of features
band_feats=np.zeros(len(bandList))

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

for bInd in range(0,len(bandList)):
	#communityAssignments=np.genfromtxt(MEG_Dir+"/Communities/"+bandList[bInd]+"GlobalModularityCommunities_Coherence.csv",delimiter=",")
	if fixedCommunities==0:
		if resolution==0:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence_Coarse.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence_Rough"+append+".csv",delimiter=",")
		elif resolution==2:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence.csv",delimiter=",")

	elif fixedCommunities==1:
		if resolution==0:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",delimiter=",")
		elif resolution==2:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence_Fine_"+append+".csv",delimiter=",")

	numClusters=int(np.max(communityAssignments))+1
	band_feats[bInd]=int((np.square(numClusters)-numClusters)/2+numClusters)

numFeats=int(np.sum(band_feats))

trial_feats=np.zeros([numTrials,numFeats])

for bInd in range(0,len(bandList)):
	print("Starting Band: " + bandList[bInd])
	# %% Optimize modularity globally over time
	if fixedCommunities==0:
		if resolution==0:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence_Coarse.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence_Rough"+append+".csv",delimiter=",")
		elif resolution==2:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/"+commList[bInd]+"GlobalModularityCommunities_Coherence.csv",delimiter=",")

	elif fixedCommunities==1:
		if resolution==0:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence.csv",delimiter=",")
		elif resolution==1:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",delimiter=",")
		elif resolution==2:
			communityAssignments=np.genfromtxt(write_Dir+"/Communities/UniversalGlobalModularityCommunities_Coherence_Fine_"+append+".csv",delimiter=",")
	
	numClusters=int(np.max(communityAssignments))+1

	for tInd in range(0,numTrials):
		t=time.time()
		
		trialRem=np.mod(tInd-1,10)
		if trialRem==0:
		     print("Clustering Coherence Matrix for Subject "+subjID+", Trial " + str(tInd) + " of " + str(numTrials)+ " for band " + bandList[bInd])
		
		if trialList[tInd]=="Empty":
			b_start=int(np.sum(band_feats[0:bInd]))
			b_end=int(b_start+band_feats[bInd])
			trial_feats[tInd,b_start:b_end]=np.nan
		else:
			
			if aCorr==1:	
				trialData=np.load(trialList[tInd] + "/Trial_Coherence_SpatialACorr.npz")
			elif aCorr==2:
				trialData=np.load(trialList[tInd] + "/Trial_Coherence_ElectrodeACorr.npz")
			elif aCorr==3:
				trialData=np.load(trialList[tInd] + "/Trial_Coherence_SpatialACorr_Mean.npz")
			elif aCorr==4:
				trialData=np.load(trialList[tInd] + "/Trial_Coherence_ElectrodeACorr_Mean.npz")

			bandMat=trialData['bandMat']
			
			if np.sum(np.isnan(bandMat)):
				b_start=int(np.sum(band_feats[0:bInd]))
				b_end=int(b_start+band_feats[bInd])
				trial_feats[tInd,b_start:b_end]=np.nan
			else:
				CohMat=bandMat[bInd,:,:]
				cluster_DMat=np.zeros([numClusters,numClusters])

				for c_i in range(0,numClusters):
					intra_cluster=CohMat[np.ix_(communityAssignments==c_i,communityAssignments==c_i)]
					if np.sum(communityAssignments==c_i)>1:
						cluster_DMat[c_i,c_i]=np.mean(intra_cluster[np.triu_indices(intra_cluster.shape[0],k=1)])
					else:
						cluster_DMat[c_i,c_i]=0

					for c_j in range(c_i+1,numClusters):
						cluster_DMat[c_i,c_j]=np.mean(CohMat[np.ix_(communityAssignments==c_i,communityAssignments==c_j)])
						cluster_DMat[c_j,c_i]=cluster_DMat[c_i,c_j]
				
				b_start=int(np.sum(band_feats[0:bInd]))
				b_end=int(b_start+band_feats[bInd])
				trial_feats[tInd,b_start:b_end]=cluster_DMat[np.triu_indices(cluster_DMat.shape[0])]
		elapsed = time.time()-t
		print(str(elapsed) + " seconds elapsed")

if fixedCommunities==0:
	if resolution==0:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_CoarNonFixed_Eps_shelve.out"
	if resolution==1:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_RoughNonFixed_"+append
	if resolution==2:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_FineNonFixed_NonNormed_shelve.out"
elif fixedCommunities==1:
	if resolution==0:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_CoarFixed_Eps_shelve.out"
	if resolution==1:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_RoughFixed_"+append+""
	if resolution==2:
		shelf_name=write_Dir+"/ClusCoherence_AllTrials_FineFixed_"+append+""

np.savez(shelf_name+".npz",trial_feats=trial_feats)
