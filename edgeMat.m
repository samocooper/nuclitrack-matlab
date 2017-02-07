function EP = edgeMat(allData,Param)

EP = zeros(Param.frames,Param.dets);

for i = 1:Param.frames
    
    D = allData{i};
    
    for j = 1:size(D,1);
        
        d = min([D(j,1) Param.dims(2)-D(j,1) D(j,2) Param.dims(1)-D(j,2)]);
        d = d./2;
        c = 1./(1+exp((Param.B*d)-Param.C)); 
        EP(i,j) = log(c) - log(1-c);
    end
end