function [Track,TrackSel,FMat] = amendTracks(L,Cost,Track,Mov,TrackSel)

% function for ammending tracks and assesing data for each track

frames = numel(Mov);
dims = size(Mov{1});
FMat = zeros(1,17);

for i = 1:frames % Clip  so labells remain constant
    Mov{i}(Mov{i}>100) = 100;
    Mov{i} = Mov{i}*1;
end

% Initialise empty structure to store selected tracks for further analysis

if isempty(TrackSel)
    m = zeros(frames,1);
    TrackSel = struct('ind',m,'cost',m,'cumCost',m,'parent',m,'parentGap',m,...
        'mstate',m,'Flag',zeros(1,size(Track.ind,2)));
end


figure('KeyPressFcn', {@keyPress,0});
global currentFrame;
currentFrame = 1;

trackInd = 0;
trackSwap = 0;

global mouseDown;
mouseDown = [];

global flag;
flag = 0;

B = uicontrol('Style','text','String','frame NA', 'Position',[40 60 60 15]);
A = uicontrol('Style','text','String','track NA', 'Position',[100 60 60 15]);
C = uicontrol('Style','text','String',' ', 'Position',[160 60 40 15]);

colormap(jet)
cmap = colormap;
prev = 0;
mval = max(Track.ind(:));
pastframe = 0;

% ---- Buttons for function selection ----

uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','(a) <<','Position',[40,30,50,17],'Callback',{@keyPress,8});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','>> (d)','Position',[100,30,50,17],'Callback',{@keyPress,9});
uicontrol('Style','pushbutton','BackgroundColor',[1 1 0.5],'String','Select (z)','Position',[160,30,60,17],'Callback',{@keyPress,1});
uicontrol('Style','pushbutton','BackgroundColor',[1 1 0.5],'String','Swap (x)','Position',[230,30,60,17],'Callback',{@keyPress,2});
uicontrol('Style','pushbutton','BackgroundColor',[1 1 0.5],'String','Assign (c)','Position',[300,30,60,17],'Callback',{@keyPress,3});
uicontrol('Style','pushbutton','BackgroundColor',[1 1 0.5],'String','Remove (v)','Position',[370,30,60,17],'Callback',{@keyPress,4});
uicontrol('Style','pushbutton','BackgroundColor',[1 0.5 1],'String','Parent 1 (b)','Position',[440,30,60,17],'Callback',{@keyPress,5});
uicontrol('Style','pushbutton','BackgroundColor',[1 0.5 1],'String','Daughter (n)','Position',[510,30,60,17],'Callback',{@keyPress,6});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','Jump (w)','Position',[40,10,50,17],'Callback',{@keyPress,7});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 1 1],'String','Save (s)','Position',[100,10,50,17],'Callback',{@keyPress,16});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 0.5 1],'String','Stop','Position',[510,10,60,17],'Callback',{@keyPress,10});
uicontrol('Style','pushbutton','BackgroundColor',[0.5 0.5 1],'String','Refresh (r)','Position',[440,10,60,17],'Callback',{@keyPress,11});
uicontrol('Style','pushbutton','BackgroundColor',[1 0.5 0.5],'String','Delete','Position',[300,10,60,17],'Callback',{@keyPress,12});
uicontrol('Style','pushbutton','BackgroundColor',[1 0.5 0.5],'String','New (e)','Position',[230,10,60,17],'Callback',{@keyPress,13});
uicontrol('Style','pushbutton','BackgroundColor',[1 0.5 0.5],'String','Store (y)','Position',[160,10,60,17],'Callback',{@keyPress,15});

%cycle phases
uicontrol('Style','pushbutton','BackgroundColor',cmap(40,:),'String','G1/S (g)','Position',[580,30,60,17],'Callback',{@keyPress,20});
uicontrol('Style','pushbutton','BackgroundColor',cmap(60,:),'String','S/G2 (h)','Position',[580,10,60,17],'Callback',{@keyPress,21});

while 1
    
    % ########## Ammend and Select functions ############
    if ~isempty(mouseDown)
        switch flag
            case 1  % Select track
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackInd = find(Track.ind(currentFrame,:) == ind);
                
            case 2 % Swap track
                if trackInd
                    [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                    trackSwap = find(Track.ind(currentFrame,:) == ind);
                    
                    if numel(trackSwap) == 1
                        Track = swapTracks(Track,currentFrame,frames,trackSwap,trackInd,1);
                    end
                end
                
            case 3 % Assign segment to track
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                if numel(trackFind) == 0
                    Track.ind(currentFrame,trackInd) = ind;
                end
                
            case 4 % Remove segment form track
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                Track.ind(currentFrame,trackFind) = 0;
                Track.mstate(currentFrame,trackFind) = 0;
                Track.parent(currentFrame,trackFind) = 0;
                
            case 5 % Assign parent
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                Track.mstate(currentFrame,trackFind) = 1;
                trackInd = trackFind;
                pastframe = currentFrame;
                
                set(C, 'String', ['parent' int2str(trackInd)]);
                
            case 6 % Select daughter
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                Track.parent(currentFrame,trackFind) = Track.ind(pastframe,trackInd);
                Track.parentGap(currentFrame,trackInd) = pastframe-currentFrame;
                
                set(C, 'String', ['' int2str(trackInd)]);
                
            case 7 % jump frames based on graphs axis
                
                xpos = round(mouseDown(2));
                if xpos < 1
                    xpos = 1;
                end
                if xpos > frames
                    xpos = frames-1;
                end
                currentFrame = xpos;
                
            case 12 % delete whole track
                
                Track.ind(:,trackInd) = [];
                Track.parent(:,trackInd) = [];
                Track.parentGap(:,trackInd) = [];
                Track.mstate(:,trackInd) = [];
                Track.cost(:,trackInd) = [];
                Track.cumCost(:,trackInd) = [];
                
            case 13 % new track
                
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                
                if numel(trackFind) == 0
                    
                    Track.ind(:,end+1) = m;
                    Track.parent(:,end+1) = m;
                    Track.parentGap(:,end+1) = m;
                    Track.mstate(:,end+1) = m;
                    Track.cost(:,end+1) = m;
                    Track.cumCost(:,end+1) = m;
                    
                    TrackSel.Flag(end+1) = 0;
                    Track.ind(currentFrame,end) = ind;
                end
                
            case 15 % select track for further analysis
                
                
                TrackSel.ind(:,end+1) = Track.ind(:,trackInd);
                TrackSel.parent(:,end+1) = Track.parent(:,trackInd);
                TrackSel.parentGap(:,end+1) = Track.parentGap(:,trackInd);
                TrackSel.mstate(:,end+1) =  Track.mstate(:,trackInd);
                TrackSel.cost(:,end+1) =Track.cost(:,trackInd);
                TrackSel.cumCost(:,end+1) = Track.cumCost(:,trackInd);
                
                TrackSel.Flag(trackInd) = size(TrackSel,2);
                
            case 16
                
                save('Track_Ammended.mat','Track')
                
            case 20
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                Track.mstate(currentFrame,trackFind) = 2;
                
            case 21
                [~,ind] = pdist2(Cost.Data{mouseDown(1)}(:,1:2),mouseDown(2:3),'euclidean','Smallest',1);
                trackFind = find(Track.ind(currentFrame,:) == ind);
                Track.mstate(currentFrame,trackFind) = 3;                
        end
    end
    
    set(B, 'String', ['track ' int2str(trackInd)]);
    set(A, 'String', ['frame ' int2str(currentFrame)]);
    
    % Create image
    
    temp = zeros(dims);
    
    for h = 1:size(Track.ind,2)
        if Track.ind(currentFrame,h) ~=0 && Track.ind(currentFrame,h) ~= mval
            
            pos = Cost.Data{currentFrame}(Track.ind(currentFrame,h),4:5);
            pos2 = Cost.Data{currentFrame}(Track.ind(currentFrame,h),1:2);
            
            label = L{currentFrame}(pos(2),pos(1));
            temp(L{currentFrame} ==label) = h;
            
            if Track.parent(currentFrame,h) ~= 0
                temp(pos2(2)-5:pos2(2)+5,pos2(1)-5:pos2(1)+5) = 10;
            end
            if Track.mstate(currentFrame,h) == 1
                temp(pos2(2)-5:pos2(2)+5, pos2(1)-5:pos2(1)+5) = 19;
            end
            if trackInd == h
                temp(pos2(2)-3:pos2(2)+3, pos2(1)-3:pos2(1)+3) = 0;
            end
        end
    end
    
    temp2 = temp;
    temp = rem(temp,20);
    temp = temp + 5*(temp2>0);
    temp(1,1) = 25;
    
    % Display graphs
    
    ax1 = subplot(2,1,1);
    imagesc([temp+1*(L{currentFrame}>0) double(0.25*Mov{currentFrame})]);
    
    if ~isempty(trackInd)
        if trackInd>0 && (trackInd ~= prev || ~isempty(find(flag == [11 12 14 15 20 21 22])))
            
            prev = trackInd;
            
            mask = find(Track.ind(:,trackInd) ~= 0 & Track.ind(:,trackInd) ~= mval)';
            Feat = zeros(numel(mask),5);
            
            for h = 1:numel(mask)
                
                ind = Track.ind(mask(h),trackInd);
                Feat(h,:) = [mask(h) Cost.Feats{mask(h)}(ind,[5 10 12 13])]; % Choose features to plot
                
            end
            
            ax2 = subplot(2,1,2);            
            plot(Feat(:,1),Feat(:,2:end));            
            hold on
            
            mask2 = find(Track.mstate(:,trackInd) ~= 0);
            if ~isempty(mask2)
                scatter(mask2,ones(1,numel(mask2)),30,cmap(Track.mstate(mask2,trackInd)*20,:),'filled');
            end
            
            xlim([1 frames]);            
            legend('Diameter','PCNA int','PCNA std', 'PCNA foci') % Feature labels
            
            if TrackSel.Flag(trackInd) > 0                
                scatter(1,1,30,'m','filled');                
            end
            hold off
        end
    end
    
    flag = 0;
    uiwait
    
    if currentFrame == 0
        currentFrame = 1;
    end
    
    if currentFrame > frames
        currentFrame = frames;
    end
    
    if flag == 10
        close(gcf)
        break
    end
end

% Record cell features into matrix for further data analysis

mval = max(TrackSel.ind(:));
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

