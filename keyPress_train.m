function keyPress_train(~, EventData,C)

global currentFrame;
global CellClass;
global ExitFlag

CellClass = zeros(1,3);

if ~C
    
    switch EventData.Key
        
        case 'a'
            currentFrame = currentFrame -1;
        case 'd'
            currentFrame = currentFrame +1;
            
        case {'z','x','c','v','b'}
            
            
            [x,y] = ginput(1);
            x = round(x);
            y = round(y);
            mouseDown = [currentFrame x y];
            
            switch EventData.Key
                case 'z'
                    C = 2;
                case 'x'
                    C = 3;
                case 'c'
                    C = 4;
                case 'v'
                    C = 5;
                case 'b'
                    C = 6;
            end
            
            CellClass(end+1,:) = [x y C];
    end
else
    if C < 10
        [x,y] = ginput(1);
        x = round(x);
        y = round(y);
        CellClass(end+1,:) = [x y C];
    end
    
    if C == 10
        currentFrame = currentFrame - 1;
    end
    
    if C == 11
        currentFrame = currentFrame + 1;
    end    
    if C == 12
        ExitFlag = 1;
    end
end

uiresume

end