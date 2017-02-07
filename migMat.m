function mig = migMat(Data,Param)

mig.mask = cell(Param.frames,Param.dets,Param.t);
mig.probS = cell(Param.frames,Param.dets,Param.t);
mig.empty = false(Param.frames,Param.dets,Param.t);

for i = 2:Param.frames
    
    if Param.t < i
        tT = Param.t;
    else
        tT = i-1;
    end
    
    for t = 1:tT
        
        D = Data{i};
        DMt = Data{i-t};
        
        for j = 1:size(D,1);
            
            mask = DMt(:,1) < D(j,1) + Param.range & DMt(:,1) > D(j,1)-Param.range & DMt(:,2) < D(j,2) + Param.range & DMt(:,2) > D(j,2)-Param.range;
            mig.mask{i,j,t} = find(mask);
            mig.empty(i,j,t) = ~isempty(mig.mask{i,j,t}); 
            
            DM1C = DMt(mask,:);
            
            tempP = zeros(1,sum(mask));
            
            for k = 1:sum(mask)
                tempP(k) = migrationProb(D(j,[1 2]),DM1C(k,[1 2]),Param);
            end
            
            mig.probS{i,j,t} = tempP;
            tempP(tempP>0.5) = 0.5;
            %mig.prob{i,j,t} = tempP;
        end
    end
end