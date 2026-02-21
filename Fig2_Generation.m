% Generate Figure 2 main results
% Created on 20260209 by Max B Wag

%% Generate data files for each participant individually (which would require data across all 20 participants)
%subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%    'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%    'EP1170','EP1173','EP1166','EP1169','EP1188'};

% chaosSegList=cell(length(subjList),1);
%speedList=cell(length(subjList),1);
%
%for sInd=1:length(subjList)
%    disp(sInd)
%    subjID=subjList{sInd};
%    featClass=2;
%    bandSelector=1;
%    useFixed=1;
%    aCorr=3;
%    
%    if aCorr==1
%        append='';
%    elseif aCorr==2
%        append='_ECorr';
%    elseif aCorr==3
%        append='_Fixed_SACorr_Mean';
%    end
%    
%    ECOG_Dir='/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/easystore/Processed_Data/';
%    bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
%    
%    figurePath=[ECOG_Dir subjID '/'];
%    
%    VAR_Data=load([figurePath 'RANSAC_PCA' append '_Trimmed.mat']);
%    useScores=VAR_Data.trimScores;
%    
%    speedVec=zeros(size(useScores,1)-1,1);
%    
%    for tInd=1:length(speedVec)
%        speedVec(tInd)=pdist2(useScores(tInd,:),useScores(tInd+1,:));
%    end
%    
%    speedList{sInd}=speedVec;
%end
%

%% Load intermediate files from each participant
load('Data/Fig2_IntermediateData.mat','speedList','annotList','matchPVal','medianTime','permTime')

cutoff=0.1;

plotTime=floor(1/cutoff)*20;
arrivalTime=zeros(length(speedList),plotTime);

for sInd=1:length(speedList)
    speedVec=speedList{sInd};
    changeInds=find(speedVec>quantile(speedVec,1-cutoff));
    timeBetween=changeInds(2:end)-changeInds(1:end-1);
    
    arrivalTime(sInd,:)=histcounts(timeBetween,0.5:(plotTime+0.5),'Normalization','probability');
end

poissonTime=cutoff*exp(-cutoff*(1:plotTime));

meanArrival=mean(arrivalTime);
arrivalSE=1.96*std(arrivalTime)/sqrt(length(speedList));

subplot(2,1,1)
timeInds=(1:plotTime)*5;
plotInds=[1:10 11:2:20 21:3:50 51:4:80 81:6:100 101:10:200];

errorbar(timeInds(plotInds), meanArrival(plotInds), arrivalSE(plotInds),'CapSize',5,'LineWidth',1); hold on
plot(timeInds(plotInds),poissonTime(plotInds),'-x','LineWidth',1.25)

set(gca,'XScale','log','YScale','log','LineWidth',0.75,'TickLength',[0.03,0.03])
xlabel('Time (secs)')
ylabel('Probability')
lgd=legend('Actual Arrival Time','Poisson Arrival Time');
lgd.FontSize=15;
title('Time between high speed windows')
set(gca,'FontSize',15)

%% Generate data files for each participant individually (which would require data across all 20 participants)
% matchPVal=zeros(length(annotList),1);
% medianTime=zeros(length(annotList),1);
% permTime=zeros(length(annotList),1);
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
% 
%     fastSeg_A=fastSegs(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
%     bChange_A=sum(abs(labels_A(2:end,:)-labels_A(1:end-1,:)),2)>0;
%     speedVec_A=speedVec(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% 
%     % remove_A=or(labels_A(:,1)>0,isnan(speedVec_A));
%     remove_A=isnan(speedVec_A);
%     fastSeg_A(remove_A(1:length(fastSeg_A)))=[];
%     bChange_A(remove_A(1:length(bChange_A)))=[];
%     speedVec_A(remove_A(1:length(speedVec_A)))=[];
% 
%     fastSeg_B=fastSegs(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
%     bChange_B=sum(abs(labels_B(2:end,:)-labels_B(1:end-1,:)),2)>0;
%     speedVec_B=speedVec(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% 
%     % remove_B=or(labels_B(:,1)>0,isnan(speedVec_B));
%     remove_B=isnan(speedVec_B);
%     fastSeg_B(remove_B(1:length(fastSeg_B)))=[];
%     bChange_B(remove_B(1:length(bChange_B)))=[];
%     speedVec_B(remove_B(1:length(speedVec_B)))=[];
% 
%     %
%     bCPoints_A=find(bChange_A);
%     fPoints_A=find(fastSeg_A);
%     distToFast_A=zeros(length(bCPoints_A),1);
% 
%     for bInd=1:length(bCPoints_A)
%         [~,minInd]=min(abs(bCPoints_A(bInd)-fPoints_A));
%         distToFast_A(bInd)=bCPoints_A(bInd)-fPoints_A(minInd);
% 
% %         distToFast_A(bInd)=min(abs(bCPoints_A(bInd)-fPoints_A));
%     end
% 
%     bCPoints_B=find(bChange_B);
%     fPoints_B=find(fastSeg_B);
%     distToFast_B=zeros(length(bCPoints_B),1);
% 
%     for bInd=1:length(bCPoints_B)
%         distToFast_B(bInd)=min(abs(bCPoints_B(bInd)-fPoints_B));
%     end
% 
%     medianDist=median([distToFast_A;distToFast_B]);
% 
%     % Permutation tests
%     permTrials=10000;
%     allBChange=[bChange_A;bChange_B];
%     allFastSeg=[fastSeg_A;fastSeg_B];
% 
%     permMedianDist=zeros(permTrials,1);
% 
%     parfor tInd=1:permTrials
%         %shiftAmount=1:length(allBChange);
%         shiftAmount=1:(3600*2/5);
% 
%         permBChange=circshift(allBChange,randsample(shiftAmount,1));
%         permFSeg=circshift(allFastSeg,randsample(shiftAmount,1));
% 
%         permBPoints=find(permBChange);
%         permFPoints=find(permFSeg);
% 
%         permDist=zeros(length(permBPoints),1);
% 
%         for bInd=1:length(permBPoints)
%             permDist(bInd)=min(abs(permBPoints(bInd)-permFPoints));
%         end
% 
%         permMedianDist(tInd)=median(permDist);
%     end
% 
%     matchPVal(sInd)=sum(permMedianDist<=medianDist)/permTrials;
% 
%     medianTime(sInd)=medianDist;
%     permTime(sInd)=mean(permMedianDist);
% end

%% Load intermediate files from each participant
subplot(2,1,2)

cla
pairError=std(medianTime-permTime)*1.96/sqrt(length(medianTime));
bar([1 2],[mean(medianTime) mean(permTime)]); hold on
er=errorbar([1 2],[mean(medianTime) mean(permTime)],[pairError/2 pairError/2],'CapSize',50,'LineWidth',2);
er.Color = [0 0 0];
er.LineStyle = 'none';

xticks([1 2])
xticklabels({'Actual\newline time','Time if\newline random'})
ylabel('Time (secs)')
title('Time between neural and behavioral transitions')
set(gca,'FontSize',15)
set(gcf,'color','w')
set(gca,'linewidth',2)

f=gcf;
f.Theme="light";