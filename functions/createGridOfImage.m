function [meanGrid, tileSize] = createGridOfImage(img, numRows, numCols)
    if size(img,3) == 3
        img = rgb2gray(img); % Convert to grayscale if it's RGB
    end
    img = double(img); % Convert to double for calculations
    
    % Compute block size based on samllest block side
    [imgHeight, imgWidth] = size(img);
    horizontalBlockSize = floor(imgWidth / numCols);  % Square block size
    verticalBlockSize = floor(imgHeight / numRows);  % Square block size
    tileSize = min([horizontalBlockSize, verticalBlockSize]);

    % Compute cropped dimensions
    cropHeight = tileSize * numRows;
    cropWidth  = tileSize * numCols;
    
    % Crop the image to fit whole blocks
    imgCropped = img(1:cropHeight, 1:cropWidth);
    
    % Compute mean intensity per tile
    meanGrid = zeros(numRows, numCols);
    for row = 1:numRows
        for col = 1:numCols
            yStart = (row-1)*tileSize + 1;
            yEnd   = row*tileSize;
            xStart = (col-1)*tileSize + 1;
            xEnd   = col*tileSize;
            
            block = imgCropped(yStart:yEnd, xStart:xEnd);
            meanGrid(row, col) = mean(block(:));
        end
    end
    return;
end

