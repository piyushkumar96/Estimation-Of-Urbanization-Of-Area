close all
clear all
clc
% Select an image from the 'Vegetation Extra Dataset' folder by opening the folder
[filename,pathname] = uigetfile({'*.*';'*.bmp';'*.tif';'*.gif';'*.png'},'Pick an aerial image');
I = imread([pathname,filename]);
figure, imshow(I);title('vegetation detection');
%%
% Color Image Segmentation
% Convert Image from RGB Color Space to L*a*b* Color Space 
% The L*a*b* space consists of a luminosity layer 'L*', chromaticity-layer 'a*' and 'b*'.
% All of the color information is in the 'a*' and 'b*' layers.
cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I,cform);

% Classify the colors in a*b* colorspace .
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,3);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end
% Display the contents of the clusters
figure, subplot(3,1,1);imshow(segmented_images{1});title('Cluster 1'); subplot(3,1,2);imshow(segmented_images{2});title('Cluster 2');
subplot(3,1,3);imshow(segmented_images{3});title('Cluster 3');

%% Feature Extraction

% The input dialogue makes sure that we extract features only from the
% green part of image
x = inputdlg('Enter the cluster no. containing the disease affected leaf part only:');
i = str2double(x);
figure,subplot(1,1,1);
imshow(segmented_images{i});
I=segmented_images{i}; % read image 

Ir=I(:,:,1); % read red chanel 
Ig=I(:,:,2); % read green chanel 
Ib=I(:,:,3); % bule chanel

% figure, imshow(I), title('Original image')
% figure, imshow(Ir), title('Red channel')
% figure, imshow(Ig), title('Green channel')
% figure, imshow(Ib), title('Blue channel')

%% read the size of the 
m = size(I,1);
n = size(I,2);


R_total= 0;
G_total= 0;
B_total= 0;

for i = 1:m
             for j = 1:n

               rVal= int64(Ir(i,j));
               gVal= int64(Ig(i,j));
               bVal= int64(Ib(i,j));

               R_total= R_total+rVal;
               G_total= G_total+gVal;
               B_total= B_total+bVal;
             end       
end
%fprintf('\n amount red pixels: %s \n', num2str(R_total));
fprintf('\n amount green pixels: %s \n', num2str(G_total));
%fprintf('\n amount blue pixels: %s \n', num2str(B_total));

Total_pixel=R_total+G_total+B_total;
percent=double(G_total)/double(Total_pixel);
percent=percent*100;
fprintf('\n percentage of green pixels: %s \n', num2str(percent));

