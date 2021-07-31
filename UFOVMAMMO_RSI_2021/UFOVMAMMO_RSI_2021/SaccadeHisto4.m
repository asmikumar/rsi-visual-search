% THIS CODE MAKES Prob Density Functions (PDFs) of Saccade length
% It assumes that you have run UFOVmammo6 and that all those variables are still live in your workspace.
% April 6, 2020

% Aug 20, 2020
% Now we load variables so it is more free standing

% cd /Users/jeremywolfe/Documents/MATLAB2016/UFOVMAMMO
% clear all
% close all


load UFOVmammo % the monster data file...now with corrected NewTrialType
load bb % the set of target bounding boxes
load Case % the set of cases
UFOVmammo(1,:)
[nlines zz]=size(UFOVmammo)
load SacCat
load InBox
load Out2InBox % Out2In is the line of the fixation BEFORE the targeting Fixation
load FirstTlines
load LastTlines
load OtherTlines


%get input
prompt={'Enter Case # (1-80, 99 does all', 'Enter Obs#  99 does all','Restriction: 0 = none, 1=correct',...
    'Write to disk? 1=yes'};
def={'99', '99', '1', '1'};
ttitle='Input Variables';
lineNo=1;

userinput=inputdlg(prompt,ttitle,lineNo,def,'on');

%Convert User Input

inputCase=str2num(userinput{1,1});
inputObs=str2num(userinput{2,1});
correctFlag=str2num(userinput{3,1});
saveFlag=str2num(userinput{4,1});



imsz=180; % size for all the little scan path figures

AllObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
GoodObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	22	23]; % just lose #21 for now


Obs=GoodObs; % Could be all obs or good obs

ObsN=length(Obs);

%   0 = First
%   1 = targeting endpoint inside bounding box of target
%   2 = True post targeting (after final fixation on the target)

%   4 = Search saccades (all other)
%   5 = absent trial saccade
%   6 = 'BetweenTargeting'; % after the first fixation, before the final fixation

col(1,:)=hsv2rgb([.33 1 .5]);
col(2,:)=hsv2rgb([0 .6 .9]);
col(3,:)=hsv2rgb([0 0 0]);
col(4,:)=hsv2rgb([.75 1 .8]);
col(5,:)=hsv2rgb([.66 .7 1]);
col(6,:)=hsv2rgb([.7 .5 .9]);
col(7,:)=hsv2rgb([.33 .5 .8]);
col(8,:)=hsv2rgb([.33 .6 1]); % first T
col(9,:)=hsv2rgb([.33 .6 .5]); % last T
col(10,:)=hsv2rgb([.45 .6 .4]); % other
col(11,:)=hsv2rgb([.25 1 .9]); % out2in

fontsize=24;

rand('state',sum(100*clock));

figure(101)
set(101,'position',[0 0 1000 600]);
set(101,'name',['Saccades histo']);
if correctFlag == 1
    title('Saccade Histogram - Correct trials only','Color',[0 .5 .7],'FontSize',24);
else
    title('Saccade Histogram - All trials','Color',[0 .5 .7],'FontSize',24);
end
xlabel('Saccade length (deg)','Color',[0 0 0],'FontSize',24);
ylabel('Proportion of saccades','Color',[0 0 0],'FontSize',24);
text(7, .28,'Search','Color',col(4,:),'FontSize',fontsize);
text(7, .26,'Targeting','Color',col(1,:),'FontSize',fontsize);
text(7.5, .24,'First Targeting','Color',col(8,:),'FontSize',18);
text(7.5, .22,'Last Targeting','Color',col(9,:),'FontSize',18);
text(7.5, .20,'Other Sac to Target','Color',col(10,:),'FontSize',18);
text(7.5, .18,'OutsideToTarget','Color',col(11,:),'FontSize',18);
text(7, .16,'Between','Color',col(6,:),'FontSize',fontsize);
text(7, .14,'PostTargeting','Color',col(2,:),'FontSize',fontsize);
text(7, .12,'Absent','Color',col(5,:),'FontSize',fontsize);
set(gca,'fontsize',18)
axis([0 10.5 0 .32]);
drawnow
hold on

figure(102)
set(102,'position',[0 600 1000 600]);
set(102,'name',['PNextGoesToTarget']);
if correctFlag == 1
    title('PNextGoesToTarget - Correct trials only','Color',[0 .5 .7],'FontSize',24);
else
    title('PNextGoesToTarget - All trials ','Color',[0 .5 .7],'FontSize',24);
end
xlabel('Distance to Target','Color',[0 0 0],'FontSize',24);
ylabel('Proportion of saccades','Color',[0 0 0],'FontSize',24);
text(7, .55,'All','Color',col(7,:),'FontSize',fontsize);
text(7, .5,'Search','Color',col(4,:),'FontSize',fontsize);
text(7, .45,'Between','Color',col(6,:),'FontSize',fontsize);
text(7, .4,'PostTargeting','Color',col(2,:),'FontSize',fontsize);
text(7, .35,'Absent','Color',col(5,:),'FontSize',fontsize);
set(gca,'fontsize',18)
axis([0 10.5 0 .6]);
drawnow
hold on

figure(103)
set(103,'position',[1000 0 1000 600]);
set(103,'name',['Distance to Target']);
if correctFlag == 1
    title('Distance to Target - Correct trials only','Color',[0 .5 .7],'FontSize',24);
else
    title('Distance to Target - All trials ','Color',[0 .5 .7],'FontSize',24);
end
xlabel('Reverse Saccade','Color',[0 0 0],'FontSize',24);
ylabel('Distance to Target','Color',[0 0 0],'FontSize',24);
text(9, 16,'HIT trials','Color',col(7,:),'FontSize',fontsize);
text(9, 15,'MISS trials','Color',col(2,:),'FontSize',fontsize);
set(gca, 'XDir','reverse')
set(gca,'fontsize',18)
% axis([0 10.5 0 .6]);
drawnow
hold on

% Out2InBox is the saccade that ends on the location before the saccade
% into the target box so you need the line after
Out2InLines=1+find(Out2InBox>0);
if Out2InLines(length(Out2InLines))>nlines % then the last entry is no good
    Out2InLines=Out2InLines(1:length(Out2InLines)-1);
end

% get the lines with the saccades you want
TargLines=find(SacCat==1);
FirstTargLines=FirstTlines;
LastTargLines=LastTlines;
OtherTargLines=OtherTlines;
Out2InPlot=Out2InLines;
SearchLines=find(SacCat==4);
PostTargLines=find(SacCat==2);
BetweenTLines=find(SacCat==6);
AbsLines=find(SacCat==5);
HITtr=find(strcmp('HIT', UFOVmammo.NewTrialType)); % HIT
MISStr=find(strcmp('MISS', UFOVmammo.NewTrialType)); % MISS
TNEGtr=find(strcmp('TNEG', UFOVmammo.NewTrialType)); % MISS
CORRECTtr=transpose([transpose(HITtr) transpose(TNEGtr)]); % All correct lines

if correctFlag==1 % then use just the correct
    TargLines=intersect(TargLines,HITtr);
    FirstTargLines=intersect(FirstTargLines,HITtr);
    LastTargLines=intersect(LastTargLines,HITtr);
    OtherTargLines=intersect(OtherTargLines,HITtr);
    Out2InPlot=intersect(Out2InPlot,HITtr);
    SearchLines=intersect(SearchLines,CORRECTtr);
    PostTargLines=intersect(PostTargLines,HITtr);
    BetweenTLines=intersect(BetweenTLines,HITtr);
    AbsLines=intersect(AbsLines,TNEGtr);
end

% Get histograms counts for deg 0:10
[TargSac Tedge]=histcounts(UFOVmammo.SacBin(TargLines),11,'BinLimits',[-.2,10]);
[FirstTargSac Tedge]=histcounts(UFOVmammo.SacBin(FirstTlines),11,'BinLimits',[-.2,10]);
[LastTargSac Tedge]=histcounts(UFOVmammo.SacBin(LastTlines),11,'BinLimits',[-.2,10]);
[OtherTargSac Tedge]=histcounts(UFOVmammo.SacBin(OtherTlines),11,'BinLimits',[-.2,10]);
[Out2InSac Tedge]=histcounts(UFOVmammo.SacBin(Out2InPlot),11,'BinLimits',[-.2,10]);
[SearchSac Tedge]=histcounts(UFOVmammo.SacBin(SearchLines),11,'BinLimits',[-.2,10]);
[PostTargSac Tedge]=histcounts(UFOVmammo.SacBin(PostTargLines),11,'BinLimits',[-.2,10]);
[BetweenTSac Tedge]=histcounts(UFOVmammo.SacBin(BetweenTLines),11,'BinLimits',[-.2,10]);
[AbsSac Tedge]=histcounts(UFOVmammo.SacBin(AbsLines),11,'BinLimits',[-.2,10]);
% normalize each of these [0,1]
TargSacNorm=TargSac/sum(TargSac);
FirstTargSacNorm=FirstTargSac/sum(FirstTargSac);
LastTargSacNorm=LastTargSac/sum(LastTargSac);
OtherTargSacNorm=OtherTargSac/sum(OtherTargSac);
Out2InSacNorm=Out2InSac/sum(Out2InSac);
SearchSacNorm=SearchSac/sum(SearchSac);
PostTargSacNorm=PostTargSac/sum(PostTargSac);
BetweenTSacNorm=BetweenTSac/sum(BetweenTSac);
AbsSacNorm=AbsSac/sum(AbsSac);



figure(101)
plot(0:10,TargSacNorm,'-', 'color', col(1,:), 'LineWidth',6)
plot(0:10,SearchSacNorm,'-', 'color', col(4,:), 'LineWidth',6)
plot(0:10,PostTargSacNorm,'-', 'color', col(2,:), 'LineWidth',6)
plot(0:10,BetweenTSacNorm,'-', 'color', col(6,:), 'LineWidth',6)
plot(0:10,AbsSacNorm,'-', 'color', col(5,:), 'LineWidth',6)
% break up the saccades that end on the target
plot(0:10,FirstTargSacNorm,'--', 'color', col(8,:), 'LineWidth',5)
plot(0:10,LastTargSacNorm,'--', 'color', col(9,:), 'LineWidth',5)
plot(0:10,OtherTargSacNorm,':', 'color', col(10,:), 'LineWidth',5)
plot(0:10,Out2InSacNorm,':', 'color', col(11,:), 'LineWidth',5)
drawnow
hold on

% % here we are creating a plot of P(targeting) X distance to target


SearchTr=find(SacCat==4); % all the pre targeting search trials
BetweenTr=find(SacCat==6); % all the between targeting search trials
PostTr=find(SacCat==2); % all the post targeting trials

for i=1:20 % lower bound of the distance range
    botrange(i)=((i-1)*.5)+.25;
    toprange(i)=botrange(i)+.5;
    bottr=find(UFOVmammo.DistTarg>=botrange(i));
    toptr=find(UFOVmammo.DistTarg < toprange(i));
    allDtr=intersect(bottr,toptr); % The set of rows with DistTarg in range.
    NallDtr(i)=length(allDtr); % number in range
    allNext=allDtr+1; % the index for the next trial
    if max(allNext) > length(InBox) % then drop the last value
        allNext=allNext(1:length(allNext)-1);
    end
    NnextInBox(i)=sum(InBox(allNext)); % number of saccades that went to the target next
    pGoToTarg(i)=NnextInBox(i)/NallDtr(i);
    
    % repeat for search Trials    
    searchDtr=intersect(allDtr, SearchTr); 
    NsearchDtr(i)=length(searchDtr); % number in range
    searchNext=searchDtr+1; % the index for the next trial
    if max(searchNext) > length(InBox) % then drop the last value
        searchNext=searchNext(1:length(searchNext)-1);
    end
    NSearchnextInBox(i)=sum(InBox(searchNext)); % number of saccades that went to the target next
    pSearchGoToTarg(i)=NSearchnextInBox(i)/NsearchDtr(i);
    
    % repeat for between Trials
    betweenDtr=intersect(allDtr, BetweenTr); 
    NbetweenDtr(i)=length(betweenDtr); % number in range
    betweenNext=betweenDtr+1; % the index for the next trial
    if max(betweenNext) > length(InBox) % then drop the last value
        betweenNext=betweenNext(1:length(betweenNext)-1);
    end
    NbetweennextInBox(i)=sum(InBox(betweenNext)); % number of saccades that went to the target next
    pbetweenGoToTarg(i)=NbetweennextInBox(i)/NbetweenDtr(i);
    
    % repeat for Post Trials
    postDtr=intersect(allDtr, PostTr); 
    NpostDtr(i)=length(postDtr); % number in range
    postNext=postDtr+1; % the index for the next trial
    if max(postNext) > length(InBox) % then drop the last value
        postNext=postNext(1:length(postNext)-1);
    end
    NpostnextInBox(i)=sum(InBox(postNext)); % number of saccades that went to the target next
    ppostGoToTarg(i)=NpostnextInBox(i)/NpostDtr(i);
      
    
end
pGoToTarg
pSearchGoToTarg
pbetweenGoToTarg
ppostGoToTarg
figure(102)
plot(botrange+.25,pGoToTarg,'-', 'color', col(7,:), 'LineWidth',6)
plot(botrange+.25,pSearchGoToTarg,'-', 'color', col(4,:), 'LineWidth',6)
plot(botrange+.25,pbetweenGoToTarg,'-', 'color', col(6,:), 'LineWidth',6)
plot(botrange+.25,ppostGoToTarg,'-', 'color', col(2,:), 'LineWidth',6)
drawnow
hold on

% distances as function of reverse sac
  
HitTrDistToTarg=zeros(ObsN,10);
MissTrDistToTarg=zeros(ObsN,10);

for k=1:ObsN
    oo=Obs(k);
    olines=find(UFOVmammo.participant==oo); % all lines for that obs
    for i=1:10 % lower bound of the distance range
        revsac(i)=11-i;
        RevSacTr=find(UFOVmammo.RevSac==revsac(i));
        RevSacXObs=intersect(RevSacTr,olines);
        HitRevSacXObs=intersect(RevSacXObs,HITtr); % Just the HITs
        MissRevSacXObs=intersect(RevSacXObs,MISStr); % Just the HITs
        HitTrDistToTarg(k,i)=mean(UFOVmammo.DistTarg(HitRevSacXObs));
        MissTrDistToTarg(k,i)=mean(UFOVmammo.DistTarg(MissRevSacXObs));
    end
    figure(103)
    plot(revsac, HitTrDistToTarg(k,:),'-','color',col(7,:), 'LineWidth',1)
    plot(revsac, MissTrDistToTarg(k,:),'-','color',col(2,:), 'LineWidth',1)
    drawnow
    hold on
end
HitTrDistToTarg
mean(HitTrDistToTarg)
MissTrDistToTarg
mean(MissTrDistToTarg)
figure(103)
plot(revsac, mean(HitTrDistToTarg),'-','color',col(7,:), 'LineWidth',6)
plot(revsac, mean(MissTrDistToTarg),'-','color',col(2,:), 'LineWidth',6)
drawnow
hold on





