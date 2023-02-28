#!/bin/bash
# Submits slurm batches to do HCP coherency calculations
# Created on 20200804 by Max B Wang

MEG_Dir=/media/mwang/easystore/Processed_Data/

subjID="EP1188"
numEDFs=`ls "${MEG_Dir}/${subjID}/Electrode_Trials/" | wc -l`

for (( i=0; i<${numEDFs}; i++)); do
	
	python3 GenCohMats.py ${subjID} ${i} 3 0 0 >> "Logs/Coh_${subjID}_${i}_SACorr.txt" &
	
done
