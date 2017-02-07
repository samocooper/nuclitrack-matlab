%% Script for segmenting cells, extracting features, tracking cell and ammending tracks

%% 1. Load movies into cell arrays: One cell array per channel

frames = 299;
Fname = 'Data/005002-1-001001001.tif'; 
% Using columbus naming screen this name describes:
% XXX row YYY column -Z- Field of view
% UUU timepoint VVV Z-position WWW Channel

Mov1 = loadMovie(Fname,1,frames); % function for loading in .tiff time series exported from columbus
Mov2 = loadMovie(Fname,2,frames);
Mov3 = loadMovie(Fname,3,frames);

dims = size(Mov3{1}); % dimension of image to define when cells cross border

%% View movies
% Movie is cell array where each element is one matrix corresponding to
% image in time series. One cell array per channel.

for i = 1:frames    
    imagesc(Mov3{i});
    pause(0.05);    
end

%% 2.  Segment cells
% To modify segmentation: Choose parameters or adapt workflow for cell 
% segmentation in the "Segmentation_Parameter_Testing" script. Subsequently 
% update the function "segmentCells" with chosen parameters. In the function 
% Segment cell both one channel and two channel segmentation scripts exist, 
% be sure to update parameters in the correct one.

L   =  segmentCells(Mov3,[]);

% save matrix L of indexed segments for future scripts

%% View Segmentation

for i = 1:frames
    imagesc(L{i});
    pause(0.02);
end

%% 3.  Extract features from segments and movies
% Features are extracted in the function extractFeatures. One channel two
% channel and three channel feature extraction are possible. The first
% channel is set up to be PCNA and includes additional features describing
% PCNA foci strength

FVs = extractFeatures(Mov3,Mov1, [], L); % First movie must be PCNA channel

%% 4. Select training data: skip if previous training matrices exist
% Load trainD and skip to stage 5 if already performed previously. 
% Otherwise select examples of cell segments describing one cell, two 
% cells, mitotic cells, or mitotic exit. 

trainD = trainingData(L,FVs,Mov3,[]); % use this function to generate new training data
%trainD = trainingData(L,FVs,Mov3,trainD); % use this function to update training data

% Save trainD at this point if classifications for other wells need to be performed.

%% 5. Assign posterior probabilities of class to cells and combine results into matrix for tracking

Posterior = cellPosteriors(FVs,trainD);

D = cell(1,frames);
F = cell(1,frames);
Pcell = cell(1,frames);

for i = 1:frames
    
    D{i} = FVs{i}(:,1:5); % Assign basic data on location and index
    F{i} = FVs{i}(:,6:end); % Store morphological and intensity features    
    Pcell{i} = Posterior(Posterior(:,end) == i,1:end-1); % Store posterior liklihood of region belonging to a given class    
    
end

Cost.Data = D;
Cost.Feats = F;
Cost.Posterior = Pcell;

% Save matrix Cost for use in tracking and feature analysis

%% 6. Track cells

% Track cells using a probablistic apporach, load trackCells script to edit
% tracking parameters, Options to remove cells with multiple tracks passing
% through (default on) as well as filtering out really short tracks are
% available

Track = trackCells(Cost,dims,2); % final number is number of optimisation sweeps through tracks to make, more is not always better.

%% 7. View and Ammend Tracks

[Track,TrackSel,FMat] = amendTracks(L,Cost,Track,Mov3,[]); % use this function to choose new tracks
%[Track,TrackSel,Fmat] = ammendTracks(L,Cost,Track,Mov3,TrackSel); % use this function to continue from prior selection

%% 8. Select cell cycle points from feature plots alone

[TrackSel,FMat] = selectPhase(TrackSel,Cost);

%% 9. Export feature matrix to CSV file

csvwrite('data.csv',FMat)


