Week-long data processing guide. This assumes both Python3 and MATLAB are installed and are running on a Linux system.

1) Obtain neural recordings in EDF-Plus format. This format can be exported from NATUS systems and likely other commonly used systems. For us, this resulted in one EDF file for each day of data which we placed into a single directory. Denote this directory as

DATA_Dir: directory all subjects go into
SUBJ_ID: ID code for a single subject

EDFs go into DATA_DIR/SUBJ_ID/EDF/

2) Convert EDF file data into indivudal .mat files for each electrode. Run Extract_Batch.sh after modifying the first few lines for the relevant paths. This should generate a folder:

DATA_DIR/SUBJ_ID/ElectrodesRaw

that contains multiple folders, each one corresponding to a single edf file. Each folder should contain several .mat files for each electrode found in the EDF

3) Filter electrodes and afterwards split them into five second trials. Run Filter_Batch.sh after modifying the relevant paths. This should generate a folder

DATA_DIR/SUBJ_ID/Electrode_Trials

that should contain multiple folders corresponding to each day (or whatever one EDF represents for you) of data. Each folder should contain many subfolders, each corresponding to one five second trial that contains Filtered_Trial.mat

4) Identify a consistent set of electrodes across all days of data. Run ElectrodeIndexer.py after modifying for the appropriate paths. This should create electrodeIndexing.npz in DATA_DIR/SUBJ_ID/

5) Use pre-operative imaging in whatever pipeline your lab has to identify the MNI locations of each electrode. Save them in the same order as in electrodeIndexing.npz as

DATA_DIR/SUBJ_ID/universalElectrodes_MNI.mat

as the variable mni_electrode_coordinates

5) Identify spatial autocorrelations to remove from the data. Run 

python3 Gen_SpatialAutocorrelation.py SUBJ_ID 0 

after modifying for the appropriate paths. This should create 

DATA_DIR/SUBJ_ID/Trial_Coherence/Spatial_Autocorrelation_Mean.npz

6) Generate coherence matrices for each five second trial by running GenCohMats_Batch.sh after modifying the relevant paths. This should create folders inside

DATA_DIR/SUBJ_ID/Trial_Coherence/EDF_LABEL/Trial_1/*npz

that correspond to the coherence matrix for that trial

7) Group electrodes into regions using Leiden algorithm. Run

python3 universal_Leiden.py SUBJ_ID 1 3

after modifying the paths. This should create

DATA_DIR/SUBJ_ID/Communities/UniversalGlobalModularityCommunities_Coherence_Rough_SACorr_mean.csv

8) Average coherence within each region and save them across the week as a single file. Go to and edit Coherence_Compressor.py. Go to line 39, add in your subject ID in the same format as the couple templates I left there. The groupList is the list of EDFs files in chronological order. breakLength is the number of empty five second trials to insert between EDFs if there are breaks between your EDF files. Then run

python3 Coherence_Compressor.py SUBJ_ID

This should generate ClusCoherence_AllTrials_RoughNonFixed_SACorr_Mean wherever you've defined the write directory (which can be the same as the read directory if you wish)

9) Remove ICA components that you'll visually inspect to look for artifacts. First, run

python3 Gen_ICA_Comps.py SUBJ_ID

after modifying the data directory (MEG_Dir). This will generate

DATA_DIR/SUBJ_ID/ICA/FastICA_Comp40_RoughFixed_*_shelve.out

Then run

python3 ICA_Analyzer.py SUBJ_ID

after modifying the data directory again. This will generate a folder

DATA_DIR/SUBJ_ID/ICA/Figures_RoughFixed_SACorr_Mean/*png

that will contain information about each ICA component. Decide if any of them look overly suspicious, then go and edit ICA_Cleaner.py at line 45 to add in your subject ID and the ICA components you want to remove. Then run

python3 ICA_Cleaner.py SUBJ_ID

with the directory modifications. Then run

python3 Save_ICA_Mats.py SUBJ_ID

to save the ICA-cleaned region coherence over times in .mat format

10) Identify networks of regions that covary together using RANSAC PCA. Run RandomConsensus_PCA.m block by block, inspecting the plots and deciding on cutoffs for outlier exclusion manually for each subject.

11) Remove time periods involving seizures and networks with significant similarity to seizure network. First, you will need to remove periods of times surrounding seizures. PcaSeizureTrim_EP1109.m gives an example of how we did this, but in general, you will need to figure out how to time register when seizures occur to your dataset. On our dataset, we consistently had a couple minutes break between ``days'' of data so I placed several NaNs between days to represent those breaks. I used those NaNs to register real-world time to the electrode data.

Afterwards, remove networks that show statistically significant similarity to the seizure network. Go to PCA_SeizureNetworkRemoval.m, modify the paths and subject lists, and for each subject, add in which electrodes are part of the seizure network and then run.

This time registration is also what you will need to do if you want to link behavioral data or other collected non-neural data to your neural data

Other scripts:

BinarySegmentationDriver.py: find changepoints in network activations using binary segmentation

RecurrentKOP_SaveState.py: train recurrent neural network/Koopman model on network activations and export both the model variables (network layer weights/Koopman operator) and the Koopman state at each point in time
-koopman_model,test_model.py,state_kop_mdl,recurrent_kop_mdl: helper files containing class definitions. I'm 99% convinced that only the last one is actually needed (former ones I was just using for debugging, but I included all of them in case I accidentally left a dependency somewhere)

