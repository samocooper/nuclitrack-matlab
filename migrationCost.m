function newdet =  migrationCost(DataLog,mig,newcell,Dstates,Mstates,Param,dn,i,tT)

m2 = zeros(1,Param.dets);      

% clear matrices for this set of scores
newdet = struct('cost',m2,'ind',m2,'gap',m2,'mit',m2,'swap',m2,'swapgap',m2);

MMtempV = cell(Param.dets,Param.t);
MMtempV(:,:) = mig.mask(i,:,:); % define as 2D matrix improves speed

MPStempV = cell(Param.dets,Param.t);
MPStempV(:,:) = mig.probS(i,:,:); % define as 2D matrix improves speed

for j = 1:dn
    for t = 1:tT
        if mig.empty(i,j,t)

            % migration cost to reach cell j
            MMtemp = MMtempV{j,t};

            [CT,IT,MT] = addCost(MPStempV{j,t},Dstates(i-t,MMtemp),Mstates(i-t,MMtemp),newcell.cost(i-t,MMtemp),DataLog{i-t}(MMtemp,6),DataLog{i}(j,7));

            CT = CT - 5*(t-1);

            % enter frame cost to reach cell j for first time point

            if t == 1

                newdet.cost(j) = CT;
                newdet.ind(j) = MMtemp(IT);
                newdet.mit(j) = MT;
                newdet.gap(j) = 1;

            elseif t > 1 && CT > newdet.cost(j)

                newdet.cost(j) = CT;
                newdet.ind(j) = MMtemp(IT);
                newdet.mit(j) = MT;
                newdet.gap(j) = t;           

            end
        end
    end
end