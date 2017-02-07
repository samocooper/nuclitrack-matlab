function Posterior = cellPosteriors(FVs,trainD)

FVmat = cell2mat(FVs'); % Matrix of all features for classification

% Assign posterior probabilities of class to cells

FVmatN = zscore(FVmat(:,6:end));
Pmat = cell2mat(trainD.P');
mask = sum(Pmat,2)>0;
FVmatSel = FVmatN(mask,:);



% ### Classification ###

mask = sum(Pmat,2)>0; % mask for selected training data

Posterior = [];
svmmods = cell(1,5); % Initialise SVM classifier

for i = 1:5;
    if sum(Pmat(mask,i)) ~= 0
    svmmods{i} = fitcsvm(FVmatSel,Pmat(mask,i)'); % train SVM classifier on data
    end
end

for i = 1:5;
    if sum(Pmat(mask,i)) ~= 0        
        [~,score] = predict(svmmods{i},FVmatN); % Predict liklihood of a cell belonging to a training class
        Posterior(:,i) = score(:,2); % Second column contains positive-class scores        
        
    else % If no training data set posterior score to low liklihood e.g. -5
        Posterior(:,i) = zeros(size(FVmatN,1),1)-5;                
    end
end

% Modify posterior for tracking i.e. Mitotic and mitotic exit cells are
% still one cell thus, probability for both one cell and mitotic/mitotic
% exit must be high for tracking

Posterior(:,2) = max(Posterior(:,2),Posterior(:,5));
Posterior(:,2) = max(Posterior(:,2),Posterior(:,4));
Posterior(:,2) = max(Posterior(:,2),Posterior(:,3));

Posterior(:,6:7) = Posterior(:,4:5);
Posterior(:,4:5) = -50; % set liklihood of three or more cells to be very low

% Final tweaking for tracking
Posterior(:,3) = Posterior(:,3)-5;
Posterior(:,6) = Posterior(:,6)*2;
Posterior(:,7) = Posterior(:,7)*2;

% columb to label by frame

Posterior(:,end+1) = FVmat(:,3);