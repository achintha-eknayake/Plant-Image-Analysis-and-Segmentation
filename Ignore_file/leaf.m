clc;
clear all;
close all;

% Step 1: Load Image
[filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.jfif'}, ...
    'Select a Leaf Image');
if isequal(filename, 0)
    disp('No file selected');
    return;
end
imagePath = fullfile(pathname, filename);
image = imread(imagePath);

% Step 2: Convert to Grayscale
if size(image, 3) == 3
    grayImage = rgb2gray(image); % Convert to grayscale
else
    grayImage = image; % Already grayscale
end

% Step 3: Define Parameters for Comparison
clipLimits = [0.01, 0.02, 0.03, 0.05]; % Different ClipLimit values
numTiles = [4, 8, 12, 16];             % Different NumTiles values

% Total number of combinations
numCombinations = length(clipLimits) * length(numTiles);

% Step 4: Apply adapthisteq with Different Settings
figure('Name', 'adapthisteq Comparison', 'NumberTitle', 'off', 'Position', [100, 50, 1400, 800]);
counter = 1;
for c = 1:length(clipLimits)
    for n = 1:length(numTiles)
        % Apply adapthisteq with current settings
        enhancedImage = adapthisteq(grayImage, ...
            'ClipLimit', clipLimits(c), 'NumTiles', [numTiles(n) numTiles(n)]);
        
        % Display the result
        subplot(5, 4, counter); % 5 rows, 4 columns
        imshow(enhancedImage);
        title(sprintf('ClipLimit=%.2f, NumTiles=%dx%d', clipLimits(c), numTiles(n), numTiles(n)));
        counter = counter + 1;
    end
end

% Step 5: Show Original Image for Reference
figure('Name', 'Original Image', 'NumberTitle', 'off');
imshow(grayImage);
title('Original Grayscale Image');
