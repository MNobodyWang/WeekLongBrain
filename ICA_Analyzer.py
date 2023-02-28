# Analyzes Gaussian Mixture Approach
# Created on 20200924 by Max B Wang

# %%
import numpy as np
import pickle
import random
from scipy import linalg
import matplotlib as mpl
import matplotlib.pyplot as plt
mpl.use('Agg')
import itertools
import shelve
from sklearn.decomposition import PCA, FastICA
import time
import sys
import statsmodels.api as sm
import os

loadData=1
genAutoCorr=1
plotAutoCorr=1
plotComponent=1

#MEG_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/"
MEG_Dir="/media/mwang/easystore/Processed_Data/"
subjID=sys.argv[1]

useFixed=1
resolution=1
aCorrIn=3

#useFixed=int(sys.argv[2])
#resolution=int(sys.argv[3])
#aCorrIn=int(sys.argv[4])

if aCorrIn==0:
	append=""
elif aCorrIn==1:
	append="SACorr"
elif aCorrIn==2:
	append="ECorr"
elif aCorrIn==3:
	append="SACorr_Mean"

if loadData==1:
	print("Loading and Transforming "+subjID)
	if useFixed==1:
		if resolution==1:
			shelf_name=MEG_Dir+subjID+"/ClusCoherence_AllTrials_RoughFixed_"+append+""
	if useFixed==0:
		if resolution==1:
			shelf_name=MEG_Dir+subjID+"/ClusCoherence_AllTrials_RoughNonFixed_"+append+""
			
	trial_data=np.load(shelf_name+".npz")
	trial_feats=trial_data["trial_feats"]

	presentIdx=np.sum(trial_feats,axis=0)!=0
	trial_feats=trial_feats[:,presentIdx]

	samplePresent=np.logical_not(np.isnan(np.sum(trial_feats,axis=1)))

	if useFixed==1:
		if resolution==1:
			shelf_name=MEG_Dir+"/"+subjID+"/ICA/FastICA_Comp40_RoughFixed_Coherence_"+append+"_shelve.out"
	elif useFixed==0:
		if resolution==1:
			shelf_name=MEG_Dir+"/"+subjID+"/ICA/FastICA_Comp40_RoughNonFixed_Coherence_"+append+"_shelve.out"

	my_shelf = shelve.open(shelf_name)
	ica=my_shelf['ica']
	my_shelf.close()
	num_comps=40
	ica_proj=np.zeros([trial_feats.shape[0],num_comps])
	ica_proj[:]=np.nan
	ica_proj[samplePresent,:]=ica.transform(trial_feats[samplePresent,:])
	num_projs=ica_proj.shape[1]
	
	bandList=["theta","alpha","beta_l","beta_u","gamma"]
	band_feats=np.zeros(len(bandList))

	for bInd in range(0,len(bandList)):
		if useFixed==1:
			if resolution==1:
				communityAssignments=np.genfromtxt(MEG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",delimiter=",")
		elif useFixed==0:
			communityAssignments=np.genfromtxt(MEG_Dir+subjID+"/Communities/"+bandList[bInd]+"GlobalModularityCommunities_Coherence_Rough"+append+".csv",delimiter=",")
			

		numClusters=int(np.max(communityAssignments))+1
		band_feats[bInd]=int((np.square(numClusters)-numClusters)/2+numClusters)
	num_electrodes=communityAssignments.shape[0]

if genAutoCorr==1:
	print("Computing Auto Corr for "+subjID)
	n_lags=720*5
	#n_lags=40
	comp_autocorr=np.zeros([n_lags+1,num_projs])
	comp_autocorr_lower=np.zeros([n_lags+1,num_projs])
	comp_autocorr_upper=np.zeros([n_lags+1,num_projs])

	for comp in range(0,num_projs):
		print("Starting Comp "+str(comp))
		t=time.time()
		auto_corr=sm.tsa.stattools.acf(ica_proj[:,comp],alpha=0.05,nlags=n_lags,missing="conservative")
		comp_autocorr[:,comp]=auto_corr[0]
		comp_autocorr_lower[:,comp]=auto_corr[1][:,0]
		comp_autocorr_upper[:,comp]=auto_corr[1][:,1]
		elapsed=time.time()-t
		print("Time elapsed: "+str(elapsed))
	
	if useFixed==1:
		if resolution==1:
			np.savez(MEG_Dir+subjID+"/ICA/ICA_AutoCorr_RoughFixed_"+append+".npz",comp_autocorr=comp_autocorr,comp_autocorr_lower=comp_autocorr_lower,comp_autocorr_upper=comp_autocorr_upper)
	if useFixed==0:
		if resolution==1:
			np.savez(MEG_Dir+subjID+"/ICA/ICA_AutoCorr_RoughNonFixed_"+append+".npz",comp_autocorr=comp_autocorr,comp_autocorr_lower=comp_autocorr_lower,comp_autocorr_upper=comp_autocorr_upper)
			
if useFixed==1:
	if resolution==1:
		figurePath=MEG_Dir+subjID+"/ICA/Figures_RoughFixed_"+append+"/"
if useFixed==0:
	if resolution==1:
		figurePath=MEG_Dir+subjID+"/ICA/Figures_RoughNonFixed_"+append+"/"

if not os.path.exists(figurePath):
	os.makedirs(figurePath)

if plotAutoCorr==1:
	if useFixed==1:
		if resolution==1:
			aCorr=np.load(MEG_Dir+subjID+"/ICA/ICA_AutoCorr_RoughFixed_"+append+".npz")
	if useFixed==0:
		if resolution==1:
			aCorr=np.load(MEG_Dir+subjID+"/ICA/ICA_AutoCorr_RoughNonFixed_"+append+".npz")

	n_lags=720*5

	comp_autocorr=aCorr['comp_autocorr']
	comp_autocorr_lower=aCorr['comp_autocorr_lower']
	comp_autocorr_upper=aCorr['comp_autocorr_upper']

	plt.rcParams["figure.figsize"] = (10,8)
	plt.plot(np.arange(1,n_lags+1)*5,comp_autocorr[1:,:],c="black")
	for comp in range(0,num_projs):
		plt.fill_between(np.arange(1,n_lags+1)*5,comp_autocorr_lower[1:,comp],comp_autocorr_upper[1:,comp])
	plt.xlabel("Time (seconds)",fontsize=14)
	plt.ylabel("Auto-correlation",fontsize=14)
	plt.xticks(fontsize=13)
	plt.yticks(fontsize=13)
	plt.title("Auto-correlation of Different Components",fontsize=18)
	plt.savefig(figurePath+"AllComps_ACorr.png")
	plt.close()
	
if plotComponent==1:
	
	for myComp in range(0,num_comps):
		mixtureWeights=np.zeros(int(np.sum(band_feats)))
		mixtureWeights[presentIdx]=ica.mixing_[:,myComp]
		
		time=np.arange(0,ica_proj.shape[0])
		
		fig,axs=plt.subplots(2)
		axs[0].plot(time*5/3600,ica_proj[:,myComp])
		axs[0].set_xlabel("Time (hrs)",fontsize=14)
		axs[0].set_ylabel("Mixing Strength",fontsize=14)
		axs[0].tick_params(axis='x', labelsize=13)
		axs[0].tick_params(axis='y', labelsize=13)
		axs[0].set_title("ICA Mix of Component "+str(myComp),fontsize=15)

		nonSigIdx=np.where(comp_autocorr_lower[:,comp]<=0)
		#if len(nonSigIdx[0])>0:
		#	nonSigCut=nonSigIdx[0][0]
		#else:
		#	nonSigCut=n_lags
		nonSigCut=n_lags	
		axs[1].plot(np.arange(1,nonSigCut)*5,comp_autocorr[1:nonSigCut,myComp],c="black")
		axs[1].fill_between(np.arange(1,nonSigCut)*5,comp_autocorr_lower[1:nonSigCut,myComp],comp_autocorr_upper[1:nonSigCut,myComp])
		axs[1].set_xlabel("Time (seconds)",fontsize=14)
		axs[1].set_ylabel("Auto-correlation",fontsize=14)
		axs[1].tick_params(axis='x', labelsize=13)
		axs[1].tick_params(axis='y', labelsize=13)
		axs[1].set_title("Auto-correlation of Component",fontsize=18)
		
		plt.subplots_adjust(left=None, bottom=None, right=None, top=None,hspace=0.75)
		plt.savefig(figurePath+"Comp_"+str(myComp)+"_Strength_ACorr.png")
		plt.close()
		
		plt.rcParams["figure.figsize"] = (14,8)
		fig,axs=plt.subplots(2,3)
		axs = axs.ravel()
		for bInd in range(0,5):
			b_start=int(np.sum(band_feats[0:bInd]))
			b_end=int(b_start+band_feats[bInd])
			
			if useFixed==1:
				if resolution==1:
					communityAssignments=np.genfromtxt(MEG_Dir+subjID+"/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_"+append+".csv",delimiter=",")
			elif useFixed==0:
				communityAssignments=np.genfromtxt(MEG_Dir+subjID+"/Communities/"+bandList[bInd]+"GlobalModularityCommunities_Coherence_Rough"+append+".csv",delimiter=",")
				
			numClusters=int(np.max(communityAssignments)+1)
			clusterDiffMat=np.zeros([numClusters,numClusters])
			clusterDiffMat[np.triu_indices(numClusters)]=mixtureWeights[b_start:b_end]
			bandWeightMat=np.zeros([num_electrodes,num_electrodes])

			for cI in range(0,numClusters):
				cI_inds=communityAssignments==cI
				bandWeightMat[np.ix_(cI_inds,cI_inds)]=clusterDiffMat[cI,cI]

				for cJ in range(cI+1,numClusters):
					cJ_inds=communityAssignments==cJ
					bandWeightMat[np.ix_(cI_inds,cJ_inds)]=clusterDiffMat[cI,cJ]
					bandWeightMat[np.ix_(cJ_inds,cI_inds)]=clusterDiffMat[cI,cJ]
			imHandle=axs[bInd].imshow(bandWeightMat,vmin=np.min(mixtureWeights),vmax=np.max(mixtureWeights),cmap='jet')
			fig.colorbar(imHandle,ax=axs[bInd])
			axs[bInd].set_title("Band: "+bandList[bInd]+", Comp: "+str(myComp),fontsize=15)
		
		plt.savefig(figurePath+"Comp_"+str(myComp)+".png")
		plt.close()

