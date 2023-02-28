% Identify regions that covary together and group them into networks represented by RANSAC PCA
% Created on 20210426 by Max B Wang

% DEFINE SUBJECT ID HERE
subjID='EP1155';

% DEFINE PATH TO ICA CLEANED DATA HERE
ECOG_Dir='/media/mwang/easystore/Processed_Data/';

featClass=2;
bandSelector=1;
useFixed=1;
aCorr=3;

bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};

if useFixed==0
    modifier='NonFixed';
elseif useFixed==1
    modifier='Fixed';
end

if aCorr==3
    corrAppend='_SACorr_Mean';
elseif aCorr==4
    corrAppend='_ECorr_Mean';
end

figurePath=[ECOG_Dir subjID '/'];

VAR_Data=load([figurePath '/ICA_Cleaned' corrAppend '_Features.mat']);

endog=VAR_Data.endog;
presentIdx=nansum(abs(endog))~=0;

%% Divide trials into strata

numTrials=size(endog,1);
blockInds=1:(6*3600/5):numTrials;

numBlockSamples=30*60/5;

numRansacTrials=1000;
ransacDists=zeros(numRansacTrials,numTrials);
trialSampIdx=zeros(numRansacTrials,numTrials);

parfor rTrial=1:numRansacTrials
    sampIdx=zeros(numBlockSamples*(length(blockInds)-1),1);
    
    for dInd=1:length(blockInds)-1
        iStart=(dInd-1)*numBlockSamples+1;
        iEnd=iStart+numBlockSamples-1;
        chunkStart=randsample(blockInds(dInd):(blockInds(dInd+1)-numBlockSamples),1);
        
        sampIdx(iStart:iEnd)=chunkStart:(chunkStart+numBlockSamples-1);
    end
    
    sampleDist=endog(sampIdx,presentIdx);
    nanIdx=isnan(sum(sampleDist,2));
    
    ransacDists(rTrial,:)=mahal(endog(:,presentIdx),sampleDist(~nanIdx,:));
    usedSample=zeros(numTrials,1);
    usedSample(sampIdx)=1;
    trialSampIdx(rTrial,:)=usedSample;
end

disp(['Trials done for ' subjID])

plot(ransacDists(randsample(numRansacTrials,1),:))

%% DECIDE ON A CUTOFF DISTANCE THAT DECIDES OUTLIERS TO EXCLUDE FROM RANSAC PCA
outlierCutoff=500;
[~,bestTrial]=min(sum(ransacDists>outlierCutoff,2));
disp('Cutoff')
plot(ransacDists(bestTrial,:))

%%
useSamples=find(trialSampIdx(bestTrial,:));
disp('Saving')
save([figurePath 'RANSAC_Samples.mat'],'useSamples');

%%
[coeff,~,latent,tsquared,explained,mu] = pca(endog(logical(trialSampIdx(bestTrial,:)),:));
numCompsNeeded=find(cumsum(explained)>=90,1)
score=endog*coeff;

%%

useComps=[1:numCompsNeeded];

useScores=score(:,useComps);
useCoefs=coeff(:,useComps);
feature_coefs=VAR_Data.feature_coefs;

%%

save([figurePath 'RANSAC_PCA_' modifier corrAppend '.mat'],'useScores','useCoefs','feature_coefs','mu');

