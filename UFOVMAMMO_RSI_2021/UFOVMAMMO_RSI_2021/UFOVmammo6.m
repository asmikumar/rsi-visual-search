% UFOVmammo6 as of April 6, 2020
% NOTE: To run this the first time, you need to include lines 27-38
% If you don't clear the workspace, you can then comment those lines out and 
% just run the code again without having to wait for the readtable commands.

% This version will categorize each fixation as
% Search (outside the bounding box - bb)
% targeting (moves from outside to insider)
% refixation (stays inside the bounding box)

% At the moment, this brings in
% SacCat
% let's classify each saccade as
%   -1= Null
%   0 = First
%   1 = targeting endpoint inside bounding box of target
%   2 = refixation (was inside the box)

%   4 = Search saccades (all other)
%   5 = absent trial saccade
%         change in position from fixation i-1 to i
%         dx
%         dy
%         bin for heat maps
%         cX
%         cY

% cd /Users/CCWU/Documents/UFOVMAMMO JMW
clear all
close all
UFOVmammo=readtable('UFOVmammoData3.xlsx');
bb=readtable('UFOVmammoBoundingBox2.xlsx');
save UFOVmammo;
[nlines zz]=size(UFOVmammo)
UFOVmammo(1,:)
save bb
size(bb)
bb(1,:)
Case=readtable('CaseName.xlsx');
save Case
%%

close all
plotFlag=2;

AllObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
GoodObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	22	23]; % just lose #21 for now


Obs=AllObs; % Could be all obs or good obs

ObsN=length(Obs);
finalTr=57;

% plotting variables
imsz=180;
% a 1 deg circle
th = 0:pi/50:2*pi;
circX = 47.76 * cos(th);
circY = 47.76 * sin(th);

% Set up a few things
SacCat=zeros(nlines,1)-1; % set saccade to -1

InBox=zeros(1,nlines);
CatStr{1}='Target';
CatStr{2}='Refixation';
CatStr{3}='TinyNonTarget';
CatStr{4}='OtherSearch';
CatStr{5}='AbsentTrial';
heatN=zeros(ObsN,4);
CatN=zeros(ObsN,4);
heattbl1=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 4 types of saccade
heattbl2=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 4 types of saccade
heattbl3=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 4 types of saccade
heattbl4=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 4 types of saccade
heattbl5=zeros(41,41); %Going to to make a table that is -10 to 10 deg in 0.5 deg bins FOR each of 4 types of saccade


load UFOVmammo
load bb
load Case
UFOVmammo(1,:)
[nlines zz]=size(UFOVmammo)
rand('state',sum(100*clock));
dx=zeros(1,nlines);
dy=zeros(1,nlines);
cX=zeros(1,nlines);
cY=zeros(1,nlines);

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
set(100,'name',['Targeting Saccades']);
set(gca,'Color',[0 0 0])
axis([-500 500 -500 500]);
drawnow
hold on

for i=1:ObsN
    % plot concentric rings in 1 deg increments
    figure(100)
    for zz=1:10
        plot((circX*zz),(circY*zz), '-','LineWidth',1,'color',[1 0 0])
    end
    drawnow
    hold on
    % Get the lines for this obs & trial
    n=0;
    ntrials=max(UFOVmammo.trial); % should be the number of trials for that obs (generally 80)
%     ntrials=finalTr;
    oo=Obs(i);
    olines=find(UFOVmammo.participant==oo); % all lines for that obs
    for tr=1:ntrials
        n=n+1;
        trlines=intersect(olines,find(UFOVmammo.trial==tr));% should be the lines for that trial
        if isempty(trlines)
            ['No trial ' num2str(n)]
        else
            figure(n)
            
            set(n,'position',[mod((n-1),13)*imsz, floor((n-1)/13)*imsz, imsz, imsz]);
            set(n,'name',['Trial', num2str(n)]);
            if strcmp('HIT', UFOVmammo.TrialType(min(trlines)))==1 % HIT
                bc=hsv2rgb([.33 .2 .7]);
            elseif strcmp('MISS', UFOVmammo.TrialType(min(trlines)))==1  % HIT
                bc=hsv2rgb([0 .2 .8]);
            elseif strcmp('TNEG', UFOVmammo.TrialType(min(trlines)))==1  % HIT
                bc=hsv2rgb([.4 .2 1]);
            elseif strcmp('FA', UFOVmammo.TrialType(min(trlines)))==1  % HIT
                bc=hsv2rgb([.1 .2 1]);
            else
                bc=[.2 .2 .2];
            end
            axis([800 1800 100 1100]);
%             set(gca,'Color',bc)
            fill([800 800 1800 1800 800], [100 1100 1100 100 100],bc) 
            drawnow
            hold on
            hue=((1:length(trlines))/(length(trlines)*2));
            cc=ones(length(trlines),3); % color triplets
            cc(:,1)=hue;
            cc=hsv2rgb(cc);
            plot(UFOVmammo.fixX(trlines), UFOVmammo.fixY(trlines),'-k')
            scatter(UFOVmammo.fixX(trlines), UFOVmammo.fixY(trlines),UFOVmammo.duration(trlines)/2,cc,'filled') % scale by fixation duration
            
            % FOR TESTING BOGUS BOX AROUND FIXATION 5
            %             if length(trlines)>4
            %                 x1=UFOVmammo.fixX(trlines(5))-100;
            %                 x2=UFOVmammo.fixX(trlines(5))+100;
            %                 y1=UFOVmammo.fixY(trlines(5))-100;
            %                 y2=UFOVmammo.fixY(trlines(5))+100;
            %             else
            %                 x1=100;
            %                 y1=200;
            %                 x2=1200;
            %                 y2=500;
            %             end
            %             bbox=[x1 y1
            %                 x2 y1
            %                 x2 y2
            %                 x1 y2
            %                 x1 y1];
            %
            %             plot(bbox(:,1), bbox(:,2),'-g', 'LineWidth', 3)
            %             scatter(UFOVmammo.fixX(trlines(5)), UFOVmammo.fixY(trlines(5)),64,[1 1 1], 'filled')
            % THE REAL BB
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
                plot((circX*1.5)+UFOVmammo.targX(min(trlines)),(circY*1.5)+UFOVmammo.targY(min(trlines)), '-','LineWidth',2,'color',[1 1 1])
            end
            drawnow
            hold on
            
            for j=min(trlines):max(trlines) % all the lines for that trial
                % find the fixations inside or near the target
                if UFOVmammo.targetPresent(j)==1 % for target present trials
                    % rule for a target saccade: It is in the bounding box
                    % defined above OR it is 1.5 deg from the target center                   
                    if (UFOVmammo.fixX(j) >= x1 && UFOVmammo.fixY(j) >= y1 && UFOVmammo.fixX(j) <= x2 && UFOVmammo.fixY(j) <= y2) || UFOVmammo.DistTarg_1_5(j)==1; %  in the box
                        InBox(j)=1; % 1 means you are in the box at that line (j)
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
            t=min(find(InBox(trlines)==1)); % this is the first target fixation
            
            if isempty(t) % no first fixation
                if UFOVmammo.targetPresent(min(trlines))==1 % target present (miss, probably)
                    SacCat(trlines)=4; % all PRE
%                     ['No FIRST FIXATION ' num2str(tr)]
                else
                    SacCat(trlines)=5; % ABSENT TRIALS
%                     ['ABSENT TRIAL ' num2str(tr)]
                end
            else
                SacCat(trlines(t))=1;
                SacCat(min(trlines):trlines(t)-1)=4; % all the SEARCH saccades (PRE)
                SacCat((trlines(t)+1):max(trlines))=2; % all the POST TARGET saccades
                if t > 1
                    TSac=[UFOVmammo.fixX(trlines(t)) UFOVmammo.fixY(trlines(t))
                        UFOVmammo.fixX(trlines(t-1)) UFOVmammo.fixY(trlines(t-1))]; % coords of the saccade into the box
                    plot(TSac(:,1), TSac(:,2),'-', 'LineWidth', 4, 'Color', [1 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1), TSac(:,2),'-', 'LineWidth', 2, 'Color', [1 0 0]) % should highlight the saccade going into the target box
                end
                scatter(UFOVmammo.fixX(trlines(find(InBox(trlines)==1))), UFOVmammo.fixY(trlines(find(InBox(trlines)==1))),36,[0 0 0])
                ['FOR TRIAL ' num2str(tr), ' MARK THESE FIXATIONS ', num2str(find(InBox(trlines)==1))]
                drawnow
                hold on
               
                % Draw fixations that go to the target for the first time,
                % normalized so the endpoint of the saccade is (0,0)
                figure(100)
                if strcmp('HIT', UFOVmammo.TrialType(min(trlines)))==1 % HIT                
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 3, 'Color', [0 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 1, 'Color', [.6 0 1]) % should highlight the saccade going into the target box                    
                else % miss saccades
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 3, 'Color', [1 1 0]) % should highlight the saccade going into the target box
                    plot(TSac(:,1)-TSac(1,1), TSac(:,2)-TSac(1,2),'-', 'LineWidth', 1, 'Color', [1 0 0]) % should highlight the saccade going into the target box                                        
                end
                
                % DIFFERENT VERSION Draw fixations that go to the target for the first time
                % Here Target location is set to (0,0) so we can see how
                % that first saccade approaches the target 
                % (NOT INTERESTING...better to histo the abs distance,
                % maybe)
              
%                 figure(100)
%                 if strcmp('HIT', UFOVmammo.TrialType(min(trlines)))==1 % HIT                
%                     plot(TSac(:,1)-UFOVmammo.targX(min(trlines)), TSac(:,2)-UFOVmammo.targY(min(trlines)),'-', 'LineWidth', 3, 'Color', [0 1 0]) % should highlight the saccade going into the target box
%                     plot(TSac(:,1)-UFOVmammo.targX(min(trlines)), TSac(:,2)-UFOVmammo.targY(min(trlines)),'-', 'LineWidth', 1, 'Color', [.6 0 1]) % should highlight the saccade going into the target box                    
%                 else % miss saccades
%                     plot(TSac(:,1)-UFOVmammo.targX(min(trlines)), TSac(:,2)-UFOVmammo.targY(min(trlines)),'-', 'LineWidth', 3, 'Color', [1 1 0]) % should highlight the saccade going into the target box
%                     plot(TSac(:,1)-UFOVmammo.targX(min(trlines)), TSac(:,2)-UFOVmammo.targY(min(trlines)),'-', 'LineWidth', 1, 'Color', [1 0 0]) % should highlight the saccade going into the target box                                        
%                 end

                
                 drawnow
                 hold on
            end
        end
    end
    if i == 14
        ['pause at OBS' num2str(i)]
        FlushEvents('KeyDown');
        GetChar;
    end
end

% dd=InBox(trlines)

FlushEvents('KeyDown');
GetChar;
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
heatplot1=heattbl1/heatmax1;
heatplot2=heattbl2/heatmax2;
% heatplot3=heattbl3/heatmax3;
heatplot4=heattbl4/heatmax4;
heatplot5=heattbl5/heatmax5;

for i=[1 2 4 5]
    cc=[];
    if i==1
        thisHeat=heatplot1;
    elseif i==2
        thisHeat=heatplot2;
    elseif i==4
        thisHeat=heatplot4;
    else
        thisHeat=heatplot5;
    end
    figure(i)
    set(i,'position',[(i-1)*500, 10, 450, 450]);
    set(i,'name',[CatStr{i}]);
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



FlushEvents('KeyDown');
GetChar;
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





% obs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
% for sub=1:18
%     % graph positions
%     gy(sub)=floor((sub-1)/9)*300;
%     gx(sub)=mod(sub-1,9)*200;
%     o=obs(sub); % the observer number for this loop
%     sublines=find(UFOVmammo.participant==o); % all the rows for that obs
%     nsublines=length(sublines);
%     if nsublines > 0 % then there are data
%         n=0;
%         dx=[];
%         dy=[];
%         SacCat=[];
%         SacCol=[];
%         SacColStr=[];
%         % let's classify each saccade as
%         %   0 = First
%         %   1 = targeting (distT < 1.5 deg)
%         %   2 = refixation (was inside the box)
%         %   3 = tinyOther (SacSize < 0.5 && NOT close to target)
%         %   4 = Search saccades (all other)
%         %   5 = absent trial saccade
%
%
%
% % plot saccade maps relative with previous fixation at center
%         figure(sub)
%         set(sub,'position',[gx(sub), gy(sub), 200, 200]);
%         set(sub,'name',['OBS = ', num2str(o)] );
%         axis([-20 20 -20 20]);
%         drawnow
%         hold on
%         % draw the other sac on the bottom
%         k=find(SacCat==4); % all the other saccades for that obs
%         plot(dx(k), dy(k), '.','MarkerSize',10,'Color',[.6 0 .5])
%         drawnow
%         hold on
%         k=find(SacCat==1); % all the Target saccades for that obs
%         plot(dx(k), dy(k), 'o','Color',[0 .6 0])
%         drawnow
%         hold on
%         k=find(SacCat==2); % all the TINY Target saccades for that obs
%         plot(dx(k), dy(k), 'o','Color',[1 0 0])
%         drawnow
%         hold on
%         k=find(SacCat==3); % all the TINY non-Target saccades for that obs
%         plot(dx(k), dy(k), '.','MarkerSize',10,'Color',[1 .5 0])
%         drawnow
%         hold on
%
%
%         % let's draw every saccade in xy coords, in color I hope
%         % (nope)...well, first 1000 sac
%         figure(sub+18)
%         set(sub+18,'position',[gx(sub), gy(sub)+600, 200, 200]);
%         axis([400 1000 0 600]);
%         drawnow
%         hold on
%         z=min(1000,length(sublines));
%         plot(UFOVmammo.fixX(sublines(1:z))/2, UFOVmammo.fixY(sublines(1:z))/2, '-k')
%         drawnow
%         hold on
%         FlushEvents('KeyDown');
%         GetChar;
%         close(2)
%         close(1)
%     end
% end
%
%
% FlushEvents('KeyDown');
% GetChar;
% close all