clc
clear 
addpath('functions');

%% Parameters
% Please choose the correct side ration here
numCols = 20; % Number of columns in  the photomosaic
numRows = floor(numCols*1.5); % Number of rows in  the photomosaic

tileFolder = 'tiles/'; % Folder where images for tiling lie
outputFilename = 'photomosaic_output.png';

%% Step 1: Import grayscale image
img = imread('final.png');  % Replace with your image filename


%% Step 2: Create the grid ofnthe image
[meanGrid, tileSize] = createGridOfImage(img, numRows, numCols);
plotGrid(meanGrid, tileSize);

%% Step 3: Find images paths
files = dir(fullfile(tileFolder, '*')); % Get all contents
files = files(~[files.isdir]); % Exclude directories

% Get full paths
filePaths = string(fullfile({files.folder}, {files.name}));
numTiles = length(filePaths);

tileImages = cell(numTiles, 1);
tileMeans = zeros(numTiles, 1);

%% Step 4: Prepare tiles


for i = 1:numTiles
    filename = filePaths(i);
    tile = im2gray(imread(filename));
    tile = imresize(tile, [tileSize, tileSize]);  
    tile = double(tile);                  
    tileImages{i} = tile;
    tileMeans(i) = mean(tile(:));
end

%% Step 5: Create output image
outputImage = zeros(numRows * tileSize, numCols * tileSize);

%% Step 6: Fill each grid position with best matching tile

maxTileUsage = round((numCols*numRows)/numTiles) + 1; % restrict overusage of one image tile

tileIndexGrid = zeros(numRows, numCols); % Track which tile was placed where
tileUsage = zeros(numTiles, 1);          % Track how often each tile is used

for row = 1:numRows
    for col = 1:numCols
        targetMean = meanGrid(row, col);

        % Filter out tiles that reached max usage
        allowedTiles = find(tileUsage < maxTileUsage);
        if isempty(allowedTiles)
            warning('All tiles reached max usage. Resetting usage count.');
            tileUsage(:) = 0;
            allowedTiles = 1:numTiles;
        end

        % Compute match error only on allowed tiles
        matchDiffs = abs(tileMeans(allowedTiles) - targetMean);
        [~, sortIdx] = sort(matchDiffs); % Sort to get the lowest distance
        topN = 15; % Leave only top 15
        topMatches = allowedTiles(sortIdx(1:min(topN, numel(sortIdx))));

        % Try up to 10 times to find a valid tile
        for attempt = 1:10
            % Weighted random sampling
            weights = 1 ./ (1 + tileUsage(topMatches));
            weights = weights / sum(weights);
            candidateIdx = randsample(topMatches, 1, true, weights);

            % 7x7 neighborhood check. 
            % To try not to select same tile in the 7x7 neighborhood
            rowMin = max(1, row - 3);
            rowMax = min(numRows, row + 3);
            colMin = max(1, col - 3);
            colMax = min(numCols, col + 3);
            block = tileIndexGrid(rowMin:rowMax, colMin:colMax);

            if ~any(block(:) == candidateIdx)
                break; % Valid tile
            end
        end

        chosenIdx = candidateIdx;
        chosenTile = tileImages{chosenIdx};
        tileUsage(chosenIdx) = tileUsage(chosenIdx) + 1;
        tileIndexGrid(row, col) = chosenIdx;

        % Adjust brightness
        tileMean = tileMeans(chosenIdx);
        adjustedTile = chosenTile * (targetMean / tileMean);
        adjustedTile = min(max(adjustedTile, 0), 255);

        % Place tile
        yStart = (row-1)*tileSize + 1;
        yEnd   = row*tileSize;
        xStart = (col-1)*tileSize + 1;
        xEnd   = col*tileSize;

        outputImage(yStart:yEnd, xStart:xEnd) = adjustedTile;
    end
end

%% Step 7: Show result
figure;
imshow(uint8(outputImage));
title("Photomosaic image assembled from" + numTiles +"tiles");

imwrite(uint8(outputImage), outputFilename);
disp("Saved photomosaic to " + outputFilename);
