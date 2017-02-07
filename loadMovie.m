function Mov = loadMovie(fname,channel,frames)

% function for loading in tiff time series exported from columbus

Mov = cell(1,frames);

for i = 1:frames    
    fname(23) = int2str(channel);
    fname(15:17) = num2str(i,'%03.0f');
    Im = imread(fname);
    Mov{i} = double(Im);
end



