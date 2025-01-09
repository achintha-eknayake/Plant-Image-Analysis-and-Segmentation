% Load the image
image = imread('Plant-1.jfif'); % Replace with your image file
R = double(image(:,:,1)); % Red channel
G = double(image(:,:,2)); % Green channel
B = double(image(:,:,3)); % Blue channel

% Fixed green weight
wG = 0.1;

% Initialize figure for visualization
figure;
plot_count = 1; % Counter for subplot

% Loop through all combinations of red and blue weights
for wR = 0.1:0.1:0.9
    for wB = 0.1:0.1:0.9
        % Ensure that the weights sum to 1
        if abs(wR + wG + wB - 1) > 1e-6
            continue; % Skip invalid combinations
        end
        
        % Convert to grayscale using current weights
        gray_image = wR * R + wG * G + wB * B;
        gray_image = uint8(gray_image); % Convert back to uint8
        
        % Display the grayscale image
        subplot(3, 3, plot_count); % Adjust grid size if needed
        imshow(gray_image);
        title(sprintf('R=%.1f, G=0.1, B=%.1f', wR, wB));
        plot_count = plot_count + 1; % Increment plot counter
        
        % Break the loop if subplot limit is reached
        if plot_count > 9 % Display first 9 combinations
            break;
        end
    end
    if plot_count > 9
        break;
    end
end

sgtitle('Grayscale Images with Fixed G=0.1 and Varying R, B Weights');
