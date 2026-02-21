% Generate Figure 4 main results
% Created on 20260211 by Max B Wang

%% Load individual behavioral classification data

% subjList={'EP1109','EP1117','EP1124','EP1135','EP1173','EP1136','EP1137','EP1149','EP1163'};
% 
% ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% 
% featExp=10;
% 
% linear_aucs=zeros(length(subjList),3);
% kop_aucs=zeros(length(subjList),3);
% 
% for sInd=1:length(subjList)
%     kopData=load([ECOG_Dir subjList{sInd} '/KOP_Models/LASSO_Coefs_BehavOut_FE' num2str(featExp) '.mat']);
%     linData=load(['/home/mwang/VideoFullAnnots/Data/' subjList{sInd} '_RawLasso.mat']);
%     linear_aucs(sInd,:)=linData.aucs;
%     kop_aucs(sInd,:)=kopData.aucs;
% end

%% Load intermediate files

load('Data/Fig4_IntermediateData.mat','linear_aucs','kop_aucs','subjList','d_list','p_list','sig_list')

figure; hold on
for labelInd=1:3
    pairError=nanstd(linear_aucs(:,labelInd)-kop_aucs(:,labelInd))*1.96/sqrt(size(linear_aucs,1));
    
    b=bar(labelInd-0.15,nanmean(linear_aucs(:,labelInd)),'FaceColor','c');
    b.BarWidth=0.2;
    b=bar(labelInd+0.15,nanmean(kop_aucs(:,labelInd)),'FaceColor','g');
    b.BarWidth=0.2;
    
    er=errorbar([labelInd-0.15 labelInd+0.15],[nanmean(linear_aucs(:,labelInd)) nanmean(kop_aucs(:,labelInd))],[pairError/2 pairError/2],'CapSize',20,'LineWidth',1.5);
    er.Color = [0 0 0];
    xticks(1:3)
    xlim([0.5 3.5])
    ylim([0.6 0.85])
    er.LineStyle = 'none';
end

xticklabels({'digital','social','physical'})
ylabel('AUC')
legend({'Network activation','Koopman state'})
set(gca,'FontSize',15)
set(gcf,'color','w')

f=gcf;
f.Theme="light";

%% Determine regions activated with each behavior
% annotList={'EP1117','EP1109','EP1173','EP1124','EP1135','EP1136','EP1137','EP1149','EP1163'};
% 
% allSubjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% ECOG_Dir='/media/mwang/easystore/Processed_Data/';
% 
% d_list=cell(length(annotList),1);
% p_list=cell(length(annotList),1);
% sig_list=cell(length(annotList),1);
% 
% for sInd=1:9
%     disp(sInd)
%     subjID=annotList{sInd};
%     dataPath=[ECOG_Dir subjID '/'];
% 
%     kopMatData=load([dataPath 'KOP_Models/KOP_Mats_FE_10.mat']);
%     pcaKopStates=kopMatData.pca_Kop_States;
% 
%     kopData=load([ECOG_Dir subjID '/KOP_Models/LASSO_Coefs_BehavOut_FE10.mat']);
%     kop_aucs=kopData.aucs;
% 
%     anotDir=['/media/qSTORAGE/homes/mwang/ECOG_Data/Videos/' subjID '/'];
%     load([anotDir 'FullAnnotationTimeStamps.mat'],'timeInds_A','timeInds_B','labels_A','labels_B')
% 
%     fullStates=[pcaKopStates(timeInds_A(1):timeInds_A(2),:);pcaKopStates(timeInds_B(1):timeInds_B(2),:)];
%     fullLabels=[labels_A;labels_B];
%     load('/home/mwang/AnatomyClustering/Data/20220421_PCA_Net.mat','allSubjPC')
% 
%     if sInd==7
%         pcMat=allSubjPC{find(strcmp(allSubjList,subjID),1)}(1:end-1,:);
%         netMat=mean(reshape(pcMat,size(pcMat,1),size(pcMat,2)/5,5),3);
%         fMRI_NetStates=fullStates*netMat;
%     else
%         pcMat=allSubjPC{find(strcmp(allSubjList,subjID),1)};
%         netMat=mean(reshape(pcMat,size(pcMat,1),size(pcMat,2)/5,5),3);
%         fMRI_NetStates=fullStates*netMat;
%     end
% 
%     for behavInd=1:3
%         aveActivation(behavInd,:)=nanmean(fMRI_NetStates(fullLabels(:,behavInd+1)==1,:));
%     end
% end

%%
d_all=cat(3,d_list{:});
p_all=zeros(3,6);
t_all=zeros(3,6);

for behavInd=1:3
    for netInd=1:6
        [~,p_all(behavInd,netInd),~,stats]=ttest(d_all(behavInd,netInd,:));
        t_all(behavInd,netInd)=stats.tstat;
    end
end


%%
figure
bar(t_all.')
xticks(1:6)
xticklabels({'DMN','DAN','SAN','SM','CON','VIS'})
ylabel('t-statistic')
xlim([0.5 6.5])

set(gca,'FontSize',15)
set(gcf,'color','w')
f=gcf;
f.Theme="light";

legend({'digital','social','physical'})

%% Load individual attractor states
% subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
%     'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
%     'EP1170','EP1173','EP1166','EP1169','EP1188'};
% 
% net_Attractor_allSubjs=zeros(length(subjList),6,5);
% 
% for sInd=1:length(subjList)
%     subjID=subjList{sInd};
% 
%     ECOG_Dir='/hpc/projects/group.chang/fomo/clinicalecog/MBW_Data/easystore/Processed_Data/';
% 
%     dataPath=[ECOG_Dir subjID '/'];
%     pcaData=load([dataPath 'RANSAC_PCA_Fixed_SACorr_Mean_Trimmed.mat'],'useCoefs','feature_coefs','mu');
%     kopData=load([dataPath 'KOP_Models/AttractorState_KOP_FE_10.mat'],'kop_Attractor','pca_Attractor');
%     OG_PC_Data=load([dataPath 'RANSAC_PCA_Fixed_SACorr_Mean.mat']);
% 
%     if or(sInd==9,sInd==19) % use updated Koopman models for trimmed PCs
%         kopMats=load([dataPath 'KOP_Models/KOP_Mats_FE_10.mat']);
%         module_Attractor=pcaData.useCoefs*kopMats.pca_Attractor.'+OG_PC_Data.mu.';
%     else
%         module_Attractor=pcaData.useCoefs*kopData.pca_Attractor.'+OG_PC_Data.mu.';
%     end
% 
% 
%     feature_coefs=pcaData.feature_coefs;
%     elec_Attractor=zeros(5,size(feature_coefs,3));
% 
%     for featInd=1:size(feature_coefs,1)
%         for bInd=1:5
%             elec_Attractor(bInd,:)=elec_Attractor(bInd,:)+squeeze(module_Attractor(featInd)*diag(squeeze(feature_coefs(featInd,bInd,:,:)))).';
%         end
%     end
% 
%     %
%     load('/home/maxwell.wang/WeekScripts/Criticality/Data/20220210_NetworkACF_ROIs.mat','electrode_ROI','subj_ROI')
%     fid = fopen('/home/maxwell.wang/WeekScripts/Atlas_ROI/DK_LookupTable.txt');
%     DK_LUT = textscan(fid,'%s%s');
%     fclose(fid);
% 
%     DK_Idx=cellfun(@str2num,DK_LUT{1,1});
%     DK_Labels=DK_LUT{1,2};
% 
%     numSubjs=length(subj_ROI);
% 
%     [roiList]=unique(electrode_ROI);
%     roiNames=DK_Labels(roiList);
% 
%     use_roi=roiList;
%     remove_inds=1;
% 
%     use_roi(remove_inds)=[];
%     useNames=roiNames;
%     useNames(remove_inds)=[];
% 
%     DK_Attractor=nan(length(useNames),5);
% 
%     for dkInd=1:length(useNames)
%         elecInd=subj_ROI{sInd}==use_roi(dkInd);
% 
%         if sum(elecInd)>0
%             DK_Attractor(dkInd,:)=mean(elec_Attractor(:,elecInd),2);
%         end
%     end
% 
%     leftHalf=[1:8 16:48];
%     rightHalf=[9:15 49:82];
% 
%     for hemiInd=1:length(leftHalf)
%         if isnan(DK_Attractor(leftHalf(hemiInd),1)) && ~isnan(DK_Attractor(rightHalf(hemiInd),1))
%             DK_Attractor(leftHalf(hemiInd),:)=DK_Attractor(rightHalf(hemiInd),:);
%         elseif ~isnan(DK_Attractor(leftHalf(hemiInd),1)) && isnan(DK_Attractor(rightHalf(hemiInd),1))
%             DK_Attractor(rightHalf(hemiInd),:)=DK_Attractor(leftHalf(hemiInd),:);
%         end
%     end
% 
%     %
%     DMN_rois=[42,75,37,70,24,57,22,55,26,59,29,62,16,49,30,63,5,12,46,79,39,72];
%     DMN_names=useNames(DMN_rois);
% 
%     DAN_rois=[43,76,29,62,18,51,42,75];
%     DAN_names=useNames(DAN_rois);
% 
%     SAN_rois=[48,82,17,50,22,55,45,78,26,59];
%     SAN_names=useNames(SAN_rois);
% 
%     SM_rois=[16,31,36,38,44,49,64,69,71,77];
%     SM_names=useNames(SM_rois);
% 
%     CONN_rois=[17,37,50,70,39,72,21,54];
%     CONN_names=useNames(CONN_rois);
% 
%     VN_rois=[25 27 58 60];
%     VN_names=useNames(VN_rois);
% 
%     network_rois={DMN_rois,DAN_rois,SAN_rois,SM_rois,CONN_rois,VN_rois};
%     networkMat=zeros(length(useNames),length(network_rois));
% 
%     for netInd=1:6
%         networkMat(network_rois{netInd},netInd)=1;
%     end
% 
%     net_Attractor=zeros(length(network_rois),5);
% 
%     for netInd=1:6
%         net_Attractor(netInd,:)=nanmean(DK_Attractor(networkMat(:,netInd)>0,:),1);
%     end
% 
%     net_Attractor_allSubjs(sInd,:,:)=net_Attractor;
% end
% 
% removeSubjs=isnan(sum(net_Attractor_allSubjs,[2 3]));
% net_Attractor_allSubjs(removeSubjs,:,:)=[];

%%
load('Data/Fig4_IntermediateData.mat','linear_aucs','kop_aucs',...
    'subjList','d_list','p_list','sig_list','net_Attractor_allSubjs')

attractor_aveBands=squeeze(mean(net_Attractor_allSubjs,3));
attractor_aveBands_Norm=attractor_aveBands-repmat(mean(attractor_aveBands,2),1,6);

p_net=zeros(6,1);
t_net=zeros(6,1);
for netInd=1:6
    [~,p_net(netInd),~,stat]=ttest(attractor_aveBands_Norm(:,netInd));
    t_net(netInd)=stat.tstat;
end

sigNets=fdr_bh(p_net); % note these are inaccurate since number of independent tests if only 5, not 6

p_net=zeros(6,1); % Note number of independent tests is five, not six
t_net=zeros(6,1);
for netInd=1:6
    [~,p_net(netInd),~,stat]=ttest(attractor_aveBands_Norm(:,netInd));
    t_net(netInd)=stat.tstat;
end

figure

subplot(1,2,1)
bar(t_net)
xticks(1:6)
xticklabels({'DMN','DAN','SAN','SM','CON','VIS'})
ylabel('t-stat of network activation at attractor')
set(gca,'FontSize',15)
set(gcf,'color','w')
xlim([0.4 6.6])
ylim([-3.5 4])

f=gcf;
f.Theme="light";

%%
load('Data/Fig4_IntermediateData.mat','linear_aucs','kop_aucs',...
    'subjList','d_list','p_list','sig_list','net_Attractor_allSubjs')

attractor_aveNets=squeeze(mean(net_Attractor_allSubjs,2));
attractor_aveNets_Norm=attractor_aveNets-repmat(mean(attractor_aveNets,2),1,5);

p_band=zeros(5,1);
t_band=zeros(5,1);
for bandInd=1:5
    [~,p_band(bandInd),~,stat]=ttest(attractor_aveNets_Norm(:,bandInd));
    t_band(bandInd)=stat.tstat;
end

sigBands=fdr_bh(p_band);

subplot(1,2,2)
bar(t_band)
xticks(1:5)
xticklabels({'\theta','\alpha','\beta_l','\beta_u','\gamma'})
ylabel('t-stat of band activation and attractor')
set(gca,'FontSize',15)
set(gcf,'color','w')
xlim([0.4 5.6])
ylim([-4.75 4.75])
yticks(-5:5)

f=gcf;
f.Theme="light";