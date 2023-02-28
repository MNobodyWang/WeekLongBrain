% Trim PCA to remove seizures
% Created on 20220120 by Max B Wang

subjList={'EP1117','EP1109','EP1111','EP1120','EP1124','EP1142','EP1133',...
    'EP1135','EP1137','EP1160','EP1149','EP1136','EP1163','EP1155','EP1165',...
    'EP1170','EP1173','EP1166','EP1169','EP1188'};

sInd=2;

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

load([figurePath 'RANSAC_PCA' append '.mat'],'useScores','useCoefs','feature_coefs','mu');
trimScores=useScores;

timeInds=(1:size(useScores,1))*5/3600;
%%
breaks=find(isnan(useScores(:,1)));
consecBreak=[0;(breaks(2:end)-breaks(1:end-1))==1; 0];
% scatter(breaks*5/3600,repmat(-0.1,length(breaks),1))

startPoint=[21 15 7];
dayMarks=[21 15 7; 24+19 45 48; 48+19 47 42; 72+19 49 53;...
    96+19 51 22; 120+19 53 16; 144+19 55 12];

dayRef=zeros(size(dayMarks,1),1);

subplot(2,1,1)
plot(useScores(:,1)); hold on

for dayInd=1:size(dayMarks,1)
    timePoint=dayMarks(dayInd,:);
    timeDiff=floor((timePoint-startPoint)*[1;1/60;1/3600]);
    
    if dayInd>1
        roughInd=floor(timeDiff*3600/5);
        [~,nearBreak]=min(abs(breaks-roughInd));
        dayRef(dayInd)=find(consecBreak(nearBreak+1:end)==0,1)+breaks(nearBreak)-1;
    end
    
    plot([dayRef(dayInd) dayRef(dayInd)],[-0.15 0.5],'--r','LineWidth',2)
    text(dayRef(dayInd)+0.2,-0.15,[num2str(rem(dayMarks(dayInd,1),24)) ':' ...
        num2str(dayMarks(dayInd,2),'%02.f') ':' num2str(dayMarks(dayInd,3),'%02.f')],'FontSize',13)
end

%%

seizureTimes=cell(size(dayMarks,1),1);

seizureTimes{1}=[22 15 19; 24+4 7 56; 24+7 7 54; 24+9 52 8];

seizureTimes{2}=[];

seizureTimes{3}=[24+3 6 40];

seizureTimes{4}=[];

seizureTimes{5}=[];

seizureTimes{6}=[];

seizureTimes{7}=[];

for dayInd=1:size(dayMarks,1)
    dayTimeStart=dayMarks(dayInd,:);
    dayTimeStart(1)=rem(dayTimeStart(1),24);
    dayRefStart=dayRef(dayInd);
    
    for eventInd=1:size(seizureTimes{dayInd},1)
        timeDiff=(seizureTimes{dayInd}(eventInd,:)-dayTimeStart)*[1;1/60;1/3600];
        plotTime=floor(dayRefStart+timeDiff*3600/5);
        
        plot([plotTime plotTime],[-0.1 0.5],'r','LineWidth',2)
        
        trimScores((plotTime-30*60/5):(plotTime+30*60/5),:)=NaN;
    end
end

subplot(2,1,2)
plot(trimScores(:,1))

%%
save([figurePath 'RANSAC_PCA' append '_Trimmed.mat'],'trimScores','useCoefs','feature_coefs','mu');