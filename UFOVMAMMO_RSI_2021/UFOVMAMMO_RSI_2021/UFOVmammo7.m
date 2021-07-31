% coming back to this in Aug 18, 2020

% UFOVmammo6 as of April 6, 2020
% NOTE: To run this the first time, you need to include lines 27-38
% If you don't clear the workspace, you can then comment those lines out and 
% just run the code again without having to wait for the readtable commands.

% This version will categorize each fixation as
% Search (outside the bounding box - bb)
% targeting (moves from outside to inside)
% refixation (stays inside the bounding box)

% At the moment, this brings in
% SacCat
% let's classify each saccade as
%   -1= Null
%   0 = First
%   1 = targeting endpoint inside bounding box of target
%   2 = True post targeting (after final fixation on the target)

%   4 = Search saccades (all other)
%   5 = absent trial saccade
%   6 = 'BetweenTargeting'; % after the first fixation, before the final fixation
%         change in position from fixation i-1 to i
%         dx
%         dy
%         bin for heat maps
%         cX
%         cY

% cd /Users/jeremywolfe/Documents/MATLAB2016/UFOVMAMMO
% clear all
% close all
plotFlag=1; % 0 = fastest for numbers, 1=normal figures, 2=stop after each obs, 3=add numbers and other diagnostics 


% UFOVmammo=readtable('UFOVmammoData3.xlsx');
% bb=readtable('UFOVmammoBoundingBox2.xlsx');
% save UFOVmammo;
% [nlines zz]=size(UFOVmammo)
% UFOVmammo(1,:)
% save bb
% size(bb)
% bb(1,:)
% Case=readtable('CaseName.xlsx');
% save Case

load UFOVmammo % the monster data file
load bb % the set of target bounding boxes
load Case % the set of cases
UFOVmammo(1,:)
[nlines zz]=size(UFOVmammo)
close all
imsz=180; % size for all the little scan path figures

AllObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
GoodObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	22	23]; % just lose #21 for now


Obs=GoodObs; % Could be all obs or good obs

ObsN=length(Obs);
finalTr=57;

% plotting variables
            drawnow
            hold on
% a 1 deg circle
th = 0:pi/50:2*pi;
circX = 47.76 * cos(th);
circY = 47.76 * sin(th);

% Set up a few things
SacCat=zeros(nlines,1)-1; % set saccade to -1

InBox=zeros(1,nlines);
Out2InBox=zeros(1,nlines);
CatStr{1}='Targeting';
CatStr{2}='Post-Targeting';
CatStr{3}='TinyNonTarget';
CatStr{4}='InitialSearch';
CatStr{5}='AbsentTrial';
CatStr{6}='BetweenTargeting'; % after the first fixation, before the final fixation

heatN=zeros(ObsN,4);
CatN=zeros(ObsN,4);
heattbl1=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade
heattbl2=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade
heattbl3=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade
heattbl4=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade
heattbl5=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade
heattbl6=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 6 types of saccade



rand('state',sum(100*clock));
dx=zeros(1,nlines);
dy=zeros(1,nlines);
cX=zeros(1,nlines);
cY=zeros(1,nlines);

FirstTlines=[];  % this will be a variable that holds the first fixation into the target region
LastTlines=[]; % this will be a variable that holds the last fixation into the target region

% First do a tabulation check
allLines=zeros(ObsN,5); % obs, HIT, TNEG, MISS, FA
TrialTypeN=zeros(ObsN,5); % obs, HIT, TNEG, MISS, FA
olineRange=zeros(ObsN,4); %obs, minline and maxline, count
HITLines=find(strcmp('HIT', UFOVmammo.TrialType));
TNEGLines=find(strcmp('TNEG', UFOVmammo.TrialType));
MISSLines=find(strcmp('MISS', UFOVmammo.TrialType));
FALines=find(strcmp('FA', UFOVmammo.TrialType));
[length(HITLines) length(TNEGLines) length(MISSLines) length(FALines)]
Sac1Lines=find(UFOVmammo.SacNumber == 1); % all the first sac lines
% first saccade for each of the target types
HIT1Lines=intersect(HITLines,Sac1Lines);
TNEG1Lines=intersect(TNEGLines,Sac1Lines);
MISS1Lines=intersect(MISSLines,Sac1Lines);
FA1Lines=intersect(FALines,Sac1Lines);

for i=1:ObsN
    oo=Obs(i);
    olines=find(UFOVmammo.participant==oo); % all lines for that obs
    olineRange(i,:)=[oo, min(olines), max(olines), 1+(max(olines)-max(olines))];
    allLines(i,:)=[oo length(intersect(HITLines, olines)) length(intersect(TNEGLines, olines)) length(intersect(MISSLines, olines)) length(intersect(FALines, olines))];
    TrialTypeN(i,:)=[oo length(intersect(HIT1Lines, olines))  length(intersect(TNEG1Lines, olines)) length(intersect(MISS1Lines, olines)) length(intersect(FA1Lines, olines))];
end
olineRange
allLines
TrialTypeN

% Second Let's Look at some scan paths


% and
% Third, let's classify each saccade as
%   -1= Null
%
%   1 = targeting endpoint inside bounding box of target
%   2 = refixation (was inside the box)
%   3 = tinyOther (SacSize < 0.5 && NOT close to target)
%   4 = Search saccades (all other) PRE
%   5 = absent trial saccade

% this figure will hold vectors of all targeting saccades
figure(100)
set(100,'position',[0 0 500 500]);
set(100,'name',['Targeting Saccades:HITS']);
title('Targeting Saccades:HITS','Color',[0 .5 .7],'FontSize',24);
xlabel('Deg','Color',[0 0 0],'FontSize',18);
ylabel('Deg','Color',[0 0 0],'FontSize',18);
set(gca,'Color',[0 0 0])
axis([-500 500 -500 500]);
drawnow
hold on

figure(200)
set(200,'position',[500 0 500 500]);
set(200,'name',['Targeting Saccades: MISSES']);
title('Targeting Saccades:MISS','Color',[0 .5 .7],'FontSize',24);
xlabel('Deg','Color',[0 0 0],'FontSize',18);
ylabel('Deg','Color',[0 0 0],'FontSize',18);
set(gca,'Color',[0 0 0])
axis([-500 500 -500 500]);
drawnow
hold on

for i=1:ObsN
% for i=1:4
    % plot concentric rings in 1 deg increments
    figure(100)
    for zz=1:10
        plot((circX*zz),(circY*zz), '-','LineWidth',1,'color',[1 0 0])
    end
    drawnow
    hold on
    figure(200)
    for zz=1:10
        plot((circX*zz),(circY*zz), '-','LineWidth',1,'color',[1 0 0])
    end
    drawnow
    hold on
    % Get the lines for this obs & trial
    n=0;
%     ntrials=finalTr;
    oo=Obs(i);
    olines=find(UFOVmammo.participant==oo); % all lines for that obs
    ntrials=max(UFOVmammo.trial(olines)); % should be the number of trials for that obs (generally 80)
    for tr=1:ntrials
        n=n+1;
        nOut2In=0; % will count the number of times you go from out to in in a trial
        trlines=intersect(olines,find(UFOVmammo.trial==tr));% should be the lines for that trial for that observer
        if isempty(trlines)
            ['No trial ' num2str(n)]
        else
            figure(n)            
            set(n,'position',[mod((n-1),12)*imsz, floor((n-1)/12)*imsz, imsz, imsz]);
            set(n,'name',['Obs', num2str(oo)]);
            title(['Trial', num2str(n)],'Color',[0 0 0],'FontSize',14);
            % color code the backgrounds by the type of trial
            if strcmp('HIT', UFOVmammo.TrialType(min(trlines)))==1 % HIT
                bc=hsv2rgb([.33 .2 .7]);
            elseif strcmp('MISS', UFOVmammo.TrialType(min(trlines)))==1  % MISS
                bc=hsv2rgb([0 .2 .8]);
            elseif strcmp('TNEG', UFOVmammo.TrialType(min(trlines)))==1  % TNEG
                bc=hsv2rgb([.4 .2 1]);
            elseif strcmp('FA', UFOVmammo.TrialType(min(trlines)))==1  % FA
                bc=hsv2rgb([.1 .2 1]);
            else
                bc=[.2 .2 .2];
            end
            axis([800 1800 100 1100]); % pixels on the screen
            drawnow
            hold on
%             set(gca,'Color',bc)
            fill([800 800 1800 1800 800], [100 1100 1100 100 100],bc); % this colors in the background
            drawnow
            hold on
            % this is going to plot every fixation with time coded in color
            % and fixation duration coded by size of the dot
            hue=((1:length(trlines))/(length(trlines)*1.4)); % should scale the colors from red to blue (rainbow)
            cc=ones(length(trlines),3); % color triplets
            cc(:,1)=hue;
            cc=hsv2rgb(cc);
            plot(UFOVmammo.fixX(trlines), UFOVmammo.fixY(trlines),'-k') % plot the lines of the scanpath
            scatter(UFOVmammo.fixX(trlines), UFOVmammo.fixY(trlines),UFOVmammo.duration(trlines)/2,cc,'filled') % scale by fixation duration
  
            % plot the bounding box around the target location
            if UFOVmammo.targetPresent(min(trlines))==1
                bnum=find(bb.Case==UFOVmammo.CaseNum(min(trlines))); % this is bounding box index
                % bounding box coords
                x1=bb.bx1(bnum);
                x2=bb.bx2(bnum);
                y1=bb.by1(bnum);
                y2=bb.by2(bnum);
                bbox=[x1 y1
                    x2 y1
                    x2 y2
                    x1 y2
                    x1 y1];
                plot(bbox(:,1), bbox(:,2),'-r', 'LineWidth', 2) % this is the bounding box
                plot((circX*1.5)+UFOVmammo.targX(min(trlines)),(circY*1.5)+UFOVmammo.targY(min(trlines)), '-','LineWidth',2,'color',[1 1 1]) % this is a 1.5 deg circle around the target
            end
            drawnow
            hold on
            
            % here is where we figure out what saccades are going into the
            % target region.
            
            for j=min(trlines):max(trlines) % all the lines for that trial
                % find the fixations inside or near the target
                if UFOVmammo.targetPresent(j)==1 % for target present trials
                    % rule for a target saccade: It is in the bounding box
                    % defined above OR it is 1.5 deg from the target center
                    if (UFOVmammo.fixX(j) >= x1 && UFOVmammo.fixY(j) >= y1 && UFOVmammo.fixX(j) <= x2 && UFOVmammo.fixY(j) <= y2) || UFOVmammo.DistTarg_1_5(j)==1; %  in the box (or within 1.5 deg
                        InBox(j)=1; % 1 means you are in the box at that line (j)
                        if j > min(trlines) % then this is not the first fixation on the trial
                            if InBox(j-1) == 0 % then you were outside the box on j-1 and you are headed into the box
                                nOut2In=nOut2In+1;
                                Out2InBox(j-1)=nOut2In; % flag that j-1 fixation
                                scatter(UFOVmammo.fixX(j-1), UFOVmammo.fixY(j-1),36,[0 0 0],'filled')
                                plot([UFOVmammo.fixX(j-1) UFOVmammo.fixX(j)],[UFOVmammo.fixY(j-1) UFOVmammo.fixY(j)],'-k', 'LineWidth', 2)
                                scatter(UFOVmammo.fixX(j), UFOVmammo.fixY(j),36,[1 1 1]) % Should mark endpnt of all saccades going to the target?
                                drawnow
                                hold on
                            end
                        end
                    end
                end
                
                % compute dx dy cX cY for all eligible pairs of fixations
                if j > 1 && UFOVmammo.fixX(j) > 0 && UFOVmammo.fixX(j-1) > 0 && UFOVmammo.fixY(j) > 0 && UFOVmammo.fixY(j-1) > 0 % then we have fixations in both spots
                    dx(j)=(UFOVmammo.fixX(j)-UFOVmammo.fixX(j-1))/47.76;
                    dy(j)=(UFOVmammo.fixY(j)-UFOVmammo.fixY(j-1))/47.76;
                    cX(j)=round((dx(j)+10)*2); % cX and CY are the indices into a heat map
                    cY(j)=round((dy(j)+10)*2);
                end
                
            end       
            
            % Classify each saccade
            %     Put a 1 in the first fixation in the box
            t=min(find(InBox(trlines)==1)); % this is the first target fixation, t is the index into trlines for the first fixation on the target
            
            if isempty(t) % no first fixation
                if UFOVmammo.targetPresent(min(trlines))==1 % target present (miss, probably)
                    SacCat(trlines)=4; % all PRE - SEARCH saccades
%                     ['No FIRST FIXATION ' num2str(tr)]
                else
                    SacCat(trlines)=5; % ABSENT TRIALS
%                     ['ABSENT TRIAL ' num2str(tr)]
                end
            else % THere was a fist (and, thus, a last) fixation on the target
                if (trlines(t) == min(trlines)) && nOut2In == 0 % special case where the traget was fixated for the first and only time on the first fixation
                    lastT=t;
                else % base lastT on Out2InBox
                    lastT=1+max(find(Out2InBox(trlines)>0)); % this is the index into trlines of the endpoint (on the target) of the last targeting saccade
                    LastTlines=[LastTlines, trlines(lastT)]; % add to this list of lines for later histograming (NOTE, only if last is not the same as first
                end
                FirstTlines=[FirstTlines, trlines(t)]; % add to this list of lines for later histograming         
                SacCat(min(trlines):trlines(t)-1)=4; % all the SEARCH saccades (PRE - before any fixations)
                if t==lastT % then there is only one saccade into the target
                    SacCat((trlines(t)+1):max(trlines))=2; % all the POST TARGET saccades
                else
                    SacCat((trlines(t)+1):(trlines(lastT)-1))=6; % Between targeting saccades
                    SacCat((trlines(lastT)+1):max(trlines))=2; % true POST TARGET saccades
                end
                SacCat(trlines(find(InBox(trlines)==1)))=1; % label all fixations in the box as 1
                % enhance the final saccade into the target
                if lastT > 1
                    TSac=[UFOVmammo.fixX(trlines(lastT)) UFOVmammo.fixY(trlines(lastT))
                        UFOVmammo.fixX(trlines(lastT-1)) UFOVmammo.fixY(trlines(lastT-1))]; % coords of the saccade into the box
                    plot(TSac(:,1), TSac(:,2),'-', 'LineWidth', 4, 'Color', [1 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1), TSac(:,2),'-', 'LineWidth', 2, 'Color', [1 0 0]) % should highlight the saccade going into the target box
                end
                drawnow
                hold on
               
                % Draw fixations that go to the target for the LAST time,
                % normalized so the endpoint of the saccade is (0,0)
                
                if strcmp('HIT', UFOVmammo.TrialType(min(trlines)))==1 % HIT   
                    figure(100)
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 3, 'Color', [0 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 1, 'Color', [.6 0 1]) % should highlight the saccade going into the target box                    
                else % miss saccades
                    figure(200)
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 3, 'Color', [1 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 1, 'Color', [1 0 0]) % should highlight the saccade going into the target box                                        
                end
                 drawnow
                 hold on
            end
        end
        if plotFlag > 1
            sac=0;
            figure(n) 
            for s=min(trlines):max(trlines) % all the lines for that trial
                sac=sac+1;
                text(UFOVmammo.fixX(s), UFOVmammo.fixY(s), num2str(sac),'Color',[1 0 0],'FontSize',16);
            end
            drawnow
            hold on
            ['FOR TRIAL ' num2str(tr), ' MARK THESE FIXATIONS: ', num2str(find(InBox(trlines)==1))]
            ['SacCat: ' num2str(transpose(SacCat(min(trlines):max(trlines))))]
        end        

    end
    %     if i == 14
    %         ['pause at OBS' num2str(i)]
    %         FlushEvents('KeyDown');
    %         GetChar;
    %     end
    
    if plotFlag > 0
        FlushEvents('KeyDown');
        GetChar;
    end
end

% dd=InBox(trlines)

% FlushEvents('KeyDown');
% GetChar;
% close all


for i=1:5
    SacCatN(i)=length(find(SacCat==i));
end
SacCatN


% Let's build the heat maps
% These show where the saccades came from with endpoint normalized to 0,0

for i=1:nlines
    if sum(UFOVmammo.participant(i) == Obs) % then this is a keeper obs for this run
        if cX(i) > 0 && cX(i) < 42 && cY(i) > 0 && cY(i) < 42 % then this is inside +/- 10 deg
            if SacCat(i)==1
                heattbl1(cX(i),cY(i))=heattbl1(cX(i),cY(i))+1;
            elseif SacCat(i)==2
                heattbl2(cX(i),cY(i))=heattbl2(cX(i),cY(i))+1;
            elseif SacCat(i)==3
                heattbl3(cX(i),cY(i))=heattbl3(cX(i),cY(i))+1;
            elseif SacCat(i)==4
                heattbl4(cX(i),cY(i))=heattbl4(cX(i),cY(i))+1;
            elseif SacCat(i)==5
                heattbl5(cX(i),cY(i))=heattbl5(cX(i),cY(i))+1;
            elseif SacCat(i)==6
                heattbl6(cX(i),cY(i))=heattbl6(cX(i),cY(i))+1;
            end
        end
    end
end

% lets make 5 heatmaps (Skip 3 for now)
heatmax1=max(max(heattbl1));
heatmax2=max(max(heattbl2));
% heatmax3=max(max(heattbl3));
heatmax4=max(max(heattbl4));
heatmax5=max(max(heattbl5));
heatmax6=max(max(heattbl6));
heatplot1=heattbl1/heatmax1;
heatplot2=heattbl2/heatmax2;
% heatplot3=heattbl3/heatmax3;
heatplot4=heattbl4/heatmax4;
heatplot5=heattbl5/heatmax5;
heatplot6=heattbl6/heatmax6;

plotn=[4 6 1 2 5];
for i=1:5
    cc=[];
    if i==1
        thisHeat=heatplot4;
    elseif i==2
        thisHeat=heatplot6;
    elseif i==3
        thisHeat=heatplot1;
    elseif i==4
        thisHeat=heatplot2;
    else
        thisHeat=heatplot5;
    end
    figure(300+i)
    set(300+i,'position',[(i-1)*500, 10, 500, 500]);
    set(300+i,'name',[CatStr{plotn(i)}]);
    title([CatStr{plotn(i)}],'Color',[0 .5 .7],'FontSize',24);
    axis([-10.5 10.5 -10.5 10.5]);
    drawnow
    hold on
    x1=[];
    y1=[];
    cc=[];
    k=0;
    for x=1:41
        for y=1:41
            k=k+1;
            x1(k)=(x/2)-10.5;
            y1(k)=(y/2)-10.5;
            if thisHeat(x,y) > 0 % some data here
                hue=(1-thisHeat(x,y))/1.5; % 0 to .5, I think red to blue
                cc(k,:)=hsv2rgb(hue,1,.6);
            else
                cc(k,:)=[0 0 0]; % black
            end
        end
    end
    scatter(x1,y1,200,cc,'s','filled')
    drawnow
    hold on
end

% now we are going to replot with just the top 'UFOVthresh' squares shown
thresh=.75; % Percentage of saccades in the heatmap (plotting from the most common location down)
for i=1:5
    cc=[];
    if i==1
        thisHeat=heatplot4;
    elseif i==2
        thisHeat=heatplot6;
    elseif i==3
        thisHeat=heatplot1;
    elseif i==4
        thisHeat=heatplot2;
    else
        thisHeat=heatplot5;
    end
    thisSum=sum(sum(thisHeat))
    threshHeat=zeros([41,41]);
    threshSum=0;
    while threshSum/thisSum < thresh % we need to keep adding to the heat map
        m=find(thisHeat==(max(max(thisHeat))));
        m=m(1); % just take one at a time
        threshHeat(m)=thisHeat(m); % transfer it over
        thisHeat(m)=0; % erase it from the original
        threshSum=sum(sum(threshHeat));
    end
    threshSum=sum(sum(threshHeat))
    
    figure(300+i)
    set(300+i,'position',[(i-1)*500, 10, 500, 500]);
    set(300+i,'name',[CatStr{plotn(i)}]);
    title([CatStr{plotn(i)} ' 75% thresh'],'Color',[0 .5 .7],'FontSize',24);
    axis([-10.5 10.5 -10.5 10.5]);
    drawnow
    hold on
    x1=[];
    y1=[];
    cc=[];
    k=0;
    for x=1:41
        for y=1:41
            k=k+1;
            x1(k)=(x/2)-10.5;
            y1(k)=(y/2)-10.5;
            if threshHeat(x,y) > 0 % some data here
                hue=(1-threshHeat(x,y))/1.5; % 0 to .5, I think red to blue
                cc(k,:)=hsv2rgb(hue,1,.6);
            else
                cc(k,:)=[0 0 0]; % black
            end
        end
    end
    scatter(x1,y1,200,cc,'s','filled')
    drawnow
    hold on
end



if plotFlag > 1
    FlushEvents('KeyDown');
    GetChar;
end
% close all

% Let's findout when the eyes first reached the target
FirstHitSac=zeros(80,ObsN); %record the sac number for the first hit for each obs
FirstHitRev=zeros(80,ObsN); %record the revsac number for the first hit for each obs
FirstHitTime=zeros(80,ObsN); %record the elapsed time for the first hit for each obs

for i=1:nlines
    if sum(UFOVmammo.participant(i) == Obs) % then this is a keeper obs for this run
        if UFOVmammo.targetPresent(i)==1 % target present
            if SacCat(i)==1 % in the target box
                ThisCase=find(strcmp(Case.Case,UFOVmammo.Case(i))==1); % locate the row with this case
                ThisObs=find(Obs==UFOVmammo.participant(i)); % locate the Col for this Obs
                if FirstHitSac(ThisCase,ThisObs)==0 % then this is the first instance
                    FirstHitSac(ThisCase,ThisObs)=UFOVmammo.SacNumber(i);
                    FirstHitRev(ThisCase,ThisObs)=UFOVmammo.RevSac(i);
                    FirstHitTime(ThisCase,ThisObs)=UFOVmammo.CumDur(i);
                end
            end
        end
    end
end

save SacCat
save InBox
save Out2InBox
save FirstTlines
save LastTlines