# Classify full video annotations
# Created on 20220822 by Max B Wang

import numpy as np
from scipy import io
from sklearn import linear_model
from sklearn import metrics
import shelve
from matplotlib import pyplot as plt

ECOG_Dir="/media/mwang/easystore/Processed_Data/"
Annot_Dir="/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/"

subjList=['EP1117','EP1109','EP1173','EP1124','EP1135','EP1136','EP1137','EP1149','EP1163']
#subjList=['EP1117','EP1109','EP1173','EP1124','EP1135','EP1136','EP1149','EP1163']
#subjList=['EP1117','EP1109','EP1173','EP1124','EP1133','EP1135','EP1136','EP1137','EP1149','EP1163']
#subjList=['EP1117','EP1109','EP1173','EP1124','EP1133','EP1135','EP1136']
#subjList=['EP1137','EP1149','EP1163']

for sInd in range(0,len(subjList)):
	subjID=subjList[sInd]
	print(subjID)
	
	#PC_Data=io.loadmat(ECOG_Dir+subjID+"/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat")
	#trimScores=PC_Data['trimScores']
	
	Coh_Data=io.loadmat(ECOG_Dir+subjID+"/ParcelCoherence_Trimmed.mat")
	nonEpzCoh=Coh_Data['trimParcelCoh']
	epzCoh=Coh_Data['seizureCoherence']
	allCoh=Coh_Data['parcelCoherence']

	trim_PC_Data=io.loadmat(ECOG_Dir+subjID+"/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat")
	passCoefs=trim_PC_Data['passCoefs'].T[0]
	nonEpzScores=trim_PC_Data['trimScores']
	epzScores=trim_PC_Data['allScores'][:,passCoefs==0]
	allScores=trim_PC_Data['allScores']
	
	#classScores=epzCoh
	#outName='_Epz_Coh'

	#classScores=nonEpzCoh
	#outName='_NonEpz_Coh'

	classScores=allCoh
	outName='_All_Coh'
	
	#classScores=epzScores
	#outName='_Epz_PCA'

	#classScores=nonEpzScores
	#outName='_NonEpz_PCA'
	
	#classScores=allScores
	#outName='_All_PCA'

	annotData=io.loadmat(Annot_Dir+subjID+"/FullAnnotationTimeStamps.mat")
	timeInds_A=annotData['timeInds_A']-1
	timeInds_B=annotData['timeInds_B']-1
	labels_A=annotData['labels_A']
	labels_B=annotData['labels_B']

	scores_A=classScores[timeInds_A[0,0]:(timeInds_A[0,1]+1),:]
	scores_B=classScores[timeInds_B[0,0]:(timeInds_B[0,1]+1),:]

	dataMissing_A=np.logical_not(np.isnan(scores_A[:,0]))
	dataMissing_B=np.logical_not(np.isnan(scores_B[:,0]))

	awake_A=dataMissing_A
	awake_B=dataMissing_B
	#awake_A=np.logical_and(labels_A[:,0]==0,dataMissing_A)
	#awake_B=np.logical_and(labels_B[:,0]==0,dataMissing_B)

	#xTr_raw=scores_A[awake_A,:]
	#yTr=labels_A[awake_A,1:]

	#xTe_raw=scores_B[awake_B,:]
	#yTe=labels_B[awake_B,1:]
	
	xTe_raw=scores_A[awake_A,:]
	yTe=labels_A[awake_A,1:]

	xTr_raw=scores_B[awake_B,:]
	yTr=labels_B[awake_B,1:]

	fprs=[]
	tprs=[]
	aucs=[]
	coefs=[]
	tr_aucs=[]
	for labelInd in range(0,yTr.shape[1]):
		#myMdl=linear_model.LassoLars(alpha=0.001)
		
		#myMdl=linear_model.Lasso(alpha=0.00001)

		#myMdl=linear_model.LogisticRegressionCV(penalty='l1',solver='liblinear')
		myMdl=linear_model.LassoCV(tol=1e-3)
		#myMdl=linear_model.LassoCV()
		#myMdl=linear_model.LogisticRegressionCV(penalty='l1',solver='liblinear')
		myMdl.fit(xTr_raw,yTr[:,labelInd])
		
		roc_metrics=metrics.roc_curve(yTe[:,labelInd],myMdl.predict(xTe_raw))
		auc=metrics.roc_auc_score(yTe[:,labelInd],myMdl.predict(xTe_raw))
		fprs.append(roc_metrics[0])
		tprs.append(roc_metrics[1])
		aucs.append(auc)
		
		tr_auc=metrics.roc_auc_score(yTr[:,labelInd],myMdl.predict(xTr_raw))
		tr_aucs.append(tr_auc)
		
		coefs.append(myMdl.coef_)
		
		#allFeats=np.concatenate((xTr_raw,xTe_raw),axis=0)
		#allLabels=np.concatenate((yTr[:,labelInd],yTe[:,labelInd]),axis=0)
		#myMdl.fit(allFeats,allLabels)

		#coefs.append(myMdl.coef_)
	print(aucs)
	print(tr_aucs)
	mdic={"aucs":aucs,"fprs":fprs,"tprs":tprs,"coefs":coefs}

	io.savemat("Data/"+subjID+outName+".mat",mdic)
	#io.savemat("Data/"+subjID+"_ParcelCoherence_RawLogistic.mat",mdic)
