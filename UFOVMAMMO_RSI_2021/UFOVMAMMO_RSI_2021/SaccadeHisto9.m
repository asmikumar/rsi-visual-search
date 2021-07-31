% THIS CODE MAKES Prob Density Functions (PDFs) of Saccade length
% It assumes that you have run UFOVmammo6 and that all those variables are still live in your workspace.
% April 6, 2020

% Aug 20, 2020
% Now we load variables so it is more free standing

% V6 is the one I am using to generate pictures for the paper.

% v7 asks if the P(next to target) functions changes as a function of dwell time

cd /Users/jeremywolfe/Documents/MATLAB2016/UFOVMAMMO
clear all
close all


load UFOVmammo % the monster data file...now with corrected NewTrialType
load bb % the set of target bounding boxes
load Case % the set of cases
load SacCat
load InBox
load Out2InBox % Out2In is the line of the fixation BEFORE the targeting Fixation
load FirstTlines
load LastTlines
load OtherTlines
load UFOVmammo % the monster data file...now with corrected NewTrialType
load Out2InBox % Out2In is the line of the fixation BEFORE the targeting Fixation

UFOVmammo(1,:)
[nlines zz]=size(UFOVmammo)

% to test random chance landing onplausible target locations, shuffle InBox
% InBox=Shuffle(InBox);


Expertise=readtable('ObsDetailsForMatlab.xlsx');
experts=Expertise.SubjID(find(Expertise.expertiseNumber==1));
genRad=Expertise.SubjID(find(Expertise.expertiseNumber==2));
residents=Expertise.SubjID(find(Expertise.expertiseNumber==3));


%get input
prompt={'Enter Case # (1-80, 99 does all', 'Enter Obs#  99 does all','Restriction: 0 = none, 1=correct',...
    'Write to disk? 1=yes'};
def={'99', '99', '0', '0'};
ttitle='Input Variables';
lineNo=1;

userinput=inputdlg(prompt,ttitle,lineNo,def,'on');

%Convert User Input

inputCase=str2num(userinput{1,1});
inputObs=str2num(userinput{2,1});
correctFlag=str2num(userinput{3,1});
saveFlag=str2num(userinput{4,1});

for correctFlag=0
    for ThisObsClass=0 % =[1,3] doe experts v residents
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
        
        %   0 = First
        %   1 = targeting endpoint inside bounding box of target
        %   2 = True post targeting (after final fixation on the target)
        
        %   4 = Search saccades (all other)
        %   5 = absent trial saccade
        %   6 = 'BetweenTargeting'; % after the first fixation, before the final fixation
        
        if ThisObsClass==0
            ThisObsDiv=1;
        else
            ThisObsDiv=ThisObsClass;
        end
        col(1,:)=hsv2rgb([.33 1/ThisObsDiv .5]);
        col(2,:)=hsv2rgb([0 .6/ThisObsDiv .5]);
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
        set(101,'position',[0 0 1000 600]);
        set(101,'name',['Saccades histo']);
        if correctFlag == 1
            tstr=['Saccade Histogram: ', ThisObsStr, '- Correct trials only'];
        else
            tstr=['Saccade Histogram: ', ThisObsStr, '- All trials'];
        end
        title(tstr,'Color',[0 .5 .7],'FontSize',28);
        xlabel('Saccade length (deg)','Color',[0 0 0],'FontSize',28);
        ylabel('Proportion of saccades','Color',[0 0 0],'FontSize',28);
        % For Fig 6a
        text(5.3, .28,'All saccades','Color',[0 0 0],'FontSize',28);
        text(5.3, .24,'Search (before targeting)','Color',col(4,:),'FontSize',28);
        text(5.3, .20,'All Targeting Saccades','Color',col(1,:),'FontSize',28);
        
% For Fig 6b
        % break out the targeting saccades
%         text(5.3, .30,'First Saccade to Target','Color',col(8,:),'FontSize',28);
%         text(5.3, .26,'Between first and last','Color',col(11,:),'FontSize',28);
%         text(5.3, .22,'Final Saccade to Target','Color',col(9,:),'FontSize',28);
%         text(5.3, .18,'Saccade refixating Target','Color',col(10,:),'FontSize',28);
        
        %         text(5.3, .16,'PostTargeting','Color',col(2,:),'FontSize',28);
        %         text(5.3, .14,'Absent','Color',col(5,:),'FontSize',28);
        set(gca,'fontsize',32)
        axis([0 10.5 0 .34]);
        drawnow
        hold on
        
        figure(102)
        set(102,'position',[0 600 1000 600]);
        set(102,'name',['PNextGoesToTarget']);
        if correctFlag == 1
            title('P(Next Saccade Goes To Target - Correct trials only)','Color',[0 .5 .7],'FontSize',18);
        else
            title('PNextGoesToTarget - All trials ','Color',[0 .5 .7],'FontSize',24);
        end
        xlabel('Distance to Target','Color',[0 0 0],'FontSize',24);
        ylabel('Proportion of saccades','Color',[0 0 0],'FontSize',24);
%         text(7, .55,'All','Color',col(7,:),'FontSize',fontsize);
%         text(7, .5,'Search','Color',col(4,:),'FontSize',fontsize);
%         text(7, .45,'Between','Color',col(6,:),'FontSize',fontsize);
        %         text(7, .4,'PostTargeting','Color',col(2,:),'FontSize',fontsize);
        %         text(7, .35,'Absent','Color',col(5,:),'FontSize',fontsize);     
        set(gca,'fontsize',24)
        axis([0 10.5 0 1]);
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
        
        figure(104)
        set(104,'position',[1000 600 1000 600]);
        set(104,'name',['PNextGoesToTarget']);
        if correctFlag == 1
            title('P(One of Next Three Saccades Goes To Target)','Color',[0 .5 .7],'FontSize',18);
        else
            title('PNextGoesToTarget - All trials ','Color',[0 .5 .7],'FontSize',24);
        end
        xlabel('Distance to Target','Color',[0 0 0],'FontSize',24);
        ylabel('Proportion of saccades','Color',[0 0 0],'FontSize',24);
        drawnow
        hold on
        %         text(7, .55,'All','Color',col(7,:),'FontSize',fontsize);
        %         text(7, .5,'Search','Color',col(4,:),'FontSize',fontsize);
        %         text(7, .45,'Between','Color',col(6,:),'FontSize',fontsize);
        %         %         text(7, .4,'PostTargeting','Color',col(2,:),'FontSize',fontsize);
        %         text(7, .35,'Absent','Color',col(5,:),'FontSize',fontsize);
        axis([0 10.5 0 1]);
        drawnow
        hold on
        set(gca,'fontsize',24)
        drawnow
        hold on
        
        % Out2InBox is the saccade that ends on the location before the saccade
        % into the target box so you need the line after
        Out2InLines=1+find(Out2InBox>0);
        if Out2InLines(length(Out2InLines))>nlines % then the last entry is no good
            Out2InLines=Out2InLines(1:length(Out2InLines)-1);
        end
        
        % get the lines with the saccades you want
        AllLines=find(SacCat>0); % excludes the first fixation since that sac hasno length
        TargLines=find(SacCat==1);
        FirstTargLines=FirstTlines;
        LastTargLines=LastTlines;
        OtherTargLines=OtherTlines;
        Out2InPlot=setdiff(Out2InLines,FirstTargLines);
        Out2InPlot=setdiff(Out2InLines,LastTargLines); % this now makes Out2InPlot the lines going into the target box that aren't first or last
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
        inClickBox=find(UFOVmammo.dist2click < 1.5);
        aa=find(UFOVmammo.dist2click >= 0); % the lines with a click
        inClickBox=intersect(aa, inClickBox);
        [length(SacCat) length(AllLines) length(CORRECTtr) length(INCORRECTtr)]
        AbsSearchLines=setdiff(AbsLines,inClickBox);
        FAboxLines=intersect(AbsLines,inClickBox);
        
        if correctFlag==1 % then use just the correct
            TargLines=intersect(TargLines,HITtr);
            length(TargLines)
            FirstTargLines=intersect(FirstTargLines,HITtr);
            LastTargLines=intersect(LastTargLines,HITtr);
            OtherTargLines=intersect(OtherTargLines,HITtr);
            Out2InPlot=intersect(Out2InPlot,HITtr);
            SearchLines=intersect(SearchLines,CORRECTtr);
            PostTargLines=intersect(PostTargLines,HITtr);
            BetweenTLines=intersect(BetweenTLines,HITtr);
            AbsLines=intersect(AbsLines,TNEGtr);
            AbsSearchLines=setdiff(AbsLines,inClickBox);
            FAboxLines=intersect(AbsLines,inClickBox);
        elseif correctFlag == 2 % all the incorrect trials
            TargLines=intersect(TargLines,INCORRECTtr);
            length(TargLines)
            FirstTargLines=intersect(FirstTargLines,INCORRECTtr);
            LastTargLines=intersect(LastTargLines,INCORRECTtr);
            OtherTargLines=intersect(OtherTargLines,INCORRECTtr);
            Out2InPlot=intersect(Out2InPlot,INCORRECTtr);
            SearchLines=intersect(SearchLines,INCORRECTtr);
            PostTargLines=intersect(PostTargLines,INCORRECTtr);
            BetweenTLines=intersect(BetweenTLines,INCORRECTtr);
            AbsLines=intersect(AbsLines,INCORRECTtr);
            AbsSearchLines=setdiff(AbsLines,inClickBox);
            FAboxLines=intersect(AbsLines,inClickBox);
        end
        
        %Now filter by the obs you want
        olines=[];
        for NObs=1:ObsN
            oo=Obs(NObs);
            olines=[olines transpose(find(UFOVmammo.participant==oo))];
        end
        olines=transpose(olines);
        length(olines)
        TargLines=intersect(TargLines,olines);
        length(TargLines)
        FirstTargLines=intersect(FirstTargLines,olines);
        LastTargLines=intersect(LastTargLines,olines);
        OtherTargLines=intersect(OtherTargLines,olines);
        Out2InPlot=intersect(Out2InPlot,olines);
        SearchLines=intersect(SearchLines,olines);
        PostTargLines=intersect(PostTargLines,olines);
        BetweenTLines=intersect(BetweenTLines,olines);
        AbsLines=intersect(AbsLines,olines);
        
        
        
        % Get histograms counts for deg 0:10
        [AllSac Tedge]=histcounts(UFOVmammo.SacBin,11,'BinLimits',[-.2,10]);
        [TargSac Tedge]=histcounts(UFOVmammo.SacBin(TargLines),11,'BinLimits',[-.2,10]);
        [FirstTargSac Tedge]=histcounts(UFOVmammo.SacBin(FirstTlines),11,'BinLimits',[-.2,10]);
        [LastTargSac Tedge]=histcounts(UFOVmammo.SacBin(LastTlines),11,'BinLimits',[-.2,10]);
        [OtherTargSac Tedge]=histcounts(UFOVmammo.SacBin(OtherTlines),11,'BinLimits',[-.2,10]);
        [Out2InSac Tedge]=histcounts(UFOVmammo.SacBin(Out2InPlot),11,'BinLimits',[-.2,10]);
        [SearchSac Tedge]=histcounts(UFOVmammo.SacBin(SearchLines),11,'BinLimits',[-.2,10]);
        [PostTargSac Tedge]=histcounts(UFOVmammo.SacBin(PostTargLines),11,'BinLimits',[-.2,10]);
        [BetweenTSac Tedge]=histcounts(UFOVmammo.SacBin(BetweenTLines),11,'BinLimits',[-.2,10]);
        [AbsSac Tedge]=histcounts(UFOVmammo.SacBin(AbsLines),11,'BinLimits',[-.2,10]);
        [AbsSearch Tedge]=histcounts(UFOVmammo.SacBin(AbsSearchLines),11,'BinLimits',[-.2,10]);
        [FAbox Tedge]=histcounts(UFOVmammo.SacBin(FAboxLines),11,'BinLimits',[-.2,10]);
        % normalize each of these [0,1]
        AllSacNorm=AllSac/sum(AllSac);
        TargSacNorm=TargSac/sum(TargSac);
        FirstTargSacNorm=FirstTargSac/sum(FirstTargSac);
        LastTargSacNorm=LastTargSac/sum(LastTargSac);
        OtherTargSacNorm=OtherTargSac/sum(OtherTargSac);
        Out2InSacNorm=Out2InSac/sum(Out2InSac);
        SearchSacNorm=SearchSac/sum(SearchSac);
        PostTargSacNorm=PostTargSac/sum(PostTargSac);
        BetweenTSacNorm=BetweenTSac/sum(BetweenTSac);
        AbsSacNorm=AbsSac/sum(AbsSac);
        AbsSearchNorm=AbsSearch/sum(AbsSearch);
        FAboxNorm=FAbox/sum(FAbox);
        
        sumAllSac=sum(AllSac)
        sumTargSac=sum(TargSac)
        sumFirstTargSac=sum(FirstTargSac)
        sumLastTargSac=sum(LastTargSac)
        sumOtherTargSac=sum(OtherTargSac)
        sumOut2InSac=sum(Out2InSac)
        sumSearchSac=sum(SearchSac)
        sumPostTargSac=sum(PostTargSac)
        sumBetweenTSac=sum(BetweenTSac)
        sumAbsSac=sum(AbsSac)
        sumAbsSearch=sum(AbsSearch)

        
        
        liner='--';
        if correctFlag==2
            liner='--';
        end
        
        figure(101) % Fig 6b version

        %     % break up the saccades that end on the target
        plot(0:10,FirstTargSacNorm,'-s', 'color', col(8,:), 'LineWidth',6)
        plot(0:10,LastTargSacNorm,'-d', 'color', col(9,:), 'LineWidth',6)
        plot(0:10,OtherTargSacNorm,'-v', 'color', col(10,:), 'LineWidth',6)
        plot(0:10,Out2InSacNorm,'-o', 'color', col(11,:), 'LineWidth',6)
        plot(0:10,PostTargSacNorm,'-o', 'color', col(1,:), 'LineWidth',3)
        plot(0:10,AbsSacNorm,'-o', 'color', col(2,:), 'LineWidth',3)
        plot(0:10,AbsSearchNorm,'-o', 'color', col(3,:), 'LineWidth',3)
  
        plot(0:10,FirstTargSacNorm,'s', 'color', col(8,:), 'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',col(8,:),...
            'MarkerSize',20)
        drawnow
        hold on
        plot(0:10,LastTargSacNorm,'o', 'color', col(9,:), 'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',col(9,:),...
            'MarkerSize',20)
        drawnow
        hold on
        plot(0:10,OtherTargSacNorm,'d', 'color', col(10,:), 'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',col(10,:),...
            'MarkerSize',20)
        drawnow
        hold on
        plot(0:10,Out2InSacNorm,'v', 'color', col(11,:), 'LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',col(11,:),...
            'MarkerSize',20)
        drawnow
        hold on
        
         figure(101) % fig 6a version
         
         plot(0:10,AllSacNorm,'-', 'color', [0 0 0], 'LineWidth',6)
         plot(0:10,TargSacNorm,'-', 'color', col(1,:), 'LineWidth',6)
         plot(0:10,SearchSacNorm,'-', 'color', col(4,:), 'LineWidth',6)
%          plot(0:10,PostTargSacNorm,liner, 'color', col(2,:), 'LineWidth',6)
%          plot(0:10,BetweenTSacNorm,liner, 'color', col(6,:), 'LineWidth',6)
%          plot(0:10,AbsSacNorm,liner, 'color', col(5,:), 'LineWidth',6)
         % break up the saccades that end on the target
%          add the symbols
         plot(0:10,AllSacNorm,'s', 'color', [0 0 0], 'LineWidth',2,...
             'MarkerEdgeColor','k',...
             'MarkerFaceColor',[.7 .7 .7],...
             'MarkerSize',30)
         drawnow
         hold on
         plot(0:10,TargSacNorm,'o', 'color', col(1,:), 'LineWidth',2,...
             'MarkerEdgeColor','k',...
             'MarkerFaceColor',col(1,:),...
             'MarkerSize',20)
         drawnow
         hold on
         plot(0:10,SearchSacNorm,'d', 'color', col(4,:), 'LineWidth',2,...
             'MarkerEdgeColor','k',...
             'MarkerFaceColor',col(4,:),...
             'MarkerSize',20)
         drawnow
         hold on
        
      
                
        if correctFlag==2
            plot(0:10,AbsSearchNorm,'--', 'color', [1 .3 .5], 'LineWidth',4)
            plot(0:10,FAboxNorm,'--', 'color', [1 0 0], 'LineWidth',2)
            drawnow
            hold on
        end
        
        drawnow
        hold on
        
        % % here we are creating a plot of P(targeting) X distance to target
        

        DwellFilterFlag=0;
        if DwellFilterFlag>0
            dwbins=3;
            DwellCounts=zeros(3,6); % lowerdwell upperdwell, Alltr, search, between, post
            DwellFilter=[0 150
                150 500
                500 2000]
        else
            dwbins=1;
            DwellCounts=zeros(1,6); % lowerdwell upperdwell, Alltr, search, between, post
            DwellFilter=[0 2000];
        end
        for zz=1:dwbins
              
            SearchTr=find(SacCat==4); % all the pre targeting search trials
            BetweenTr=find(SacCat==6); % all the between targeting search trials
            PostTr=find(SacCat==2); % all the post targeting trials
            
            dwbot=find(UFOVmammo.duration > DwellFilter(zz,1));
            dwtop=find(UFOVmammo.duration < DwellFilter(zz,2));
            dw=intersect(dwbot, dwtop);
            DwellCounts(zz,:)=[DwellFilter(zz,1), DwellFilter(zz,2), length(dw), length(intersect(dw,SearchTr)), length(intersect(dw,BetweenTr)),length(intersect(dw,PostTr))];
            
            
            for i=1:10 % lower bound of the distance range
                botrange(i)=((i-1))+.5;
                toprange(i)=botrange(i)+1;
                bottr=find(UFOVmammo.DistTarg>=botrange(i));
                toptr=find(UFOVmammo.DistTarg < toprange(i));
                allDtr=intersect(bottr,toptr); % The set of rows with DistTarg in range.
                allDtr=intersect(allDtr,olines); % Restrict to the right class of Os
                allDtr=intersect(allDtr,dw); % restrict to a time range
                NallDtr(i)=length(allDtr); % number in range
                for nxt=1:3 % we will look at the next 3 fixations
                    allNext=allDtr+nxt; % the index for the next trial
                    while max(allNext) > length(InBox) % then drop the last value
                        allNext=allNext(1:length(allNext)-1);
                    end
                    NnextInBox(nxt,i)=sum(InBox(allNext)); % number of saccades that went to the target next
                    pGoToTarg(nxt,i)=NnextInBox(nxt,i)/NallDtr(i);
                end
                
                % repeat for search Trials
                searchDtr=intersect(allDtr, SearchTr);
                searchDtr=intersect(searchDtr,dw); % restrict to a time range
                NsearchDtr(i)=length(searchDtr); % number in range
                for nxt=1:3 % we will look at the next 3 fixations
                    searchNext=searchDtr+nxt; % the index for the next trial
                    while max(searchNext) > length(InBox) % then drop any values that are too big
                        searchNext=searchNext(1:length(searchNext)-1);
                    end
                    NSearchnextInBox(nxt,i)=sum(InBox(searchNext)); % number of saccades that went to the target next
                    pSearchGoToTarg(nxt,i)=NSearchnextInBox(nxt,i)/NsearchDtr(i);
                end
                
                % repeat for between Trials
                betweenDtr=intersect(allDtr, BetweenTr);
                betweenDtr=intersect(betweenDtr,dw); % restrict to a time range
                NbetweenDtr(i)=length(betweenDtr); % number in range
                for nxt=1:3 % we will look at the next 3 fixations
                    betweenNext=betweenDtr+nxt; % the index for the next trial
                    while max(betweenNext) > length(InBox) % then drop the last value
                        betweenNext=betweenNext(1:length(betweenNext)-1);
                    end
                    NbetweennextInBox(nxt,i)=sum(InBox(betweenNext)); % number of saccades that went to the target next
                    pbetweenGoToTarg(nxt,i)=NbetweennextInBox(nxt,i)/NbetweenDtr(i);
                end
                
                % repeat for Post Trials
                postDtr=intersect(allDtr, PostTr);
                postDtr=intersect(postDtr,dw); % restrict to a time range
                NpostDtr(i)=length(postDtr); % number in range
                for nxt=1:3 % we will look at the next 3 fixations
                    postNext=postDtr+nxt; % the index for the next trial
                    while max(postNext) > length(InBox) % then drop the last value
                        postNext=postNext(1:length(postNext)-1);
                    end
                    NpostnextInBox(nxt,i)=sum(InBox(postNext)); % number of saccades that went to the target next
                    ppostGoToTarg(nxt,i)=NpostnextInBox(nxt,i)/NpostDtr(i);
                end
                % repeat for First 5 saccades
                short=find(UFOVmammo.SacNumber < 6);
                ShortDtr=intersect(allDtr, short);
                ShortDtr=intersect(ShortDtr,dw); % restrict to a time range
                NShortDtr(i)=length(ShortDtr); % number in range
                for nxt=1:3 % we will look at the next 3 fixations
                    shortNext=ShortDtr+nxt; % the index for the next trial
                    while max(shortNext) > length(InBox) % then drop the last value
                        shortNext=shortNext(1:length(postNext)-1);
                    end
                    NshortnextInBox(nxt,i)=sum(InBox(shortNext)); % number of saccades that went to the target next
                    pshortGoToTarg(nxt,i)=NshortnextInBox(nxt,i)/NShortDtr(i);
                end                
            end
            pGoToTarg
            pSearchGoToTarg
            pbetweenGoToTarg
            ppostGoToTarg
            pshortGoToTarg
            figure(102)
            plot(botrange+.25,pGoToTarg(1,:),'-', 'color', hsv2rgb([.33  zz/3  zz/3]), 'LineWidth',6)
            drawnow
            hold on
            plot(botrange+.25,pSearchGoToTarg(1,:),'-', 'color', hsv2rgb([.8  zz/3  zz/3]), 'LineWidth',6)
            drawnow
            hold on
%             plot(botrange+.25,pbetweenGoToTarg(1,:),'-', 'color', hsv2rgb([.7  zz/3  zz/3]), 'LineWidth',6)
%             drawnow
%             hold on            
%             plot(botrange+.25,pshortGoToTarg(1,:),'-', 'color', hsv2rgb([.95  zz/3  zz/3]), 'LineWidth',6)
%             drawnow
%             hold on
            %         plot(botrange+.25,ppostGoToTarg,'-', 'color', col(2,:), 'LineWidth',6)
            plot(botrange+.25,pGoToTarg(1,:),'o', 'color', hsv2rgb([.33  zz/3  zz/3]), 'LineWidth',2, ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',hsv2rgb([.33  1  1]),...
                'MarkerSize',20)
            drawnow
            hold on
            
            plot(botrange+.25,pSearchGoToTarg(1,:),'s', 'color', hsv2rgb([.7  zz/3  zz/3]), 'LineWidth',2, ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',hsv2rgb([.8  1  1]),...
                'MarkerSize',20)
            drawnow
            hold on
            
%             plot(botrange+.25,pbetweenGoToTarg(1,:),'d', 'color', hsv2rgb([.8  zz/3  zz/3]), 'LineWidth',2, ...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',hsv2rgb([.7  1  1]),...
%                 'MarkerSize',20)
%             drawnow
%             hold on
%             plot(botrange+.25,pshortGoToTarg(1,:),'d', 'color', hsv2rgb([.8  zz/3  zz/3]), 'LineWidth',2, ...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',hsv2rgb([.95  .3  1]),...
%                 'MarkerSize',20)
            drawnow
            hold on
            
            %         plot(botrange+.25,ppostGoToTarg,'o', 'color', col(2,:), 'LineWidth',2, ...
            %             'MarkerEdgeColor','k',...
            %             'MarkerFaceColor',col(2,:),...
            %             'MarkerSize',20)
            
            drawnow
            hold on
            
            % you need to compute the probability of landing at least once on
            % the target. THat is 1 - P(never landing)
            ppGoToTarg=1-(prod(1-pGoToTarg))
            ppSearchGoToTarg=1-(prod(1-pSearchGoToTarg))
            ppbetweenGoToTarg=1-(prod(1-pbetweenGoToTarg))
            ppshortGoToTarg=1-(prod(1-pshortGoToTarg))
            figure(104)
            plot(botrange+.25,(ppGoToTarg),'-', 'color',  hsv2rgb([.33  zz/3  zz/3]), 'LineWidth',6)
            drawnow
            hold on
            plot(botrange+.25,(ppSearchGoToTarg),'-', 'color',  hsv2rgb([.8  zz/3  zz/3]), 'LineWidth',6)
            drawnow
            hold on
%             plot(botrange+.25,(ppbetweenGoToTarg),'-', 'color',  hsv2rgb([.7  zz/3  zz/3]), 'LineWidth',6)
%             drawnow
%             hold on
%             plot(botrange+.25,(ppshortGoToTarg),'-', 'color',  hsv2rgb([.95  zz/3  zz/3]), 'LineWidth',6)
%             drawnow
%             hold on
            %         plot(botrange+.25,ppostGoToTarg,'-', 'color', col(2,:), 'LineWidth',6)
            plot(botrange+.25,(ppGoToTarg),'o', 'color', hsv2rgb([.33  zz/3  zz/3]), 'LineWidth',2, ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',hsv2rgb([.33  1  1]),...
                'MarkerSize',20)
            drawnow
            hold on
            plot(botrange+.25,(ppSearchGoToTarg),'s', 'color',hsv2rgb([.8  zz/3  zz/3]), 'LineWidth',2, ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',hsv2rgb([.8  1  1]),...
                'MarkerSize',20)
            drawnow
            hold on
%             plot(botrange+.25,(ppbetweenGoToTarg),'d', 'color', hsv2rgb([.7  zz/3  zz/3]), 'LineWidth',2, ...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',hsv2rgb([.7  1  1]),...
%                 'MarkerSize',20)
%             drawnow
%             hold on
%             plot(botrange+.25,(ppshortGoToTarg),'d', 'color', hsv2rgb([.7  zz/3  zz/3]), 'LineWidth',2, ...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',hsv2rgb([.95  .3  1]),...
%                 'MarkerSize',20)
            
            %         plot(botrange+.25,ppostGoToTarg,'o', 'color', col(2,:), 'LineWidth',2, ...
            %             'MarkerEdgeColor','k',...
            %             'MarkerFaceColor',col(2,:),...
            %             'MarkerSize'6
            
            drawnow
            hold on
            % distances as function of reverse sac
        end
        
        
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
            %             figure(103)
            %             plot(revsac, HitTrDistToTarg(k,:),'-','color',col(7,:), 'LineWidth',1)
            %             plot(revsac, MissTrDistToTarg(k,:),'-','color',col(2,:), 'LineWidth',1)
            %             drawnow
            %             hold on
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
        %         FlushEvents('KeyDown');
        %         GetChar;
        %     close all
    end
end

%Generate Basic mean, std, median, N for all the saccade types
% get all the lines that contain real saccades (Sometimes fixation n-1 is
% not good so that saccade has no length
AllLines=(intersect(NotNanLines,AllLines));
TargLines=(intersect(NotNanLines,TargLines));
FirstTargLines=(intersect(NotNanLines,FirstTargLines));
LastTargLines=(intersect(NotNanLines,LastTargLines));
OtherTargLines=(intersect(NotNanLines,OtherTargLines));
Out2InPlot=(intersect(NotNanLines,Out2InPlot));
SearchLines=(intersect(NotNanLines,SearchLines));
PostTargLines=(intersect(NotNanLines,PostTargLines));
BetweenTLines=(intersect(NotNanLines,BetweenTLines));
AbsLines=(intersect(NotNanLines,AbsLines));

MeanTable=zeros(ObsN,11);
for i=1:ObsN
    oo=Obs(i);
    olines=find(UFOVmammo.participant==oo); % all lines for that obs
    % get the mean for each observer
    meanAllLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,AllLines)));
    meanTargLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,TargLines)));
    meanFirstTargLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,FirstTargLines)));
    meanLastTargLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,LastTargLines)));
    meanOtherTargLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,OtherTargLines)));
    meanOut2InPlot=mean(UFOVmammo.SacSize_deg_(intersect(olines,Out2InPlot)));
    meanSearchLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,SearchLines)));
    meanPostTargLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,PostTargLines)));
    meanBetweenTLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,BetweenTLines)));
    meanAbsLines=mean(UFOVmammo.SacSize_deg_(intersect(olines,AbsLines)));
    HeaderString='Obs(i), meanAllLines, meanTargLines, meanFirstTargLines, meanLastTargLines, meanOtherTargLines, meanOut2InPlot, meanSearchLines, meanPostTargLines, meanBetweenTLines, meanAbsLines';
    MeanTable(i,:)=[Obs(i) meanAllLines meanTargLines meanFirstTargLines meanLastTargLines meanOtherTargLines meanOut2InPlot meanSearchLines meanPostTargLines meanBetweenTLines meanAbsLines];
end




