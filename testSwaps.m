function newdet = testSwaps(newdet,Track,MMStemp,MPStemp,i,numDet,det_tot)

cost2 = newdet.cost;
ind2 = newdet.ind;
gap2 = newdet.gap;
mit2 = newdet.mit;

for j = 1:numDet;
        
        MMtemp = MMStemp{j};                
        MPtemp = MPStemp{j};
        
        for k = 1:numel(MMtemp)
            
            a = find(Track.ind(i-1,:) == MMtemp(k));
            
            if ~isempty(a)
                for l = 1:numel(a)
                    if Track.ind(i,a(l)) ~= 0 && Track.ind(i,a(l)) ~= 0 && Track.ind(i,a(l)) ~= det_tot+1
                        
                        pCut = Track.cost(i,a(l));
                                                
                        CT = MPtemp(k) - pCut + newdet.cost(Track.ind(i,a(l)));
                        if CT > newdet.cost(j) && newdet.mit(Track.ind(i,a(l))) == 0
                                                        
                            cost2(j) = CT;
                            newdet.mit(j) = 0;
                            
                            newdet.swapgap(j) = 1;
                            
                            gap2(j) = newdet.gap(Track.ind(i,a(l)));                            
                            ind2(j) = newdet.ind(Track.ind(i,a(l)));
                            mit2(j) = newdet.mit(Track.ind(i,a(l)));

                            newdet.swap(j) = a(l);
                           
                            
                        end
                        
                    end
                end
            end
        end
end

newdet.gap = gap2;
newdet.ind = ind2;
newdet.mit = mit2;
newdet.cost = cost2;