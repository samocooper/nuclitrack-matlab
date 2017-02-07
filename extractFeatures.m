function FVs = extractFeatures(Mov1,Mov2,Mov3,L)

frames = numel(Mov1);

m2 = ~isempty(Mov2);
m3 = ~isempty(Mov3);

% Initialise feature cell array based on segment number

FVs = cell(1,frames);
dets = cell(1,frames);
for i = 1:frames
    dets{i} = unique(L{i});
    dets{i}(1) = [];
    FVs{i} = zeros(numel(dets{i}),18 + 2*m2 + 2*m3);
end

% Extract features from cell segments based on channels

if m3 % 3 channels !! Unwrapped as otherwise parfor loop is unstable !!
    
    parfor i = 1:frames
        
        Lt = L{i};
        
        M1t = Mov1{i};
        M2t = Mov2{i};
        M3t = Mov3{i};
        
        for h = 1:numel(dets{i})
            
           
            
            tempV = zeros(1, 22);
            temp = regionprops(Lt == dets{i}(h),M1t,'all');
            
            tempV(1) = round(temp(1).Centroid(1));
            tempV(2) = round(temp(1).Centroid(2));
            tempV(3) = i;
            tempV(4) = temp(1).PixelList(1,1);
            tempV(5) = temp(1).PixelList(1,2);
            
            % Gross morphology features describing cell segment shape
             
            tempV(6) = temp(1).Area;
            tempV(7) = temp(1).MajorAxisLength;
            tempV(8) = temp(1).MinorAxisLength;
            tempV(9) = temp(1).Eccentricity;
            tempV(10) = temp(1).EquivDiameter;
            tempV(11) = temp(1).Solidity;
            tempV(12) = temp(1).Perimeter;
            tempV(13) = 4*3.14*temp(1).Area ./ temp(1).Perimeter.^2;
            idx = kmeans(temp(1).PixelList,2,'Replicates',3);
            tempV(14) = mean(silhouette(temp(1).PixelList,idx));
            
            % ## PCNA channel one specific intensity measures for S-phase
            % demarcation ##
            tempV(15) = temp(1).MeanIntensity;
            
            pix = double(M1t(Lt == dets{i}(h)));
            tempV(16) = std(pix);
            tempV(17) = kurtosis(pix);
            pix = pix(pix>mean(pix));
            tempV(18) = std(pix); % Floored to mean Standard deviation
            
            % Intensity and standard deviation for second flourescent
            % channel
            
            temp2 = regionprops(Lt == dets{i}(h),M2t,'all');
            tempV(19) = temp2(1).MeanIntensity;
            tempV(20) = std(double(M2t(Lt == dets{i}(h))));
            
            % Intensity and standard deviation for third flourescent
            % channel
            
            temp3 = regionprops(Lt == dets{i}(h),M3t,'all');
            tempV(21) = temp3(1).MeanIntensity;
            tempV(22) = std(double(M3t(Lt == dets{i}(h))));
            
            FVs{i}(h,:) = tempV;
            
        end
    end
    
elseif m2 % 2 channels 
    
    parfor i = 1:frames
        
        Lt = L{i};
        
        M1t = Mov1{i};
        M2t = Mov2{i};
        
        for h = 1:numel(dets{i})
            
            tempV = zeros(1, 20);
            temp = regionprops(Lt == dets{i}(h),M1t,'all');
            
            tempV(1) = round(temp(1).Centroid(1));
            tempV(2) = round(temp(1).Centroid(2));
            tempV(3) = i;
            tempV(4) = temp(1).PixelList(1,1);
            tempV(5) = temp(1).PixelList(1,2);
            tempV(6) = temp(1).Area;
            tempV(7) = temp(1).MajorAxisLength;
            tempV(8) = temp(1).MinorAxisLength;
            tempV(9) = temp(1).Eccentricity;
            tempV(10) = temp(1).EquivDiameter;
            tempV(11) = temp(1).Solidity;
            tempV(12) = temp(1).Perimeter;
            tempV(13) = 4*3.14*temp(1).Area ./ temp(1).Perimeter.^2;
           
            idx = kmeans(temp(1).PixelList,2,'Replicates',3);
            tempV(14) = mean(silhouette(temp(1).PixelList,idx));
            
            % PCNA, channel one specific intensity measures for S-phase demarcation
            tempV(15) = temp(1).MeanIntensity;

            pix = double(M1t(Lt == dets{i}(h)));
            tempV(16) = std(pix);
            tempV(17) = kurtosis(pix);
            pix = pix(pix>mean(pix));
            tempV(18) = std(pix); % Floored to mean Standard deviation
            
            temp2 = regionprops(Lt == dets{i}(h),M2t,'all');
            tempV(19) = temp2(1).MeanIntensity;
            tempV(20) = std(double(M2t(Lt == dets{i}(h))));
            
            FVs{i}(h,:) = tempV;
            
        end
    end
    
else % 1 channel
    
    parfor i = 1:frames
        
        Lt = L{i};
        
        M1t = Mov1{i};
        
        for h = 1:numel(dets{i})
            
            tempV = zeros(1, 17);
            temp = regionprops(Lt == dets{i}(h),M1t,'all');
            
            tempV(1) = round(temp(1).Centroid(1));
            tempV(2) = round(temp(1).Centroid(2));
            tempV(3) = i;
            tempV(4) = temp(1).PixelList(1,1);
            tempV(5) = temp(1).PixelList(1,2);
            tempV(6) = temp(1).Area;
            tempV(7) = temp(1).MajorAxisLength;
            tempV(8) = temp(1).MinorAxisLength;
            tempV(9) = temp(1).Eccentricity;
            tempV(10) = temp(1).EquivDiameter;
            tempV(11) = temp(1).Solidity;
            tempV(12) = temp(1).Perimeter;
            tempV(13) = 4*3.14*temp(1).Area ./ temp(1).Perimeter.^2;            
            idx = kmeans(temp(1).PixelList,2,'Replicates',3);
            tempV(14) = mean(silhouette(temp(1).PixelList,idx));
            
            % PCNA, channel one specific intensity measures for S-phase demarcation
            tempV(15) = temp(1).MeanIntensity;
            
            pix = double(M1t(Lt == dets{i}(h)));
            tempV(16) = std(pix);
            tempV(17) = kurtosis(pix);
            pix = pix(pix>mean(pix));
            tempV(18) = std(pix); % Floored to mean Standard deviation
            
            FVs{i}(h,:) = tempV;
            
        end
    end
    
end

