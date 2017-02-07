function [Track,Mstates,C] = trackBack(Track,newcell,Mstates,count)

[C,y] = max(newcell.cost);
[C,x] = max(C);    
y = y(x);

newtrack = zeros(1,size(newcell.indmat,1));
cumCost = zeros(1,size(newcell.indmat,1));

parent = zeros(1,size(newcell.indmat,1));
parentGap = zeros(1,size(newcell.indmat,1));

newtrack(y) = x;
cumCost(y) = newcell.cost(y,x);

while y > 0
    
    td = newcell.gap(y,x);
    x2 = newcell.indmat(y,x);
    
    if  newcell.mit(y,x) == 1
            parent(y) = x2;
            parentGap(y) = td;
            Mstates(y-td,x2) = 1;
           break
    end
    
    if x2 == 0  
        break
    end
    
    
    
    x = x2;
    
    y = y - td;
    
    newtrack(y) = x;
    cumCost(y) = newcell.cost(y,x);
end

Track.ind(:,count) = newtrack;
Track.cumCost(:,count) = cumCost;
Track.parent(:,count) = parent;
Track.parentGap(:,count) = parentGap;