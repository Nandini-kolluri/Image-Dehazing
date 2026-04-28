clc;
clear;
close all;


I = imread('027.png');
I = im2double(I);

[m,n,~] = size(I);

figure
subplot(2,3,1)
imshow(I)
title('Original Hazy Image')

patch = 15;
dark = zeros(m,n);

for i = 1:m
    for j = 1:n
        
        rmin = max(i-floor(patch/2),1);
        rmax = min(i+floor(patch/2),m);
        cmin = max(j-floor(patch/2),1);
        cmax = min(j+floor(patch/2),n);
        
        patchImg = I(rmin:rmax , cmin:cmax , :);
        
        dark(i,j) = min(patchImg(:));
        
    end
end

subplot(2,3,2)
imshow(dark)
title('Dark Channel')

darkVec = dark(:);
imageVec = reshape(I,m*n,3);


[~,index] = sort(darkVec,'descend');

numPixels = floor(m*n*0.001);

A = mean(imageVec(index(1:numPixels),:));
omega = 0.95;

transmission = zeros(m,n);

for i = 1:m
    for j = 1:n
        
        transmission(i,j) = 1 - omega*dark(i,j)/max(A);
        
    end
end

subplot(2,3,3)
imshow(transmission)
title('Initial Transmission')


kernel = fspecial('average',[15 15]);
t_refined = imfilter(transmission,kernel,'replicate');

subplot(2,3,4)
imshow(t_refined)
title('Refined Transmission')


t0 = 0.01;

J = zeros(size(I));

for c = 1:3
    
    J(:,:,c) = (I(:,:,c) - A(c)) ./ max(t_refined,t0) + A(c);
    
end

J(J>1) = 1;
J(J<0) = 0;

J = imadjust(J,stretchlim(J),[]);

subplot(2,3,5)
imshow(J)
title('Dehazed Image')

R = J(:,:,1);
G = J(:,:,2);
B = J(:,:,3);

[countR,binR] = imhist(R);
[countG,binG] = imhist(G);
[countB,binB] = imhist(B);

subplot(2,3,6)

plot(binR,countR,'r','LineWidth',1.5)
hold on
plot(binG,countG,'g','LineWidth',1.5)
plot(binB,countB,'b','LineWidth',1.5)

xlabel('Bins')
ylabel('# of Pixels')
title('Dehazed RGB Histogram')
legend('Red','Green','Blue')


figure
imshowpair(I,J,'montage')
title('Before and After Dehazing')
