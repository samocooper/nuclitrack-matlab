function [Track,Dstates] = trackSwaps(Track,newcell,Dstates,MPS,MM,loc,dets)

Track.cost(:,loc) = zeros(1,size(Dstates,1));

for i = 1:size(Dstates,1);
    if Track.ind(i,loc) > 0
        
        jt = Track.ind(i,loc);
        if jt ~= dets + 1  
            Dstates(i,jt) = Dstates(i,jt) +1;
        end
        if newcell.swap(i,jt) ~= 0
            
            swap = newcell.swap(i,jt);
            
            if Track.parent(i,loc) == Track.ind(i-Track.parentGap(i,loc),swap) %% fix against swap onto own track
                td = newcell.gap(i,jt);
                if td == 0
                    td =1;
                end
                if Track.ind(i-td,loc) > 0
                    x2 = Track.ind(i-td,loc);
                    Track.cost(i,loc) = MPS{i,Track.ind(i,loc),td}(MM{i,Track.ind(i,loc),td}==x2);
                end
                continue
            end
            
            ts_ind = Track.ind(:,swap)>0;
            ts_ind(1:i-1) = 0;
            tl_ind = Track.ind(:,loc)>0;
            tl_ind(1:i-1) = 0;
            
            Track.cumCost(ts_ind,swap) = Track.cumCost(ts_ind,swap)- Track.cumCost(i-1,swap);
            Track.cumCost(tl_ind,loc) = Track.cumCost(tl_ind,loc)- Track.cumCost(i-1,loc);
            
            Track = swapTracks(Track,1,i-1,swap,loc,0);
            
            Track.cumCost(tl_ind,swap) = Track.cumCost(tl_ind,swap)+ Track.cumCost(i-1,swap);
            Track.cumCost(ts_ind,loc) = Track.cumCost(ts_ind,loc)+ Track.cumCost(i-1,loc);
                        
        end
        
        td = newcell.gap(i,jt);
        if td == 0
            td =1;
        end
        
        if i > 1 && jt ~= dets + 1  ;
            if newcell.swap(i,jt) ~= 0
                
                if Track.ind(i-td,swap) > 0
                    
                    swap = newcell.swap(i,jt);
                    x2 = Track.ind(i-td,swap);
                    
                    Track.cost(i,swap) = MPS{i,Track.ind(i,swap),td}(MM{i,Track.ind(i,swap),td}==x2);
                end
                
                if Track.ind(i-newcell.swapgap(i,jt),loc) > 0
                    
                    x3 = Track.ind(i-newcell.swapgap(i,jt),loc);
                    Track.cost(i,loc) = MPS{i,Track.ind(i,loc),newcell.swapgap(i,jt)}(MM{i,Track.ind(i,loc),newcell.swapgap(i,jt)}==x3);
                end
                
            else
                if Track.ind(i-td,loc) > 0
                    x2 = Track.ind(i-td,loc);
                    Track.cost(i,loc) = MPS{i,Track.ind(i,loc),td}(MM{i,Track.ind(i,loc),td}==x2);
                end
            end
        end
        
    end
end