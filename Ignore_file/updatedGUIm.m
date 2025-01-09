function plantDiseaseGUI
    global originalImages rgb_weights;
    originalImages = cell(1,3);
    rgb_weights = [0.2989, 0.5870, 0.1140]; % Default weights
    
    fig = figure('Name', 'Plant Disease Detection', 'Position', [0 0, 1200 800]);
    
    % Main buttons
    uicontrol('Style', 'pushbutton', 'String', 'Load Images', ...
        'Position', [50 750 100 30], 'Callback', @loadImages);
    
    uicontrol('Style', 'pushbutton', 'String', 'Calculate Contrast', ...
        'Position', [170 750 100 30], 'Callback', @calculateContrast);
    
    uicontrol('Style', 'pushbutton', 'String', 'Convert to Grayscale', ...
        'Position', [290 750 100 30], 'Callback', @convertGrayscale);
    
    uicontrol('Style', 'pushbutton', 'String', 'Show Histogram', ...
        'Position', [410 750 100 30], 'Callback', @showHistogram);
    
    uicontrol('Style', 'pushbutton', 'String', 'Detect Disease', ...
        'Position', [530 750 100 30], 'Callback', @detectDisease);
        
    uicontrol('Style', 'pushbutton', 'String', 'Show Binary', ...
        'Position', [650 750 100 30], 'Callback', @showBinary);
    
    % RGB weight controls
    createWeightControls();
end

function createWeightControls()
    global rgb_weights weightDisplays;
    weightDisplays = zeros(1,3);
    
    % Labels
    uicontrol('Style', 'text', 'String', 'R Weight:', ...
        'Position', [50 710 60 20]);
    uicontrol('Style', 'text', 'String', 'G Weight:', ...
        'Position', [50 680 60 20]);
    uicontrol('Style', 'text', 'String', 'B Weight:', ...
        'Position', [50 650 60 20]);
    
    % Sliders
    uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', rgb_weights(1), ...
        'Position', [120 710 150 20], 'Callback', {@updateWeight, 1});
    uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', rgb_weights(2), ...
        'Position', [120 680 150 20], 'Callback', {@updateWeight, 2});
    uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', rgb_weights(3), ...
        'Position', [120 650 150 20], 'Callback', {@updateWeight, 3});
    
    % Value displays
    weightDisplays(1) = uicontrol('Style', 'text', 'String', num2str(rgb_weights(1)), ...
        'Position', [280 710 50 20]);
    weightDisplays(2) = uicontrol('Style', 'text', 'String', num2str(rgb_weights(2)), ...
        'Position', [280 680 50 20]);
    weightDisplays(3) = uicontrol('Style', 'text', 'String', num2str(rgb_weights(3)), ...
        'Position', [280 650 50 20]);
end

function updateWeight(source, ~, weight_index)
    global rgb_weights weightDisplays;
    rgb_weights(weight_index) = get(source, 'Value');
    set(weightDisplays(weight_index), 'String', num2str(rgb_weights(weight_index)));
end

function loadImages(~, ~)
    global originalImages;
    
    for i = 1:3
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg,*.png,*.bmp)'});
        if filename ~= 0
            img = imread(fullfile(pathname, filename));
            originalImages{i} = img;
            
            subplot(2,3,i);
            imshow(img);
            title(['Original Image ' num2str(i)]);
        end
    end
end

function contrast = calculateRMSContrast(img)
    if size(img,3) == 3
        img = rgb2gray_custom(img);
    end
    img = double(img)/255;
    mean_intensity = mean(img(:));
    contrast = sqrt(mean((img(:) - mean_intensity).^2));
end

function calculateContrast(~, ~)
    global originalImages;
    for i = 1:3
        if ~isempty(originalImages{i})
            contrast = calculateRMSContrast(originalImages{i});
            msgbox(sprintf('RMS Contrast for Image %d: %.4f', i, contrast));
        end
    end
end

function gray_img = rgb2gray_custom(rgb_img)
    global rgb_weights;
    gray_img = rgb_weights(1) * double(rgb_img(:,:,1)) + ...
               rgb_weights(2) * double(rgb_img(:,:,2)) + ...
               rgb_weights(3) * double(rgb_img(:,:,3));
    gray_img = uint8(gray_img);
end

function convertGrayscale(~, ~)
    global originalImages;
    for i = 1:3
        if ~isempty(originalImages{i})
            gray_img = rgb2gray_custom(originalImages{i});
            subplot(2,3,i+3);
            imshow(gray_img);
            title(['Grayscale Image ' num2str(i)]);
        end
    end
end

function hist_values = calculateHistogram(img)
    if size(img,3) == 3
        img = rgb2gray_custom(img);
    end
    hist_values = zeros(1,256);
    for i = 0:255
        hist_values(i+1) = sum(img(:) == i);
    end
end

function showHistogram(~, ~)
    global originalImages;
    figure('Name', 'Image Histograms');
    
    for i = 1:3
        if ~isempty(originalImages{i})
            subplot(1,3,i);
            hist_values = calculateHistogram(originalImages{i});
            bar(0:255, hist_values);
            title(['Histogram ' num2str(i)]);
            xlabel('Intensity');
            ylabel('Frequency');
        end
    end
end

function showBinary(~, ~)
    global originalImages;
    figure('Name', 'Binary Images');
    
    for i = 1:3
        if ~isempty(originalImages{i})
            gray_img = rgb2gray_custom(originalImages{i});
            level = graythresh(gray_img);
            binary_img = imbinarize(gray_img, level);
            
            subplot(1,3,i);
            imshow(binary_img);
            title(['Binary Image ' num2str(i)]);
        end
    end
end

function detectDisease(~, ~)
    global originalImages;
    figure('Name', 'Disease Detection Results');
    
    for i = 1:3
        if ~isempty(originalImages{i})
            % Convert to grayscale
            gray_img = rgb2gray_custom(originalImages{i});
            
            % Apply Otsu's thresholding
            level = graythresh(gray_img);
            binary_img = imbinarize(gray_img, level);
            
            % Create custom structuring element
            se = strel('disk', 3);
            
            % Apply morphological operations
            processed_img = imclose(binary_img, se);
            processed_img = imfill(processed_img, 'holes');
            
            % Calculate diseased area percentage
            diseased_area = sum(processed_img(:));
            total_area = numel(processed_img);
            disease_percentage = (diseased_area/total_area) * 100;
            
            % Display results
            subplot(1,3,i);
            imshow(processed_img);
            title(sprintf('Diseased Area: %.1f%%', disease_percentage));
        end
    end
end