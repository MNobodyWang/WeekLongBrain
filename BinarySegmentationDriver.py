# Runs binary segmentation across subjects
# Created on 20221209 by Max B Wang

import numpy as np
import matplotlib.pylab as plt
import ruptures as rpt
import time
from scipy import io

ECOG_Dir="/media/mwang/easystore/Processed_Data/"

subjList=['EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133','EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165','EP1170','EP1173','EP1166','EP1169','EP1188']
#subjList=['EP1109','EP1111','EP1120','EP1124','EP1142','EP1133','EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165','EP1170','EP1173','EP1166','EP1169','EP1188']
#subjList=['EP1117']

myPen=2

for sInd in range(0,len(subjList)):
	print('Loading '+str(sInd))
	cohDic=io.loadmat(ECOG_Dir+subjList[sInd]+'/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat')
	trimScores=cohDic['trimScores']
	
	useTrials=np.logical_not(np.isnan(trimScores[:,0]))
	
	checkTrials=np.insert(useTrials,[0,len(useTrials)],[False,False])
	startPoints=np.argwhere(np.logical_and(checkTrials[1:],np.logical_not(checkTrials[0:-1])))
	endPoints=np.argwhere(np.logical_and(np.logical_not(checkTrials[1:]),checkTrials[0:-1]))
	
	breakVec=np.zeros(trimScores.shape[0])

	for segInd in range(0,len(startPoints)):
		if endPoints[segInd]-startPoints[segInd]>10:
			print('Finding Breakpoint in Seg '+str(segInd)+' of '+str(len(startPoints)))
			t=time.time()
			segTime=np.arange(int(startPoints[segInd]),int(endPoints[segInd]))
			#breakPoints=rpt.Binseg().fit_predict(signal=trimScores[segTime,:],pen=myPen)
			numBPoints=np.floor((endPoints[segInd]-startPoints[segInd])/(10*60/5))
			breakPoints=rpt.Binseg().fit_predict(signal=trimScores[segTime,:],n_bkps=numBPoints)
			bPoints=np.array(breakPoints)
			breakVec[segTime[bPoints[bPoints<len(segTime)]]]=1
			elapsed=time.time()-t
			print('Done: '+str(elapsed)+' secs elapsed')
	
	mdic={"breakVec":breakVec}

	#io.savemat(ECOG_Dir+subjList[sInd]+'/ChangePoints_Region_Pen_'+str(myPen)+'.mat',mdic)
	io.savemat(ECOG_Dir+subjList[sInd]+'/ChangePoints_PCA_BP_10min.mat',mdic)

	#cohDic=io.loadmat(ECOG_Dir+subjList[sInd]+'/ParcelCoherence_Trimmed.mat')
