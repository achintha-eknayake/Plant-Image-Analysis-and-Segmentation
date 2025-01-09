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
figure('Name', 'Fine-Tuned Leaf Segmentation', 'NumberTitle', 'off', 'Position', [100, 50, 1400, 700]);

for i = 1:numImages
    % Read Image
    image = imread(fullfile(pathname, filenames{i}));
    
    % Step 3: Convert to HSV Color Space
    hsvImage = rgb2hsv(image);
    hChannel = hsvImage(:,:,1); % Hue channel
    sChannel = hsvImage(:,:,2); % Saturation channel

    % Step 4: Adjust Thresholds for Green Color (Minimal Adjustment)
    greenMask = (hChannel > 0.095 & hChannel < 0.6) & (sChannel > 0.13); % Slightly expanded range

    % Step 5: Morphological Processing
    se_open = strel('disk', 6); % Structuring element for opening
    se_dilate_large = strel('disk', 9); % Large dilation element
    se_dilate_small = strel('disk', 1); % Minimal dilation
    se_close = strel('disk', 10); % Structuring element for closing

    % Perform morphological operations
    cleanedMask = imopen(greenMask, se_open); % Remove small noise
    closedMask = imclose(cleanedMask, se_close); % Close small gaps
    filledMask = imfill(closedMask, 'holes'); % Fill small holes
    dilatedMask = imdilate(filledMask, se_dilate_large); % Expand slightly
    fineTunedMask = imdilate(dilatedMask, se_dilate_small); % Minimal additional expansion

    % Step 6: Extract Largest Connected Component
    leafSegment = bwareafilt(fineTunedMask, 1); % Keep only the largest connected component

    % Step 7: Overlay the Segmented Leaf on the Original Image
    overlayImage = imoverlay(image, leafSegment, [1, 0, 0]); % Highlight the leaf in red

    % Display Results for Each Image
    subplot(numImages, 4, (i-1)*4 + 1); imshow(image); title('Original Image');
    subplot(numImages, 4, (i-1)*4 + 2); imshow(greenMask); title('Initial Green Mask');
    subplot(numImages, 4, (i-1)*4 + 3); imshow(leafSegment); title('Segmented Leaf');
    subplot(numImages, 4, (i-1)*4 + 4); imshow(overlayImage); title('Overlay on Original');
end

% Adjust layout for better visualization
sgtitle('Fine-Tuned Leaf Segmentation with Minimal Increment');
