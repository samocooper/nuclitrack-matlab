function trainD = trainingData(L,FVs,Mov1,trainD)
frames = numel(Mov1);

% prepare matrices for classification

if isempty(trainD)
    
    P = cell(1,frames);
    C = cell(1,frames);
    
    for i = 1:frames
        C{i} = double(L{i}>0);
        P{i} = zeros(size(FVs{i},1),5);
    end
    trainD.P = P;
    trainD.C = C;
end

% Keyboard controls for GUI

figure('KeyPressFcn', {@keyPress_train,0});

global currentFrame
currentFrame = 1;
global ExitFlag
ExitFlag = 0;
global CellClass;
CellClass = zeros(1,3);

colormap jet
cmap = colormap;
cScale = round(size(cmap,1)/6);

dims = size(Mov1{1});

%------ Standard controls
    
uicontrol('Style','pushbutton','String','(a) <<','Position',[230,30,50,25],'Callback',{@keyPress_train,10});
uicontrol('Style','pushbutton','String','>> (d)','Position',[280,30,50,25],'Callback',{@keyPress_train,11});
uicontrol('Style','pushbutton','String','Stop','Position',[340,30,50,25],'Callback',{@keyPress_train,12});

%------- Cell Class Buttons

uicontrol('Style','pushbutton','BackgroundColor',cmap(20,:),'String','No cell (z)','Position',[400,30,80,25],'Callback',{@keyPress_train,2});
uicontrol('Style','pushbutton','BackgroundColor',cmap(30,:),'String','1 cell (x)','Position',[500,30,80,25],'Callback',{@keyPress_train,3});
uicontrol('Style','pushbutton','BackgroundColor',cmap(40,:),'String','2 cell (c)','Position',[600,30,80,25],'Callback',{@keyPress_train,4});
uicontrol('Style','pushbutton','BackgroundColor',cmap(50,:),'String','Mitotic (v)','Position',[700,30,80,25],'Callback',{@keyPress_train,5});
uicontrol('Style','pushbutton','BackgroundColor',cmap(60,:),'String','Mitotic Exit (b)','Position',[800,30,80,25],'Callback',{@keyPress_train,6});
    

while 1
    
    %Prepare images and class mats for visualisation
    
    Ltemp = L{currentFrame};
    temp = label2rgb(Ltemp, 'jet', 'w', 'shuffle');

    Gtemp = double(Mov1{currentFrame});
        
    Z =  double(ind2rgb(round(trainD.C{currentFrame}*cScale*0.9), cmap))*256;    
    Z2 = repmat(Gtemp,[1 1 3]);  
    
    image([Z+Z2  temp])    
    truesize
    
    uiwait
    
    if currentFrame == 0
        currentFrame = currentFrame + 1;
    end
    if currentFrame == frames
        currentFrame = currentFrame -1;
    end
    
    for j = 2:size(CellClass,1)
        
        pos = CellClass(j,:);
        pos = round(pos);
        
        % Assign class to selected cell
        
        if pos(1)>0 && pos(1)<dims(2) && pos(2)>0 && pos(2)<dims(1)
            
            val = Ltemp(pos(2),pos(1));
            
            if  val ~= 0
                
                [~,I] = pdist2(FVs{currentFrame}(:,1:2),pos(1:2),'Euclidean','Smallest',1);
                
                trainD.P{currentFrame}(I,:) = 0;
                trainD.P{currentFrame}(I,pos(3)-1) = 1;  
                
                trainD.C{currentFrame}(Ltemp == val) = pos(3);
            end
        end
    end
        
    if ExitFlag == 1
        
        close(gcf)        
        break
    end
    
end