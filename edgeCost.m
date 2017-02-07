function newdet = edgeCost(newdet, newcell, EP , dn, i)

for j = 1:dn

        if newdet.gap(j) > 0 && newdet.ind(j)~=0

            if newdet.mit(j)~= 1
                add_val = newdet.cost(j) - newcell.cost(i-newdet.gap(j),newdet.ind(j));                
            else
                add_val = newdet.cost(j);                    
            end                

            if add_val > 0.5
                newdet.cost(j) = newdet.cost(j) - add_val + 0.5;
            end

            if  EP(i,j) > add_val

                newdet.cost(j) = EP(i,j);
                newdet.ind(j) = 0;
                newdet.mit(j) = 0;
                newdet.gap(j) = 1;

            end                
        end
    end
