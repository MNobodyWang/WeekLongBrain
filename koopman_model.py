import numpy as np
from matplotlib import pyplot as plt
import tensorflow as tf
from sklearn import metrics
from scipy import io
from scipy import stats
import sys
from tensorflow.keras import layers
import time

class koopman_model:
	def __init__(self,numPCs):
		self.numPCs=numPCs
		self.extra_states=int(numPCs/2)
		
		self.dict_model=self.make_dict_model()
		self.kop_model=self.make_kop_model()

		self.dict_opt = tf.keras.optimizers.Adam(1e-3)
		self.kop_opt = tf.keras.optimizers.Adam(1e-3)
		self.loss_fn = tf.keras.losses.MeanSquaredError()
	
	def make_dict_model(self):
		model = tf.keras.Sequential()
		model.add(layers.Dense(self.numPCs, input_shape=(self.numPCs,)))
		model.add(layers.ReLU())
		model.add(layers.Dropout(0.1))
		
		model.add(layers.Dense(self.numPCs))
		model.add(layers.ReLU())
		model.add(layers.Dropout(0.1))
		
		model.add(layers.Dense(self.numPCs))
		model.add(layers.ReLU())
		model.add(layers.Dropout(0.1))
		
		model.add(layers.Dense(int(self.extra_states)))
		model.add(layers.ReLU())
		
		return model

	def make_kop_model(self):
		model = tf.keras.Sequential()
		model.add(layers.Dense(self.numPCs+int(self.extra_states)))
		
		return model
	
	@tf.function
	def train_step(self,x_tr,y_tr):
		with tf.GradientTape() as dict_tape, tf.GradientTape() as kop_tape:
			x_tr_dict = self.dict_model(x_tr)
			x_tr_state = tf.concat([x_tr,x_tr_dict],1)
			
			y_tr_pred = self.kop_model(x_tr_state)
			y_tr_dict = self.dict_model(y_tr)
			y_tr_state = tf.concat([y_tr,y_tr_dict],1)
			
			step_loss = self.loss_fn(y_tr_pred,y_tr_state)
			#step_loss = self.loss_fn(y_tr_pred[:,0:self.numPCs],y_tr_state[:,0:self.numPCs])
		
		dict_gradient = dict_tape.gradient(step_loss,self.dict_model.trainable_variables)
		kop_gradient = kop_tape.gradient(step_loss,self.kop_model.trainable_variables)
		
		self.dict_opt.apply_gradients(zip(dict_gradient,self.dict_model.trainable_variables))
		self.kop_opt.apply_gradients(zip(kop_gradient,self.kop_model.trainable_variables))
		
		return step_loss
	
	@tf.function
	def test(self,x_te):
		x_te_dict = self.dict_model(x_te)
		x_te_state = tf.concat([x_te,x_te_dict],1)
		
		y_te_pred_state = self.kop_model(x_te_state)
		y_te_pred=y_te_pred_state[:,0:self.numPCs]
		
		return y_te_pred	

	@tf.function
	def return_state(self,x_te):
		x_te_dict = self.dict_model(x_te)
		x_te_state = tf.concat([x_te,x_te_dict],1)

		return x_te_state

	@tf.function
	def state_evolution(self,x_te_state):
		y_te_pred_state = self.kop_model(x_te_state)

		return y_te_pred_state

	def train(self,x_tr,y_tr,epochs):
		for epoch in range(epochs):
			start=time.time()
			
			batchSize=32
			
			train_dataset = tf.data.Dataset.from_tensor_slices((x_tr,y_tr))
			train_dataset = train_dataset.shuffle(buffer_size=len(x_tr)).batch(32)
			
			for step,(x_batch_tr,y_batch_tr) in enumerate(train_dataset):
				self.train_step(x_batch_tr,y_batch_tr)
				print('Training epoch: '+str(step)+'/'+str(len(train_dataset)),end='\r')

			y_tr_pred=self.test(x_tr)
			step_loss=self.loss_fn(y_tr,y_tr_pred).numpy()
			
			print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
			
			#if np.mod(epoch,10)==0:
			#	print("Epoch "+str(epoch)+" of "+str(epochs)+", Loss "+str(step_loss))
