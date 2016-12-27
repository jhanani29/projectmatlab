function crophealth()
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
workspace;	% Make sure the workspace panel is showing.
  originalFolder = pwd; 
  fontSize = 12;	
  folder = 'C:\Users\jan\Documents\Arduino\think3\'; 
	if ~exist(folder, 'dir') 
		folder = pwd; 
		end 
		cd(folder); 
		% Browse for the image file. 
		[baseFileName, folder] = uigetfile('*.*', 'Specify an image file'); 
		fullImageFileName = fullfile(folder, baseFileName); 
		% Set current folder back to the original one. 
		cd(originalFolder);
		selectedImage = 'My own image'; % Need for the if threshold selection statement later.
        % Read in image into an array.
	[rgbImage storedColorMap] = imread(fullImageFileName); 
	[rows columns numberOfColorBands] = size(rgbImage); 
	% If it's monochrome (indexed), convert it to color. 
	% Check to see if it's an 8-bit image needed later for scaling).
	if strcmpi(class(rgbImage), 'uint8')
		% Flag for 256 gray levels.
		eightBit = true;
	else
		eightBit = false;
	end
	if numberOfColorBands == 1
		if isempty(storedColorMap)
			% Just a simple gray level image, not indexed with a stored color map.
			% Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
			rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
		else
			% It's an indexed image.
			rgbImage = ind2rgb(rgbImage, storedColorMap);
			% ind2rgb() will convert it to double and normalize it to the range 0-1.
			% Convert back to uint8 in the range 0-255, if needed.
			if eightBit
				rgbImage = uint8(255 * rgbImage);
			end
		end
	end 
	% Display the original image.
	subplot(3, 4, 1);
	imshow(rgbImage);
	drawnow; % Make it display immediately. 
	% Extract out the color bands from the original image
	% into 3 separate 2D arrays, one for each color component.
	redBand = rgbImage(:, :, 1); 
	greenBand = rgbImage(:, :, 2); 
	blueBand = rgbImage(:, :, 3); 
	% Display them.
	subplot(3, 4, 2);
	imshow(redBand);
	title('Red Band', 'FontSize', fontSize);
	subplot(3, 4, 3);
	imshow(greenBand);
	title('Green Band', 'FontSize', fontSize);
	subplot(3, 4, 4);
	imshow(blueBand);
	title('Blue Band', 'FontSize', fontSize);
	message = sprintf('These are the individual color bands.\nNow we will compute the image histograms.');
    % Compute and plot the red histogram. 
	hR = subplot(3, 4, 6); 
	[countsR, grayLevelsR] = imhist(redBand); 
	maxGLValueR = find(countsR > 0, 1, 'last'); 
	maxCountR = max(countsR); 
	bar(countsR, 'r'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Red Band', 'FontSize', fontSize);

	% Compute and plot the green histogram. 
	hG = subplot(3, 4, 7); 
	[countsG, grayLevelsG] = imhist(greenBand); 
	maxGLValueG = find(countsG > 0, 1, 'last'); 
	maxCountG = max(countsG); 
	bar(countsG, 'g', 'BarWidth', 0.95); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Green Band', 'FontSize', fontSize);

	% Compute and plot the blue histogram. 
	hB = subplot(3, 4, 8); 
	[countsB, grayLevelsB] = imhist(blueBand); 
	maxGLValueB = find(countsB > 0, 1, 'last'); 
	maxCountB = max(countsB); 
	bar(countsB, 'b'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Blue Band', 'FontSize', fontSize);

	% Set all axes to be the same width and height.
	% This makes it easier to compare them.
	maxGL = max([maxGLValueR,  maxGLValueG, maxGLValueB]); 
	if eightBit 
			maxGL = 255; 
	end 
	maxCount = max([maxCountR,  maxCountG, maxCountB]); 
	axis([hR hG hB], [0 maxGL 0 maxCount]); 

	% Plot all 3 histograms in one plot.
	subplot(3, 4, 5); 
	plot(grayLevelsR, countsR, 'r', 'LineWidth', 2); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	hold on; 
	plot(grayLevelsG, countsG, 'g', 'LineWidth', 2); 
	plot(grayLevelsB, countsB, 'b', 'LineWidth', 2); 
	title('Histogram of All Bands', 'FontSize', fontSize); 
	maxGrayLevel = max([maxGLValueR, maxGLValueG, maxGLValueB]); 
	% Trim x-axis to just the max gray level on the bright end. 
	if eightBit 
		xlim([0 255]); 
	else 
		xlim([0 maxGrayLevel]); 
    end
    
    redThresholdLow1 = 0;
	redThresholdHigh1 = 50;
     
    redThresholdLow2 = 50;
	redThresholdHigh2 = 150;
    
    redThresholdLow3 = 150;
	redThresholdHigh3 = 255;
    
        PlaceThresholdBars(6, redThresholdLow1, redThresholdHigh1);
        PlaceThresholdBars(6, redThresholdLow2, redThresholdHigh2);
        redMask1 = (redBand >= redThresholdLow1) & (redBand <= redThresholdHigh1);
        redMask2 = (redBand >= redThresholdLow2) & (redBand <= redThresholdHigh2);
        redMask3 = (redBand >= redThresholdLow3) & (redBand <= redThresholdHigh3);
        subplot(3, 4, 9);
	imshow(redMask1, []);
	title('high green pigment area', 'FontSize', fontSize);
    subplot(3, 4, 10);
	imshow(redMask2, []);
	title('medium green pigment area', 'FontSize', fontSize);
    subplot(3, 4, 11);
    imshow(redMask3, []);
	title('low green pigment area', 'FontSize', fontSize);
    return;
    
    function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
	% Show the thresholds as vertical red bars on the histograms.
	subplot(3, 4, plotNumber); 
	hold on;
	maxYValue = ylim;
	maxXValue = xlim;
	hStemLines = stem([lowThresh highThresh], [maxYValue(2) maxYValue(2)], 'r');
	children = get(hStemLines, 'children');
	set(children(2),'visible', 'off');
	% Place a text label on the bar chart showing the threshold.
	fontSizeThresh = 14;
	annotationTextL = sprintf('%d', lowThresh);
	annotationTextH = sprintf('%d', highThresh);
	% For text(), the x and y need to be of the data class "double" so let's cast both to double.
	text(double(lowThresh + 5), double(0.85 * maxYValue(2)), annotationTextL, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	text(double(highThresh + 5), double(0.85 * maxYValue(2)), annotationTextH, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	
	% Show the range as arrows.
	% Can't get it to work, with either gca or gcf.
% 	annotation(gca, 'arrow', [lowThresh/maxXValue(2) highThresh/maxXValue(2)],[0.7 0.7]);

	return; % from PlaceThresholdBars()