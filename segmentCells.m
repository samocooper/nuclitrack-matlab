function [Lmov,Mov1A,Mov2A] = segmentCells(Mov1,Mov2)

frames = numel(Mov1);
Lmov = cell(1,frames);
Mov1A = cell(1,frames);
Mov2A = cell(1,frames);

if ~isempty(Mov2) % Two channel segmentation for two nuclear markers
    
    parfor i = 1:frames
        
        % ----- Channel 1 image preprocessing -----
        ch1 = Mov1{i};
        
        % Clipping Limit, adjust to reduce bright spots
        clim = 100;
        ch1(ch1> clim) = clim;
        
        ch1 = mat2gray(ch1);
        
        % Flatfield correction adjust kernal size
        G = fspecial('gaussian',[100 100],30);
        Bg = imfilter(ch1,G,'replicate','same');
        ch1 = ch1-Bg;
        
        % Adaptive histogram equalisation
        ch1 = adapthisteq(ch1,'numtiles',[10 10],'cliplimit',0.002);
        
        %imagesc(ch1);
        
        
        % ----- Channel 2 image preprocessing -----
        
        ch2 = Mov2{i};
        
        % Clipping Limit, adjust to reduce bright spots
        clim = 30;
        ch2(ch2> clim) = clim;
        
        ch2 = mat2gray(ch2);
        
        % Flatfield correction adjust kernal size
        G = fspecial('gaussian',[100 100],30);
        Bg = imfilter(ch2,G,'replicate','same');
        ch2 = ch2-Bg;
        
        % Adaptive histogram equalisation
        ch2 = adapthisteq(ch2,'numtiles',[10 10],'cliplimit',0.002);
        
        %imagesc(ch2);
        
        % Combine channels adjust weighting depending on images (weightings ideally sum to one)
        
        Im = (0.5*ch2 + 0.5*ch1);
        %imagesc (Im);
        
        
        % Blur image adjust kernal size for strength, aim for clear nuclei, roughly single peak intensity per nuclei
        G = fspecial('gaussian',[9 9],3);
        Im2 = imfilter(Im,G,'replicate','same');
        
        %imagesc(Im2)
        
        % See matlab tutorial on watershed segmentation for further details of this process
        % Image processing for foreground detection
        
        se = strel('disk', 5);
        Ie = imerode(Im2, se);
        Iobr = imreconstruct(Ie, Im2);
        
        Iobrd = imdilate(Iobr, se);
        Im3 = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        Im3 = imcomplement(Im3);
        
        %imagesc(Im3)
        % Peak picking nuclei intensity adjust size of blurring kernal and strel disk kernal to ensure one fgm per nuclei
        
        fgm = imregionalmax(Im3);
        
        % Adjust kernal size or comment out to adjust connection distance of neighbouring peaks
        se2 = strel(ones(2,2));
        fgm = imclose(fgm, se2);
        %imagesc([fgm Im3]);
        %truesize
        
        % Threshold background
        
        bw = im2bw(Im3, 1.6*mean(Im3(:)));
        %imagesc(bw)
        
        % Mark out "zones of influence" these skeleton line shouldn't cross over nuclei centers
        
        D = bwdist(bw);
        DL = watershed(D);
        bgm = DL == 0;
        
        %imagesc([bgm Im3]);
        %truesize
        % Generate gradient matrix for watershed segmentation
        
        % Adjust blur to control gradient line smoothness, this should generally be
        % lower blur than the kernal used for foreground background marking
        
        G = fspecial('gaussian',[8 8],3);
        Im4 = imfilter(Im,G,'replicate','same');
        
        % Sobel kernal for gradient detection
        
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(Im4), hy, 'replicate');
        Ix = imfilter(double(Im4), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        % Combine images for watershed segmentation, nuclei outline should be
        % highest intensity, t hese are the barriers that define segment lines
        gradmag2 = imimposemin(gradmag, bgm | fgm);
        
        %imagesc(gradmag2);
        % Perform Watershed
        
        L = watershed(gradmag2);
        
        % Visualise results; some low intensity region may segment these will be
        % filtered out
        Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
        %imshow(Lrgb);
        
        % Filter out border and low intensity segments
        
        border = unique([L(1,:) L(end,:) L(:,1)' L(:,end)']);
        
        for j = 1:numel(border)
            %Filter nuclei touching the border
            L(L==border(j)) = 0;
        end
        
        for j = 1:max(L(:))
            meanIntensity = mean(mean(Im2(L == j)));
            
            % Filter out low intensity nuclei
            if meanIntensity<0.1
                L(L==j) = 0;
            end
            
            % Filter out very large segments to ensure background is a single segment label = 0;
            % if magnification is high i.e.very large nuclei area this will need to increase
            if sum(L(:)==j) > 2000
                L(L==j) = 0;
            end
        end
        
        % Gentle dilation to include entire nucleus in segment
        
        se = strel('disk', 1);
        L = imdilate(L, se);
        
        % Visualise final results
        %imagesc([mat2gray(L) Im]);
        %truesize
        
        Lmov{i} = L;
        
        % optional processed movies for feature extraction on these
        Mov1A{i} = ch1;
        Mov2A{i} = ch2;
    end
    
else % One channel segmentation for one nuclear marker
    
    parfor i = 1:frames
        
        % ----- Channel 1 image preprocessing -----
        ch1 = Mov1{i};
        
        % Clipping Limit, adjust to reduce bright spots
        clim = 100;
        ch1(ch1> clim) = clim;
        
        ch1 = mat2gray(ch1);
        
        % Flatfield correction adjust kernal size
        G = fspecial('gaussian',[100 100],30);
        Bg = imfilter(ch1,G,'replicate','same');
        ch1 = ch1-Bg;
        
        % Adaptive histogram equalisation
        ch1 = adapthisteq(ch1,'numtiles',[10 10],'cliplimit',0.002);
        
        %imagesc(ch1);
        
        % Combine channels adjust weighting depending on images (weightings ideally sum to one)
        
        Im = ch1;
        %imagesc (Im);
        
        % Blur image adjust kernal size for strength, aim for clear nuclei, roughly single peak intensity per nuclei
        G = fspecial('gaussian',[9 9],3);
        Im2 = imfilter(Im,G,'replicate','same');
        
        %imagesc(Im2)
        
        % See matlab tutorial on watershed segmentation for further details of this process
        % Image processing for foreground detection
        
        se = strel('disk', 5);
        Ie = imerode(Im2, se);
        Iobr = imreconstruct(Ie, Im2);
        
        Iobrd = imdilate(Iobr, se);
        Im3 = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        Im3 = imcomplement(Im3);
        
        %imagesc(Im3)
        % Peak picking nuclei intensity adjust size of blurring kernal and strel disk kernal to ensure one fgm per nuclei
        
        fgm = imregionalmax(Im3);
        
        % Adjust kernal size or comment out to adjust connection distance of neighbouring peaks
        se2 = strel(ones(2,2));
        fgm = imclose(fgm, se2);
        %imagesc([fgm Im3]);
        %truesize
        
        % Threshold background
        
        bw = im2bw(Im3, 1.6*mean(Im3(:)));
        %imagesc(bw)
        
        % Mark out "zones of influence" these skeleton line shouldn't cross over nuclei centers
        
        D = bwdist(bw);
        DL = watershed(D);
        bgm = DL == 0;
        
        %imagesc([bgm Im3]);
        %truesize
        % Generate gradient matrix for watershed segmentation
        
        % Adjust blur to control gradient line smoothness, this should generally be
        % lower blur than the kernal used for foreground background marking
        
        G = fspecial('gaussian',[8 8],3);
        Im4 = imfilter(Im,G,'replicate','same');
        
        % Sobel kernal for gradient detection
        
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(Im4), hy, 'replicate');
        Ix = imfilter(double(Im4), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        % Combine images for watershed segmentation, nuclei outline should be
        % highest intensity, t hese are the barriers that define segment lines
        gradmag2 = imimposemin(gradmag, bgm | fgm);
        
        %imagesc(gradmag2);
        % Perform Watershed
        
        L = watershed(gradmag2);
        
        % Visualise results; some low intensity region may segment these will be
        % filtered out
        Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
        %imshow(Lrgb);
        
        % Filter out border and low intensity segments
        
        border = unique([L(1,:) L(end,:) L(:,1)' L(:,end)']);
        
        for j = 1:numel(border)
            %Filter nuclei touching the border
            L(L==border(j)) = 0;
        end
        
        for j = 1:max(L(:))
            meanIntensity = mean(mean(Im2(L == j)));
            
            % Filter out low intensity nuclei
            if meanIntensity<0.08
                L(L==j) = 0;
            end
            
            % Filter out very large segments to ensure background is a single segment label = 0;
            % if magnification is high i.e.very large nuclei area this will need to increase
            if sum(L(:)==j) > 2000
                L(L==j) = 0;
            end
        end
        
        % Gentle dilation to include entire nucleus in segment
        
        se = strel('disk', 1);
        L = imdilate(L, se);
        
        % Visualise final results
        %imagesc([mat2gray(L) Im]);
        %truesize
        
        Lmov{i} = L;
        
        % optional processed movies for feature extraction on these
        Mov1A{i} = ch1;
    end
end


