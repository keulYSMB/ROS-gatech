A = imread('PS1-1-1Pair2Noise.png');
B = imread('PS1-1-2Pair2Noise.png');
[height width] = size(A);
sizeWindow=12;
magnify = 1.8;
threshfact = 0.7;
parasites=(A>=threshfact*max(max(A)));
A(parasites)=A(parasites)/10;
parasites=(B>=threshfact*max(max(B)));
B(parasites)=B(parasites)/10;

figure(10);
imshow(magnify*B(sizeWindow:height,sizeWindow:width-100));
imwrite(magnify*B(sizeWindow:height,sizeWindow:width-100),'PS1-1-1Pair2Noisethresh.png');
figure(11);
imshow(magnify*A(sizeWindow:height,100:width-sizeWindow));
imwrite(magnify*A(sizeWindow:height,100:width-sizeWindow),'PS1-1-2Pair2Noisethresh.png');