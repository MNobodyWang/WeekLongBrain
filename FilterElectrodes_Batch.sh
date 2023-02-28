#!/bin/bash
# Filters electrode data
# Created on 20200804 by Max B Wang

Data_Dir=/media/mwang/easystore/Processed_Data/

# EP1165, EP1166, EP1188
subjID="EP1174"
numEDFs=`ls "${Data_Dir}/${subjID}/ElectrodesRaw/" | wc -l`

for (( i=0; i<${numEDFs}; i++)); do
	
	python3 FilterElectrodes.py ${Data_Dir} ${subjID} ${i} 
	
done
