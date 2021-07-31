% THIS CODE MAKES Prob Density Functions (PDFs) of Saccade length
% It assumes that you have run UFOVmammo6 and that all those variables are still live in your workspace.
% April 6, 2020

rand('state',sum(100*clock));
figure(101)
set(101,'position',[0 550 500 300]);
set(101,'name',['Saccades histo']);
% set(gca,'Color',[0 0 0])
axis([0 10.5 0 .3]);
drawnow
hold on
figure(102)
set(102,'position',[550 550 500 300]);
set(102,'name',['Early Saccade histo']);
% set(gca,'Color',[0 0 0])
axis([0 10.5 0 .3]);
drawnow
hold on
figure(103)
set(103,'position',[1100 550 500 300]);
set(103,'name',['Late Saccade histo']);
% set(gca,'Color',[0 0 0])
axis([0 10.5 0 .3]);
drawnow
hold on

[TargSac Tedge]=histcounts(UFOVmammo.SacBin(find(SacCat==1)),11,'BinLimits',[-.2,10])
[PreSac Tedge]=histcounts(UFOVmammo.SacBin(find(SacCat==4)),11,'BinLimits',[-.2,10]);
[PostSac Tedge]=histcounts(UFOVmammo.SacBin(find(SacCat==2)),11,'BinLimits',[-.2,10]);
TargSacNorm=TargSac/sum(TargSac);
PreSacNorm=PreSac/sum(PreSac);
PostSacNorm=PostSac/sum(PostSac);

TS=find(SacCat==1);
PreS=find(SacCat==4);
PostS=find(SacCat==2);
Early=find(UFOVmammo.SacNumber<4);
Late=find(UFOVmammo.SacNumber>=4);
EarlyTS=UFOVmammo.SacBin(intersect(TS,Early));
EarlyPreS=UFOVmammo.SacBin(intersect(PreS,Early));
EarlyPostS=UFOVmammo.SacBin(intersect(PostS,Early));
LateTS=UFOVmammo.SacBin(intersect(TS,Late));
LatePreS=UFOVmammo.SacBin(intersect(PreS,Late));
LatePostS=UFOVmammo.SacBin(intersect(PostS,Late));
[HEarlyTS Tedge]=histcounts(EarlyTS,11,'BinLimits',[-.2,10])
[HEarlyPreS Tedge]=histcounts(EarlyPreS,11,'BinLimits',[-.2,10])
[HEarlyPostS Tedge]=histcounts(EarlyPostS,11,'BinLimits',[-.2,10])
[HLateTS Tedge]=histcounts(LateTS,11,'BinLimits',[-.2,10])
[HLatePreS Tedge]=histcounts(LatePreS,11,'BinLimits',[-.2,10])
[HLatePostS Tedge]=histcounts(LatePostS,11,'BinLimits',[-.2,10])
EarlyTSNorm=HEarlyTS/sum(HEarlyTS);
EarlyPreNorm=HEarlyPreS/sum(HEarlyPreS);
EarlyPostNorm=HEarlyPostS/sum(HEarlyPostS);
LateTSNorm=HLateTS/sum(HLateTS);
LatePreNorm=HLatePreS/sum(HLatePreS);
LatePostNorm=HLatePostS/sum(HLatePostS);

figure(101)
plot(0:10,TargSacNorm,'-', 'color', [0 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,PreSacNorm,'-', 'color', [1 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,PostSacNorm,'-', 'color', [1 .2 .6], 'LineWidth',2)
drawnow
hold on

figure(102)
plot(0:10,EarlyTSNorm,'-', 'color', [0 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,EarlyPreNorm,'-', 'color', [1 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,EarlyPostNorm,'-', 'color', [1 .2 .6], 'LineWidth',2)
drawnow
hold on

figure(103)
plot(0:10,LateTSNorm,'-', 'color', [0 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,LatePreNorm,'-', 'color', [1 .5 .1], 'LineWidth',2)
drawnow
hold on
plot(0:10,LatePostNorm,'-', 'color', [1 .2 .6], 'LineWidth',2)
drawnow
hold on

figure(101)
rsac=zeros(5,11);
rsacNorm=zeros(5,11);
for rr=1:5 % let's histo the last 5 revsacs
   [rsac(rr,:) Tedge]=histcounts(UFOVmammo.SacBin(find(UFOVmammo.RevSac==rr)),11,'BinLimits',[-.2,10]);
   rsacNorm(rr,:)=rsac(rr,:)/sum(rsac(rr,:));
   plot(0:10,rsacNorm(rr,:),'--', 'color', [.6/rr .6 .6], 'LineWidth',1)
drawnow
hold on
end
rsac

ForPrism=zeros(11,8);

ForPrism(:,1)=transpose(PreSacNorm);
ForPrism(:,2)=transpose(TargSacNorm);
ForPrism(:,3)=transpose(PostSacNorm);
ForPrism(:,4:8)=transpose(rsacNorm);
