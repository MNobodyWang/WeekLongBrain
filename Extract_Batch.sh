#!/bin/bash
# Batch extract electrodes from all edfs found in folder
# Created on 20200804 by Max B Wang

# This folder should contain individual subfolders, each one corresponding to a single subject
Data_Dir=/media/qSTORAGE/homes/mwang/ECOG_Data/

# Name of the folder belong to the subject you want to process
subjID="EP1174"

numEDFs=`ls "${MEG_Dir}/${subjID}/EDF/" | wc -l`

mkdir Logs

for (( i=0; i<${numEDFs}; i++)); do
	
	python3 ExtractElectrodes.py ${Data_Dir} ${subjID} ${i} >> "Logs/Extract_${subjID}_${i}.txt" &
	
done
