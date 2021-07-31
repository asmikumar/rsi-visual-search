% this code will plot every saccade on top of the image of the breast for
% each of 80 cases

% This is the loading code that you need the first time
% clear all
% close all
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

% If things are preloaded, you can use this.
cd /Users/jeremywolfe/Documents/MATLAB2016/UFOVMAMMO
load UFOVmammo
load bb
load Case

UFOVmammo(1,:)

% Control which Os are included
AllObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	21	22	23];
GoodObs=[0	1	2	3	4	5	6	8	10	11	12	16	17	18	19	22	23]; % just lose #21 for now
Obs=AllObs; % Could be all obs or good obs
ObsN=length(Obs);
UFOVmammoCaseData=zeros(80,6);

% HERE IS WHERE WE GET ALL THE FILE NAMES OF ALL THE IMAGES IN THE FOLDER
xoffset=521; % This is the correction that translates x values in the data to x values in the image

Cases=table2cell(Case); % I dunno why Case is a table...but whatever....
cd UFOVMammoImages3
% First we do all the target categories
d=dir; % d now contains a list of files in the directory imageDir
[nname junk]=size(d); %I don't know what junk is, maybe the number of columns in imageDir -George
[holder{1:nname}]=deal(d.name); % ****this line takes the names of the image files and "deals" them into a character array called name
n=0;
for j=1:nname
    if findstr(holder{j}, 'png') > 0; % Then it is a good stim good stim
        n=n+1;
        HoldNames{n}=holder{j}; % load an item into A list of names I think
    end
end
% now go from holdnames to holdnums
HoldNum=[];
for hn=1:length(HoldNames)
    if strcmp(HoldNames{hn}(4),'p') % then this is a one digit case
        HoldNum(hn)=str2num(HoldNames{hn}(2));
    elseif strcmp(HoldNames{hn}(4),'.') || strcmp(HoldNames{hn}(4),'L') || strcmp(HoldNames{hn}(4),'R')% then this is a two digit case
        HoldNum(hn)=str2num(HoldNames{hn}(2:3));
    else
        HoldNum(hn)=str2num(HoldNames{hn}(2:4));    % then this is a three digit case
    end
end

cd ..

for CaseN=1:80 % there are 80 images that were actually used
    CorrectAns=0;
    WrongAns=0;
    ThisCaseStr=(Cases{CaseN}); % This is the string version of the case name
    ThisCaseStr=ThisCaseStr(1:4); % this just truncates it to C or N and a number (I forget why) 
    if findstr(ThisCaseStr(1),'c') % then it is target present
        yn=1;
    else
        yn=0;
    end
    ['Image ' num2str(CaseN), ' ', ThisCaseStr]
    ynlines=find(UFOVmammo.targetPresent==yn); % Gives you all the present or absent lines
    % get the image number whcih can be 1, 2 or 3 digits
    if findstr(ThisCaseStr(4),'C')  % then this is a 1 digit case
        ThisCaseNum=str2num(ThisCaseStr(2));
    elseif findstr(ThisCaseStr(4),'N')
         ThisCaseNum=str2num(ThisCaseStr(2));
    elseif findstr(ThisCaseStr(4),'_') % then this is a 2 digit case
        ThisCaseNum=str2num(ThisCaseStr(2:3));
        ThisCaseStr=ThisCaseStr(1:3);
    else % it is a 3 digit case
        ThisCaseNum=str2num(ThisCaseStr(2:4));
        ThisCaseStr=ThisCaseStr(1:4);
    end
    % this is the image file name to pull off the disk
    for hn=1:length(HoldNames) % go through all the names (because I don't know how to do this in one line
        if HoldNum(hn)==ThisCaseNum  
            ThisNameNum=hn;
            ThisName=HoldNames{hn};
            ['Image ' num2str(CaseN), ' ', ThisCaseStr, ' ', num2str(ThisCaseNum), ' ', ThisName]
        end
    end
    ['Image ' num2str(CaseN), ' ', ThisCaseStr, ' ', num2str(ThisCaseNum), ' ', ThisName]
    % Get the lines for this case
    
    CaseLines=find(UFOVmammo.CaseNum==ThisCaseNum);
    CaseLines=intersect(CaseLines,ynlines); % because you could have c123 and n123

    cd UFOVMammoImages3
    [imageArray,cmap]=imread(ThisName,'png');
    cd ..
    [yy xx]=size(imageArray);
    
    grayArray=zeros(yy, xx, 3);
    grayArray=imageArray/max(max(imageArray));
    grayArray(:,:,1)=imageArray;
    grayArray(:,:,2)=imageArray;
    grayArray(:,:,3)=imageArray;
    
    figure(1)
    set(1,'position',[0 0 xx yy]);
    axis([0 xx 0 yy]);
    h = image(grayArray);
    uistack(h,'bottom')
    drawnow
    hold on
    clear(['imageArray','cmap'])
    if UFOVmammo.targetPresent(min(Caselines))==1
        bnum=find(bb.Case==ThisCaseNum); % this is bounding box index
        % bounding box coords
        x1=bb.bx1(bnum)-xoffset;
        x2=bb.bx2(bnum)-xoffset;
        y1=bb.by1(bnum);
        y2=bb.by2(bnum);
        bbox=[x1 y1
            x2 y1
            x2 y2
            x1 y2
            x1 y1];
        plot(bbox(:,1), bbox(:,2),'-r', 'LineWidth', 2) % this is the bounding box
        
    end
    
    for i=1:ObsN
        % Get the lines for this obs & case
        oo=Obs(i);
        olines=find(UFOVmammo.participant==oo); % all lines for that obs
        trlines=intersect(olines,CaseLines);
        scatter(UFOVmammo.fixX(trlines)-xoffset,UFOVmammo.fixY(trlines),UFOVmammo.duration(trlines)/2, hsv2rgb([1-(i/ObsN) 1 1]))
%         Tabulate accuracy
        if UFOVmammo.accuracy(min(trlines))==1
            CorrectAns=CorrectAns+1;
            plot(UFOVmammo.fixX(trlines)-xoffset,UFOVmammo.fixY(trlines),'-','color',[.8 1 .8]) %correct in greenish
        elseif UFOVmammo.accuracy(min(trlines))==0
            WrongAns=WrongAns+1;
            plot(UFOVmammo.fixX(trlines)-xoffset,UFOVmammo.fixY(trlines),'-','color',[1 .7 .7]) %incorrect in reddish
        end
    end
    pctcorr=round(100*CorrectAns/(CorrectAns+WrongAns));
    UFOVmammoCaseData(CaseN,:)=[ThisCaseNum, yn, CorrectAns, WrongAns, CorrectAns+WrongAns,  pctcorr];
    set(1,'name',[ThisName, '_scan_', num2str(pctcorr), 'pctCorr.png']);
    drawnow
    hold on
%     
%         FlushEvents('KeyDown');
%         GetChar;
    
    % Write the image out to the disk
    cd UFOVMammoImagesWithScanpaths
    saveas(1,[ThisCaseStr 'Wfix_', num2str(pctcorr), 'pctCorr.png'],'png')
    cd ..
    close(1)
    

end
UFOVmammoCaseData