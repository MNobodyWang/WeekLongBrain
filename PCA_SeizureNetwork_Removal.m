% Compare principal components to seizure networks
% Created on 20210811 by Max B Wang

% LIST OF SUBJECT IDs TO PROCESS
subjList={'EP1155','EP1156'};

snetSimilarity=cell(length(subjList),1);
simCutoff=zeros(length(subjList),1);

for sInd=1:length(subjList)
    disp(sInd)
    subjID=subjList{sInd};
    featClass=2;
    bandSelector=1;
    useFixed=1;
    aCorr=3;
    
    if aCorr==1
        append='';
    elseif aCorr==2
        append='_ECorr';
    elseif aCorr==3
        append='_Fixed_SACorr_Mean';
    end
    
    ECOG_Dir='/media/mwang/easystore/Processed_Data/';
    bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
    
    figurePath=[ECOG_Dir subjID '/'];
    
    % Load in a variable universalElectrodes which has a list of all electrodes part of the patient's seizure related areas that you want to remove
    electrodeName_Data=load([figurePath 'electrodeIndexing.mat']);
    universalElectrodes=cellstr(electrodeName_Data.universalElectrodes);
    
    PCA_Data=load([figurePath 'RANSAC_PCA' append '.mat'],'useScores','useCoefs','feature_coefs','mu');
    
    useCoefs=PCA_Data.useCoefs;
    %
    % FOR EACH SUBJECT, LABEL ALL ELECTRODES BELONGING TO THE SEIZURE NETWORK
    if strcmp(subjID,'EP1155')
        snet={'LAMY4','LAMY5','LAMY6','LAMY7','LHH1','LHH2','RHH1','RHH2','RAMY1','RAMY2'};
    elseif strcmp(subjID,'EP1156')
        snet={'LHH1','LHH2','LHH3','LHT1','LHT2','LBT1'};
    end
    
    [~,ia,~] = intersect(universalElectrodes,snet);
    snetVec=zeros(length(universalElectrodes),1);
    snetVec(ia)=1;
    snetVec=snetVec/sqrt(snetVec.'*snetVec);
    
    % Store diagonals of feature coefs
    numBands=5;
    numElectrodes=size(VAR_Data.feature_coefs,3);
    numFeats=size(VAR_Data.feature_coefs,1);
    
    diag_coefs=zeros(numBands,numFeats,numElectrodes);
    
    for bInd=1:5
        for fInd=1:numFeats
            diag_coefs(bInd,fInd,:)=diag(squeeze(VAR_Data.feature_coefs(fInd,bInd,:,:)));
        end
    end
    
    numPCs=size(useCoefs,2);
    snetSims=zeros(numPCs,1);
    
    for plotInd=1:numPCs
        plot_Feat_Coefs=useCoefs(:,plotInd);
        
        if sum(plot_Feat_Coefs)<0
            plot_Feat_Coefs=-1*plot_Feat_Coefs;
        end
        
        bandMat=zeros(numElectrodes,5);
        for bInd=1:5
            bandMat(:,bInd)=(plot_Feat_Coefs.'*squeeze(diag_coefs(bInd,:,:))).';
        end
        pcaVec=mean(abs(bandMat),2);
        pcaVec=pcaVec./sqrt(pcaVec.'*pcaVec);
        
        snetSims(plotInd,1)=abs(snetVec.'*pcaVec);
    end
    
    % Permutation testing to assess significance
    numTrials=1000;
    maxSims=zeros(numTrials,1);
    
    for tInd=1:numTrials
        randBandSims=zeros(numPCs,1);
        
        for plotInd=1:numPCs
            coefsVec=rand(numFeats,1);
            
            randMat=zeros(numElectrodes,5);
            for bInd=1:5
                randMat(:,bInd)=(coefsVec.'*squeeze(diag_coefs(bInd,:,:))).';
            end
            
            randVec=mean(abs(randMat),2);
            randVec=randVec./sqrt(randVec.'*randVec);
            
            randBandSims(plotInd)=abs(snetVec.'*randVec);
        end
        
        maxSims(tInd)=max(randBandSims);
    end
    
    subplot(5,4,sInd)
    plot(snetSims,'-o','LineWidth',2); hold on
    plot([1 numPCs],[quantile(maxSims,0.95) quantile(maxSims,0.95)],'r','LineWidth',2)
    xlabel('Component')
    ylabel('Similarity')
    set(gca,'FontSize',15)
    title(subjID,'FontSize',20)
    
    snetSimilarity{sInd}=snetSims;
    simCutoff(sInd)=quantile(maxSims,0.95);
end

set(gcf,'color','w');

% save('Data/20220421_SozSimilarity.mat','subjList','snetSimilarity','simCutoff')

%%
load('Data/20220421_SozSimilarity.mat','subjList','snetSimilarity','simCutoff')
% figure('units','normalized','outerposition',[0 0 1 1])
for sInd=1:length(subjList)
    snetSims=snetSimilarity{sInd};
    plotCutoff=simCutoff(sInd);
    numPCs=length(snetSims);
    
    subplot(5,4,sInd)
    plot(snetSims,'-o','LineWidth',2); hold on
    plot([1 numPCs],[plotCutoff plotCutoff],'r','LineWidth',2)
    xlabel('Subnetwork')
    ylabel('Similarity')
    set(gca,'FontSize',11)
    title(subjList{sInd},'FontSize',13)
end

set(gcf,'color','w');
% orient(gcf,'landscape')
% print('/home/mwang/SevenDayFigures/SOZ_Similarity','-dpdf','-fillpage')

%%
load('Data/20220421_SozSimilarity.mat','subjList','snetSimilarity','simCutoff')
for sInd=1:length(subjList)
    disp(sInd)
%     subplot(5,4,sInd)
%     plot(snetSimilarity{sInd},'-o','LineWidth',2); hold on
%     plot([1 length(snetSimilarity{sInd})],[simCutoff(sInd) simCutoff(sInd)],'r','LineWidth',2)
%     xlabel('Component')
%     ylabel('Similarity')
%     set(gca,'FontSize',15)
%     % title(['Eigenmode Similarity to Seizure Onset Zone: ' subjID],'FontSize',30)
%     title(subjList{sInd},'FontSize',20)

    subjID=subjList{sInd};
    featClass=2;
    bandSelector=1;
    useFixed=1;
    aCorr=3;
    
    if aCorr==1
        append='';
    elseif aCorr==2
        append='_ECorr';
    elseif aCorr==3
        append='_Fixed_SACorr_Mean';
    end
    
    ECOG_Dir='/media/mwang/easystore/Processed_Data/';
    bandNames={'Theta','Alpha','Beta_l','Beta_u','Gamma'};
    
    figurePath=[ECOG_Dir subjID '/'];
    
    PCA_Data=load([figurePath 'RANSAC_PCA' append '_Trimmed.mat'],'trimScores','useCoefs','mu','feature_coefs','allScores','allCoefs','allMu');
    OG_PC_Data=load([figurePath 'RANSAC_PCA' append '.mat'],'feature_coefs');
%     allScores=PCA_Data.trimScores;
%     allCoefs=PCA_Data.useCoefs;
%     allMu=PCA_Data.mu;
    
    allScores=PCA_Data.allScores;
    allCoefs=PCA_Data.allCoefs;
    allMu=PCA_Data.allMu;
    
    if ~isnan(simCutoff(sInd))
        passCoefs=snetSimilarity{sInd}<simCutoff(sInd);
    else
        passCoefs=true(size(allScores,2),1);
    end
    
    trimScores=allScores(:,passCoefs);
    useCoefs=allCoefs(:,passCoefs);
    mu=allMu(passCoefs);
    feature_coefs=OG_PC_Data.feature_coefs;
    save([figurePath 'RANSAC_PCA' append '_Trimmed.mat'],'trimScores',...
        'useCoefs','feature_coefs','mu','allScores','allCoefs','allMu');
end

% set(gcf,'color','w');
