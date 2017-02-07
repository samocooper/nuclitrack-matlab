function [C,I,Mflag] = addCost(MPtemp,Dstate,Mstate,Mcost,Mmit,Daughter)

C = -1E100;
I = 1;
Mflag = 0;

for k = 1:numel(MPtemp)    
    if Dstate(k) == 1
        % migration cost to reach cell j from k
        migCost = Mcost(k) + MPtemp(k);
        if migCost > C;
            C = migCost;
            I = k;
            Mflag = 0;
        end
    else
        
        % migration cost to reach cell j from k
        
        migCost = Mcost(k) + MPtemp(k);
        
        % mitosis cost to reach cell j
        
        if Daughter > -3 && Mmit(k,1) > -3 && Mstate(k) == 0 && Dstate(k) == 2;
            
            mitCost = Mmit(k,1) + MPtemp(k);
            
            if mitCost > migCost
                
                if mitCost > C
                    C = mitCost;
                    I = k;
                    Mflag = 1;
                end
            else
                if migCost > C
                    C = migCost;
                    I = k;
                    Mflag = 0;                    
                end
            end
        else            
            if migCost > C && Mstate(k) == 0
                C = migCost;
                I = k;
                Mflag = 0;
            end
        end
        
    end
end