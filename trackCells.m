function Track = trackCells(Cost,dims,reps)

% Function for tracking cells utilising the matrix Cost from the script Tracking_preparation
% Output from the script is the matrix "track" this is then used for
% analysis, and track selection in the Track_ammend function


% Set parameters for migration probability function

Param.frames = numel(Cost.Feats); 

Param.min = 30; % Minimum score before tracking is stopped

Param.range = 40; % maximum distance of migration between frames
Param.t = 2; % Number of prior time frames to check, i.e. t = 2 one frame can be jumped
Param.C = 3; % Migration distance probability constant
Param.B = 0.17; % Migration distance probability ~gradient

% Visualise migration probability function
%plot(0:0.1:100,1./(1+exp((Param.B*(0:0.1:100))-Param.C)));

% ### Prepare for main loop #####

Param.dims = dims; % dimensions of movie

% Determine max width of cost matrix i.e. maximum detection number in a frame

dets = zeros(1,Param.frames);
for i = 1:Param.frames
    dets(i) = size(Cost.Data{i},1);
end
Param.dets = max(dets) + 1; % include column for screen exit

% Generate matrix of migration probailities for all considered detections

mig = migMat(Cost.Data,Param);

% Generate matrix of edge entry exit probabilities fro all detections

EP = edgeMat(Cost.Data,Param);

% Initialise matrices to store cell tracks

Dstates = ones(Param.frames,Param.dets);
Mstates = zeros(Param.frames,Param.dets);

m = zeros(Param.frames,1);
m1 = zeros(Param.frames,Param.dets+1); % define empty outside loop

Track = struct('ind',m,'cost',m,'cumCost',m,'parent',m,'parentGap',m);

% ###### Main loop ######

% counters for track number and replacement in subsequent track optimisation

count = 0;
replaceFlag = 0;
replace = 0;

while 1
    
    % Count number of replacements made for further optimisation sweeps
    
    if ~replaceFlag
        count = count+1;
    end

    % initialise new cell structure to contain data for this cell track

    newcell = struct('cost',m1,'indmat',m1,'gap',m1,'mit',m1,'swap',m1,'swapgap',m1);
    newcell.gap(:,end) = 1;    
    newdet.cost = zeros(1,Param.dets+1);

    D = Cost.Posterior{1};
    
    % initialize matrix on the first frame

    for j = 1:size(D,1);
       newdet.cost(j) = D(j,Dstates(1,j)+1) - D(j,Dstates(1,j));
    end

    newcell.cost(1,:) = newdet.cost;

    % consider all tracks iterate through frames

    for i = 2:Param.frames
        
        % Include previous timepoints
        
        if Param.t < i
            tT = Param.t;
        else
            tT = i-1;
        end
        
        for j = 1:dets(i-1)
            
            exitTemp = newcell.cost(i-1,j) + EP(i-1,j);
            
            if exitTemp > newcell.cost(i,end);

                newcell.cost(i,end) = exitTemp;
                newcell.indmat(i,end) = j;

            end
        end
        
        % most likely way of getting to cell excluding swaps i.e. migration
        % or mitosis
        
        newdet = migrationCost(Cost.Posterior,mig,newcell,Dstates,Mstates,Param,dets(i),i,tT);
        
        %Account for swaps
        
        MMStemp = mig.mask(i,:,1);
        MPStemp = mig.probS(i,:,1);
        
        newdet = testSwaps(newdet,Track,MMStemp,MPStemp,i,dets(i),Param.dets);

        % likelihood of entrance from edge
        
        newdet = edgeCost(newdet, newcell, EP , dets(i), i);

        for j = 1:dets(i);
            
            CTemp = newdet.cost(j) + Cost.Posterior{i}(j,Dstates(i,j)+1) - Cost.Posterior{i}(j,Dstates(i,j));            
            newcell.cost(i,j) = CTemp;
            
        end
       
        newcell.mit(i,1:end-1) = newdet.mit;
        newcell.indmat(i,1:end-1) = newdet.ind;
        newcell.gap(i,1:end-1) = newdet.gap;
        newcell.swap(i,1:end-1) = newdet.swap;
        newcell.swapgap(i,1:end-1) = newdet.swapgap;
        
    end
    
    % Trace tracks back through matrix
    
    [Track,Mstates, C] = trackBack(Track,newcell,Mstates,count);
    
    if C <= Param.min || C == Inf
        replaceFlag = 1;
    end
    
    [Track,Dstates] = trackSwaps(Track,newcell,Dstates,mig.probS,mig.mask,count,Param.dets); 

    % Cycle through testing replacement of tracks

    if replaceFlag
        
        if replace > 0 && sum(max(trackPrev.cumCost)) > sum(max(Track.cumCost))

            Track = trackPrev;
            Dstates = DstatesPrev;
            Mstates = MstatesPrev;

            % cycle tracks round one

            Track.ind = Track.ind(:,[2:count 1]);
            Track.cost = Track.cost(:,[2:count 1]);
            Track.parent = Track.parent(:,[2:count 1]);
            Track.parentGap = Track.parentGap(:,[2:count 1]);
            Track.cumCost = Track.cumCost(:,[2:count 1]);

        end

        replace = replace+1;
        
        trackPrev = Track;
        DstatesPrev = Dstates;
        MstatesPrev = Mstates;

        for j = 1:Param.frames
            if Track.parent(j,1) ~= 0
                gap = Track.parentGap(j,1);
                ind = Track.parent(j,1);                
                Mstates(j - gap,ind) = 0;                
            end
            if Track.ind(j,1) > 0 && Track.ind(j,1)<Param.dets
                Dstates(j,Track.ind(j,1)) = Dstates(j,Track.ind(j,1))-1;                
            end
        end
       
        Track.ind(:,1) = [];
        Track.cost(:,1) = [];
        Track.parent(:,1) = [];
        Track.parentGap(:,1) = [];
        Track.cumCost(:,1) = [];

    end

    disp(['    :' num2str(C,6) '     :' num2str(sum(max(Track.cumCost)),6) '     :' num2str(replace)])

    if replace > reps*size(Track.ind,2)-2 && replaceFlag;
        break
    end
end

Track.mstate = zeros(size(Track.ind));

for i = 1:Param.frames
    for h = 1:size(Mstates,2)
        if Mstates(i,h) == 1;
            ind = find(Track.ind(i,:) == h);
            Track.mstate(i,ind) = 1;
        end
    end
end

%{

%% ------------- Optional: Filter out really short tracks ------------

mask = sum(track.ind>0) < 3;
track.ind(:,mask) = [];
track.cost(:,mask) = [];
track.mstate(:,mask) = [];
track.parent(:,mask) = [];
track.parentGap(:,mask) = [];
track.cumCost(:,mask) = [];

%}

% ------------ Optional: Remove multiple segmentation -----------

for i = 1:Param.frames
    for j = 1:Param.dets                
        if Dstates(i,j) > 2
            
            inds = find(Track.ind(i,:) == j);
            
            Track.ind(i,inds) = 0;
            Track.cost(i,inds) = 0;
            Track.mstate(i,inds) = 0;
            Track.parent(i,inds) = 0;
            Track.parentGap(i,inds) = 0;
            Track.cumCost(i,inds) = 0;
        end
    end
end
