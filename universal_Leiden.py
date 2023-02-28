# Tests Leiden algorith and igraph packages
# Created on 20200609 by Max B Wang

# %%
import igraph as ig
import leidenalg as la
import numpy as np
import os
import time
import psutil
import sys
import shelve
import glob
import traceback
# %%

tStart=time.time()

# EP1155, EP1156, EP1165, EP1166, EP1184, EP1188
#MEG_Dir=sys.argv[1]
#MEG_Dir="/media/mwang/easystore/Processed_Data/"
Coh_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/"

MEG_Dir=Coh_Dir

subjID=sys.argv[1]
resolution=int(sys.argv[2]) # coarse=0, rough=1, fine=2
aCorr=int(sys.argv[3]) # none=0, spatial=1, electrode=2, spatial_mean=3, electrode_mean=4

writeDir=MEG_Dir+"/"+subjID+"/"
readDir=Coh_Dir+"/"+subjID+"/"

partition_list=[]

dirList=glob.glob(MEG_Dir+subjID+"/Electrode_Trials/*")
scanList = [os.path.basename(x) for x in dirList]

eI_Data=np.load(writeDir+"electrodeIndexing.npz")
scanInds=eI_Data["scanInds"]

numElectrodes=scanInds.shape[1]
print(numElectrodes)
for sInd in range(0,len(scanList)):
	scan=scanList[sInd]
	print("Starting Scan: " + scan)
	t=time.time()
	# %% Optimize modularity globally over time
	numTrials=len(next(os.walk(readDir+"/Trial_Coherence/"+scan+"/"))[1])

	allTrials=range(1,numTrials+1)
	useTrials=np.random.choice(allTrials,np.int(np.floor(numTrials/7)),replace=False)
	for tInd in range(0,len(useTrials)):
		trialRem=np.mod(tInd-1,200)
		if trialRem==0:
			print("Creating Graph Object-Trial " + str(tInd) + " of " + str(len(useTrials))+ " for scan " + scan)
			#print(process.memory_info()[0])

		if aCorr==0:
			trialData=np.load(readDir+"/Trial_Coherence/"+scan+"/Trial_" + str(useTrials[tInd]) + "/Trial_Coherence.npz")
		elif aCorr==1:
			trialData=np.load(readDir+"/Trial_Coherence/"+scan+"/Trial_" + str(useTrials[tInd]) + "/Trial_Coherence_SpatialACorr.npz")
		elif aCorr==2:
			trialData=np.load(readDir+"/Trial_Coherence/"+scan+"/Trial_" + str(useTrials[tInd]) + "/Trial_Coherence_ElectrodeACorr.npz")
		elif aCorr==3:
			trialData=np.load(readDir+"/Trial_Coherence/"+scan+"/Trial_" + str(useTrials[tInd]) + "/Trial_Coherence_SpatialACorr_Mean.npz")
		elif aCorr==4:
			trialData=np.load(readDir+"/Trial_Coherence/"+scan+"/Trial_" + str(useTrials[tInd]) + "/Trial_Coherence_ElectrodeACorr_Mean.npz")
			
		bandMat=trialData['bandMat']
		#diffMat=np.square(np.genfromtxt(readDir+scan+"/SimilarityMats/Trial_"+str(useTrials[tInd])+"/SimilarityRootedMat_"+band+".csv",delimiter=','))
		bInd=np.random.randint(5)
		
		try:
			adjMat=bandMat[bInd,:,:]
			#indexedMat=adjMat[np.ix_(scanInds[sInd,:],scanInds[sInd,:])]
			myGraph = ig.Graph.Weighted_Adjacency(adjMat.tolist())
			#myPartition=la.ModularityVertexPartition(myGraph,weights=myGraph.es['weight'])
			if resolution==0:
				myPartition=la.RBConfigurationVertexPartition(myGraph,weights=myGraph.es['weight'])
			elif resolution==1:
				myPartition=la.RBConfigurationVertexPartition(myGraph,weights=myGraph.es['weight'],resolution_parameter=1.25)
			elif resolution==2:
				myPartition=la.RBConfigurationVertexPartition(myGraph,weights=myGraph.es['weight'],resolution_parameter=1.5)

			partition_list.append(myPartition)
		
		except Exception:
			traceback.print_exc()
			print(str(useTrials[tInd]) +" trial failed")

	elapsed=time.time()-t
	print(str(elapsed)+" seconds elapsed")
#	print(process.memory_info()[0])

## %%

print("Optimizing Global Modularity")
optimiser = la.Optimiser()
diff = optimiser.optimise_partition_multiplex(partitions=partition_list,n_iterations=-1)
print("Done")
## Membership of all partitions is the same, so just grab the membership of the first one
membership=partition_list[0].membership
cluster_membership=np.array(membership)
#numElectrodes=bandMat.shape[1]
clusterMat=np.zeros((numElectrodes,numElectrodes))

for myCluster in range(0,np.max(cluster_membership)+1):
	clusterMat[np.ix_(cluster_membership==myCluster,cluster_membership==myCluster)]=myCluster+1

#plt.imshow(clusterMat)
#plt.show()

outPath=writeDir+"Communities/"

if not os.path.exists(outPath):
	os.makedirs(outPath)

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

if resolution==0:
	np.savetxt(outPath+"UniversalGlobalModularityCommunities_Coherence"+append+".csv",cluster_membership,delimiter=",")
elif resolution==1:
	np.savetxt(outPath+"UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",cluster_membership,delimiter=",")
elif resolution==2:
	np.savetxt(outPath+"UniversalGlobalModularityCommunities_Coherence_Fine_"+append+".csv",cluster_membership,delimiter=",")
