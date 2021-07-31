% THIS CODE MAKES Prob Density Functions (PDFs) of FIXATION DURATIONS
% It assumes that you have run UFOVmammo11 and that all those variables are still live in your workspace.
% Actually, they don't need to be live....just available on disk

% June 3, 2021 This version (v11) will plot correct and incorrect trials
% histograms. As well as all trials.
% this is pretty different from v10 so go back to v10 if you don't like v11

% April 6, 2020

% Aug 20, 2020
% Now we load variables so it is more free standing

% V6 is the one I am using to generate pictures for the paper.

% v7 asks if the P(next to target) functions changes as a function of dwell time

% v10 is going to look at the angle to the target as well as the radius


cd /Users/jeremywolfe/Documents/MATLAB2016/UFOVMAMMO
clear all
close all

% this weird kluge has to do with preventing SacCat from destroying
% UFOVmammo...or vice versa. Something I don't understand about .mat files
load SacCat
SacCat(1:10)
SacCat2=SacCat;
save SacCat2
load SacCat2
SacCat2(1:10)
load UFOVmammo % the monster data file...now with corrected NewTrialType
SacCat2(1:10)
load bb % the set of target bounding boxes
load Case % the set of cases
%   -1= Null
%   0 = First
%   1 = targeting endpoint inside bounding box of target
%   2 = True post targeting (after final fixation on the target)
%   4 = Search saccades (all other)
%   5 = absent trial saccade
%   6 = 'BetweenTargeting'; % after the first fixation, before the final fixation

load InBox
load Out2InBox % Out2In is the line of the fixation BEFORE the targeting Fixation
load FirstTlines
load LastTlines
load OtherTlines
load Out2InBox % Out2In is the line of the fixation BEFORE the targeting Fixation
load FixToTargDistAndAngle % % fixX fixY targX targY dx dy Dist Angle(deg) % assumes you have run OrientationHistoUFOVmammo1.m

load UFOVmammo 
UFOVmammo(1,:)
[nlines zz]=size(UFOVmammo)
UFOVmammo.StartDuration(1:10)
SacCat=SacCat2;
SacCat(1:10)

% to test random chance landing onplausible target locations, shuffle InBox
% InBox=Shuffle(InBox);
Pnext=zeros(9,10); % I am just going to use this to export the numbers
Pn=0;

Expertise=readtable('ObsDetailsForMatlab.xlsx');
experts=Expertise.SubjID(find(Expertise.expertiseNumber==1));
genRad=Expertise.SubjID(find(Expertise.expertiseNumber==2));
residents=Expertise.SubjID(find(Expertise.expertiseNumber==3));


%get input
% prompt={'Enter Case # (1-80, 99 does all', 'Enter Obs#  99 does all','Restriction: 0 = none, 1=correct',...
%     'Write to disk? 1=yes'};
% def={'99', '99', '0', '0'};
% ttitle='Input Variables';
% lineNo=1;
%
% userinput=inputdlg(prompt,ttitle,lineNo,def,'on');
%
% %Convert User Input
%
% inputCase=str2num(userinput{1,1});
% inputObs=str2num(userinput{2,1});
% correctFlag=str2num(userinput{3,1});
% saveFlag=str2num(userinput{4,1});


ThisObsClass=0; % =[1,3] doe experts v residents
imsz=180; % size for all the little scan path figures

AllObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
GoodObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	22	23]; % just lose #21 for now

Obs=GoodObs; % Could be all obs or good obs

if ThisObsClass==1
    ThisObsStr='ExpertMammo'
    Obs=intersect(transpose(experts),GoodObs)
elseif ThisObsClass==2
    ThisObsStr='GenRadiologist'
    Obs=intersect(transpose(genRad),GoodObs)
elseif ThisObsClass==3
    ThisObsStr='Resident'
    Obs=intersect(transpose(residents),GoodObs)
else
    ThisObsStr=' ';
end


ObsN=length(Obs);
if ThisObsClass==0
    ThisObsDiv=1;
else
    ThisObsDiv=ThisObsClass;
end
col(1,:)=hsv2rgb([.33 1/ThisObsDiv .5]);
col(2,:)=hsv2rgb([0 .3 .9]); % pinkish
col(3,:)=hsv2rgb([0 0 0]);
col(4,:)=hsv2rgb([.8 1/ThisObsDiv .8]);
col(5,:)=hsv2rgb([.6 .6/ThisObsDiv 1]);
col(6,:)=hsv2rgb([.66 .8 .9]);
col(7,:)=hsv2rgb([.28 .8 .9]);
col(8,:)=hsv2rgb([.3 .7/ThisObsDiv .7]); % first T
col(9,:)=hsv2rgb([.35 .8/ThisObsDiv .5]); % last T
col(10,:)=hsv2rgb([.1 .8/ThisObsDiv .8]); % other
col(11,:)=hsv2rgb([.45 1/ThisObsDiv .9]); % out2in

fontsize=24;

rand('state',sum(100*clock));

figure(101)
set(101,'position',[0 0 700 400]);
set(101,'name',['Duration histo']);
tstr=['Duration Histogram: ', ThisObsStr, '- All trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',20);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
% For Fig 6a
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);

% For Fig 6b
% break out the targeting saccades
%         text(500, .30,'First Saccade to Target','Color',col(8,:),'FontSize',18);
%         text(500, .26,'Between first and last','Color',col(11,:),'FontSize',18);
%         text(500, .22,'Final Saccade to Target','Color',col(9,:),'FontSize',18);
%         text(500, .18,'Saccade refixating Target','Color',col(10,:),'FontSize',18);

%         text(500, .16,'PostTargeting','Color',col(2,:),'FontSize',18);
%         text(500, .14,'Absent','Color',col(5,:),'FontSize',18);
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

figure(102)
set(102,'position',[0 400 700 400]);
set(102,'name',['Duration histo']);
tstr=['Duration Histogram: ', ThisObsStr, '- Correct trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',18);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
% For Fig 6a
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);
% For Fig 6b
% break out the targeting saccades
%         text(500, .30,'First Saccade to Target','Color',col(8,:),'FontSize',18);
%         text(500, .26,'Between first and last','Color',col(11,:),'FontSize',18);
%         text(500, .22,'Final Saccade to Target','Color',col(9,:),'FontSize',18);
%         text(500, .18,'Saccade refixating Target','Color',col(10,:),'FontSize',18);

%         text(500, .16,'PostTargeting','Color',col(2,:),'FontSize',18);
%         text(500, .14,'Absent','Color',col(5,:),'FontSize',18);
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

figure(103)
set(103,'position',[0 800 700 400]);
set(103,'name',['Duration histo']);
tstr=['Duration Histogram: ', ThisObsStr, '- Incorrect trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',20);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

figure(104)
set(104,'position',[700 0 700 400]);
set(104,'name',['PRE-Duration histo']);
tstr=['PRE-Duration Histogram: ', ThisObsStr, '- All trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',20);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

figure(105)
set(105,'position',[700 400 700 400]);
set(105,'name',['PRE-Duration histo']);
tstr=['PRE-Duration Histogram: ', ThisObsStr, '- Correct trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',18);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

figure(106)
set(106,'position',[700 800 700 400]);
set(106,'name',['PRE-Duration histo']);
tstr=['PRE-Duration Histogram: ', ThisObsStr, '- Incorrect trials'];
title(tstr,'Color',[0 .5 .7],'FontSize',20);
xlabel('Duration length (msec)','Color',[0 0 0],'FontSize',18);
ylabel('Proportion of Durations','Color',[0 0 0],'FontSize',18);
text(500, .18,'All saccades','Color',[0 0 0],'FontSize',18);
text(500, .16,'Search (before targeting)','Color',col(4,:),'FontSize',18);
text(500, .14,'All Targeting Saccades','Color',col(1,:),'FontSize',18);
text(500, .12,'All Absent Saccades','Color',col(2,:),'FontSize',18);
drawnow
hold on
set(gca,'fontsize',18)
axis([0 1000 0 .25]);
drawnow
hold on

UFOVmammo.StartDuration(1:10)
for correctFlag=0:2 % 0 = all, 1=correct, 2=incorrect
%     % Out2InBox is the saccade that ends on the location before the saccade
%     % into the target box so you need the line after
%     Out2InLines=1+find(Out2InBox>0);
%     if Out2InLines(length(Out2InLines))>nlines % then the last entry is no good
%         Out2InLines=Out2InLines(1:length(Out2InLines)-1);
%     end
%     
    % get the lines with the saccades you want
    SacCat(1:10)
    AllLines=find(SacCat>0); % excludes the first fixation since that sac hasno length
    AllLines(1:10)
    TargLines=find(SacCat==1);
    FirstTargLines=FirstTlines;
    LastTargLines=LastTlines;
    OtherTargLines=OtherTlines;
%     Out2InPlot=setdiff(Out2InLines,FirstTargLines);
%     Out2InPlot=setdiff(Out2InLines,LastTargLines); % this now makes Out2InPlot the lines going into the target box that aren't first or last
    SearchLines=find(SacCat==4);
    PostTargLines=find(SacCat==2);
    BetweenTLines=find(SacCat==6);
    AbsLines=find(SacCat==5);
    NotNanLines=find(isnan(UFOVmammo.SacSize_deg_)== 0); % all the lines that are not NaN for sac lengths
    
    HITtr=find(strcmp('HIT', UFOVmammo.NewTrialType)); % HIT
    MISStr=find(strcmp('MISS', UFOVmammo.NewTrialType)); % MISS
    MISSFAtr=find(strcmp('MISS&FA', UFOVmammo.NewTrialType)); % MISS&FA
    TNEGtr=find(strcmp('TNEG', UFOVmammo.NewTrialType)); % TNEG
    FAtr=find(strcmp('FA', UFOVmammo.NewTrialType)); % FA
    CORRECTtr=transpose([transpose(HITtr) transpose(TNEGtr)]); % All correct lines
    INCORRECTtr=setdiff(AllLines, CORRECTtr);
%     inClickBox=find(UFOVmammo.dist2click < 1.5);
%     aa=find(UFOVmammo.dist2click >= 0); % the lines with a click
%     inClickBox=intersect(aa, inClickBox);
      [length(SacCat) length(AllLines) length(CORRECTtr) length(INCORRECTtr)]
%     AbsSearchLines=setdiff(AbsLines,inClickBox);
%     FAboxLines=intersect(AbsLines,inClickBox);
    
    if correctFlag==1 % then use just the correct
        TargLines=intersect(TargLines,HITtr);
        length(TargLines)
        FirstTargLines=intersect(FirstTargLines,HITtr);
        LastTargLines=intersect(LastTargLines,HITtr);
        OtherTargLines=intersect(OtherTargLines,HITtr);
%         Out2InPlot=intersect(Out2InPlot,HITtr);
        SearchLines=intersect(SearchLines,CORRECTtr);
        PostTargLines=intersect(PostTargLines,HITtr);
        BetweenTLines=intersect(BetweenTLines,HITtr);
        AbsLines=intersect(AbsLines,TNEGtr);
%         AbsSearchLines=setdiff(AbsLines,inClickBox);
%         FAboxLines=intersect(AbsLines,inClickBox);
    elseif correctFlag == 2 % all the incorrect trials
        TargLines=intersect(TargLines,INCORRECTtr);
        length(TargLines)
        FirstTargLines=intersect(FirstTargLines,INCORRECTtr);
        LastTargLines=intersect(LastTargLines,INCORRECTtr);
        OtherTargLines=intersect(OtherTargLines,INCORRECTtr);
%         Out2InPlot=intersect(Out2InPlot,INCORRECTtr);
        SearchLines=intersect(SearchLines,INCORRECTtr);
        PostTargLines=intersect(PostTargLines,INCORRECTtr);
        BetweenTLines=intersect(BetweenTLines,INCORRECTtr);
        AbsLines=intersect(AbsLines,INCORRECTtr);
%         AbsSearchLines=setdiff(AbsLines,inClickBox);
%         FAboxLines=intersect(AbsLines,inClickBox);
    end
    
    %Now filter by the obs you want
    olines=[];
    for NObs=1:ObsN
        oo=Obs(NObs);
        olines=[olines transpose(find(UFOVmammo.participant==oo))];
    end
    
    %%%%%%%
    %Here is where we range restrict olines to include only saccades STARTING between X and Y deg from the target.
    length(olines)
    lowdist=1.5;
    hidist=3;
    lower=find(UFOVmammo.StartDistTarg > lowdist); % lower bound (-100, includes absent trials)
    upper=find(UFOVmammo.StartDistTarg < hidist); % upper bound
    dtarglines=intersect(lower, upper);
    UseTheseLines=[transpose(dtarglines), transpose(AbsLines)];
    olines=intersect(olines,UseTheseLines);
    length(olines)
    RangeStr=['Fix2Targ Range= ', num2str(lowdist), '-', num2str(hidist), ' deg']
    %%%%%
    
    
    olines=transpose(olines);
    length(olines)
    TargLines=intersect(TargLines,olines);
    length(TargLines)
    FirstTargLines=intersect(FirstTargLines,olines);
    LastTargLines=intersect(LastTargLines,olines);
    OtherTargLines=intersect(OtherTargLines,olines);
%     Out2InPlot=intersect(Out2InPlot,olines);
    SearchLines=intersect(SearchLines,olines);
    PostTargLines=intersect(PostTargLines,olines);
    BetweenTLines=intersect(BetweenTLines,olines);
    AbsLines=intersect(AbsLines,olines);
    
    
    
    % Get histograms counts for STARTING Durations 0:1000
    [AllSac Tedge]=histcounts(UFOVmammo.StartDuration,20,'BinLimits',[0,1000]);
    [TargSac Tedge]=histcounts(UFOVmammo.StartDuration(TargLines),20,'BinLimits',[0,1000]);
    [FirstTargSac Tedge]=histcounts(UFOVmammo.StartDuration(FirstTargLines),20,'BinLimits',[0,1000]);
    [LastTargSac Tedge]=histcounts(UFOVmammo.StartDuration(LastTargLines),20,'BinLimits',[0,1000]);
    [OtherTargSac Tedge]=histcounts(UFOVmammo.StartDuration(OtherTargLines),20,'BinLimits',[0,1000]);
%     [Out2InSac Tedge]=histcounts(UFOVmammo.StartDuration(Out2InPlot),20,'BinLimits',[0,1000]);
    [SearchSac Tedge]=histcounts(UFOVmammo.StartDuration(SearchLines),20,'BinLimits',[0,1000]);
    [PostTargSac Tedge]=histcounts(UFOVmammo.StartDuration(PostTargLines),20,'BinLimits',[0,1000]);
    [BetweenTSac Tedge]=histcounts(UFOVmammo.StartDuration(BetweenTLines),20,'BinLimits',[0,1000]);
    [AbsSac Tedge]=histcounts(UFOVmammo.StartDuration(AbsLines),20,'BinLimits',[0,1000]);
%     [AbsSearch Tedge]=histcounts(UFOVmammo.StartDuration(AbsSearchLines),20,'BinLimits',[0,1000]);
%     [FAbox Tedge]=histcounts(UFOVmammo.StartDuration(FAboxLines),20,'BinLimits',[0,1000]);
    % normalize each of these [0,1]
    AllSacNorm=AllSac/sum(AllSac);
    TargSacNorm=TargSac/sum(TargSac);
    FirstTargSacNorm=FirstTargSac/sum(FirstTargSac);
    LastTargSacNorm=LastTargSac/sum(LastTargSac);
    OtherTargSacNorm=OtherTargSac/sum(OtherTargSac);
%     Out2InSacNorm=Out2InSac/sum(Out2InSac);
    SearchSacNorm=SearchSac/sum(SearchSac);
    PostTargSacNorm=PostTargSac/sum(PostTargSac);
    BetweenTSacNorm=BetweenTSac/sum(BetweenTSac);
    AbsSacNorm=AbsSac/sum(AbsSac);
%     AbsSearchNorm=AbsSearch/sum(AbsSearch);
%     FAboxNorm=FAbox/sum(FAbox);
    
%     sumAllSac=sum(AllSac)
%     sumTargSac=sum(TargSac)
%     sumFirstTargSac=sum(FirstTargSac)
%     sumLastTargSac=sum(LastTargSac)
%     sumOtherTargSac=sum(OtherTargSac)
%     sumOut2InSac=sum(Out2InSac)
%     sumSearchSac=sum(SearchSac)
%     sumPostTargSac=sum(PostTargSac)
%     sumBetweenTSac=sum(BetweenTSac)
%     sumAbsSac=sum(AbsSac)
%     sumAbsSearch=sum(AbsSearch)
    
    
    
    liner='--';
    if correctFlag==2
        liner='--';
    end
    
    if correctFlag == 0
        figure(101) % June 2021 version
    elseif correctFlag == 1
        figure(102) % June 2021 version
    else
        figure(103) % June 2021 version
    end
    
    text(20, .23,RangeStr,'Color',[0 0 0],'FontSize',14);
    plot(25:50:1000,AllSacNorm,'-', 'color', [0 0 0], 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,TargSacNorm,'-', 'color', col(1,:), 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,SearchSacNorm,'-', 'color', col(4,:), 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,AbsSacNorm,'-', 'color', col(2,:), 'LineWidth',6)
    drawnow
    hold on

    %          plot(0:10,PostTargSacNorm,liner, 'color', col(2,:), 'LineWidth',6)
    %          plot(0:10,BetweenTSacNorm,liner, 'color', col(6,:), 'LineWidth',6)
    %          plot(0:10,AbsSacNorm,liner, 'color', col(5,:), 'LineWidth',6)
    % break up the saccades that end on the target
    %          add the symbols
    plot(25:50:1000,AllSacNorm,'s', 'color', [0 0 0], 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.7 .7 .7],...
        'MarkerSize',15)
    drawnow
    hold on
    plot(25:50:1000,TargSacNorm,'o', 'color', col(1,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(1,:),...
        'MarkerSize',15)
    drawnow
    hold on
    plot(25:50:1000,SearchSacNorm,'d', 'color', col(4,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(4,:),...
        'MarkerSize',15)
    drawnow
    hold on    
    plot(25:50:1000,AbsSacNorm,'d', 'color', col(2,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(2,:),...
        'MarkerSize',15)
    drawnow
    hold on
    
    %This is going to do the same thing for the FINAL DURATION (ENDPOINT of the saccade)

    % Get histograms counts for Durations 0:1000
    [AllSac Tedge]=histcounts(UFOVmammo.duration,20,'BinLimits',[0,1000]);
    [TargSac Tedge]=histcounts(UFOVmammo.duration(TargLines),20,'BinLimits',[0,1000]);
    [FirstTargSac Tedge]=histcounts(UFOVmammo.duration(FirstTargLines),20,'BinLimits',[0,1000]);
    [LastTargSac Tedge]=histcounts(UFOVmammo.duration(LastTargLines),20,'BinLimits',[0,1000]);
    [OtherTargSac Tedge]=histcounts(UFOVmammo.duration(OtherTargLines),20,'BinLimits',[0,1000]);
%     [Out2InSac Tedge]=histcounts(UFOVmammo.duration(Out2InPlot),20,'BinLimits',[0,1000]);
    [SearchSac Tedge]=histcounts(UFOVmammo.duration(SearchLines),20,'BinLimits',[0,1000]);
    [PostTargSac Tedge]=histcounts(UFOVmammo.duration(PostTargLines),20,'BinLimits',[0,1000]);
    [BetweenTSac Tedge]=histcounts(UFOVmammo.duration(BetweenTLines),20,'BinLimits',[0,1000]);
    [AbsSac Tedge]=histcounts(UFOVmammo.duration(AbsLines),20,'BinLimits',[0,1000]);
    
%     [AbsSearch Tedge]=histcounts(UFOVmammo.duration(PreAbsSearchLines),20,'BinLimits',[0,1000]);
%     [FAbox Tedge]=histcounts(UFOVmammo.duration(PreFAboxLines),20,'BinLimits',[0,1000]);
    % normalize each of these [0,1]
    AllSacNorm=AllSac/sum(AllSac);
    TargSacNorm=TargSac/sum(TargSac);
    FirstTargSacNorm=FirstTargSac/sum(FirstTargSac);
    LastTargSacNorm=LastTargSac/sum(LastTargSac);
    OtherTargSacNorm=OtherTargSac/sum(OtherTargSac);
%     Out2InSacNorm=Out2InSac/sum(Out2InSac);
    SearchSacNorm=SearchSac/sum(SearchSac);
    PostTargSacNorm=PostTargSac/sum(PostTargSac);
    BetweenTSacNorm=BetweenTSac/sum(BetweenTSac);
    AbsSacNorm=AbsSac/sum(AbsSac);
%     AbsSearchNorm=AbsSearch/sum(AbsSearch);
%     FAboxNorm=FAbox/sum(FAbox);
    
    sumAllSac=sum(AllSac);
    sumTargSac=sum(TargSac);
    sumFirstTargSac=sum(FirstTargSac);
    sumLastTargSac=sum(LastTargSac);
    sumOtherTargSac=sum(OtherTargSac);
%     sumOut2InSac=sum(Out2InSac);
    sumSearchSac=sum(SearchSac);
    sumPostTargSac=sum(PostTargSac);
    sumBetweenTSac=sum(BetweenTSac);
    sumAbsSac=sum(AbsSac);
%     sumAbsSearch=sum(AbsSearch);
    
    
    
    
    liner='--';
    if correctFlag==2
        liner='--';
    end
    
    if correctFlag == 0
        figure(104) % June 2021 version
    elseif correctFlag == 1
        figure(105) % June 2021 version
    else
        figure(106) % June 2021 version
    end
    plot(25:50:1000,AllSacNorm,'-', 'color', [0 0 0], 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,TargSacNorm,'-', 'color', col(1,:), 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,SearchSacNorm,'-', 'color', col(4,:), 'LineWidth',6)
    drawnow
    hold on
    plot(25:50:1000,AbsSacNorm,'-', 'color', col(2,:), 'LineWidth',6)
    drawnow
    hold on
    %          plot(0:10,PostTargSacNorm,liner, 'color', col(2,:), 'LineWidth',6)
    %          plot(0:10,BetweenTSacNorm,liner, 'color', col(6,:), 'LineWidth',6)
    %          plot(0:10,AbsSacNorm,liner, 'color', col(5,:), 'LineWidth',6)
    % break up the saccades that end on the target
    %          add the symbols
    plot(25:50:1000,AllSacNorm,'s', 'color', [0 0 0], 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.7 .7 .7],...
        'MarkerSize',15)
    drawnow
    hold on
    plot(25:50:1000,TargSacNorm,'o', 'color', col(1,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(1,:),...
        'MarkerSize',15)
    drawnow
    hold on
    plot(25:50:1000,SearchSacNorm,'d', 'color', col(4,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(4,:),...
        'MarkerSize',15)
    drawnow
    hold on
        plot(25:50:1000,AbsSacNorm,'d', 'color', col(2,:), 'LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',col(2,:),...
        'MarkerSize',15)
    drawnow
    hold on
end

