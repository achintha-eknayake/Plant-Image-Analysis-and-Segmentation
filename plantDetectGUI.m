%% Main GUI function
function plantDetectGUI

    % Clear environment and close all figures
    clc;
    clear all;
    close all;

    % Create the main figure window
    fig = figure('Name', 'Plant Detection','NumberTitle','off', 'Position', [200 50 1200 700]);
    
    % Create UI controls - buttons
    uicontrol('Style', 'pushbutton', 'String', 'Load Images', ...
        'Position', [40 620 100 30], 'Callback', @loadImages);    
    
    uicontrol('Style', 'pushbutton', 'String', 'Calculate Contrast', ...
        'Position', [40 520 100 30], 'Callback', @calculateContrast);
    
    uicontrol('Style', 'pushbutton', 'String', 'Convert to Grayscale', ...
        'Position', [40 420 100 30], 'Callback', @convertGrayscale);
    
    uicontrol('Style', 'pushbutton', 'String', 'Show Histogram', ...
        'Position', [40 320 100 30], 'Callback', @showHistogram);
    
    uicontrol('Style', 'pushbutton', 'String', 'Segmentation', ...
        'Position', [40 220 100 30], 'Callback', @segmentedImage);
   

    % Create static text for RGB weights
    uicontrol('Style', 'text', 'String', 'RGB Weights:', ...
        'Position', [40 170 100 20], 'HorizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'R: 0.1140', ...
        'Position', [40 150 100 20], 'HorizontalAlignment', 'left');   
    uicontrol('Style', 'text', 'String', 'G: 0.5870', ...
        'Position', [40 130 100 20], 'HorizontalAlignment', 'left');   
    uicontrol('Style', 'text', 'String', 'B: 0.2989', ...
        'Position', [40 110 100 20], 'HorizontalAlignment', 'left');
    
    % Create static text for contrast values
    global contrastText;
    contrastText = cell(1,3);

    % Contrast value display area
    uicontrol('Style', 'text', 'String', 'Contrast Values:', ...
        'Position', [40 80 100 20], 'HorizontalAlignment', 'left');
  
    for i = 1:3
        contrastText{i} = uicontrol('Style', 'text', ...
            'String', sprintf('Image %d: --', i), ...
            'Position', [40 60-((i-1)*20) 100 20], ...
            'HorizontalAlignment', 'left');
    end
end

%% Load and display images function
function loadImages(~, ~)
    global originalImages;

    originalImages = cell(1,3);
    
    % Load up to 3 images with file dialog
    for i = 1:3
        [filename, pathname] = uigetfile('*.jpg;*.png;*.jpeg;*.jfif', strcat('Select Image ',num2str(i)));
        if filename ~= 0
            img = imread(fullfile(pathname, filename));
            originalImages{i} = img;
            
            subplot(2,3,i);
            imshow(img);
            title(['Original Image ' num2str(i)]);
        end
    end
end

%% Custom function for RMS contrast calculation
function contrast = calculateRMSContrast(img)
    % Convert to grayscale if RGB
    if size(img,3) == 3
        img = rgb2gray_custom(img);
    end

    % Calculate RMS contrast
    img = double(img)/255;
    mean_intensity = mean(img(:));
    contrast = sqrt(mean((img(:) - mean_intensity).^2));
end

%% Calculate and display contrast for all images
function calculateContrast(~, ~)
    global originalImages contrastText;
    
    % Check if any images are loaded
    if isempty(originalImages) || all(cellfun(@isempty, originalImages))
        msgbox('Please upload at least one image.');
        return;
    end
    
    % Calculate and display contrast for each image
    for i = 1:3
        if ~isempty(originalImages{i})
            contrast = calculateRMSContrast(originalImages{i});
            % Update contrast value in UI
            set(contrastText{i}, 'String', sprintf('Image %d: %.4f', i, contrast));
        end
    end
end

%% Custom RGB to Grayscale conversion
function gray_img = rgb2gray_custom(rgb_img)
    % Optimized weights for better contrast
    r_weight = 0.2989;
    g_weight = 0.0870;
    b_weight = 0.6140;
    
    % Apply weighted conversion
    gray_img = r_weight * double(rgb_img(:,:,1)) + ...
               g_weight * double(rgb_img(:,:,2)) + ...
               b_weight * double(rgb_img(:,:,3));
    gray_img = uint8(gray_img);
end

%% Convert to grayscale with optimized weights and display 
function convertGrayscale(~, ~)
    global originalImages;
    
    % Check if any images are loaded
    if isempty(originalImages) || all(cellfun(@isempty, originalImages))
        msgbox('Please upload at least one image.');
        return;
    end
    
    % Convert and display each image
    for i = 1:3
        if ~isempty(originalImages{i})
            gray_img = rgb2gray_custom(originalImages{i});
            subplot(2,3,i+3);
            imshow(gray_img);
            title(['Grayscale Image ' num2str(i)]);
        end
    end
end

%% Custom histogram calculation
function hist_values = calculateHistogram(img)
    
    % Convert image to grayscale
    if size(img,3) == 3
        img = rgb2gray_custom(img);
    end

    % Calculate histogram values
    hist_values = zeros(1,256);
    for i = 0:255
        hist_values(i+1) = sum(img(:) == i);
    end
end

%% Display histogram
function showHistogram(~, ~)
    global originalImages;
    
    % Check if any images are loaded
    if isempty(originalImages) || all(cellfun(@isempty, originalImages))
        msgbox('Please upload at least one image.');
        return;
    end
    
    % Create new figure for histograms
    figure('Name', 'Image Histograms','NumberTitle','off','Position', [300 100 1000 500]);
    
    % Display histogram for each image
    for i = 1:3
        if ~isempty(originalImages{i})
            subplot(1,3,i);
            hist_values = calculateHistogram(originalImages{i});
            bar(0:255, hist_values);
            title(['Histogram ' num2str(i)]);
            xlabel('Pixel Intensity');
            ylabel('Frequency');
        end
    end
end

%% Leaf detection using image processing
function segmentedImage(~, ~)
    global originalImages;
    
    % Check if any images are loaded
    if isempty(originalImages) || all(cellfun(@isempty, originalImages))
        msgbox('Please upload at least one image.');
        return;
    end
    
    % Create a figure for display segmentation results
    figure('Name', 'Leaf Detection','NumberTitle','off','Position', [300 100 1000 500]);
    
    % Process each image
    for i = 1:3
        if ~isempty(originalImages{i})
            % Extract RGB channels
            image = originalImages{i};
            greenChannel = image(:,:,2); % Extract the green channel
            redChannel = image(:,:,1);  % Extract the red channel
            blueChannel = image(:,:,3); % Extract the blue channel
    
            % Create Green mask with enhased contrast
            greenMask = (greenChannel > redChannel * 1.001) & (greenChannel > blueChannel * 1.001); 
            enhancedGreen = imadjust(greenChannel, stretchlim(greenChannel(greenMask), [0.02, 0.98]), [0 1]);
    
            % Appy otsu thresholding 
            thresholdValue = graythresh(enhancedGreen); % Otsu's thresholding
            binaryMask = imbinarize(enhancedGreen, thresholdValue * 0.65);
    
            % Remove Noise and Small objects
            minArea = round(size(greenChannel, 1) * size(greenChannel, 2) * 0.00005); 
            noiseFreeMask = bwareaopen(binaryMask & greenMask, minArea); 
    
            % Apply Morphological Processing with Structuring Element
            se = strel('disk', 18); 
            refinedMask = imclose(noiseFreeMask, se); % Close small gaps
            refinedMask = imfill(refinedMask, 'holes'); % Fill holes within the leaf
    
            % Extract the largest leaf reigon
            largestLeaf = bwareafilt(refinedMask, 1); % Retain only the largest region
    
            % Overlay Segmentation on Original Image
            overlayImage = imoverlay(image, largestLeaf, [1, 0, 0]); % Highlight the leaf in red
    
            % Display Results
            subplot(3, 3, (i-1)*3 + 1); imshow(image); title(['Original Image ' num2str(i)]);
            subplot(3, 3, (i-1)*3 + 2); imshow(largestLeaf); title(['Segmented Leaf ' num2str(i)]);
            subplot(3, 3, (i-1)*3 + 3); imshow(overlayImage); title(['Overlay on Original Image' num2str(i)]);
        end
    end
end