% Generate Figure 6 main results
% Created on 20260214 by Max B Wang

%% Example of EP1117_SleepDeprivation.m, loads sleep deprivation transition data for single participant
% 
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% sInd=1;
% subjID=subjList{sInd};
% 
% anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
% 
% ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
% subjPath=[ECOG_Dir subjID '/'];
% load([subjPath 'RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% 
% load('/home/mwang/ChangePoints/Data/20221228_BurstDistribution_PCA_BP_10min.mat','subjList','displacementList_Euc','distanceList_Euc','trajEndPointList')
% load('/home/mwang/ChangePoints/Data/20220518_ChaosSpeed.mat','chaosSegList')
% 
% %load([anotDir 'FullAnnotationTimeStamps.mat'],'timeInds_A','timeInds_B','labels_A','labels_B')
% 
% %timeInds_A=[floor(11*3600/5) floor(23*3600/5)]+2*24*3600/5;
% timeInds_A=[floor(13*3600/5) floor(18.5*3600/5)]+24*3600/5;
% timeInds_B=[floor(14*3600/5) floor(26*3600/5)]+4*24*3600/5;
% 
% featureMat=trimScores;
% 
% speedVec=zeros(size(featureMat,1)-1,1);
% 
% for tInd=1:length(speedVec)
% 	speedVec(tInd)=pdist2(featureMat(tInd,:),featureMat(tInd+1,:));
% end
% 
% fastSegs=zeros(size(featureMat,1)-1,1);
% 
% subjEndPoints=trajEndPointList{sInd};
% 
% for eInd=1:size(subjEndPoints,1)
% 	fastSegs(subjEndPoints(eInd,1):subjEndPoints(eInd,2))=1;
% end
% 
% segLength=10*60/5;
% myChaosSeg=chaosSegList{sInd};
% 
% chaosVec=nan(size(featureMat,1),1);
% 
% for segInd=1:length(myChaosSeg)
% 	tStart=(segInd-1)*segLength+1;
% 	tEnd=tStart+segLength-1;
% 
% 	chaosVec(tStart:tEnd)=myChaosSeg(segInd);
% end
% 
% fastSeg_A=fastSegs(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% speedVec_A=speedVec(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% featureMat_A=featureMat(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% chaosVec_A=chaosVec(timeInds_A(1):min([length(fastSegs) timeInds_A(2)]),:);
% 
% remove_A=isnan(speedVec_A);
% fastSeg_A(remove_A(1:length(fastSeg_A)))=[];
% speedVec_A(remove_A(1:length(speedVec_A)))=[];
% featureMat_A(remove_A(1:length(speedVec_A)),:)=[];
% chaosVec_A(remove_A(1:length(speedVec_A)),:)=[];
% 
% fastSeg_B=fastSegs(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% speedVec_B=speedVec(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% featureMat_B=featureMat(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% chaosVec_B=chaosVec(timeInds_B(1):min([length(fastSegs) timeInds_B(2)]),:);
% 
% remove_B=isnan(speedVec_B);
% fastSeg_B(remove_B(1:length(fastSeg_B)))=[];
% speedVec_B(remove_B(1:length(speedVec_B)))=[];
% featureMat_B(remove_B(1:length(speedVec_B)),:)=[];
% chaosVec_B(remove_B(1:length(speedVec_B)),:)=[];
% 
% fCPoints_A=find((fastSeg_A(2:end)-fastSeg_A(1:end-1))>0);
% distance_neuralTransition_A=zeros(length(fCPoints_A),1);
% displacement_neuralTransition_A=zeros(length(fCPoints_A),1);
% chaos_neuralTransition_A=zeros(length(fCPoints_A),1);
% length_A=zeros(length(fCPoints_A),1);
% 
% for fInd=1:length(fCPoints_A)
% 	nTrans_start=fCPoints_A(fInd);
% 
% 	trailFastSegs=fastSeg_A(fCPoints_A(fInd):end);
% 	nTrans_end=find((trailFastSegs(2:end)-trailFastSegs(1:end-1))==-1,1,'first')+fCPoints_A(fInd)-1;
% 
% 	if isempty(nTrans_end)
% 	    nTrans_end=length(fastSeg_A);
% 	end
% 
% 	distance_neuralTransition_A(fInd)=sum(speedVec_A(nTrans_start:nTrans_end));
% 	displacement_neuralTransition_A(fInd)=pdist2(featureMat_A(nTrans_start,:),featureMat_A(nTrans_end,:));
% 	chaos_neuralTransition_A(fInd)=nanmean(chaosVec_A(nTrans_start:nTrans_end));
% 	length_A(fInd)=nTrans_end-nTrans_start;
% end
% 
% fCPoints_B=find((fastSeg_B(2:end)-fastSeg_B(1:end-1))>0);
% distance_neuralTransition_B=zeros(length(fCPoints_B),1);
% displacement_neuralTransition_B=zeros(length(fCPoints_B),1);
% chaos_neuralTransition_B=zeros(length(fCPoints_B),1);
% length_B=zeros(length(fCPoints_B),1);
% 
% for fInd=1:length(fCPoints_B)
% 	nTrans_start=fCPoints_B(fInd);
% 
% 	trailFastSegs=fastSeg_B(fCPoints_B(fInd):end);
% 	nTrans_end=find((trailFastSegs(2:end)-trailFastSegs(1:end-1))==-1,1,'first')+fCPoints_B(fInd)-1;
% 
% 	if isempty(nTrans_end)
% 	    nTrans_end=length(fastSeg_B);
% 	end
% 
% 	distance_neuralTransition_B(fInd)=sum(speedVec_B(nTrans_start:nTrans_end));
% 	displacement_neuralTransition_B(fInd)=pdist2(featureMat_B(nTrans_start,:),featureMat_B(nTrans_end,:));
% 	chaos_neuralTransition_B(fInd)=nanmean(chaosVec_B(nTrans_start:nTrans_end));
% 	length_B(fInd)=nTrans_end-nTrans_start;
% end
% 
% dvdRatio_A=distance_neuralTransition_A./displacement_neuralTransition_A;
% dvdRatio_B=distance_neuralTransition_B./displacement_neuralTransition_B;
% 
% [~,pval_dvd,~,stat_dvd]=ttest2(dvdRatio_A,dvdRatio_B);
% [~,pval_chaos,~,stat_chaos]=ttest2(chaos_neuralTransition_A,chaos_neuralTransition_B);

%% Load sleep deprivation transition data across all participants
% commandList={'EP1135_SleepDeprivation','EP1149_SleepDeprivation','EP1163_SleepDeprivation',...
%     'EP1136_SleepDeprivation','EP1155_SleepDeprivation','EP1137_SleepDeprivation','EP1173_SleepDeprivation','EP1117_SleepDeprivation'};
% 
% dvd_list=cell(length(commandList),2);
% dist_list=cell(length(commandList),2);
% disp_list=cell(length(commandList),2);
% chaos_list=cell(length(commandList),2);
% 
% for cInd=1:length(commandList)
% 	eval(commandList{cInd})
% 
% 	dvd_list{cInd,1}=dvdRatio_A;
% 	dvd_list{cInd,2}=dvdRatio_B;
% 
% 	dist_list{cInd,1}=distance_neuralTransition_A;
% 	dist_list{cInd,2}=distance_neuralTransition_B;
% 
% 	disp_list{cInd,1}=displacement_neuralTransition_A;
% 	disp_list{cInd,2}=displacement_neuralTransition_B;
% 
% 	chaos_list{cInd,1}=chaos_neuralTransition_A;
% 	chaos_list{cInd,2}=chaos_neuralTransition_B;
% end

%% Load intermediate data files across all participants
load('Data/Fig6_IntermediateData.mat','commandList','dvd_list','dist_list','disp_list','chaos_list')

writeInd=1;
entryLengths=cellfun(@length,dvd_list);

dvd_vec=zeros(sum(entryLengths(:)),1);
dist_vec=zeros(sum(entryLengths(:)),1);
disp_vec=zeros(sum(entryLengths(:)),1);
chaos_vec=zeros(sum(entryLengths(:)),1);
day_vec=zeros(sum(entryLengths(:)),1);
subj_vec=zeros(sum(entryLengths(:)),1);

for sInd=1:length(dvd_list)
	myLength=entryLengths(sInd,1);
	writeBlock=writeInd:(writeInd+myLength-1);

	dvd_vec(writeBlock)=dvd_list{sInd,1};
	dist_vec(writeBlock)=dist_list{sInd,1};
	disp_vec(writeBlock)=disp_list{sInd,1};
	chaos_vec(writeBlock)=chaos_list{sInd,1};
	day_vec(writeBlock)=1;
	subj_vec(writeBlock)=sInd;

	writeInd=writeInd+myLength;

	myLength=entryLengths(sInd,2);
	writeBlock=writeInd:(writeInd+myLength-1);

	dvd_vec(writeBlock)=dvd_list{sInd,2};
	dist_vec(writeBlock)=dist_list{sInd,2};
	disp_vec(writeBlock)=disp_list{sInd,2};
	chaos_vec(writeBlock)=chaos_list{sInd,2};
	day_vec(writeBlock)=2;
	subj_vec(writeBlock)=sInd;
	
	writeInd=writeInd+myLength;
end

dist_table=table(dist_vec,day_vec,subj_vec);
disp_table=table(disp_vec,day_vec,subj_vec);
dvd_table=table(dvd_vec,day_vec,subj_vec);
chaos_table=table(chaos_vec,day_vec,subj_vec);

disp_lme=fitlme(disp_table,'disp_vec~1+day_vec+(1|subj_vec)');
dist_lme=fitlme(dist_table,'dist_vec~1+day_vec+(1|subj_vec)');
dvd_lme=fitlme(dvd_table,'dvd_vec~1+day_vec+(1|subj_vec)');
chaos_lme=fitlme(chaos_table,'chaos_vec~1+day_vec+(1|subj_vec)');

plotColors=distinguishable_colors(length(commandList));
randDev=0.1*randn(length(commandList),1);

subplot(1,2,1)
cla; hold on

for sInd=1:length(commandList)
    plotInds=subj_vec==sInd;
    inds_a=and(plotInds,day_vec==1);
    inds_b=and(plotInds,day_vec==2);

    subj_mean=[nanmean(dvd_vec(inds_a)) nanmean(dvd_vec(inds_b))];
    subj_se=1.96*[nanstd(dvd_vec(inds_a))/sqrt(sum(inds_a)) nanstd(dvd_vec(inds_b))/sqrt(sum(inds_b))];

    errorbar([0.75+randDev(sInd) 2.25+randDev(sInd)],subj_mean,subj_se,'s','LineWidth',1,'CapSize',7.5,'MarkerSize',7.5,'Color',plotColors(sInd,:),'MarkerFaceColor',plotColors(sInd,:))
end

dvd_mean=[dvd_lme.Coefficients.Estimate(1)+dvd_lme.Coefficients.Estimate(2) dvd_lme.Coefficients.Estimate(1)+2*dvd_lme.Coefficients.Estimate(2)];
dvd_ebar=[(dvd_lme.Coefficients.Upper(2)-dvd_lme.Coefficients.Lower(2))/2 (dvd_lme.Coefficients.Upper(2)-dvd_lme.Coefficients.Lower(2))/2];

errorbar([1 2],dvd_mean,dvd_ebar,'-o','LineWidth',1.5,'CapSize',20,'MarkerSize',7.5,'Color','k','MarkerFaceColor','k')
xlim([0.5 2.5])
xticks([1 2])
xticklabels({'Baseline','Sleep\newlinedeprived'})
ylabel('Distance to\newlinedisplacement ratio')
set(gca,'FontSize',15)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.02, 0.02])

subplot(1,2,2)
cla; hold on

for sInd=1:length(commandList)
    plotInds=subj_vec==sInd;
    inds_a=and(plotInds,day_vec==1);
    inds_b=and(plotInds,day_vec==2);

    subj_mean=[nanmean(chaos_vec(inds_a)) nanmean(chaos_vec(inds_b))];
    subj_se=1.96*[nanstd(chaos_vec(inds_a))/sqrt(sum(inds_a)) nanstd(chaos_vec(inds_b))/sqrt(sum(inds_b))];

    errorbar([0.75+randDev(sInd) 2.25+randDev(sInd)],subj_mean,subj_se,'s','LineWidth',1,'CapSize',7.5,'MarkerSize',7.5,'Color',plotColors(sInd,:),'MarkerFaceColor',plotColors(sInd,:))
end

chaos_mean=[chaos_lme.Coefficients.Estimate(1)+chaos_lme.Coefficients.Estimate(2) chaos_lme.Coefficients.Estimate(1)+2*chaos_lme.Coefficients.Estimate(2)];
chaos_ebar=[(chaos_lme.Coefficients.Upper(2)-chaos_lme.Coefficients.Lower(2))/2 (chaos_lme.Coefficients.Upper(2)-chaos_lme.Coefficients.Lower(2))/2];

errorbar([1 2],chaos_mean,chaos_ebar,'-o','LineWidth',1.5,'CapSize',20,'MarkerSize',7.5,'Color','k','MarkerFaceColor','k')
xlim([0.5 2.5])

xticks([1 2])
xticklabels({'Baseline','Sleep\newlinedeprived'})
ylabel('Transition chaoticity')

set(gca,'FontSize',15)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.02, 0.02])

f=gcf;
f.Theme="light";

%% Example script of SlowManifold_SleepDeprivation_EP1117.m which loads individual sleep deprived slow manifold activations for a single participant
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% sInd=1;
% subjID=subjList{sInd};
% 
% annotMat=load(['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/FullAnnotationTimeStamps.mat']);
% 
% base_A=time2num(duration(12,45,0),'seconds')/5;
% end_A=time2num(duration(18,50,0),'seconds')/5;
% offset_A=annotMat.timeInds_B(1);
% 
% oActive_A=base_A+offset_A+find(sum(annotMat.labels_B(base_A:end_A,2:end),2)>0);
% wRest_A=base_A+offset_A+find(sum(annotMat.labels_B(base_A:end_A,:),2)==0);
% 
% base_B=floor(4*24*3600/5+time2num(duration(0,17,25),'seconds')/5);
% 
% %oActive_B=base_B+[floor(time2num(duration(14,5,40),'seconds')/5):floor(time2num(duration(15,40,45),'seconds')/5) floor(time2num(duration(22,0,0),'seconds')/5):floor(time2num(duration(24,0,0),'seconds')/5)];
% oActive_B=base_B+[floor(time2num(duration(22,0,0),'seconds')/5):floor(time2num(duration(24,0,0),'seconds')/5)];
% wRest_B=base_B+[floor(time2num(duration(19,56,30),'seconds')/5):floor(time2num(duration(20,9,10),'seconds')/5)];
% sleep_B=base_B+[floor(time2num(duration(8,30,0),'seconds')/5):floor(time2num(duration(13,40,0),'seconds')/5)];
% 
% anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
% 
% ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
% 
% subjPath=[ECOG_Dir subjID '/'];
% load([subjPath 'RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');
% kopMats=load([subjPath 'KOP_Models/KOP_Mats_FE_10_Recalculated.mat']);
% 
% kopStates=kopMats.kopStates;
% kopAttractor=kopMats.kop_Attractor;
% 
% [V,D]=eig(kopMats.kop_A);
% eigVals=diag(D);
% [~,maxEval]=max(real(eigVals));
% slowManifold=real(V(:,maxEval));
% 
% projVector=slowManifold;
% projVector=-projVector./sqrt(projVector.'*projVector);
% 
% axisProjection=kopStates*projVector-kopAttractor.'*projVector;
% axisProjection=axisProjection-nanmean(axisProjection);
% 
% stateProjection_A=[nanmean(axisProjection(oActive_A)) nanmean(axisProjection(wRest_A))]
% stateProjection_B=[nanmean(axisProjection(oActive_B)) nanmean(axisProjection(wRest_B)) nanmean(axisProjection(sleep_B))]
% 
% testProjection=axisProjection(annotMat.timeInds_A(1):annotMat.timeInds_A(2));
% testProjection=testProjection(annotMat.labels_A(:,1)==0);
% testProjection(isnan(testProjection))=[];
% aCorrVec=zeros(floor(length(testProjection)*1/4),1);
% 
% parfor k=1:length(aCorrVec)
% 	aCorrVec(k)=corr(testProjection(1:end-k),testProjection((1+k):end));
% end
% 
% aCorrVec_oA_A=zeros(floor(length(oActive_A)*1/4),1);
% proj_oA_A=axisProjection(oActive_A);
% proj_oA_A(isnan(proj_oA_A))=[];
% 
% parfor k=1:length(aCorrVec_oA_A)
% 	aCorrVec_oA_A(k)=corr(proj_oA_A(1:end-k),proj_oA_A((1+k):end));
% end
% 
% aCorrVec_wR_A=zeros(floor(length(wRest_A)*1/4),1);
% proj_wR_A=axisProjection(wRest_A);
% 
% parfor k=1:length(aCorrVec_wR_A)
% 	aCorrVec_wR_A(k)=corr(proj_wR_A(1:end-k),proj_wR_A((1+k):end),'rows','complete');
% end
% 
% aCorrVec_oA_B=zeros(floor(length(oActive_B)*1/4),1);
% proj_oA_B=axisProjection(oActive_B);
% 
% parfor k=1:length(aCorrVec_oA_B)
% 	aCorrVec_oA_B(k)=corr(proj_oA_B(1:end-k),proj_oA_B((1+k):end),'rows','complete');
% end
% 
% aCorrVec_wR_B=zeros(floor(length(wRest_B)*1/4),1);
% proj_wR_B=axisProjection(wRest_B);
% 
% parfor k=1:length(aCorrVec_wR_B)
% 	aCorrVec_wR_B(k)=corr(proj_wR_B(1:end-k),proj_wR_B((1+k):end),'rows','complete');
% end
% 
% aCorrVec_oA_A(find(aCorrVec_oA_A<0,1):end)=[];
% aCorrVec_wR_A(find(aCorrVec_wR_A<0,1):end)=[];
% aCorrVec_oA_B(find(aCorrVec_oA_B<0,1):end)=[];
% aCorrVec_wR_B(find(aCorrVec_wR_B<0,1):end)=[];
% aCorrVec(find(aCorrVec<0,1):end)=[];
% 
% 
% aCorrVec=aCorrVec_oA_A;
% V_oA_A=1+2*sum((1-(1:length(aCorrVec))/length(oActive_A)).*aCorrVec.');
% V_wR_A=1+2*sum((1-(1:length(aCorrVec))/length(wRest_A)).*aCorrVec.');
% V_oA_B=1+2*sum((1-(1:length(aCorrVec))/length(oActive_B)).*aCorrVec.');
% V_wR_B=1+2*sum((1-(1:length(aCorrVec))/length(wRest_B)).*aCorrVec.');
% V_S_B=1+2*sum((1-(1:length(aCorrVec))/length(sleep_B)).*aCorrVec.');
% 
% se_oA_A=1.96*sqrt(V_oA_A*nanvar(axisProjection(oActive_A))/length(oActive_A));
% se_wR_A=1.96*sqrt(V_wR_A*nanvar(axisProjection(wRest_A))/length(wRest_A));
% se_oA_B=1.96*sqrt(V_oA_B*nanvar(axisProjection(oActive_B))/length(oActive_B));
% se_wR_B=1.96*sqrt(V_wR_B*nanvar(axisProjection(wRest_B))/length(wRest_B));
% se_S_B=1.96*sqrt(V_S_B*nanvar(axisProjection(sleep_B))/length(sleep_B));
% 
% disp(['SE_A: ' num2str([se_oA_A se_wR_A])])
% disp(['SE_B: ' num2str([se_oA_B se_wR_B])])
% SE_A=[se_oA_A se_wR_A];
% SE_B=[se_oA_B se_wR_B se_S_B];

%% Load sleep deprivation data across all participants
% commandList={'SlowManifold_SleepDeprivation_EP1135','SlowManifold_SleepDeprivation_EP1149','SlowManifold_SleepDeprivation_EP1163','SlowManifold_SleepDeprivation_EP1136','SlowManifold_SleepDeprivation_EP1155','SlowManifold_SleepDeprivation_EP1137','SlowManifold_SleepDeprivation_EP1173','SlowManifold_SleepDeprivation_EP1117'};
% 
% oActive_list=cell(length(commandList),2);
% wRest_list=cell(length(commandList),2);
% effectiveSamples_oA=zeros(length(commandList),2);
% effectiveSamples_wR=zeros(length(commandList),2);
% 
% oActive_mean=zeros(length(commandList),2);
% wRest_mean=zeros(length(commandList),2);
% 
% for cInd=1:length(commandList)
% 	eval(commandList{cInd})
% 	oActive_list{cInd,1}=axisProjection(oActive_A);
% 	oActive_list{cInd,2}=axisProjection(oActive_B);
% 
% 	wRest_list{cInd,1}=axisProjection(wRest_A);
% 	wRest_list{cInd,2}=axisProjection(wRest_B);
% 
% 	effectiveSamples_oA(cInd,1)=length(oActive_A)/V_oA_A;
% 	effectiveSamples_oA(cInd,2)=length(oActive_B)/V_oA_B;
% 	effectiveSamples_wR(cInd,1)=length(wRest_A)/V_wR_A;
% 	effectiveSamples_wR(cInd,2)=length(wRest_B)/V_wR_B;
% 
% 	oActive_mean(cInd,1)=nanmean(axisProjection(oActive_A));
% 	oActive_mean(cInd,2)=nanmean(axisProjection(oActive_B));
% 	wRest_mean(cInd,1)=nanmean(axisProjection(wRest_A));
% 	wRest_mean(cInd,2)=nanmean(axisProjection(wRest_B));
% end
% 
% effectiveSamples_oA(effectiveSamples_oA<4)=2;
% effectiveSamples_wR(effectiveSamples_wR<4)=2;
% 
% subjCorr_oA=cell(length(commandList),2);
% subjCorr_wR=cell(length(commandList),2);
% 
% subj_mean_oA=mean(oActive_mean,2);
% subj_mean_wR=mean(wRest_mean,2);
% 
% for cInd=1:length(commandList)
% 	subjCorr_oA{cInd,1}=oActive_list{cInd,1}-subj_mean_oA(cInd);
% 	subjCorr_oA{cInd,2}=oActive_list{cInd,2}-subj_mean_oA(cInd);
% 
% 	subjCorr_wR{cInd,1}=wRest_list{cInd,1}-subj_mean_wR(cInd);
% 	subjCorr_wR{cInd,2}=wRest_list{cInd,2}-subj_mean_wR(cInd);
% end
% 
% oA_mean=[nanmean(cat(1,subjCorr_oA{:,1})) nanmean(cat(1,subjCorr_oA{:,2}))];
% oA_SE=[1.96*nanstd(cat(1,subjCorr_oA{:,1}))/sqrt(sum(effectiveSamples_oA(:,1))) 1.96*nanstd(cat(1,subjCorr_oA{:,2}))/sqrt(sum(effectiveSamples_oA(:,2)))];
% 
% wR_mean=[nanmean(cat(1,subjCorr_wR{:,1})) nanmean(cat(1,subjCorr_wR{:,2}))];
% wR_SE=[1.96*nanstd(cat(1,subjCorr_wR{:,1}))/sqrt(sum(effectiveSamples_wR(:,1))) 1.96*nanstd(cat(1,subjCorr_wR{:,2}))/sqrt(sum(effectiveSamples_wR(:,2)))];
% 
% z_oA=(oA_mean(2)-oA_mean(1))/(nanstd(cat(1,subjCorr_oA{:,1}))/sqrt(sum(effectiveSamples_oA(:,1)))+nanstd(cat(1,subjCorr_oA{:,2}))/sqrt(sum(effectiveSamples_oA(:,2))));
% p_oA=(1-normcdf(z_oA))*2;
% 
% z_wR=(wR_mean(2)-wR_mean(1))/(nanstd(cat(1,subjCorr_wR{:,1}))/sqrt(sum(effectiveSamples_wR(:,1)))+nanstd(cat(1,subjCorr_wR{:,2}))/sqrt(sum(effectiveSamples_wR(:,2))));
% p_wR=(1-normcdf(z_wR))*2;

%%
load('Data/Fig6_IntermediateData.mat','commandList','dvd_list','dist_list','disp_list','chaos_list','wRest_mean','oActive_mean','effectiveSamples_oA','effectiveSamples_wR','oActive_list','wRest_list','oA_mean','wR_mean','oA_SE','wR_SE')

oActive_SE=zeros(length(commandList),2);
wRest_SE=zeros(length(commandList),2);

for cInd=1:length(commandList)
	oActive_SE(cInd,1)=nanstd(oActive_list{cInd,1})/sqrt(effectiveSamples_oA(cInd,1));
	oActive_SE(cInd,2)=nanstd(oActive_list{cInd,2})/sqrt(effectiveSamples_oA(cInd,2));

    wRest_SE(cInd,1)=nanstd(wRest_list{cInd,1})/sqrt(effectiveSamples_wR(cInd,1));
	wRest_SE(cInd,2)=nanstd(wRest_list{cInd,2})/sqrt(effectiveSamples_wR(cInd,2));
end

plotColors=distinguishable_colors(length(commandList));
randDev=0.1*randn(length(commandList),1);

figure
for sInd=1:length(commandList)
    subplot(1,2,1); hold on
    errorbar([0.75+randDev(sInd) 2.25+randDev(sInd)],[oActive_mean(sInd,1) oActive_mean(sInd,2)],...
        [oActive_SE(sInd,1) oActive_SE(sInd,2)],'s','LineWidth',1,'CapSize',7.5,'MarkerSize',10,'Color',plotColors(sInd,:),'MarkerFaceColor',plotColors(sInd,:))

    subplot(1,2,2); hold on
    errorbar([0.75+randDev(sInd) 2.25+randDev(sInd)],[wRest_mean(sInd,1) wRest_mean(sInd,2)],...
        [wRest_SE(sInd,1) wRest_SE(sInd,2)],'s','LineWidth',1,'CapSize',7.5,'MarkerSize',10,'Color',plotColors(sInd,:),'MarkerFaceColor',plotColors(sInd,:))
end

subplot(1,2,1)
errorbar([1 2],oA_mean+mean(mean(oActive_mean,2)),oA_SE,'-o','LineWidth',1.5,'CapSize',20,'MarkerSize',7.5,'Color','k','MarkerFaceColor','k')
xlim([0.5 2.5])
set(gca,'FontSize',15)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.02, 0.02])

xticks([1 2])
xticklabels({'Baseline','Sleep\newlinedeprived'})
ylabel('Center manifold projection')
title('Outwardly oriented behavior')

subplot(1,2,2)
errorbar([1 2],wR_mean+mean(mean(wRest_mean,2)),wR_SE,'-o','LineWidth',1.5,'CapSize',20,'MarkerSize',7.5,'Color','k','MarkerFaceColor','k')
xlim([0.5 2.5])
set(gca,'FontSize',15)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.02, 0.02])

xticks([1 2])
xticklabels({'Baseline','Sleep\newlinedeprived'})
ylabel('Center manifold projection')
title('Wakeful rest')

f=gcf;
f.Theme="light";

%% Load individual sleep deprivation velocity data
% commandList={'EP1135_SleepDeprivation','EP1149_SleepDeprivation','EP1163_SleepDeprivation','EP1136_SleepDeprivation','EP1155_SleepDeprivation','EP1137_SleepDeprivation','EP1173_SleepDeprivation','EP1117_SleepDeprivation'};
% 
% speed_list=cell(length(commandList),2);
% effectiveSamples=zeros(length(commandList),2);
% 
% for cInd=1:length(commandList)
% 	eval(commandList{cInd})
% 
% 	speed_list{cInd,1}=speedVec(timeInds_A);
% 	speed_list{cInd,2}=speedVec(timeInds_B);
% 
% 	aCorrVec_A=zeros(floor(length(timeInds_A)*1/4),1);
% 	dataVec=speedVec(timeInds_A);
% 	dataVec(isnan(dataVec))=[];
% 
% 	parfor k=1:length(aCorrVec_A)
% 		aCorrVec_A(k)=corr(dataVec(1:end-k),dataVec((1+k):end));
% 	end
% 
% 	aCorrVec_B=zeros(floor(length(timeInds_B)*1/4),1);
% 	dataVec=speedVec(timeInds_B);
% 	dataVec(isnan(dataVec))=[];
% 
% 	parfor k=1:length(aCorrVec_B)
% 		aCorrVec_B(k)=corr(dataVec(1:end-k),dataVec((1+k):end));
% 	end
% 
% 	aCorrVec_A(find(aCorrVec_A<0,1):end)=[];
% 	aCorrVec_B(find(aCorrVec_B<0,1):end)=[];
% 
% 	V_A=1+2*sum((1-(1:length(aCorrVec_A))/length(timeInds_A)).*aCorrVec_A.');
% 	V_B=1+2*sum((1-(1:length(aCorrVec_B))/length(timeInds_B)).*aCorrVec_B.');
% 
% 	effectiveSamples(cInd,1)=length(timeInds_A)/V_A;
% 	effectiveSamples(cInd,2)=length(timeInds_B)/V_B;
% end

%% Load intermediate files
load('Data/Fig6_IntermediateData.mat','commandList','dvd_list','dist_list',...
    'disp_list','chaos_list','wRest_mean','oActive_mean','effectiveSamples_oA',...
    'effectiveSamples_wR','oActive_list','wRest_list','oA_mean','wR_mean','oA_SE','wR_SE','speed_list','effectiveSamples')

subjCorr_speed=cell(length(commandList),2);
speed_mean=zeros(length(commandList),1);

for cInd=1:length(commandList)
    subjCorr_speed{cInd,1}=speed_list{cInd,1}-nanmean(cat(1,speed_list{cInd,:}));
    subjCorr_speed{cInd,2}=speed_list{cInd,2}-nanmean(cat(1,speed_list{cInd,:}));

    speed_mean(cInd)=nanmean(cat(1,speed_list{cInd,:}));

    effectiveSamples(cInd,1)=length(speed_list{cInd,1})/85;
	effectiveSamples(cInd,2)=length(speed_list{cInd,2})/85;
end

allSpeed_A=cat(1,subjCorr_speed{:,1});
allSpeed_B=cat(1,subjCorr_speed{:,2});

meanSpeed=[nanmean(allSpeed_A) nanmean(allSpeed_B)];
seSpeed=[1.96*nanstd(allSpeed_A)/sum(effectiveSamples(:,1)) 1.96*nanstd(allSpeed_B)/sum(effectiveSamples(:,2))];

plotColors=distinguishable_colors(length(commandList));
randDev=0.15*randn(length(commandList),1);

figure; hold on

for sInd=1:length(commandList)
    mean_a=nanmean(speed_list{sInd,1});
    % se_a=1.96*nanstd(speed_list{sInd,1})/sqrt(effectiveSamples(sInd,1));
    se_a=1.96*nanstd(speed_list{sInd,1})/sqrt(effectiveSamples(sInd,1));

    mean_b=nanmean(speed_list{sInd,2});
    % se_b=1.96*nanstd(speed_list{sInd,2})/sqrt(effectiveSamples(sInd,2));
    se_b=1.96*nanstd(speed_list{sInd,2})/sqrt(effectiveSamples(sInd,2));

    errorbar([0.75+randDev(sInd) 2.25+randDev(sInd)],[mean_a mean_b],...
        [se_a se_b],'s','LineWidth',1,'CapSize',7.5,'MarkerSize',10,'Color',plotColors(sInd,:),'MarkerFaceColor',plotColors(sInd,:))
end

errorbar([1 2],meanSpeed+mean(speed_mean),seSpeed,'-o','LineWidth',1.5,'CapSize',20,'MarkerSize',7.5,'Color','k','MarkerFaceColor','k')
xlim([0.5 2.5])
set(gca,'FontSize',15)
set(gca,'LineWidth',1.5)
set(gca,'TickLength',[0.02, 0.02])

xticks([1 2])
xticklabels({'Baseline','Sleep\newlinedeprived'})
ylabel('Velocity')
f=gcf;
f.Theme="light";