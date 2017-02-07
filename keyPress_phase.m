function keyPress_phase(~, EventData, f)

global currentTrack;
global mouseDown;
global flag;

if ~f
    switch EventData.Key
        
        case 'a'
            currentTrack = currentTrack -1;
        case 'd'
            currentTrack = currentTrack +1;
            
        case {'z','x','c'}
            
            
            [x,y] = ginput(1);
            x = round(x);
            y = round(y);
            mouseDown = [currentTrack x y];
            
            switch EventData.Key
                case 'z'
                    flag = 1;
                case 'x'
                    flag = 2;
                case 'c'
                    flag = 3;
            end
    end
else
    switch f
        case {1,2,3}
            [x,y] = ginput(1);
            x = round(x);
            y = round(y);
            mouseDown = [currentTrack x y];
            flag = f;
        case 4
            currentTrack = currentTrack -1;
        case 5
            currentTrack = currentTrack +1;
        case 6
            flag = 6;
    end
end
uiresume