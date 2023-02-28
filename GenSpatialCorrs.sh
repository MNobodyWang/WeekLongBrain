#!/bin/bash
# Submits slurm batches to do HCP coherency calculations
# Created on 20200804 by Max B Wang

MEG_Dir=/media/mwang/easystore/Processed_Data/

subjList="EP1169 EP1188"

for subjID in ${subjList}; do
	
	python3 Gen_SpatialAutocorrelation.py ${MEG_Dir} ${subjID} 0
	
done
