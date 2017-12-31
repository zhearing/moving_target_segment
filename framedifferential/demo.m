clear;
clc;
close all;

%% Read in the picture
figure;
N_image = 9;
Cell_image=cell(1,N_image);
for i=1:9
    Name_image=strcat('images/traffic/mobile_',num2str(i+27),'.bmp');
    temp = imread(Name_image);
    Cell_image{1,i} = temp;
    imshow(Cell_image{1,i}), title('figure of traffic');
end

%% Convert to grayscale image
figure;
traffic = cell(1,9);
for i=1:9
    temp = Cell_image{1,i};
    if size(temp,3) == 3
        temp = rgb2gray(temp);
    end
    traffic{1,i} = temp;
    imshow(traffic{1,i}), title('gray figure of traffic');
end

%% gray correlation frame differenence
D_image = cell(1,8);
for i=1:8
    D_image{1,i}=traffic{1,i+1} - traffic{1,i};
end

figure;
k = 5;
subplot(231);
imshow(Cell_image{1,k-1}),title('fig.1 reference image');
image_k = Cell_image{1,k};
row = size(image_k,1);
column = size(image_k,2);

%% Thresholding to obtain a binarized image
threshold = 50;
image = D_image{1,k};
New_image = image;
for i=1:size(image,1)
   for j=1:size(image,2)
       if image(i,j) > threshold
           New_image(i,j) = 255;
       else
           New_image(i,j) = 0;
       end
   end
end
Threshold_image = New_image;
subplot(232);
imshow(image_k),title('fig.2 original image');
subplot(233);
imshow(D_image{1,k}),title('fig.3 Interframe difference image');
subplot(234);
imshow(Threshold_image),title('fig.4 binarized differential image');

%% Morphology denoising, first corrosion and then expansion
s0 = strel('square',1);
s1 = strel('square',8);
Threshold_image = imdilate(Threshold_image, s1);
Threshold_image = imerode(Threshold_image,s0);
subplot(235);
imshow(Threshold_image),title('fig.5 Morphological operation of the differential image');

%% mark
Image = mark(Cell_image{1,5} ,Threshold_image);
subplot(236);
imshow(Image),title('fig.6 moving target');

