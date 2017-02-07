function keyPress(~, EventData, f)

global currentFrame;
global mouseDown;
global flag;

if ~f
    
   switch EventData.Key
            
    case 'a'
    currentFrame = currentFrame -1;            
    case 'd'       
    currentFrame = currentFrame +1;    
    case 'r'
        flag = 11;        
    case 'y'
        flag = 15;
    case 's'
        flag = 16;
        
    case {'z','x','c','v','b','n','w','u','e','g','h'}
        
        
        [x,y] = ginput(1);
        x = round(x);
        y = round(y);
        mouseDown = [currentFrame x y];
                
        switch EventData.Key
            case 'z'
                flag = 1;
            case 'x'
                flag = 2;
            case 'c'
                flag = 3;
            case 'v'
                flag = 4;
            case 'b'
                flag = 5;
            case 'n' 
                flag = 6;
            case 'w' 
                flag = 7;
            case 'e'
                flag = 13;
            case 'g'
                flag = 20;
            case 'h'
                flag = 21;
            case 'j'
                flag = 22;
        end          
        
   end    
else  
    switch f
        case 8
            currentFrame = currentFrame -1;
        case 9
            currentFrame = currentFrame +1;
        case {1,2,3,4,5,6,7,13,20,21,22}
            
        [x,y] = ginput(1);
        x = round(x);
        y = round(y);
        mouseDown = [currentFrame x y];
        flag = f;
        case {10,11,12,15,16}
            flag = f;            
    end    
end


uiresume
