clear all;
close all;

IML = imread('proj2-pair1-L.png');
IMR = imread('proj2-pair1-R.png');
IML = double(rgb2gray(IML));
IMR = double(rgb2gray(IMR));
[height,width] = size(IML);
dmax=30;
dmin = 1;
sizeWindow = 11;
moy = mean2(IMR);
IMR = IMR-moy;
IMR = IMR*1.1;
IMR = IMR+moy;

tic
    Corr= zeros(height,width);
for x = floor(sizeWindow/2)+sizeWindow : height -floor(sizeWindow/2)
        for y = sizeWindow:width-sizeWindow
            A = normxcorr2(IML(x-floor(sizeWindow/2):x+floor(sizeWindow/2),y-floor(sizeWindow/2):y+floor(sizeWindow/2)),IMR(x-floor(sizeWindow/2):x+floor(sizeWindow/2),sizeWindow:width-sizeWindow));
            [val Ind] = max(max(A));
            %Ind
            Corr(x,y)= abs(Ind-y-1);
        end
end 
figure(1);
imshow(uint8(Corr))
imwrite(uint8(Corr),strcat('corrCarrePC1Pair1Contrast',num2str(sizeWindow),'x',num2str(sizeWindow),'.png'));    


Corr= zeros(height,width);
for x = floor(sizeWindow/2)+sizeWindow : height -floor(sizeWindow/2)
        for y = sizeWindow:width-sizeWindow
            A = normxcorr2(IMR(x-floor(sizeWindow/2):x+floor(sizeWindow/2),y-floor(sizeWindow/2):y+floor(sizeWindow/2)),IML(x-floor(sizeWindow/2):x+floor(sizeWindow/2),sizeWindow:width-sizeWindow));
           [val Ind] = max(max(A));
            Corr(x,y)= abs(Ind-y-1);
        end
end
figure(2);
imshow(uint8(Corr))
imwrite(uint8(Corr),strcat('corrCarrePC1Pair1Contrast',num2str(sizeWindow),'x',num2str(sizeWindow),'2.png'));    

toc
