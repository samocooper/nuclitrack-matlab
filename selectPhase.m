function [TrackSel,FMat] = selectPhase(TrackSel,Cost)


figure('KeyPressFcn', {@keyPress_phase,0});
mval = max(TrackSel.ind(:));
frames = size(TrackSel.ind,1);

global currentTrack;
currentTrack = 2;

global mouseDown;
mouseDown = [];

global flag;
flag = 0;

A = uicontrol('Style','text','String','track NA', 'Position',[40 50 60 15]);
colormap(jet)

cmap = colormap;

% ---- Buttons for function selection ----

colormap(jet)
cmap = colormap;

uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','(a) <<','Position',[40,30,50,17],'Callback',{@keyPress_phase,4});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','>> (d)','Position',[100,30,50,17],'Callback',{@keyPress_phase,5});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 0.5 1],'String','Stop','Position',[160,30,50,17],'Callback',{@keyPress_phase,6});


%cycle phases
uicontrol('Style','pushbutton','BackgroundColor',cmap(20,:),'String','Mitosis (z)','Position',[40,10,50,17],'Callback',{@keyPress_phase,1});
uicontrol('Style','pushbutton','BackgroundColor',cmap(40,:),'String','G1/S (x)','Position',[100,10,50,17],'Callback',{@keyPress_phase,2});
uicontrol('Style','pushbutton','BackgroundColor',cmap(60,:),'String','S/G2 (c)','Position',[160,10,50,17],'Callback',{@keyPress_phase,3});

while 1
    
    % ########## Ammend and Select functions ############
    mask = find(TrackSel.ind(:,currentTrack) ~= 0 & TrackSel.ind(:,currentTrack) ~= mval)';
    
    if ~isempty(mouseDown)
        if flag == 1 || flag == 2 || flag == 3
            
            xpos = round(mouseDown(2));
            if xpos < 1
                xpos = 1;
            end
            if xpos > frames
                xpos = frames-1;
            end
            
            [~,ind] = pdist2(mask',xpos,'euclidean','Smallest',1);
            TrackSel.mstate(mask(ind),currentTrack) = flag;
        end
    end
    
    mask = find(TrackSel.ind(:,currentTrack) ~= 0 & TrackSel.ind(:,currentTrack) ~= mval)';
    Feat = zeros(numel(mask),5);
    
    for h = 1:numel(mask)
        
        ind = TrackSel.ind(mask(h),currentTrack);
        Feat(h,:) = [mask(h) Cost.Feats{mask(h)}(ind,[5 9 10 12])]; % Choose features to plot
        
    end
    
    plot(Feat(:,1),Feat(:,2:end)); 
    hold on
    
    mask2 = find(TrackSel.mstate(:,currentTrack) ~= 0);
    
    if ~isempty(mask2)
        scatter(mask2,ones(1,numel(mask2)),30,cmap(TrackSel.mstate(mask2,currentTrack)*20,:),'filled');
    end
    
    xlim([1 frames]);    
    legend('Diameter','PCNA int','PCNA std', 'PCNA foci') % Feature labels
    
    hold off
    
    flag = 0;
    uiwait
    
    if currentTrack == 1
        currentTrack = 2;
    end
    
    if currentTrack > size(TrackSel.ind,2)
        currentTrack = size(TrackSel.ind,2);
    end
    
    if flag == 6
        close(gcf)
        break
    end
end

% Record cell features into matrix for further data analysis


FMat = zeros(1,(size(Cost.Feats{1},2)+5));

for i = 1:size(TrackSel.ind,2)
    
    mask = find(TrackSel.ind(:,i) ~= 0 & TrackSel.ind(:,i) ~= mval)';
    Feat = zeros(numel(mask),(size(Cost.Feats{1},2)+5));
    
    indT = find(TrackSel.Flag == i);
    
    for h = 1:numel(mask)
        
        ind = TrackSel.ind(mask(h),i);
        
        if h > 1            
            indm1 = TrackSel.ind(mask(h-1),i);
            d = pdist2(Cost.Data{mask(h-1)}(indm1,1:2),Cost.Data{mask(h)}(ind,1:2));
        else
            d = 0;
        end
        
        if TrackSel.parent(mask(h),i) ~= 0 % Record index of parent in feature matrix
            
            pind = TrackSel.parent(mask(h),i);
            pgap = TrackSel.parentGap(mask(h),i);
            p  = find(pind == TrackSel.ind(mask(h)-pgap,:));
            if isempty(p)
                p = 0;
            end
            
        else
            p=0;
        end
        
        Feat(h,:) = [i p mask(h) d Cost.Feats{mask(h)}(ind,:) TrackSel.mstate(mask(h),i)]; % Choose features to plot
        
    end
    
    FMat = [FMat; Feat];
    
end
FMat(1,:) = [];



