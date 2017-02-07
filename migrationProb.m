function P = migrationProb(pos1,pos2,Param)

d = sqrt((pos1(1)-pos2(1)).^2 + (pos1(2)-pos2(2)).^2);
c = 1./(1+exp((Param.B*d)-Param.C));
P = log(c) - log(1-c);