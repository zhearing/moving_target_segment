clear;
clc;
close all;

%% 读入图片
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
imshow(Gray_image{1,8}),title('(1)参考图像');
subplot(332);
imshow(Gray_image{1,4}),title('(2)原始图像');

%% 计算光流信息
Iinputg = Gray_image{1,8};
Irefg = Gray_image{1,4};
% 创建光流对象及类型转化对象
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
converter = vision.ImageDataTypeConverter;

% 修改光流对象的配置
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form'; % 返回复数形式光流图
opticalFlow.ReferenceFrameSource = 'Input port'; % 对比两张图片，而不是视频流
if 1 % 使用的算法
    opticalFlow.Method = 'Lucas-Kanade';
    opticalFlow.NoiseReductionThreshold = 0.01; % 默认是0.0039
else
    opticalFlow.Method = 'Horn-Schunck';
    opticalFlow.Smoothness = 0.5; % 默认是1
end

% 调用光流对象计算两张图片的光流
Iinputg_c = step(converter, Iinputg);
Irefg_c = step(converter, Irefg);
opticflow = step(opticalFlow, Iinputg_c, Irefg_c);

%% 光流图像二值化
% 光流场的彩色显示
flow_H = real(opticflow);
flow_V = imag(opticflow);
flow_cc = computeColor(flow_H, flow_V);
subplot(333)
imshow(flow_cc),title('(3)光流场的彩色显示');

% 光流场的灰度显示
flow_gray = 255 - rgb2gray(flow_cc);
subplot(334);
imshow(flow_gray),title('(4)光流场的灰度显示');

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
imshow(flow_gray),title('(5)二值化后的光流场的灰度显示');

%% 腐蚀和膨胀
se1 = strel('square',8);
se0 = strel('square',1);
flow_gray = imdilate(flow_gray, se1);
flow_gray = imerode(flow_gray,se0);
subplot(336);
imshow(flow_gray),title('(6)形态学处理后的光流场的灰度显示');

%% 标记
Image = mark(Iinputg, flow_gray);
subplot(337)
imshow(Image),title('(7)运动目标分割');