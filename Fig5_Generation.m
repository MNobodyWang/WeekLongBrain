% Generates Figure 5 main results
% Created on 202060213 by Max B Wang

%% Load individual data files
% annotList={'EP1117','EP1109','EP1173','EP1124','EP1135','EP1136','EP1137','EP1149','EP1163'};
% 
% ECOG_Dir='/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/easystore/Processed_Data/';
% 
% noB_Awake_dists=zeros(length(annotList),1);
% B_Awake_dists=zeros(length(annotList),1);
% 
% sleep_dists=zeros(length(annotList),1);
% 
% for sInd=1:length(annotList)
%     subjID=annotList{sInd};
% 
%     dataPath=[ECOG_Dir subjID '/'];
%     kopData=load([dataPath 'KOP_Models/AttractorState_KOP_FE_10.mat'],'kop_Attractor','pca_Attractor');
%     kopStatesData=load([dataPath 'KOP_Models/KopStates_FE10.mat'],'kopStates');
% 
%     anotDir=['/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/qSTORAGE/ECOG_Data/Videos/' subjID '/'];
% 
%     load([anotDir 'FullAnnotationTimeStamps.mat'],'timeInds_A','timeInds_B','labels_A','labels_B')
% 
%     kopStates_A=kopStatesData.kopStates(timeInds_A(1):timeInds_A(2),:);
%     kopStates_B=kopStatesData.kopStates(timeInds_B(1):timeInds_B(2),:);
% 
%     distAttractor_A=pdist2(kopStates_A,kopData.kop_Attractor);
%     distAttractor_B=pdist2(kopStates_B,kopData.kop_Attractor);
% 
%     %
%     allDists=[distAttractor_A;distAttractor_B];
%     allDists_normed=(allDists-nanmean(allDists))/nanstd(allDists);
% 
%     allLabels=[labels_A;labels_B];
% 
%     noB_Awake=sum(allLabels,2)==0;
%     B_Awake=sum(allLabels(:,2:end),2)>0;
% 
%     noB_Awake_dists(sInd)=nanmean(allDists(noB_Awake))-nanmean(allDists);
%     B_Awake_dists(sInd)=nanmean(allDists(B_Awake))-nanmean(allDists);
%     sleep_dists(sInd)=nanmean(allDists(allLabels(:,1)==1))-nanmean(allDists);
% 
%     lastMean=nanmean(allDists);
% end

%% Load intermediate data
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists','sleep_dists','lastMean')

cla
pairError=std(noB_Awake_dists-B_Awake_dists)*1.96/sqrt(length(B_Awake_dists));
% bar([1 2],[mean(noB_Awake_dists) mean(B_Awake_dists)]+lastMean); hold on
er=errorbar([1 2],[mean(noB_Awake_dists) mean(B_Awake_dists)]+lastMean,[pairError/2 pairError/2],'x','CapSize',50,'LineWidth',2,'MarkerSize',20);
er.Color = [0 0 0];
er.LineStyle = 'none';
xticks([1 2])
xticklabels({'Wakeful\newlinerest','Awake,\newlineactive'})
f=gcf;
f.Theme="light";
xlim([0.75,2.25])

set(gca,'FontSize',15)
ylabel('Distance to attractor')

%% Load individual circadian data
% subjList={'EP1117','EP1109','EP1120','EP1124','EP1137','EP1160','EP1149','EP1136','EP1165','EP1173','EP1169'};
% 
% alignmentManifold=zeros(length(subjList),1);
% alignmentPermManifold=cell(length(subjList),1);
% 
% for sInd=1:length(subjList)
%     disp(sInd)
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
%     load([figurePath 'RANSAC_PCA' append '_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% 
%     kopMats=load([figurePath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
%     kopStates=kopMats.kopStates;
% 
%     breaks=find(isnan(trimScores(:,1)));
%     consecBreak=[0;(breaks(2:end)-breaks(1:end-1))==1; 0];
% 
%     [startPoint,dayMarks]=returnDayMarks(subjID);
%     dayRef=zeros(size(dayMarks,1),1);
% 
%     for dayInd=1:size(dayMarks,1)
%         timePoint=dayMarks(dayInd,:);
%         timeDiff=floor((timePoint-startPoint)*[1;1/60;1/3600]);
% 
%         if dayInd>1
%             roughInd=floor(timeDiff*3600/5);
%             [~,nearBreak]=min(abs(breaks-roughInd));
%             dayRef(dayInd)=find(consecBreak(nearBreak+1:end)==0,1)+breaks(nearBreak)-1;
%         end
%     end
% 
%     dayRef(1)=1;
%     realTime=zeros(size(trimScores,1),1);
%     whichDay=zeros(size(trimScores,1),1);
% 
%     for dayInd=1:size(dayMarks,1)
%         tStart=dayRef(dayInd);
% 
%         if dayInd<size(dayMarks,1)
%             tEnd=dayRef(dayInd+1);
%         else
%             tEnd=size(trimScores,1);
%         end
% 
%         realTime(tStart:tEnd)=mod((1:(tEnd-tStart+1))*5/3600+dayMarks(dayInd,:)*[1;1/60;1/3600],24);
%         whichDay(tStart:tEnd)=floor(((1:(tEnd-tStart+1))*5/3600+dayMarks(dayInd,:)*[1;1/60;1/3600])/24);
%     end
% 
%     realTimePhase=[cos(realTime/24*2*pi) sin(realTime/24*2*pi)];
% 
%     [V,D]=eig(kopMats.kop_A);
%     eigVals=diag(D);
%     [~,maxEval]=max(real(eigVals));
%     slowManifold=real(V(:,maxEval));
%     projVector=slowManifold;
%     projVector=projVector./sqrt(projVector.'*projVector);
% 
%     useInds=find(~isnan(realTimePhase(:,1)) & ~isnan(kopStates(:,1)));
% 
%     [A,B,alignmentManifold(sInd),~,~,~]=canoncorr(realTimePhase(useInds,:),kopStates(useInds,:)*projVector);
% 
%     permTrials=1000;
%     permCorr=zeros(permTrials,1);
% 
%     parfor tInd=1:permTrials
%         [~,~,permCorr(tInd)]=canoncorr(realTimePhase(useInds,:),kopStates(useInds,:)*projVector(randperm(length(projVector))));
%     end
% 
%     alignmentPermManifold{sInd}=permCorr;
% end

%% Load EKG data
% subjList={'EP1117','EP1109','EP1149','EP1136','EP1160','EP1142','EP1133'};
% subjSign=[1,1,1,1,-1,1,1]; % One participant ekg leads were flipped
% % subjList={'EP1109','EP1149','EP1136','EP1160','EP1142','EP1133'};
% 
% alignmentManifold_all=zeros(length(subjList),12);
% alignmentOffManifold_all=zeros(length(subjList),12);
% 
% EKG_Dir='/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/qSTORAGE/ECOG_Data/';
% 
% for sInd=1:length(subjList)
%     disp(sInd)
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
%     ECOG_Dir='/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/easystore/Processed_Data/';
%     bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
%     figurePath=[ECOG_Dir subjID '/'];
% 
%     load([figurePath 'RANSAC_PCA' append '_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% 
%     kopMats=load([figurePath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
%     kopStates=kopMats.kopStates;
% 
%     [V,D]=eig(kopMats.kop_A);
%     eigVals=diag(D);
%     [~,maxEval]=max(real(eigVals));
%     slowManifold=real(V(:,maxEval));
%     projVector=slowManifold;
%     projVector=projVector./sqrt(projVector.'*projVector);
% 
%     if subjSign(sInd)==1
%         load([EKG_Dir subjID '/EKG/BPM_AllMeasures.mat'],'subjMeasures','myKeys');
%     else
%         load([EKG_Dir subjID '/EKG/BPM_AllMeasures_Flipped.mat'],'subjMeasures','myKeys');
%     end
% 
%     bpm=subjMeasures{1};
%     bpm=bpm(1:size(trimScores,1)).';
%     dayLength=24*3600/5;
%     outliers=movmean(bpm>140 | bpm<30,5*12,'omitnan')>0;
%     bpm(outliers)=nan;
% 
%     useInds=find(~isnan(bpm) & ~isnan(kopStates(:,1)));
% 
%     for measureInd=1:size(alignmentManifold_all,2)
%         myMeasureTrace=subjMeasures{measureInd}.';
%         useInds=useInds(~isnan(myMeasureTrace(useInds)));
%         [R,P]=corr(myMeasureTrace(useInds),kopStates(useInds,:)*projVector);
%         alignmentManifold_all(sInd,measureInd)=abs(R);
% 
%         offManifoldCorrs=zeros(size(kopStates,2),1);
%         offManifoldStates=kopStates-(kopStates*projVector)*projVector.';
% 
%         for kopStateInd=1:size(kopStates,2)
%             [R_off,P_off]=corr(myMeasureTrace(useInds),offManifoldStates(useInds,kopStateInd));
%             offManifoldCorrs(kopStateInd)=R_off;
%         end
% 
%         alignmentOffManifold_all(sInd,measureInd)=median(abs(offManifoldCorrs));
%     end
% end

%%
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists','sleep_dists','lastMean',...
    'alignmentManifold','alignmentPermManifold','alignmentManifold_all','alignmentOffManifold_all')

subjList={'EP1117','EP1109','EP1120','EP1124','EP1137','EP1160','EP1149','EP1136','EP1165','EP1173','EP1169'};

meanPermAlignment=zeros(length(subjList),1);
for sInd=1:length(subjList)
    meanPermAlignment(sInd)=mean(alignmentPermManifold{sInd});
end

eBar=std(alignmentManifold-meanPermAlignment)*1.96/sqrt(length(alignmentManifold));

figure; hold on
errorbar([1 2]-0.1,[mean(meanPermAlignment) mean(alignmentManifold)],[eBar/2 eBar/2],'x','CapSize',40,'LineWidth',2,'Color','r','MarkerSize',20)
xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Off\newlinemanifold','On\newlinemanifold'})
ylabel('Correlation')
% yticks(0:0.1:0.3)
set(gca,'FontSize',14)
set(gca,'LineWidth',1.5)
set(gcf,'Color','w')
f=gcf;
f.Theme="light";

eBar_ekg=std(alignmentManifold_all(:,1)-alignmentOffManifold_all(:,1))*1.96/sqrt(length(alignmentManifold));
errorbar([1 2]+0.1,[mean(alignmentOffManifold_all(:,1)) mean(alignmentManifold_all(:,1))],[eBar_ekg/2 eBar_ekg/2],'x','CapSize',40,'LineWidth',2,'Color','b','MarkerSize',20)

%% Behavioral manifold projection
% subjList={'EP1117','EP1109','EP1124','EP1135','EP1173','EP1136','EP1137','EP1149','EP1163'};
% fileID_List={{'06f7b','a6e6c'},{'98285','cdfc5'},{'26465','df0a8'},...
%     {'ffc2a','059a7'},{'c4601','14430'},{'e4334','6b158'},{'5e824','4d1c9'},{'33109','c9e87'},{'1de1b','4b11e'}};
% 
% centroidStage=zeros(length(subjList),9); 
% 
% for subjInd=1:length(subjList)
%     disp(subjInd)
%     subjID=subjList{subjInd};
%     scoreDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/SleepScoring/' subjID '/'];
% 
%     sleepData_A=load([scoreDir subjID '_' fileID_List{subjInd}{1} '.mat']);
%     SleepStage_A=sleepData_A.SleepStage;
%     sleepData_B=load([scoreDir subjID '_' fileID_List{subjInd}{2} '.mat']);
%     SleepStage_B=sleepData_B.SleepStage;
% 
%     anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
%     load([anotDir 'FullAnnotationTimeStamps.mat'],'labels_A','labels_B')
% 
%     sleepLabels_A=zeros(size(labels_A,1),1); % 1:R,2:W,3-5:N1-N3
%     startTime=datetime(datestr(SleepStage_A(1,2)));
% 
%     for sleepInd=1:size(SleepStage_A,1)
%         currentTime=datetime(datestr(SleepStage_A(sleepInd,2)));
% 
%         startInd=seconds(currentTime-startTime)/5+1;
%         endInd=min([startInd+5 size(labels_A,1)]);
% 
%         if startInd<=size(labels_A,1)
%             sleepLabels_A(startInd:endInd)=SleepStage_A(sleepInd,3);
%         end
%     end
% 
%     sleepLabels_B=zeros(size(labels_B,1),1); % 1:R,2:W,3-5:N1-N3
%     startTime=datetime(datestr(SleepStage_B(1,2)));
% 
%     for sleepInd=1:size(SleepStage_B,1)
%         currentTime=datetime(datestr(SleepStage_B(sleepInd,2)));
% 
%         startInd=seconds(currentTime-startTime)/5+1;
%         endInd=min([startInd+5 size(labels_B,1)]);
% 
%         if startInd<=size(labels_B,1)
%             sleepLabels_B(startInd:endInd)=SleepStage_B(sleepInd,3);
%         end
%     end
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% 
%     dataPath=[ECOG_Dir subjID '/'];
% %     kopMats=load([dataPath 'KOP_Models/KOP_Mats_FE_10.mat']);
%     kopMats=load([dataPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
%     kopAttractor=kopMats.kop_Attractor;
% 
%     anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
% 
%     load([anotDir 'FullAnnotationTimeStamps.mat'],'timeInds_A','timeInds_B','labels_A','labels_B')
% 
%     kopStates_A=kopMats.kopStates(timeInds_A(1):timeInds_A(2),:);
%     kopStates_B=kopMats.kopStates(timeInds_B(1):timeInds_B(2),:);
% 
%     allKopStates=[kopStates_A;kopStates_B];
%     allLabels=[labels_A;labels_B];
% 
%     sleepLabels=[sleepLabels_A;sleepLabels_B];
%     sleepLabels(allLabels(:,1)==0)=0;
% 
%     sleepCenter=nanmean(allKopStates(allLabels(:,1)==1,:));
%     bAwakeCenter=nanmean(allKopStates(sum(allLabels(:,2:end),2)>0,:));
% 
%     [V,D]=eig(kopMats.kop_A);
%     eigVals=diag(D);
% 
%     [~,maxEval]=max(real(eigVals));
% 
%     slowManifold=real(V(:,maxEval));
% 
%     projVector=slowManifold;
%     projVector=projVector./sqrt(projVector.'*projVector);
% 
%     axisProjection=allKopStates*projVector-kopAttractor.'*projVector;
% 
%     % asleep, b_awake, nob_awake, rem, n1, n2, n3
% %     centroidStage(subjInd,1)=nanmean(axisProjection(allLabels(:,1)==1));
% %     centroidStage(subjInd,2)=nanmean(axisProjection(sum(allLabels(:,2:4),2)>0));
% 
%     centroidStage(subjInd,1)=nanmean(axisProjection(sum(allLabels(:,2:4),2)>0)); % active waking
%     centroidStage(subjInd,2)=nanmean(axisProjection(sum(allLabels,2)==0)); % wakeful rest
%     centroidStage(subjInd,3)=nanmean(axisProjection(sleepLabels==1)); % rem
%     centroidStage(subjInd,4)=nanmean(axisProjection(sleepLabels==3)); % n1
%     centroidStage(subjInd,5)=nanmean(axisProjection(sleepLabels==4)); % n2
%     centroidStage(subjInd,6)=nanmean(axisProjection(sleepLabels==5)); % n3
%     centroidStage(subjInd,7)=nanmean(axisProjection(allLabels(:,2)==1)); % digital
%     centroidStage(subjInd,8)=nanmean(axisProjection(allLabels(:,3)==1)); % social
%     centroidStage(subjInd,9)=nanmean(axisProjection(allLabels(:,4)==1)); % physical
% end

%%
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists',...
    'sleep_dists','lastMean','alignmentManifold','alignmentPermManifold',...
    'alignmentManifold_all','alignmentOffManifold_all','centroidStage')

resortCentroidStage=[centroidStage(:,7:9) centroidStage(:,2:6)];

errorBars=zeros(8,1);
numSamples=size(resortCentroidStage,1);
errorBars(1:3)=0.5*std(resortCentroidStage(:,1:3)-repmat(resortCentroidStage(:,4),1,3))*1.96/sqrt(numSamples);
errorBars(4)=0.5*errorBars(3)+0.25*std(resortCentroidStage(:,4)-resortCentroidStage(:,6))*1.96/sqrt(numSamples);
errorBars(5)=0.5*std(resortCentroidStage(:,8)-resortCentroidStage(:,5))*1.96/sqrt(numSamples);
errorBars(6)=0.25*std(resortCentroidStage(:,4)-resortCentroidStage(:,6))*1.96/sqrt(numSamples)+...
    0.25*std(resortCentroidStage(:,6)-resortCentroidStage(:,7))*1.96/sqrt(numSamples);
errorBars(7)=0.25*std(resortCentroidStage(:,6)-resortCentroidStage(:,7))*1.96/sqrt(numSamples)+...
    0.25*std(resortCentroidStage(:,7)-resortCentroidStage(:,8))*1.96/sqrt(numSamples);
errorBars(8)=0.5*std(resortCentroidStage(:,7)-resortCentroidStage(:,8))*1.96/sqrt(numSamples);

figure
errorbar(1:8,mean(resortCentroidStage),errorBars,'x','MarkerSize',15,'LineWidth',2)
xlim([0 9])
ylim([-0.08 0.06])
xticks(1:8)
xticklabels({'Digital','Social','Physical','Wakeful\newlinerest','REM','N1','N2','N3'})
ylabel('Center manifold')
yticks(-0.06:0.03:0.06)
set(gca,'FontSize',15)
set(gcf,'color','w')

f=gcf;
f.Theme="light";

%%
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% numLags=720*8;
% 
% autocorrelationOnManifold=zeros(length(subjList),numLags);
% autocorrelationOffManifold=zeros(length(subjList),numLags);
% 
% parfor sInd=1:length(subjList)
%     disp(sInd)
%     subjID=subjList{sInd};
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     dataPath=[ECOG_Dir subjID '/'];
%     kopMats=load([dataPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
%     kopStates=kopMats.kopStates;
%     kopAttractor=kopMats.kop_Attractor;
% 
%     [V,D]=eig(kopMats.kop_A);
%     eigVals=diag(D);
% 
%     [~,maxEval]=max(real(eigVals));
% 
%     slowManifold=real(V(:,maxEval));
% 
%     projVector=slowManifold;
%     projVector=projVector./sqrt(projVector.'*projVector);
% 
%     axisProjection=kopStates*projVector-kopAttractor.'*projVector;
%     onManifold_acf=autocorr(axisProjection,'NumLags',numLags);
%     autocorrelationOnManifold(sInd,:)=onManifold_acf(2:end);
% 
%     perpendicularStates=kopStates-(kopStates*projVector)*projVector.';
%     numSamples=10;
% 
%     offManifold_acf_sample=zeros(numSamples,numLags);
%     for sampInd=1:numSamples
%         acf_curve=autocorr(perpendicularStates(:,randsample(size(perpendicularStates,2),1)),'NumLags',numLags);
%         offManifold_acf_sample(sampInd,:)=acf_curve(2:end);
%     end
% 
%     autocorrelationOffManifold(sInd,:)=mean(offManifold_acf_sample);
% end

%%
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists',...
    'sleep_dists','lastMean','alignmentManifold','alignmentPermManifold',...
    'alignmentManifold_all','alignmentOffManifold_all','centroidStage',...
    'autocorrelationOnManifold','autocorrelationOffManifold')

numLags=720*8;
timeInds=(1:numLags)*5/3600;
useInds=1:120:length(timeInds);

figure
errorbar(timeInds(useInds),nanmean(autocorrelationOnManifold(:,useInds)),...
    1.96*nanstd(autocorrelationOnManifold(:,useInds))/sqrt(size(autocorrelationOnManifold,1)),'LineWidth',1.5); hold on
errorbar(timeInds(useInds),nanmean(autocorrelationOffManifold(:,useInds)),...
    1.96*nanstd(autocorrelationOffManifold(:,useInds))/sqrt(size(autocorrelationOnManifold,1)),'LineWidth',1.5);
% xlim([0.4 2.6])
% ylim([0 1])
set(gca,'TickLength',[0.025, 0.025],'box','off')
set(gca,'linewidth',1.5)
xlabel('Time (hrs)')
ylabel('Autocorrelation')
set(gca,'FontSize',15)
set(gcf,'color','w')

f=gcf;
f.Theme="light";

%%
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% chaosOnManifold=zeros(length(subjList),1);
% chaosOffManifold=zeros(length(subjList),1);
% 
% parfor sInd=1:length(subjList)
%     disp(sInd)
%     subjID=subjList{sInd};
% 
%     ECOG_Dir='/media/mwang/easystore/Processed_Data/';
%     dataPath=[ECOG_Dir subjID '/'];
%     kopMats=load([dataPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
%     kopStates=kopMats.kopStates;
%     kopAttractor=kopMats.kop_Attractor;
% 
%     [V,D]=eig(kopMats.kop_A);
%     eigVals=diag(D);
% 
%     [~,maxEval]=max(real(eigVals));
% 
%     slowManifold=real(V(:,maxEval));
% 
%     projVector=slowManifold;
%     projVector=projVector./sqrt(projVector.'*projVector);
% 
%     axisProjection=kopStates*projVector-kopAttractor.'*projVector;
% 
%     distVec=kopStates-axisProjection*projVector.'+repmat(kopAttractor.',size(kopStates,1),1);
% 
%     distToManifold=zeros(size(distVec,1),1);
% 
%     for tInd=1:size(distVec,1)
%         distToManifold(tInd)=distVec(tInd,:)*distVec(tInd,:).';
%     end
% %     distToManifold=diag(distVec*distVec.');
% 
%     % Find longest-uninterrupted signal
%     sigLength=zeros(length(axisProjection),1);
%     currentLength=0;
%     for tInd=1:length(axisProjection)
%         if ~isnan(axisProjection(tInd))
%             currentLength=currentLength+1;
%             sigLength(tInd)=currentLength;
%         else
%             currentLength=0;
%         end
%     end
% 
%     [~,endInd]=max(sigLength);
%     startInd=find(isnan(axisProjection(1:endInd)),1,'last')+1;
% 
% %     timeStep=20;
% %     overSampled_A=1;
% %     overSampled_B=1;
% %     while overSampled_A+overSampled_B>0
% %         [chaosOnManifold(sInd),overSampled_A]=z1test(axisProjection(startInd:timeStep:endInd));
% %         [chaosOffManifold(sInd),overSampled_B]=z1test(distToManifold(startInd:timeStep:endInd));
% %         timeStep=timeStep+10;
% %     end
% 
%     timeStep=20;
%     overSampled_A=1;
%     signal=axisProjection(startInd:timeStep:endInd);
%     if std(signal)<0.02 % since 0-1 chaos test falls apart is standard dev <1e-2 per Toker
%         signal=0.02*signal./std(signal);
%     end
% 
%     while overSampled_A>0
%         [chaosOnManifold(sInd),overSampled_A]=z1test(axisProjection(startInd:timeStep:endInd));
%         timeStep=timeStep+10;
%     end
% 
% %     timeStep=20;
% %     overSampled_B=1;
% %     while overSampled_B>0
% %         [chaosOffManifold(sInd),overSampled_B]=z1test(distToManifold(startInd:timeStep:endInd));
% %         timeStep=timeStep+10;
% %     end
% 
%     perpendicularStates=kopStates-(kopStates*projVector)*projVector.';
% 
%     numSamples=10;
%     chaosPerpMani=zeros(numSamples,1);
%     for sampleInd=1:numSamples
%         timeStep=20;
%         overSampled_B=1;
%         signal=perpendicularStates(startInd:timeStep:endInd,randsample(size(perpendicularStates,2),1));
%         if std(signal)<0.02
%             signal=0.02*signal./std(signal);
%         end
% 
%         while overSampled_B>0 && timeStep<150
%             [chaosPerpMani(sampleInd),overSampled_B]=z1test(signal);
%             timeStep=timeStep+10;
%         end
%     end
%     chaosOffManifold(sInd)=mean(chaosPerpMani);
% end

%%
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists','sleep_dists','lastMean','alignmentManifold','alignmentPermManifold','alignmentManifold_all','alignmentOffManifold_all','centroidStage','autocorrelationOnManifold','autocorrelationOffManifold','chaosOffManifold','chaosOnManifold')

pairedMargin=1.96/sqrt(20)*[std(chaosOnManifold-chaosOffManifold)]/2;

% bar([mean(chaosOnManifold([1:13 15:20])) mean(chaosOffManifold([1:13 15:20]))]); hold on
figure
errorbar([mean(chaosOnManifold([1:13 15:20])) mean(chaosOffManifold([1:13 15:20]))],...
    [pairedMargin pairedMargin],'x','CapSize',40,'LineWidth',2,'MarkerSize',20,'Color','k')
xlim([0.4 2.6])
ylim([0.5 0.9])
set(gca,'TickLength',[0.025, 0.025],'box','off')
set(gca,'linewidth',1.5)
xticks([1 2])
xticklabels({'On\newlinemanifold','Off\newlinemanifold'})
ylabel('0-1 chaoticity')
set(gca,'FontSize',15)
set(gcf,'color','w')

f=gcf;
f.Theme="light";

%% Speed along slow manifold
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% quantStart=0:0.1:0.9;
% quantEnd=0.1:0.1:1;
% flipSubjs=zeros(length(subjList),1); flipSubjs([1 2 8 12 9 14 19])=1; % Flip awake states to top of manifold
% 
% subjSpeed_ManifoldProjection=zeros(length(subjList),length(quantStart));
% 
% for sInd=1:length(subjList)
% 	disp(sInd)
% 	subjID=subjList{sInd};
% 
% 	if flipSubjs(sInd)==1
% 		flipSign=-1;
% 	else
% 		flipSign=1;
% 	end
% 
% 	% Load PCA data
% 	ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% 	bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
% 	subjPath=[ECOG_Dir subjID '/'];
% 	load([subjPath 'RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% 	kopMats=load([subjPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
% 
% 	kopStates=kopMats.kopStates;
% 	kopAttractor=kopMats.kop_Attractor;
% 
% 	[V,D]=eig(kopMats.kop_A);
% 	eigVals=diag(D);
% 	[~,maxEval]=max(real(eigVals));
% 	slowManifold=real(V(:,maxEval));
% 
% 	projVector=slowManifold;
% 	projVector=flipSign*projVector./sqrt(projVector.'*projVector);
% 
% 	axisProjection=kopStates*projVector-kopAttractor.'*projVector;
% 	axisProjection=axisProjection-nanmean(axisProjection);
% 
% 	featureMat=trimScores;
% 
% 	speedVec=zeros(size(featureMat,1)-1,1);
% 
% 	for tInd=1:length(speedVec)
% 		speedVec(tInd)=pdist2(featureMat(tInd,:),featureMat(tInd+1,:));
% 	end
% 
% 	speedVec=(speedVec-nanmean(speedVec))/nanstd(speedVec);
% 
% 	for qInd=1:length(quantStart)
% 		lowerBound=quantile(axisProjection,quantStart(qInd));
% 		upperBound=quantile(axisProjection,quantEnd(qInd));
% 
% 		quantInds=and(axisProjection>=lowerBound,axisProjection<=upperBound);
% 		subjSpeed_ManifoldProjection(sInd,qInd)=nanmean(speedVec(quantInds));
% 	end
% end

%% Chaoticity along slow manifold
% 
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% quantStart=0:0.1:0.9;
% quantEnd=0.1:0.1:1;
% flipSubjs=zeros(length(subjList),1); flipSubjs([1 2 8 12 9 14 19])=1; % Flip awake states to top of manifold
% 
% subjChaos_ManifoldProjection=zeros(length(subjList),length(quantStart));
% load('/home/mwang/ChangePoints/Data/20220518_ChaosSpeed.mat','chaosSegList')
% 
% for sInd=1:length(subjList)
% 	disp(sInd)
% 	subjID=subjList{sInd};
% 
% 	if flipSubjs(sInd)==1
% 		flipSign=-1;
% 	else
% 		flipSign=1;
% 	end
% 
% 	%% Load PCA data
% 	ECOG_Dir='/media/mwang/easystore2/Processed_Data/';
% 	bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
% 	subjPath=[ECOG_Dir subjID '/'];
% 	load([subjPath 'RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% 	kopMats=load([subjPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
% 
% 	kopStates=kopMats.kopStates;
% 	kopAttractor=kopMats.kop_Attractor;
% 
% 	[V,D]=eig(kopMats.kop_A);
% 	eigVals=diag(D);
% 	[~,maxEval]=max(real(eigVals));
% 	slowManifold=real(V(:,maxEval));
% 
% 	projVector=slowManifold;
% 	projVector=flipSign*projVector./sqrt(projVector.'*projVector);
% 
% 	axisProjection=kopStates*projVector-kopAttractor.'*projVector;
% 	axisProjection=axisProjection-nanmean(axisProjection);
% 
% 	featureMat=trimScores;
% 
% 	segLength=10*60/5;
% 	myChaosSeg=chaosSegList{sInd};
% 
% 	chaosVec=nan(size(featureMat,1),1);
% 
% 	for segInd=1:length(myChaosSeg)
% 		tStart=(segInd-1)*segLength+1;
% 		tEnd=tStart+segLength-1;
% 
% 		chaosVec(tStart:tEnd)=myChaosSeg(segInd);
% 	end
% 
% 	for qInd=1:length(quantStart)
% 		lowerBound=quantile(axisProjection,quantStart(qInd));
% 		upperBound=quantile(axisProjection,quantEnd(qInd));
% 
% 		quantInds=and(axisProjection>=lowerBound,axisProjection<=upperBound);
% 		subjChaos_ManifoldProjection(sInd,qInd)=nanmean(chaosVec(quantInds));
% 	end
% end

%%
load('Data/Fig5_IntermediateData.mat','noB_Awake_dists','B_Awake_dists',...
    'sleep_dists','lastMean','alignmentManifold','alignmentPermManifold',...
    'alignmentManifold_all','alignmentOffManifold_all','centroidStage',...
    'autocorrelationOnManifold','autocorrelationOffManifold','chaosOffManifold',...
    'chaosOnManifold','slowManifoldPlotVec','subjChaos_ManifoldProjection',...
    'subjSpeed_ManifoldProjection')

% baseline center each participant's average speed/chaos

for subjInd=1:size(subjSpeed_ManifoldProjection,1)
    subjSpeed_ManifoldProjection(subjInd,:)=subjSpeed_ManifoldProjection(subjInd,:)-...
        nanmean(subjSpeed_ManifoldProjection(subjInd,:))+nanmean(subjSpeed_ManifoldProjection(1,:));
    subjChaos_ManifoldProjection(subjInd,:)=subjChaos_ManifoldProjection(subjInd,:)-...
        nanmean(subjChaos_ManifoldProjection(subjInd,:))+nanmean(subjChaos_ManifoldProjection(1,:));
end

figure;
subplot(1,2,1)
meanSpeedProj=nanmean(subjSpeed_ManifoldProjection);
seSpeedProj=1.96*std(subjSpeed_ManifoldProjection)/sqrt(20);
errorbar(slowManifoldPlotVec,meanSpeedProj,seSpeedProj,'-x','CapSize',40,'LineWidth',2,'MarkerSize',20,'Color','k')
xlabel('Center manifold projection')
ylabel('Neural velocity')
set(gca,'FontSize',15)

xlim([-0.08 0.08])

subplot(1,2,2)
meanChaosProj=nanmean(subjChaos_ManifoldProjection);
seChaosProj=1.96*std(subjChaos_ManifoldProjection)/sqrt(20);
errorbar(slowManifoldPlotVec,meanChaosProj,seChaosProj,'-x','CapSize',40,'LineWidth',2,'MarkerSize',20,'Color','k')
xlabel('Center manifold projection')
ylabel('0-1 chaos')
set(gca,'FontSize',15)
xlim([-0.08 0.08])

f=gcf;
f.Theme="light";