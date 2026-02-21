% Generate Figure 3 main results
% Created on 20260210 by Max B Wang

%% Distance vs displacement of transitions
subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
    'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
    'EP1170','EP1173','EP1166','EP1169','EP1188'};

%% Generate data files for each participant individually (which would require data across all 20 participants)
% displacementList=cell(length(subjList),1);
% distanceList=cell(length(subjList),1);
% 
% displacementList_Euc=cell(length(subjList),1);
% distanceList_Euc=cell(length(subjList),1);
% 
% displacementListState_Euc=cell(length(subjList),1);
% distanceListState_Euc=cell(length(subjList),1);
% 
% for sInd=1:length(subjList)
%     % sInd=1;
%     disp(sInd)
% 
%     subjID=subjList{sInd};
%     featClass=2;
%     bandSelector=1;
%     useFixed=1;
%     aCorr=3;
% 
%     if aCorr==1
%         append='';
%     elseif aCorr==2
%         append='_ECorr';
%     elseif aCorr==3
%         append='_Fixed_SACorr_Mean';
%     end
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
%     figurePath=[ECOG_Dir subjID '/'];
% 
% %     PCA_Data=load([figurePath 'VAR_RANSAC_Comps' append '.mat']);
%     PCA_Data=load([figurePath 'RANSAC_PCA' append '_Trimmed.mat']);
%     useScores=PCA_Data.trimScores;
% 
%     % smoothWindows=[30*60/5];
%     smoothWindows=[10*60/5];
%     windowInd=1;
% 
%     sampleMissing=isnan(sum(useScores,2));
% 
%     smoothScores=movmean(useScores,smoothWindows(windowInd),'omitnan');
%     smoothScores(sampleMissing,:)=NaN;
% 
%     ogSmoothScores=smoothScores;
% 
%     % Normalize scores
%     for scoreInd=1:size(smoothScores,2)
%         %     smoothScores(:,scoreInd)=smoothScores(:,scoreInd)-min(smoothScores(:,scoreInd));
%         %     smoothScores(:,scoreInd)=smoothScores(:,scoreInd)/max(smoothScores(:,scoreInd));
% 
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)-quantile(smoothScores(:,scoreInd),0.05);
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)/quantile(smoothScores(:,scoreInd),0.95);
%         %     smoothScores(~sampleMissing,scoreInd)=zscore(smoothScores(~sampleMissing,scoreInd));
%     end
% 
%     smoothScores(smoothScores<0)=0;
%     smoothScores(smoothScores>1)=1;
% 
%     timeInds=(1:size(smoothScores,1))*5/3600;
%     smoothScores=smoothScores./repmat(sum(smoothScores,2),1,size(smoothScores,2));
% 
%     projWeight=smoothScores;
%     %
%     speedVec=zeros(size(projWeight,1)-1,1);
%     speedVec_H=zeros(size(projWeight,1)-1,1);
%     speedVec_Euc=zeros(size(projWeight,1)-1,1);
% 
%     for tInd=1:length(speedVec)
%         speedVec(tInd)=bc_dist(projWeight(tInd,:),projWeight(tInd+1,:));
%         speedVec_H(tInd)=hellinger_dist(projWeight(tInd,:),projWeight(tInd+1,:));
% 
%         speedVec_Euc(tInd)=pdist2(ogSmoothScores(tInd,:),ogSmoothScores(tInd+1,:));
%     end
% 
%     speedSmoothWindows=[1 6 12];
% 
%     smoothedSpeed=zeros(length(speedVec_H),length(speedSmoothWindows));
%     smoothedSpeedQuantiles=zeros(length(speedVec_H),length(speedSmoothWindows));
%     for wInd=1:length(speedSmoothWindows)
%         smoothedSpeed(:,wInd)=movmean(speedVec_H,speedSmoothWindows(wInd));
% 
%         [cdfY,cdfX]=ecdf(smoothedSpeed(:,wInd));
%         [~,useCDF]=unique(cdfX);
%         smoothedSpeedQuantiles(:,wInd)=interp1(cdfX(useCDF),cdfY(useCDF),smoothedSpeed(:,wInd));
%     end
% 
%     fastSegs=(smoothedSpeedQuantiles(:,1)>0.95 | ...
%         smoothedSpeedQuantiles(:,2)>0.85) | ...
%         smoothedSpeedQuantiles(:,3)>0.8;
% 
%     fastSegs(movmean(fastSegs,12*5)>0)=1;
% 
%     fastSegs(1)=0;
%     fastSegs(end)=0;
%     % subplot(2,1,1)
%     % plot(timeInds(1:end-1),speedVec_H)
%     % xlabel('Time (hrs)')
%     % ylabel('Hellinger Speed')
%     % set(gca,'FontSize',15)
% 
%     % Grab trajectories of extended variability
%     numTrajectories=sum((fastSegs(2:end)-fastSegs(1:end-1))<0);
% 
%     trajEndpoints=zeros(numTrajectories,2);
%     trajEndpoints(:,1)=find((fastSegs(2:end)-fastSegs(1:end-1))>0);
%     trajEndpoints(:,2)=find((fastSegs(2:end)-fastSegs(1:end-1))<0);
% 
%     furthestPoint=zeros(numTrajectories,1);
% 
%     for trajInd=1:numTrajectories
%         furthestPoint(trajInd)=max(hellinger_dist(smoothScores(trajEndpoints(trajInd,1),:),...
%             smoothScores(trajEndpoints(trajInd,1):trajEndpoints(trajInd,2),:)));
%     end
% 
%     trajEndpoints=trajEndpoints(furthestPoint>quantile(furthestPoint,0.75),:);
%     numTrajectories=size(trajEndpoints,1);
% 
%     trajDiplacement=zeros(numTrajectories,1);
%     trajDistance=zeros(numTrajectories,1);
% 
%     trajDiplacement_Euc=zeros(numTrajectories,1);
%     trajDistance_Euc=zeros(numTrajectories,1);
% 
%     trajDiplacementState_Euc=zeros(numTrajectories,1);
%     trajDistanceState_Euc=zeros(numTrajectories,1);
% 
%     startState=zeros(numTrajectories,size(projWeight,2));
%     endState=zeros(numTrajectories,size(projWeight,2));
% 
%     startState_Og=zeros(numTrajectories,size(ogSmoothScores,2));
%     endState_Og=zeros(numTrajectories,size(ogSmoothScores,2));
% 
%     for trajInd=1:size(trajEndpoints,1)
%         startState(trajInd,:)=projWeight(trajEndpoints(trajInd,1),:);
%         endState(trajInd,:)=projWeight(trajEndpoints(trajInd,2)+1,:);
% 
%         startState_Og(trajInd,:)=ogSmoothScores(trajEndpoints(trajInd,1),:);
%         endState_Og(trajInd,:)=ogSmoothScores(trajEndpoints(trajInd,2)+1,:);
%     end
% 
%     stateInds=find(~fastSegs(1:end-1));
%     timeInState=zeros(length(stateInds),1);
% 
%     inTraj=find(fastSegs | isnan(fastSegs));
% 
%     for tInd=1:length(timeInState)
%         nextTraj=inTraj(find((inTraj-stateInds(tInd))>0,1));
% 
%         if isempty(nextTraj)
%             timeInState(tInd)=length(fastSegs)-stateInds(tInd);
%         else
%             timeInState(tInd)=nextTraj-stateInds(tInd);
%         end
%     end
%     maxStateLength=max(timeInState);
% 
%     for trajInd=1:numTrajectories
%         trajDiplacement(trajInd)=hellinger_dist(startState(trajInd,:),endState(trajInd,:));
% 
%         trajDistance(trajInd)=nansum(speedVec_H(trajEndpoints(trajInd,1):...
%             (trajEndpoints(trajInd,2)+1)));
% 
%         trajDiplacement_Euc(trajInd)=pdist2(startState_Og(trajInd,:),endState_Og(trajInd,:));
%         trajDistance_Euc(trajInd)=nansum(speedVec_Euc(trajEndpoints(trajInd,1):...
%             (trajEndpoints(trajInd,2)+1)));
% 
%         trajLength=trajEndpoints(trajInd,2)-trajEndpoints(trajInd,1);
% 
%         if trajLength>maxStateLength
%             trajLength=maxStateLength-5;
%         end
% 
%         tStart=randsample(stateInds(timeInState>trajLength),1);
%         tEnd=tStart+trajLength;
% 
%         trajDiplacementState_Euc(trajInd)=...
%             pdist2(ogSmoothScores(tStart,:),ogSmoothScores(tEnd,:));
% 
%         trajDistanceState_Euc(trajInd)=nansum(speedVec_Euc(tStart:tEnd));
%     end
% 
%     displacementList{sInd}=trajDiplacement;
%     distanceList{sInd}=trajDistance;
% 
%     displacementList_Euc{sInd}=trajDiplacement_Euc;
%     distanceList_Euc{sInd}=trajDistance_Euc;
% 
%     displacementListState_Euc{sInd}=trajDiplacementState_Euc;
%     distanceListState_Euc{sInd}=trajDistanceState_Euc;
% end

%% Load intermediate files from each participant
load('Data/Fig3_IntermediateData.mat','displacementList','distanceList',...
    'displacementList_Euc','distanceList_Euc',...
    'displacementListState_Euc','distanceListState_Euc');

displacementMeans=zeros(length(subjList),1);
displacementSE=zeros(length(subjList),1);

distanceMeans=zeros(length(subjList),1);
distanceSE=zeros(length(subjList),1);

distanceStateMeans=zeros(length(subjList),1);
distanceStateSE=zeros(length(subjList),1);

displacementStateMeans=zeros(length(subjList),1);
displacementStateSE=zeros(length(subjList),1);

for sInd=1:length(subjList)
    displacementMeans(sInd)=nanmean(displacementList_Euc{sInd});
    displacementSE(sInd)=1.96*nanstd(displacementList_Euc{sInd})/sqrt(length(displacementList_Euc{sInd}));
    
    distanceMeans(sInd)=nanmean(distanceList_Euc{sInd});
    distanceSE(sInd)=1.96*nanstd(distanceList_Euc{sInd})/sqrt(length(displacementList_Euc{sInd}));
    
    displacementStateMeans(sInd)=nanmean(displacementListState_Euc{sInd});
    displacementStateSE(sInd)=1.96*nanstd(displacementListState_Euc{sInd})/sqrt(length(displacementList_Euc{sInd}));
    
    distanceStateMeans(sInd)=nanmean(distanceListState_Euc{sInd});
    distanceStateSE(sInd)=1.96*nanstd(distanceListState_Euc{sInd})/sqrt(length(displacementList_Euc{sInd}));
end

subjData=[displacementMeans distanceMeans displacementStateMeans distanceStateMeans];

%%

bar(mean(subjData)); hold on
var_a=std(subjData(:,2)-subjData(:,1))*1.96/sqrt(20);
var_b=std(subjData(:,4)-subjData(:,3))*1.96/sqrt(20);

ci=std(subjData)*1.96/sqrt(20);
errorbar(1:4,mean(subjData),ci,'kx','LineWidth',1.5,'CapSize',45,'MarkerEdgeColor','k')
set(gcf,'Color','w')
xlim([0.5 4.5])
xticks(1:4)
xticklabels({'Transition\newlineDisplacement','Transition\newlineDistance','State\newlineDisplacement','State\newlineDistance'})
ylabel('Euclidean Distance')
title('Distance vs Displacement of transitions over participants')
set(gca,'FontSize',15)

f=gcf;
f.Theme="light";

%% Create statistics on change points dependent on how they relate to behavioral transitions
% load('Data/20221228_BurstDistribution_PCA_BP_10min.mat','subjList','displacementList_Euc','distanceList_Euc','trajEndPointList')
% load('Data/20220518_ChaosSpeed.mat','chaosSegList')
% 
% fastSegList=cell(length(annotList),1);
% speedList=cell(length(annotList),1);
% stateList=cell(length(annotList),1);
% chaosList=cell(length(annotList),1);
% 
% for sInd=1:length(annotList)
%     disp(sInd)
%     subjID=annotList{sInd};
%     allInd=find(strcmp(subjList,subjID),1);
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     dataPath=[ECOG_Dir subjID '/'];
% 
%     Coh_Data=load([dataPath '/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores');
%     trimScores=Coh_Data.trimScores;
%     featureMat=trimScores;
% 
%     speedVec=zeros(size(featureMat,1)-1,1);
% 
%     for tInd=1:length(speedVec)
%         speedVec(tInd)=pdist2(featureMat(tInd,:),featureMat(tInd+1,:));
%     end
% 
%     fastSegs=zeros(size(featureMat,1)-1,1);
% 
%     subjEndPoints=trajEndPointList{allInd};
% 
%     for eInd=1:size(subjEndPoints,1)
%         fastSegs(subjEndPoints(eInd,1):subjEndPoints(eInd,2))=1;
%     end
% 
%     fastSegList{sInd}=fastSegs;
%     speedList{sInd}=speedVec;
%     stateList{sInd}=featureMat;
% 
%     % Unpack chaos vec
%     segLength=10*60/5;
%     myChaosSeg=chaosSegList{allInd};
% 
%     chaosVec=nan(size(featureMat,1),1);
% 
%     for segInd=1:length(myChaosSeg)
%         tStart=(segInd-1)*segLength+1;
%         tEnd=tStart+segLength-1;
% 
%         chaosVec(tStart:tEnd)=myChaosSeg(segInd);
%     end
% 
%     chaosList{sInd}=chaosVec;
% end
% 
% changePoint_Statistics=cell(length(annotList),5); 
% % Time between behavior and neural transition, Distance, Displacement,
% % Chaos, Length
% 
% for sInd=1:length(annotList)
%     disp(sInd)
%     subjID=annotList{sInd};
% 
%     anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
% 
%     load([anotDir 'FullAnnotationTimeStamps.mat'],'timeInds_A','timeInds_B','labels_A','labels_B')
% 
%     fastSegs=fastSegList{sInd};
%     speedVec=speedList{sInd};
%     featureMat=stateList{sInd};
%     chaosVec=chaosList{sInd};
% 
%     fastSeg_A=fastSegs(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
%     bChange_A=sum(abs(labels_A(2:end,:)-labels_A(1:end-1,:)),2)>0;
%     speedVec_A=speedVec(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
%     featureMat_A=featureMat(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
%     chaosVec_A=chaosVec(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% 
%     remove_A=isnan(speedVec_A);
%     fastSeg_A(remove_A(1:length(fastSeg_A)))=[];
%     bChange_A(remove_A(1:length(bChange_A)))=[];
%     speedVec_A(remove_A(1:length(speedVec_A)))=[];
%     featureMat_A(remove_A(1:length(speedVec_A)),:)=[];
%     chaosVec_A(remove_A(1:length(speedVec_A)),:)=[];
% 
%     fastSeg_B=fastSegs(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
%     bChange_B=sum(abs(labels_B(2:end,:)-labels_B(1:end-1,:)),2)>0;
%     speedVec_B=speedVec(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
%     featureMat_B=featureMat(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
%     chaosVec_B=chaosVec(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% 
%     remove_B=isnan(speedVec_B);
%     fastSeg_B(remove_B(1:length(fastSeg_B)))=[];
%     bChange_B(remove_B(1:length(bChange_B)))=[];
%     speedVec_B(remove_B(1:length(speedVec_B)))=[];
%     featureMat_B(remove_B(1:length(speedVec_B)),:)=[];
%     chaosVec_B(remove_B(1:length(speedVec_B)),:)=[];
% 
%     bCPoints_A=find(bChange_A);
%     fPoints_A=find(fastSeg_A);
%     distToFast_A=zeros(length(bCPoints_A),1);
%     distance_neuralTransition_A=zeros(length(bCPoints_A),1);
%     displacement_neuralTransition_A=zeros(length(bCPoints_A),1);
%     chaos_neuralTransition_A=zeros(length(bCPoints_A),1);
%     length_A=zeros(length(bCPoints_A),1);
% 
%     for bInd=1:length(bCPoints_A)
%         [~,minInd]=min(abs(bCPoints_A(bInd)-fPoints_A));
%         distToFast_A(bInd)=bCPoints_A(bInd)-fPoints_A(minInd);
% 
%         leadFastSegs=fastSeg_A(1:fPoints_A(minInd));
%         nTrans_start=find((leadFastSegs(2:end)-leadFastSegs(1:end-1))==1,1,'last')+1;
% 
%         trailFastSegs=fastSeg_A(fPoints_A(minInd):end);
%         nTrans_end=find((trailFastSegs(2:end)-trailFastSegs(1:end-1))==-1,1,'first')+fPoints_A(minInd)-1;
% 
%         if isempty(nTrans_start)
%             nTrans_start=1;
%         end
% 
%         if isempty(nTrans_end)
%             nTrans_end=length(fastSeg_A);
%         end
% 
%         distance_neuralTransition_A(bInd)=sum(speedVec_A(nTrans_start:nTrans_end));
%         displacement_neuralTransition_A(bInd)=pdist2(featureMat_A(nTrans_start,:),featureMat_A(nTrans_end,:));
%         chaos_neuralTransition_A(bInd)=nanmean(chaosVec_A(nTrans_start:nTrans_end));
%         length_A(bInd)=nTrans_end-nTrans_start;
%     end
% 
%     bCPoints_B=find(bChange_B);
%     fPoints_B=find(fastSeg_B);
%     distToFast_B=zeros(length(bCPoints_B),1);
%     distance_neuralTransition_B=zeros(length(bCPoints_B),1);
%     displacement_neuralTransition_B=zeros(length(bCPoints_B),1);
%     chaos_neuralTransition_B=zeros(length(bCPoints_B),1);
%     length_B=zeros(length(bCPoints_B),1);
% 
%     for bInd=1:length(bCPoints_B)
%         [~,minInd]=min(abs(bCPoints_B(bInd)-fPoints_B));
%         distToFast_B(bInd)=bCPoints_B(bInd)-fPoints_B(minInd);
% 
%         leadFastSegs=fastSeg_B(1:fPoints_B(minInd));
%         nTrans_start=find((leadFastSegs(2:end)-leadFastSegs(1:end-1))==1,1,'last')+1;
% 
%         trailFastSegs=fastSeg_B(fPoints_B(minInd):end);
%         nTrans_end=find((trailFastSegs(2:end)-trailFastSegs(1:end-1))==-1,1,'first')+fPoints_B(minInd)-1;
% 
%         if isempty(nTrans_start)
%             nTrans_start=1;
%         end
% 
%         if isempty(nTrans_end)
%             nTrans_end=length(fastSeg_B);
%         end
% 
%         distance_neuralTransition_B(bInd)=sum(speedVec_B(nTrans_start:nTrans_end));
%         displacement_neuralTransition_B(bInd)=pdist2(featureMat_B(nTrans_start,:),featureMat_B(nTrans_end,:));
%         chaos_neuralTransition_B(bInd)=nanmean(chaosVec_B(nTrans_start:nTrans_end));
%         length_B(bInd)=nTrans_end-nTrans_start;
%     end
% 
%     changePoint_Statistics{sInd,1}=[distToFast_A;distToFast_B];
%     changePoint_Statistics{sInd,2}=[distance_neuralTransition_A;distance_neuralTransition_B];
%     changePoint_Statistics{sInd,3}=[displacement_neuralTransition_A;displacement_neuralTransition_B];
%     changePoint_Statistics{sInd,4}=[chaos_neuralTransition_A;chaos_neuralTransition_B];
%     changePoint_Statistics{sInd,5}=[length_A;length_B];
% end

%% 
load('Data/Fig3_IntermediateData.mat','displacementList','distanceList',...
    'displacementList_Euc','distanceList_Euc','displacementListState_Euc',...
    'distanceListState_Euc','changePoint_Statistics');

annotList={'EP1117','EP1109','EP1173','EP1124','EP1135','EP1136','EP1137','EP1149','EP1163'};

dvdRatios=zeros(length(annotList),2);
chaosLevel=zeros(length(annotList),2);
leadPercentage=zeros(length(annotList),1);
timeBetween=zeros(length(annotList),1);
transitionLength=zeros(length(annotList),2);

for sInd=1:length(annotList)
    myDistToFast=changePoint_Statistics{sInd,1};
    myDistance=changePoint_Statistics{sInd,2};
    myDisplacement=changePoint_Statistics{sInd,3};
    myChaos=changePoint_Statistics{sInd,4};
    myLength=changePoint_Statistics{sInd,5};
    myLength(myLength>16)=NaN;
    
    closeInds=abs(myDistToFast)<5;
    myQuantiles=quantile(myDistToFast(closeInds),[1/3 2/3]);
    
    neuralLeadInds=and(myDistToFast>=myQuantiles(2),myDistToFast<5);
    neuralLagInds=and(myDistToFast<myQuantiles(1),myDistToFast>-5);
    
%     neuralLeadInds=and(myDistToFast>=0,myDistToFast<5);
%     neuralLagInds=and(myDistToFast<0,myDistToFast>-5);
    
    dvdRatios(sInd,1)=nanmedian(myDistance(neuralLeadInds)./myDisplacement(neuralLeadInds))/4;
    dvdRatios(sInd,2)=nanmedian(myDistance(neuralLagInds)./myDisplacement(neuralLagInds))/4;
    
    chaosLevel(sInd,1)=nanmedian(myChaos(neuralLeadInds));
    chaosLevel(sInd,2)=nanmedian(myChaos(neuralLagInds));
    
    leadPercentage(sInd)=mean(myDistToFast>=0);
    timeBetween(sInd)=mean(myDistToFast);
    
    transitionLength(sInd,1)=nanmedian(myLength(neuralLeadInds));
    transitionLength(sInd,2)=nanmean(myLength(neuralLagInds));
end

%%
figure
subplot(1,2,1)
errorBound=1.96*std(dvdRatios(:,1)-dvdRatios(:,2))/sqrt(length(dvdRatios))/2;
errorbar(mean(dvdRatios),[errorBound errorBound],'x','Color','k','LineWidth',2,'CapSize',20,'MarkerSize',20)
xticks([1 2])
xlim([0.75 2.25])
ylim([0 16])
xticklabels({'Late behavior\newlineonset','Early behavior\newlineonset'})
ylabel('Distance to displacement ratio')
set(gca,'FontSize',17)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.03 0.03])
box off

subplot(1,2,2)
errorBound=1.96*std(chaosLevel(:,1)-chaosLevel(:,2))/sqrt(length(chaosLevel))/2;
errorbar(mean(chaosLevel),[errorBound errorBound],'x','Color','k','LineWidth',2,'CapSize',20,'MarkerSize',20)
xticks([1 2])
yticks(0.74:0.02:0.8)
xlim([0.75 2.25])
xticklabels({'Late behavior\newlineonset','Early behavior\newlineonset'})
ylabel('0-1 chaos test')
set(gca,'FontSize',17)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.03 0.03])
box off

set(gcf,'color','w')
f=gcf;
f.Theme="light";

%% Create statistics on chaoticity of change points
% chaosSegList=cell(length(subjList),1);
% speedSegList=cell(length(subjList),1);
% 
% for sInd=1:length(subjList)
%     disp(sInd)
%     subjID=subjList{sInd};
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
%     figurePath=[ECOG_Dir subjID '/'];
% 
%     VAR_Data=load([figurePath 'RANSAC_PCA' append '_Trimmed.mat']);
%     useScores=VAR_Data.trimScores;
% 
%     % smoothWindows=[30*60/5];
%     smoothWindows=[1];
%     windowInd=1;
% 
%     sampleMissing=isnan(sum(useScores,2));
% 
%     smoothScores=movmean(useScores,smoothWindows(windowInd),'omitnan');
%     smoothScores(sampleMissing,:)=NaN;
% 
%     ogSmoothScores=smoothScores;
% 
%     % Normalize scores
%     for scoreInd=1:size(smoothScores,2)
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)-quantile(smoothScores(:,scoreInd),0.05);
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)/quantile(smoothScores(:,scoreInd),0.95);
%     end
% 
%     smoothScores(smoothScores<0)=0;
%     smoothScores(smoothScores>1)=1;
% 
%     timeInds=(1:size(smoothScores,1))*5/3600;
%     smoothScores=smoothScores./repmat(sum(smoothScores,2),1,size(smoothScores,2));
% 
%     %
%     speedVec=zeros(size(smoothScores,1)-1,1);
%     speedVec_H=zeros(size(smoothScores,1)-1,1);
%     speedVec_Euc=zeros(size(smoothScores,1)-1,1);
% 
%     for tInd=1:length(speedVec)
%         speedVec(tInd)=bc_dist(smoothScores(tInd,:),smoothScores(tInd+1,:));
%         speedVec_H(tInd)=abs(hellinger_dist(smoothScores(tInd,:),smoothScores(tInd+1,:)));
%         speedVec_Euc(tInd)=pdist2(ogSmoothScores(tInd,:),ogSmoothScores(tInd+1,:));
%     end
% 
%     % Measure chaos in ten-minute chunks of data
%     segLength=10*60/5;
%     numSegs=floor(size(smoothScores,1)/segLength);
% 
%     speedSeg=nan(numSegs,1);
%     chaosSeg=nan(numSegs,1);
% 
% %     parfor segInd=1:numSegs
%     for segInd=1:numSegs
%         tStart=(segInd-1)*segLength+1;
%         tEnd=tStart+segLength;
% 
%         if sum(isnan(smoothScores(tStart:tEnd,1)))==0
% %             speedSeg(segInd)=nanmean(speedVec_H(tStart:tEnd));
%             speedSeg(segInd)=nanmean(speedVec_Euc(tStart:tEnd));
% %             chaosVec=zeros(size(smoothScores,2),1);
% 
% %             for scoreInd=1:size(smoothScores,2)
% %                 chaosVec(scoreInd)=chaosTest(smoothScores(tStart:tEnd,scoreInd));
% %             end
% 
% %             chaosSeg(segInd)=median(chaosVec);
%         end
%     end
% 
% %     chaosSegList{sInd}=chaosSeg;
%     speedSegList{sInd}=speedSeg;
% end
% 
% fastSegList=cell(length(subjList),1);
% isBurstList=cell(length(subjList),1);
% 
% for sInd=1:length(subjList)
%     disp(sInd)
% 
%     subjID=subjList{sInd};
%     featClass=2;
%     bandSelector=1;
%     useFixed=1;
%     aCorr=3;
% 
%     if aCorr==1
%         append='';
%     elseif aCorr==2
%         append='_ECorr';
%     elseif aCorr==3
%         append='_Fixed_SACorr_Mean';
%     end
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
%     figurePath=[ECOG_Dir subjID '/'];
% 
% %     PCA_Data=load([figurePath 'VAR_RANSAC_Comps' append '.mat']);
%     PCA_Data=load([figurePath 'RANSAC_PCA' append '_Trimmed.mat']);
%     useScores=PCA_Data.trimScores;
% 
%     % smoothWindows=[30*60/5];
%     smoothWindows=[10*60/5];
%     windowInd=1;
% 
%     sampleMissing=isnan(sum(useScores,2));
% 
%     smoothScores=movmean(useScores,smoothWindows(windowInd),'omitnan');
%     smoothScores(sampleMissing,:)=NaN;
% 
%     ogSmoothScores=smoothScores;
% 
%     % Normalize scores
%     for scoreInd=1:size(smoothScores,2)
%         %     smoothScores(:,scoreInd)=smoothScores(:,scoreInd)-min(smoothScores(:,scoreInd));
%         %     smoothScores(:,scoreInd)=smoothScores(:,scoreInd)/max(smoothScores(:,scoreInd));
% 
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)-quantile(smoothScores(:,scoreInd),0.05);
%         smoothScores(:,scoreInd)=...
%             smoothScores(:,scoreInd)/quantile(smoothScores(:,scoreInd),0.95);
%         %     smoothScores(~sampleMissing,scoreInd)=zscore(smoothScores(~sampleMissing,scoreInd));
%     end
% 
%     smoothScores(smoothScores<0)=0;
%     smoothScores(smoothScores>1)=1;
% 
%     timeInds=(1:size(smoothScores,1))*5/3600;
%     smoothScores=smoothScores./repmat(sum(smoothScores,2),1,size(smoothScores,2));
% 
%     projWeight=smoothScores;
%     %
%     speedVec=zeros(size(projWeight,1)-1,1);
%     speedVec_H=zeros(size(projWeight,1)-1,1);
%     speedVec_Euc=zeros(size(projWeight,1)-1,1);
% 
%     for tInd=1:length(speedVec)
%         speedVec(tInd)=bc_dist(projWeight(tInd,:),projWeight(tInd+1,:));
%         speedVec_H(tInd)=hellinger_dist(projWeight(tInd,:),projWeight(tInd+1,:));
% 
%         speedVec_Euc(tInd)=pdist2(ogSmoothScores(tInd,:),ogSmoothScores(tInd+1,:));
%     end
% 
%     speedSmoothWindows=[1 6 12];
% 
%     smoothedSpeed=zeros(length(speedVec_H),length(speedSmoothWindows));
%     smoothedSpeedQuantiles=zeros(length(speedVec_H),length(speedSmoothWindows));
%     for wInd=1:length(speedSmoothWindows)
%         smoothedSpeed(:,wInd)=movmean(speedVec_H,speedSmoothWindows(wInd));
% 
%         [cdfY,cdfX]=ecdf(smoothedSpeed(:,wInd));
%         [~,useCDF]=unique(cdfX);
%         smoothedSpeedQuantiles(:,wInd)=interp1(cdfX(useCDF),cdfY(useCDF),smoothedSpeed(:,wInd));
%     end
% 
%     fastSegs=(smoothedSpeedQuantiles(:,1)>0.95 | ...
%         smoothedSpeedQuantiles(:,2)>0.85) | ...
%         smoothedSpeedQuantiles(:,3)>0.8;
% 
%     fastSegs(movmean(fastSegs,12*5)>0)=1;
% 
%     fastSegs(1)=0;
%     fastSegs(end)=0;
% 
%     fastSegList{sInd}=fastSegs;
% 
%     smoothWindows=[1];
%     windowInd=1;
% 
%     sampleMissing=isnan(sum(useScores,2));
% 
%     smoothScores=movmean(useScores,smoothWindows(windowInd),'omitnan');
%     smoothScores(sampleMissing,:)=NaN;
% 
%     segLength=10*60/5;
%     numSegs=floor(size(smoothScores,1)/segLength);
% 
%     isBurst=zeros(numSegs,1);
% 
%     for segInd=1:numSegs
%         tStart=(segInd-1)*segLength+1;
%         tEnd=tStart+segLength;
% 
%         isBurst(segInd)=sum(fastSegs(tStart:tEnd))>0;
%     end
% 
%     isBurstList{sInd}=isBurst;
% end

%% 
load('Data/Fig3_IntermediateData.mat','displacementList','distanceList',...
    'displacementList_Euc','distanceList_Euc',...
    'displacementListState_Euc','distanceListState_Euc','chaosSegList','speedSegList','fastSegList','isBurstList');
    
chaosMeans_State=zeros(length(subjList),1);
chaosMeans_Burst=zeros(length(subjList),1);

for sInd=1:length(subjList)
    chaosMeans_State(sInd)=nanmean(chaosSegList{sInd}(isBurstList{sInd}==0));
    chaosMeans_Burst(sInd)=nanmean(chaosSegList{sInd}(isBurstList{sInd}==1));
end

pairError=std(chaosMeans_State-chaosMeans_Burst)*1.96/sqrt(length(chaosMeans_State));

figure

bar([1 2],[mean(chaosMeans_State) mean(chaosMeans_Burst)]); hold on
er=errorbar([1 2],[mean(chaosMeans_State) mean(chaosMeans_Burst)],[pairError/2 pairError/2],'CapSize',50,'LineWidth',2);
er.Color = [0 0 0];
er.LineStyle = 'none';

ylim([0.7 0.8])
xticks([1 2])
xticklabels({'Between\newlinetransitions','During\newlinetransitions'})
ylabel('0-1 chaos test')
title('Transition Chaoticity')
set(gca,'FontSize',15)
set(gcf,'color','w')

f=gcf;
f.Theme="light";

%% Power law distributions of transitions
% displacementList_Euc=cell(length(subjList),1);
% distanceList_Euc=cell(length(subjList),1);
% 
% trajEndPointList=cell(length(subjList),1);
% 
% for sInd=1:length(subjList)
%     disp(sInd)
% 
%     subjID=subjList{sInd};
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
%     dataPath=[ECOG_Dir subjID '/'];
% 
%     Coh_Data=load([dataPath '/RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores');
%     trimScores=Coh_Data.trimScores;
% 
%     featureMat=trimScores;
% 
%     useTrials=find(~isnan(featureMat(:,1)));
% 
%     speedVec=zeros(size(featureMat,1)-1,1);
% 
%     for tInd=1:length(speedVec)
%         speedVec(tInd)=pdist2(featureMat(tInd,:),featureMat(tInd+1,:));
%     end
% 
%     smoothedSpeed=movmean(speedVec,12,'omitnan');
%     smoothedSpeed(isnan(speedVec))=NaN;
% 
%     breakData=load([dataPath '/ChangePoints_PCA_BP_10min.mat']);
% 
%     breakVec=find(breakData.breakVec);
% 
%     cutoff=quantile(smoothedSpeed,0.5);
% 
%     trajEndpoints=zeros(length(breakVec),2);
% 
%     for bInd=1:length(breakVec)
%         if bInd==1
%             leftHalf=find(smoothedSpeed(1:(breakVec(bInd)-1))<cutoff,1,'last');
%             rightHalf=find(smoothedSpeed((breakVec(bInd)+1):(breakVec(bInd+1)-1))<cutoff,1)+breakVec(bInd);
% 
%             if ~isempty(leftHalf)
%                 trajEndpoints(bInd,1)=leftHalf;
%             else
%                 trajEndpoints(bInd,1)=1;
%             end
% 
%             if ~isempty(rightHalf)
%                 trajEndpoints(bInd,2)=rightHalf;
%             else
%                 trajEndpoints(bInd,2)=breakVec(bInd+1)-1;
%             end
% 
%         elseif bInd==length(breakVec)
%             leftHalf=find(smoothedSpeed((breakVec(bInd-1)+1):(breakVec(bInd)-1))<cutoff,1,'last')+breakVec(bInd-1);
%             rightHalf=find(smoothedSpeed((breakVec(bInd)+1):end)<cutoff,1)+breakVec(bInd);
% 
%             if ~isempty(leftHalf)
%                 trajEndpoints(bInd,1)=leftHalf;
%             else
%                 trajEndpoints(bInd,1)=breakVec(bInd)-1;
%             end
% 
%             if ~isempty(rightHalf)
%                 trajEndpoints(bInd,2)=rightHalf;
%             else
%                 trajEndpoints(bInd,2)=length(smoothedSpeed);
%             end
%         else
%             leftHalf=find(smoothedSpeed((breakVec(bInd-1)+1):(breakVec(bInd)-1))<cutoff,1,'last')+breakVec(bInd-1);
%             rightHalf=find(smoothedSpeed((breakVec(bInd)+1):(breakVec(bInd+1)-1))<cutoff,1)+breakVec(bInd);
% 
%             if ~isempty(leftHalf)
%                 trajEndpoints(bInd,1)=leftHalf;
%             else
%                 trajEndpoints(bInd,1)=breakVec(bInd)-1;
%             end
% 
%             if ~isempty(rightHalf)
%                 trajEndpoints(bInd,2)=rightHalf;
%             else
%                 trajEndpoints(bInd,2)=breakVec(bInd+1)-1;
%             end
%         end
%     end
% 
%     trajEndPointList{sInd}=trajEndpoints;
% 
%     trajDisplacement=zeros(length(breakVec),1);
%     trajDistance=zeros(length(breakVec),1);
% 
%     for bInd=1:length(breakVec)
%         trajDisplacement(bInd)=pdist2(featureMat(trajEndpoints(bInd,1),:),featureMat(trajEndpoints(bInd,2),:));
%         trajDistance(bInd)=sum(speedVec(trajEndpoints(bInd,1):trajEndpoints(bInd,2)));
%     end
% 
%     displacementList_Euc{sInd}=trajDisplacement;
%     distanceList_Euc{sInd}=trajDistance;
% end

%%
load('Data/Fig3_IntermediateData.mat','displacementList','distanceList',...
    'displacementList_Euc','distanceList_Euc',...
    'displacementListState_Euc','distanceListState_Euc','chaosSegList',...
    'speedSegList','fastSegList','isBurstList','transitionSize','trajEndPointList');

subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
    'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
    'EP1170','EP1173','EP1166','EP1169','EP1188'};

figure
subplot(1,2,1)
cla()
hold on
for sInd=1:length(subjList)    
    dispVec=transitionSize{sInd};
    dispVec=dispVec(dispVec>20);
    
    [time_dist,time_edges]=histcounts(dispVec,'Normalization','probability');
    plotMagInds=time_dist>0;
    
    mid_edges=mean([time_edges(1:end-1);time_edges(2:end)]);
    
    loglog(mid_edges(plotMagInds),time_dist(plotMagInds),'-o','LineWidth',1,'MarkerSize',5)
end

set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Burst Size')
ylabel('Probability')
set(gca,'FontSize',16)
title('Transition size distribution over subjects','FontSize',16)
set(gcf,'color','white')
f=gcf;
f.Theme="light";

%%
timeInState_List=cell(length(subjList),1);

for sInd=1:length(subjList)
    trajEndpoints=trajEndPointList{sInd};
    numTrajectories=size(trajEndpoints,1);
    timeInState_List{sInd}=trajEndpoints(2:numTrajectories,1)-...
        trajEndpoints(1:numTrajectories-1,2);
end

%%
subplot(1,2,2)
cla()
hold on

for sInd=1:length(subjList)
    timeInState=timeInState_List{sInd}*5/3600;
    useTimes=timeInState;
    
    time_edges=0:(1/3):5;
    
    [time_dist,~]=histcounts(useTimes,time_edges,'Normalization','probability');
    plotTimeInds=time_dist>0;
    mid_edges=mean([time_edges(1:end-1);time_edges(2:end)]);
    loglog(60*mid_edges(plotTimeInds),time_dist(plotTimeInds),'-o','LineWidth',1,'MarkerSize',5)
end

xticks([10 30 50 70 110 150])
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Time in State (mins)')
ylabel('Probability')
set(gca,'FontSize',16)
title('Time between transitions over subjects','FontSize',16)

set(gcf,'color','white')
f=gcf;
f.Theme="light";