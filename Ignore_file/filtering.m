clc;
clear all;
close all;

% Step 1: Load Multiple Images
[filenames, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.jfif'}, ...
    'Select Multiple Images', 'MultiSelect', 'on');
if isequal(filenames, 0)
    disp('No files selected');
    return;
end
if ischar(filenames)
    filenames = {filenames}; % Convert to cell array if only one file is selected
end

% Step 2: Loop Through Each Image
numImages = length(filenames);
figure('Name', 'Leaf Segmentation with Final Increment', 'NumberTitle', 'off', 'Position', [100, 50, 1400, 800]);

for i = 1:numImages
    % Read Image
    image = imread(fullfile(pathname, filenames{i}));
    
    % Step 3: Convert to Grayscale
    if size(image, 3) == 3
        grayImage = rgb2gray(image); % Convert to grayscale
        greenChannel = image(:,:,2); % Extract the green channel
        redChannel = image(:,:,1);  % Extract the red channel
        blueChannel = image(:,:,3); % Extract the blue channel
    else
        grayImage = image; % Already grayscale
        greenChannel = grayImage; % No green channel
        redChannel = grayImage;
        blueChannel = grayImage;
    end

    % Step 4: Enhance Green Channel and Loosen Green Mask
    greenMask = (greenChannel > redChannel * 1.001) & (greenChannel > blueChannel * 1.001); % Slightly more relaxed
    enhancedGreen = imadjust(greenChannel, stretchlim(greenChannel(greenMask), [0.02, 0.98]), [0 1]);

    % Step 5: Global Thresholding with Further Reduction
    thresholdValue = graythresh(enhancedGreen); % Otsu's thresholding
    binaryMask = imbinarize(enhancedGreen, thresholdValue * 0.65); % Slightly lowered

    % Step 6: Remove Noise and Small Regions
    minArea = round(size(grayImage, 1) * size(grayImage, 2) * 0.00005); % Allow even smaller regions
    noiseFreeMask = bwareaopen(binaryMask & greenMask, minArea); % Combine with greenMask to refine

    % Step 7: Morphological Processing with Larger Structuring Element
    se = strel('disk', 18); % Slightly larger size
    refinedMask = imclose(noiseFreeMask, se); % Close small gaps
    refinedMask = imfill(refinedMask, 'holes'); % Fill holes within the leaf

    % Step 8: Keep the Largest Connected Component
    largestLeaf = bwareafilt(refinedMask, 1); % Retain only the largest region

    % Step 9: Overlay Segmentation on Original Image
    overlayImage = imoverlay(image, largestLeaf, [1, 0, 0]); % Highlight the leaf in red

    % Display Results
    subplot(numImages, 4, (i-1)*4 + 1); imshow(image); title('Original Image');
    subplot(numImages, 4, (i-1)*4 + 2); imshow(enhancedGreen); title('Enhanced Green Channel');
    subplot(numImages, 4, (i-1)*4 + 3); imshow(largestLeaf); title('Segmented Leaf');
    subplot(numImages, 4, (i-1)*4 + 4); imshow(overlayImage); title('Overlay on Original');
end

% Adjust layout for better visualization
sgtitle('Leaf Segmentation with Final Increment');
