# Uses time series models to predict future neural state 
# Created on 20220816 by Max B Wang
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
import numpy as np
from matplotlib import pyplot as plt
import tensorflow as tf
from sklearn import metrics
from scipy import io
from scipy import stats
import sys
from tensorflow.keras import layers
import time
import ar_models
from koopman_model import koopman_model
from test_model import test_model
from state_kop_mdl import state_kop_mdl
from recurrent_kop_mdl import recurrent_kop_mdl
import shelve

# %%
ECOG_Dir="/media/mwang/easystore/Processed_Data/"
#subjID="EP1111"
subjID=sys.argv[1]

featExp=float(sys.argv[2])
alpha=1
numLayers=0
stepSize=1

numEpochs=5

loss_fn = tf.keras.losses.MeanSquaredError()

PC_Data=io.loadmat(ECOG_Dir+subjID+"/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat")
trimScores=PC_Data['trimScores']

windowSize=60
numTrials=trimScores.shape[0]
numPCs=trimScores.shape[1]
scoreSeries=np.zeros([numTrials-windowSize-stepSize,windowSize+stepSize,numPCs])

for tStart in range(0,numTrials-windowSize-stepSize):
	scoreSeries[tStart,:,:]=trimScores[tStart:(tStart+windowSize+stepSize),:]

nanMask=np.isnan(np.sum(scoreSeries,axis=(1,2)))

x_series=np.delete(scoreSeries,np.argwhere(nanMask),axis=0)

x_tr=tf.cast(x_series[:,0:windowSize,:],tf.float32)
y_tr=tf.cast(x_series[:,-1,:],tf.float32)
y_tr_x=tf.cast(x_series[:,stepSize:,:],tf.float32)

print("Model Parameters: FE_"+str(featExp)+"_A_E"+str(int(-np.log10(alpha)))+"_NL_"+str(numLayers)+"_S_"+str(stepSize))

rec_kop_mdl=recurrent_kop_mdl(numPCs=numPCs,featExp=featExp,alpha=alpha,numLayers=numLayers)
print("Training Recurrent Koopman Model")
rec_kop_mdl.train(x_tr,y_tr,y_tr_x,numEpochs)
print("Getting Dictionary State")
_,_,x_tr_enc=rec_kop_mdl.test(x_tr)

kopStates=np.empty([trimScores.shape[0],x_tr_enc.shape[1]])
kopStates[:]=np.nan

fillStates=np.argwhere(np.logical_not(nanMask)).T[0]+windowSize-1
kopStates[fillStates,:]=x_tr_enc

if not os.path.isdir(ECOG_Dir+subjID+"/KOP_Models"):
	os.makedirs(ECOG_Dir+subjID+"/KOP_Models")	

my_shelf=shelve.open(ECOG_Dir+subjID+"/KOP_Models/RecurrentKoopmanModel_FE_"+str(featExp)+"_A_E"+str(int(-np.log10(alpha)))+"_NL_"+str(numLayers)+"_S"+str(stepSize)+".shelve.out")
my_shelf['kop_mdl_vars']=rec_kop_mdl.kop_model.trainable_variables
my_shelf['enc_mdl_vars']=rec_kop_mdl.enc_model.trainable_variables
my_shelf['dec_mdl_vars']=rec_kop_mdl.dec_model.trainable_variables
my_shelf['kopStates']=kopStates
my_shelf.close()
