%% Generate Figure 1 main results
% Created on 20260209 by Max B Wag

% Load electrode data
load('Data/Fig1_IntermediateData.mat','subjList','electrodeAlpha','electrodeBeta','electrodeMNI','electrode_ROI','subj_ROI','DK_LUT')

all_mni_coordinates=cat(1,electrodeMNI{:});
all_alpha=cat(1,electrodeAlpha{:});
all_beta=cat(1,electrodeBeta{:});
all_decay=(1/2).^(1./all_beta)*5/3600;

removeElecs=all_decay>24; % remove electrodes w/ numerical errors
all_alpha(removeElecs)=NaN;
all_beta(removeElecs)=NaN;
all_decay(removeElecs)=NaN;

subject_index=zeros(length(all_beta),1);
writeInd=1;

for subjInd=1:length(subjList)
    endWriteInd=writeInd+length(electrodeAlpha{subjInd})-1;
    subject_index(writeInd:endWriteInd)=subjInd;
    writeInd=endWriteInd+1;
end

useElectrodes=~isnan(all_alpha);

%%

DK_Idx=cellfun(@str2num,DK_LUT{1,1});
DK_Labels=DK_LUT{1,2};

numSubjs=length(subj_ROI);

[roiList]=unique(electrode_ROI);
roiNames=DK_Labels(roiList);

%%
use_roi=roiList;
remove_inds=[1];

use_roi(remove_inds)=[];
useNames=roiNames;
useNames(remove_inds)=[];

subjRoiAlpha=nan(numSubjs,length(use_roi));
subjRoiBeta=nan(numSubjs,length(use_roi));

for roiInd=1:length(use_roi)
    myROI=use_roi(roiInd);
    
    for sInd=1:numSubjs
        eInds=subj_ROI{sInd}==myROI;
        
        if sum(eInds)>0
            subjRoiAlpha(sInd,roiInd)=mean(electrodeAlpha{sInd}(eInds));
            subjRoiBeta(sInd,roiInd)=mean(electrodeBeta{sInd}(eInds));
        end
    end
end

%% Sort DK regions into nets
DMN_rois=[42,75,37,70,24,57,22,55,26,59,29,62,16,49,30,63,5,12,46,79,39,72];
DMN_names=useNames(DMN_rois);

DAN_rois=[43,76,29,62,18,51,42,75];
DAN_names=useNames(DAN_rois);

SAN_rois=[48,82,17,50,22,55,45,78,26,59];
SAN_names=useNames(SAN_rois);

SM_rois=[16,31,36,38,44,49,64,69,71,77];
SM_names=useNames(SM_rois);

CONN_rois=[17,37,50,70,39,72,21,54];
CONN_names=useNames(CONN_rois);

VN_rois=[25 27 58 60];
VN_names=useNames(VN_rois);

netIndices={DMN_rois,DAN_rois,SAN_rois,...
    SM_rois,CONN_rois,VN_rois};

electrodeNetInds=zeros(length(electrode_ROI),1);

netAlpha=nan(numSubjs,length(netIndices));
netBeta=nan(numSubjs,length(netIndices));

for netInd=1:length(netIndices)
    myNetGroup=use_roi(netIndices{netInd});
    
    for sInd=1:numSubjs
        eInds=ismember(subj_ROI{sInd},myNetGroup);
        
        if sum(eInds)>0
            netAlpha(sInd,netInd)=mean(electrodeAlpha{sInd}(eInds));
            netBeta(sInd,netInd)=mean(electrodeBeta{sInd}(eInds));
        end
    end
    
    allEInds=ismember(electrode_ROI,myNetGroup);
    
    electrodeNetInds(allEInds)=netInd;
end

%%

alpha_NetLME=cell(6);
beta_NetLME=cell(6);

alpha_NetPvals=zeros(6);
alpha_NetCoefs=zeros(6);
beta_NetPvals=zeros(6);
beta_NetCoefs=zeros(6);

for netA=1:5
    for netB=(netA+1):6
        useInds=or(electrodeNetInds==netA,electrodeNetInds==netB);
        net_tbl_alpha=table(electrodeNetInds(useInds)==netA,...
            all_alpha(useInds), subject_index(useInds),'VariableNames', {'l','y','s'});
        net_tbl_beta=table(electrodeNetInds(useInds)==netA,...
            all_beta(useInds), subject_index(useInds),'VariableNames', {'l','y','s'});

        alpha_NetLME{netA,netB}=fitlme(net_tbl_alpha, 'y ~ l + (1|s)');
        beta_NetLME{netA,netB}=fitlme(net_tbl_beta, 'y ~ l + (1|s)');
        
        alpha_NetPvals(netA,netB)=alpha_NetLME{netA,netB}.Coefficients(2,6);
        alpha_NetCoefs(netA,netB)=alpha_NetLME{netA,netB}.Coefficients(2,2);
        beta_NetPvals(netA,netB)=beta_NetLME{netA,netB}.Coefficients(2,6);
        beta_NetCoefs(netA,netB)=beta_NetLME{netA,netB}.Coefficients(2,2);
    end
end

triuIdx=triu(true(6),1);
alphaSigInds=fdr_bh(alpha_NetPvals(triuIdx));
alphaSigMat=zeros(6);
alphaSigMat(triuIdx)=alphaSigInds;
alpha_NetCoefs(~alphaSigMat)=0;
alpha_NetCoefs=alpha_NetCoefs-alpha_NetCoefs.';

betaSigInds=fdr_bh(beta_NetPvals(triuIdx));
betaSigMat=zeros(6);
betaSigMat(triuIdx)=betaSigInds;
beta_NetCoefs(~betaSigMat)=0;
beta_NetCoefs=beta_NetCoefs-beta_NetCoefs.';

%%
mean_alpha=zeros(6,1);
se_alpha=zeros(6,1);

mean_beta=zeros(6,1);
se_beta=zeros(6,1);

mean_alpha(1)=nanmean(all_alpha(electrodeNetInds==1));
se_alpha(1)=(double(alpha_NetLME{1,2}.Coefficients(2,2))-double(alpha_NetLME{1,2}.Coefficients(2,7)))/2;

mean_beta(1)=nanmean(all_beta(electrodeNetInds==1));
se_beta(1)=(double(beta_NetLME{1,2}.Coefficients(2,2))-double(beta_NetLME{1,2}.Coefficients(2,7)))/2;

for netInd=2:6
    mean_alpha(netInd)=mean_alpha(1)-double(alpha_NetLME{1,netInd}.Coefficients(2,2));
    se_alpha(netInd)=(double(alpha_NetLME{1,netInd}.Coefficients(2,2))-double(alpha_NetLME{1,netInd}.Coefficients(2,7)))/2;
    
    mean_beta(netInd)=mean_beta(1)-double(beta_NetLME{1,netInd}.Coefficients(2,2));
    se_beta(netInd)=(double(beta_NetLME{1,netInd}.Coefficients(2,2))-double(beta_NetLME{1,netInd}.Coefficients(2,7)))/2;
end

%%
subplot(1,2,1); cla
errorbar(mean_alpha,se_alpha,'x','LineWidth',2,'CapSize',20,'MarkerSize',20,'Color','k')
xlim([0.5 6.5])
ylim([0.08 0.15])
xticks(1:6)
xticklabels({'DMN','DAN','SAN','SM','CON','VIS'})
ylabel('Autocorrelation')
title('Autocorrelation at one hr')

set(gca,'FontSize',18)
set(gca,'LineWidth',2)
subplot(1,2,2); cla
errorbar(mean_beta,se_beta,'x','LineWidth',2,'CapSize',20,'MarkerSize',20,'Color','k')
xlim([0.5 6.5])
xticks(1:6)
ylim([-0.27 -0.19])
xticklabels({'DMN','DAN','SAN','SM','CON','VIS'})
ylabel('Decay rate')
title('Autocorrelation decay rate')

set(gca,'FontSize',18)
set(gcf,'Color','w')
set(gca,'LineWidth',2)

f=gcf;
f.Theme="light";