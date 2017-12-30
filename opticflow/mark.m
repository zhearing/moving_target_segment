function [ I_output ] = mark( I_src, I_ref )
% 根据所给的参考图像（像素值为0或255）给原图像标记

% 获取参考图像中连通单元的数目
count = bwconncomp(I_ref, 8);
Num_c = count.NumObjects;

I_output = I_src;
objects = cell(1,Num_c);
row = size(I_output,1);
column = size(I_output,2);

for k=1:Num_c
    temp = zeros(row,column);
    temp(count.PixelIdxList{k}) = 255;
    objects{1,k} = temp;
end

palette = unidrnd(256,Num_c,size(I_src,3))-1;


for k = 1:Num_c
    for i=1:row
        for j=1:column
            if objects{1,k}(i,j)==255
               I_output(i,j,:) = palette(k,:);
            end
        end
    end
end
end

