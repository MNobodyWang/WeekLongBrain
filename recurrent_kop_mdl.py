# Koopman operator model, single time step, encoder/decoder variant
# Created on 20220815 by Max B Wang

import numpy as np
from matplotlib import pyplot as plt
import tensorflow as tf
from sklearn import metrics
from scipy import io
from scipy import stats
import sys
from tensorflow.keras import layers
import time

class recurrent_kop_mdl:
	def __init__(self,numPCs,featExp=2,alpha=0.1,numLayers=0):
		self.numPCs=numPCs
		self.kop_states=int(featExp*numPCs)
		self.alpha=alpha
		self.numLayers=numLayers

		self.enc_model=self.make_enc_model()
		self.dec_model=self.make_dec_model()
		self.kop_model=self.make_kop_model()

		self.enc_opt = tf.keras.optimizers.Adam(1e-4)
		self.dec_opt = tf.keras.optimizers.Adam(1e-4)
		self.kop_opt = tf.keras.optimizers.Adam(1e-4)
		self.loss_fn = tf.keras.losses.MeanSquaredError()
	
	def make_enc_model(self):
		model = tf.keras.Sequential()
		model.add(layers.LSTM(self.kop_states, return_sequences=False))
		
		for lInd in range(0,self.numLayers):
			model.add(layers.Dense(self.kop_states))
			model.add(layers.ReLU())
			model.add(layers.Dropout(0.1))
		
		model.add(layers.Dense(self.kop_states))

		return model
	
	def make_dec_model(self):
		model = tf.keras.Sequential()
		model.add(layers.Dense(self.kop_states))
		model.add(layers.ReLU())
		model.add(layers.Dropout(0.1))
		
		for lInd in range(0,self.numLayers):
			model.add(layers.Dense(self.kop_states))
			model.add(layers.ReLU())
			model.add(layers.Dropout(0.1))
		
		model.add(layers.Dense(self.numPCs))
		
		return model

	def make_kop_model(self):
		model = tf.keras.Sequential()
		model.add(layers.Dense(int(self.kop_states)))
		
		return model
	
	@tf.function
	def train_step(self,x_tr,y_tr,y_tr_x):
		with tf.GradientTape() as enc_tape, tf.GradientTape() as dec_tape, tf.GradientTape() as kop_tape:
			x_tr_enc = self.enc_model(x_tr)
			y_tr_enc = self.enc_model(y_tr_x)
			
			y_tr_enc_pred = self.kop_model(x_tr_enc)
			
			x_tr_pred = self.dec_model(x_tr_enc)
			#y_tr_pred = self.dec_model(x_tr_enc)
			
			step_loss = self.loss_fn(y_tr_enc,y_tr_enc_pred)+self.alpha*self.loss_fn(x_tr[:,-1,:],x_tr_pred)
			#step_loss = self.loss_fn(y_tr_enc,y_tr_enc_pred)+self.loss_fn(y_tr,y_tr_pred)
			#step_loss = self.loss_fn(y_tr,y_tr_pred)
		
		enc_gradient = enc_tape.gradient(step_loss,self.enc_model.trainable_variables)
		dec_gradient = dec_tape.gradient(step_loss,self.dec_model.trainable_variables)
		kop_gradient = kop_tape.gradient(step_loss,self.kop_model.trainable_variables)
		
		self.enc_opt.apply_gradients(zip(enc_gradient,self.enc_model.trainable_variables))
		self.dec_opt.apply_gradients(zip(dec_gradient,self.dec_model.trainable_variables))
		self.kop_opt.apply_gradients(zip(kop_gradient,self.kop_model.trainable_variables))
		
		return step_loss
	
	@tf.function
	def test(self,x_te):
		x_te_enc = self.enc_model(x_te)
		#y_te_pred = self.dec_model(x_te_enc)
		y_te_enc = self.kop_model(x_te_enc)
		y_te_pred = self.dec_model(y_te_enc)
		
		return y_te_pred,y_te_enc,x_te_enc	
	
	@tf.function
	def eval_state(self,x_te_enc):
		#y_te_pred = self.dec_model(x_te_enc)
		y_te_enc = self.kop_model(x_te_enc)
		y_te_pred = self.dec_model(y_te_enc)
		
		return y_te_pred,y_te_enc	

	def train(self,x_tr,y_tr,y_tr_x,epochs):
		for epoch in range(epochs):
			start=time.time()
			
			batchSize=32
			
			train_dataset = tf.data.Dataset.from_tensor_slices((x_tr,y_tr,y_tr_x))
			train_dataset = train_dataset.shuffle(buffer_size=len(x_tr)).batch(batchSize)
			
			for step,(x_batch_tr,y_batch_tr,y_batch_tr_x) in enumerate(train_dataset):
				self.train_step(x_batch_tr,y_batch_tr,y_batch_tr_x)
				print('Training epoch: '+str(step)+'/'+str(len(train_dataset)),end='\r')

			y_tr_pred,_,_=self.test(x_tr)
			step_loss=self.loss_fn(y_tr,y_tr_pred).numpy()
			
			print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
			
			#if np.mod(epoch,10)==0:
			#	print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
