function UdithaDetection
    % Create the figure for the GUI
    f = figure('Name', 'Image Processing GUI', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);

    % Upload buttons for images
    uicontrol('Style', 'pushbutton', 'String', 'Upload Image 1', 'Position', [20, 550, 120, 30], 'Callback', @uploadImage1);
    uicontrol('Style', 'pushbutton', 'String', 'Upload Image 2', 'Position', [20, 500, 120, 30], 'Callback', @uploadImage2);
    uicontrol('Style', 'pushbutton', 'String', 'Upload Image 3', 'Position', [20, 450, 120, 30], 'Callback', @uploadImage3);

    % Action buttons for processing
    uicontrol('Style', 'pushbutton', 'String', 'Calculate Contrast', 'Position', [20, 400, 120, 30], 'Callback', @calculateContrast);
    uicontrol('Style', 'pushbutton', 'String', 'Convert to Grayscale', 'Position', [20, 350, 120, 30], 'Callback', @convertToGrayscale);
    uicontrol('Style', 'pushbutton', 'String', 'Display Histogram', 'Position', [20, 300, 120, 30], 'Callback', @displayHistogram);
    uicontrol('Style', 'pushbutton', 'String', 'Apply Thresholding & Morphology', 'Position', [20, 250, 160, 30], 'Callback', @applyMorphology);

    % Axes for displaying images
    axes('Position', [0.3, 0.1, 0.65, 0.8]);

    % Variables to hold the uploaded images
    img1 = [];
    img2 = [];
    img3 = [];

    % Function to upload Image 1
    function uploadImage1(~, ~)
        [file, path] = uigetfile('*.jpg;*.png;*.jpeg;*.jfif', 'Select Image 1');
        if file
            img1 = imread(fullfile(path, file));
            displayImages(); % Display all images after uploading
        end
    end

    % Function to upload Image 2
    function uploadImage2(~, ~)
        [file, path] = uigetfile('.jpg;.png;.jpeg;.jfif', 'Select Image 2');
        if file
            img2 = imread(fullfile(path, file));
            displayImages(); % Display all images after uploading
        end
    end

    % Function to upload Image 3
    function uploadImage3(~, ~)
        [file, path] = uigetfile('*.jpg;*.png;*.jpeg;*.jfif', 'Select Image 3');
        if file
            img3 = imread(fullfile(path, file));
            displayImages(); % Display all images after uploading
        end
    end

    % Function to display all three images in the same window
    function displayImages()
        % Create subplots for displaying images side by side
        subplot(1, 3, 1);
        if ~isempty(img1)
            imshow(img1);
            title('Image 1');
        else
            text(0.5, 0.5, 'No Image 1', 'HorizontalAlignment', 'center');
        end
        
        subplot(1, 3, 2);
        if ~isempty(img2)
            imshow(img2);
            title('Image 2');
        else
            text(0.5, 0.5, 'No Image 2', 'HorizontalAlignment', 'center');
        end
        
        subplot(1, 3, 3);
        if ~isempty(img3)
            imshow(img3);
            title('Image 3');
        else
            text(0.5, 0.5, 'No Image 3', 'HorizontalAlignment', 'center');
        end
    end

    % Function to calculate contrast for all three images
    function calculateContrast(~, ~)
        if isempty(img1) && isempty(img2) && isempty(img3)
            msgbox('Please upload at least one image.');
            return;
        end
        contrast = [];
        if ~isempty(img1)
            contrast(1) = calculateRMSContrast(img1);
        end
        if ~isempty(img2)
            contrast(2) = calculateRMSContrast(img2);
        end
        if ~isempty(img3)
            contrast(3) = calculateRMSContrast(img3);
        end
        msgbox(['Contrast (RMS): Image 1 = ', num2str(contrast(1)), ...
            ', Image 2 = ', num2str(contrast(2)), ', Image 3 = ', num2str(contrast(3))]);
    end

    % Function to calculate RMS contrast
    function contrast = calculateRMSContrast(image)
        image = double(image);
        meanIntensity = mean(image(:));
        contrast = sqrt(mean((image(:) - meanIntensity).^2));
    end

    % Function to convert all images to grayscale with optimized weights
    function convertToGrayscale(~, ~)
        if isempty(img1) && isempty(img2) && isempty(img3)
            msgbox('Please upload at least one image.');
            return;
        end
        grayscaleImgs = {};
        if ~isempty(img1)
            grayscaleImgs{1} = convertToGrayscaleOptimized(img1);
        end
        if ~isempty(img2)
            grayscaleImgs{2} = convertToGrayscaleOptimized(img2);
        end
        if ~isempty(img3)
            grayscaleImgs{3} = convertToGrayscaleOptimized(img3);
        end
        figure;
        for i = 1:length(grayscaleImgs)
            subplot(1, 3, i);
            imshow(grayscaleImgs{i});
            title(['Grayscale Image ', num2str(i)]);
        end
    end

    % Function to convert to grayscale with optimized weights
    function grayscaleImg = convertToGrayscaleOptimized(image)
        % Use optimized weights for RGB channels
        redWeight = 0.2989;
        greenWeight = 0.5870;
        blueWeight = 0.1140;
        grayscaleImg = uint8(redWeight * double(image(:,:,1)) + greenWeight * double(image(:,:,2)) + blueWeight * double(image(:,:,3)));
    end

    % Function to display histogram of all grayscale images
    function displayHistogram(~, ~)
        if isempty(img1) && isempty(img2) && isempty(img3)
            msgbox('Please upload at least one image.');
            return;
        end
        figure;
        if ~isempty(img1)
            subplot(1, 3, 1);
            grayscaleImg = convertToGrayscaleOptimized(img1);
            plotHistogram(grayscaleImg);
            title('Histogram of Image 1');
        end
        if ~isempty(img2)
            subplot(1, 3, 2);
            grayscaleImg = convertToGrayscaleOptimized(img2);
            plotHistogram(grayscaleImg);
            title('Histogram of Image 2');
        end
        if ~isempty(img3)
            subplot(1, 3, 3);
            grayscaleImg = convertToGrayscaleOptimized(img3);
            plotHistogram(grayscaleImg);
            title('Histogram of Image 3');
        end
    end

    % Function to plot histogram of grayscale image
    function plotHistogram(grayscaleImg)
        [counts, binLocations] = imhist(grayscaleImg);
        bar(binLocations, counts, 'BarWidth', 1);
        xlabel('Pixel Intensity');
        ylabel('Frequency');
    end

    % Function to apply thresholding and morphological operations to all images
    function applyMorphology(~, ~)
        if isempty(img1) && isempty(img2) && isempty(img3)
            msgbox('Please upload at least one image.');
            return;
        end
        processedImgs = {};
        if ~isempty(img1)
            grayscaleImg = convertToGrayscaleOptimized(img1);
            processedImgs{1} = binarizeAndMorphology(grayscaleImg);
        end
        if ~isempty(img2)
            grayscaleImg = convertToGrayscaleOptimized(img2);
            processedImgs{2} = binarizeAndMorphology(grayscaleImg);
        end
        if ~isempty(img3)
            grayscaleImg = convertToGrayscaleOptimized(img3);
            processedImgs{3} = binarizeAndMorphology(grayscaleImg);
        end
        figure;
        for i = 1:length(processedImgs)
            subplot(1, 3, i);
            imshow(processedImgs{i});
            title(['Processed Image ', num2str(i)]);
        end
    end

    % Function to binarize the image and apply morphological operations
    function processedImg = binarizeAndMorphology(grayscaleImg)
        threshold = graythresh(grayscaleImg);
        binaryImg = imbinarize(grayscaleImg, threshold);
        se = strel('disk', 5); % Custom structuring element
        processedImg = imopen(binaryImg, se); % Apply morphological opening
    end
end