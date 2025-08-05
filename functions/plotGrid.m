function plotGrid(meanGrid, tileSize)
    [numRows, numCols] = size(meanGrid);

    imageHeight = numRows * tileSize;
    imageWidth = numCols * tileSize;

    gridImage = zeros(imageHeight, imageWidth);
    for row = 1:numRows
        for col = 1:numCols
            yStart = (row-1)*tileSize + 1;
            yEnd   = row*tileSize;
            xStart = (col-1)*tileSize + 1;
            xEnd   = col*tileSize;
            gridImage(yStart:yEnd, xStart:xEnd) = meanGrid(row, col);
        end
    end
    
    % Plot image
    figure;
    imshow(uint8(gridImage));
    title("Pixelated image using mean values of " + numRows + "x" + numCols + " square blocks");
end