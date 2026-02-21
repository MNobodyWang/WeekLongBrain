#!/bin/bash
# Submits slurm batches to extract EDF files
# Created on 20200804 by Max B Wang

EDF_Dir="$1"
subjID="$2"

numEDFs=`ls "${EDF_Dir}/${subjID}/EDF/" | wc -l`

for (( i=0; i<${numEDFs}; i++)); do
	
	python3 /home/maxwell.wang/WeekScripts/TestRun/WeekLongBrain-main/ExtractElectrodes.py ${EDF_Dir} ${subjID} ${i} >> "Logs/Extract_${subjID}_${i}.txt" &
	
done
