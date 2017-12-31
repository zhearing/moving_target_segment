clear;
clc;
close all;

%% Read in the picture
figure;
N_image = 9;
Cell_image=cell(1,N_image);
for i=1:N_image
    Name_image=strcat('images/traffic/mobile_',num2str(i+27),'.bmp');
    Cell_image{1,i} = imread(Name_image);
end
Gray_image = cell(1,N_image);
for i=1:N_image
    if size(Cell_image{1,i},3) > 1
        Gray_image{1,i} = rgb2gray(Cell_image{1,i});
    else
        Gray_image{1,i} = Cell_image{1,i};
    end
end

subplot(331);
imshow(Gray_image{1,8}),title('fig.1 reference image');
subplot(332);
imshow(Gray_image{1,4}),title('fig.2 original image');

%% Calculate optical flow information
Iinputg = Gray_image{1,8};
Irefg = Gray_image{1,4};
% Create optical flow objects and type conversion objects
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
converter = vision.ImageDataTypeConverter;

% Modify the configuration of the optical flow object
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form'; % Returns the complex optical flow diagram
opticalFlow.ReferenceFrameSource = 'Input port'; % Compare two pictures, not a video stream
if 1 % The algorithm used
    opticalFlow.Method = 'Lucas-Kanade';
    opticalFlow.NoiseReductionThreshold = 0.01; % defult:0.0039
else
    opticalFlow.Method = 'Horn-Schunck';
    opticalFlow.Smoothness = 0.5; % defult:1
end

% Call the optical flow object to calculate the optical flow of two pictures
Iinputg_c = step(converter, Iinputg);
Irefg_c = step(converter, Irefg);
opticflow = step(opticalFlow, Iinputg_c, Irefg_c);

%% Optical flow image binarization
% Optical flow of color display
flow_H = real(opticflow);
flow_V = imag(opticflow);
flow_cc = computeColor(flow_H, flow_V);
subplot(333)
imshow(flow_cc),title('fig.3 the color flow of optical field');

% Light flow field of the gray display
flow_gray = 255 - rgb2gray(flow_cc);
subplot(334);
imshow(flow_gray),title('fig.4 the optical flow of the gray-scale');

threshold = 45;
New_image = flow_gray;
for i=1:size(flow_gray,1)
   for j=1:size(flow_gray,2)
       if flow_gray(i,j) > threshold
           New_image(i,j) = 255;
       else
           New_image(i,j) = 0;
       end
   end
end
flow_gray = New_image;

subplot(335);
imshow(flow_gray),title('fig.5 gray-scale of the binarized optical flow field');

%% Corrosion and swelling
se1 = strel('square',8);
se0 = strel('square',1);
flow_gray = imdilate(flow_gray, se1);
flow_gray = imerode(flow_gray,se0);
subplot(336);
imshow(flow_gray),title('fig.6 Morphology of the optical flowafter the gray-scale');

%% mark
Image = mark(Iinputg, flow_gray);
subplot(337)
imshow(Image),title('fig.7 moving target');