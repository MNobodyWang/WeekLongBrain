import numpy as np
from matplotlib import pyplot as plt
import tensorflow as tf
from sklearn import metrics
from scipy import io
from scipy import stats
import sys
from tensorflow.keras import layers
import time

class test_model:
	def __init__(self,numPCs):
		self.numPCs=numPCs
		
		self.edmd_model=self.make_edmd_model()
		self.edmd_opt = tf.keras.optimizers.Adam(1e-3)
		self.loss_fn = tf.keras.losses.MeanSquaredError()

	def make_edmd_model(self):
		edmd_in=tf.keras.layers.Input(shape=(self.numPCs),name='singleton_in')
		nextLayer=layers.Dense(self.numPCs,activation='relu')(edmd_in)
		nextLayer=layers.Dropout(0.1)(nextLayer)
		nextLayer=layers.Dense(self.numPCs,activation='relu')(nextLayer)
		nextLayer=layers.Dropout(0.1)(nextLayer)
		nextLayer=layers.Dense(self.numPCs,activation='relu')(nextLayer)
		nextLayer=layers.Dropout(0.1)(nextLayer)
		nextLayer=layers.Dense(self.numPCs,activation='relu')(nextLayer)
		nextLayer=layers.Dropout(0.1)(nextLayer)
		nextLayer=layers.Dense(self.numPCs,activation='relu')(nextLayer)
		nextLayer=layers.Dropout(0.1)(nextLayer)
		nextLayer=layers.Dense(int(self.numPCs),activation='relu')(nextLayer)
		nextLayer=layers.Concatenate(axis=-1)([edmd_in,nextLayer])
		edmd_target=layers.Dense(self.numPCs)(nextLayer)

		edmd_mdl=tf.keras.models.Model(inputs=edmd_in,outputs=edmd_target)
		
		return edmd_mdl
	
	@tf.function
	def train_step(self,x_tr,y_tr):
		with tf.GradientTape() as edmd_tape:
			y_tr_pred = self.edmd_model(x_tr)
			
			step_loss = self.loss_fn(y_tr_pred,y_tr)
		
		edmd_gradient=edmd_tape.gradient(step_loss,self.edmd_model.trainable_variables)
		self.edmd_opt.apply_gradients(zip(edmd_gradient,self.edmd_model.trainable_variables))
		
		return step_loss
	
	@tf.function
	def test(self,x_te):
		y_te_pred = self.edmd_model(x_te)
		
		return y_te_pred	

	def train(self,x_tr,y_tr,epochs):
		for epoch in range(epochs):
			start=time.time()
			
			batchSize=32
			
			train_dataset = tf.data.Dataset.from_tensor_slices((x_tr,y_tr))
			train_dataset = train_dataset.shuffle(buffer_size=len(x_tr)).batch(32)
			
			for step,(x_batch_tr,y_batch_tr) in enumerate(train_dataset):
				self.train_step(x_batch_tr,y_batch_tr)
				print('Training epoch: '+str(step)+'/'+str(len(train_dataset)),end='\r')

			#for trInd in range(0,numTrials):
			#	startInd=int(trInd*batchSize)
			#	endInd=int(np.max([startInd+batchSize,x_tr.shape[0]]))
			#	self.train_step(x_tr[startInd:endInd,:],y_tr[startInd:endInd,:])

			#	print('Training epoch: '+str(trInd)+'/'+str(numTrials),end='\r')

			y_tr_pred=self.test(x_tr)
			step_loss=self.loss_fn(y_tr,y_tr_pred).numpy()
			
			print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
			
			#if np.mod(epoch,10)==0:
			#	print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
