clear all;
close all;

thresholdForeground =80;
thresholdlevel2 = 70;
thresholdlevel3 = 60;
thresholdBackground =40;
 sizeWindow = 5;
 dmax = 128;
IML = imread('proj2-pair1-L.png');
IMR = imread('proj2-pair1-R.png');
%IML = imread('proj2-pair2-L.png');
%IMR = imread('proj2-pair2-R.png');
IML = double(rgb2gray(IML));
IMR = double(rgb2gray(IMR));
 [height,width] = size(IML);
DL = Inf(height,width,dmax+1);
DLtemp = zeros(height,width,dmax+1);
tic
x= 1:height;
y= 1:width;%-dmax;
dMat = zeros(height,width,sizeWindow*sizeWindow);
for d=0 : dmax
    %y= 1:width-d;
    k=1;
   for i=-floor(sizeWindow/2):floor(sizeWindow/2)
       for j=-floor(sizeWindow/2):floor(sizeWindow/2)
         IMRShift = circshift(IMR,[0 d]);
         dMat(:,:,k)=circshift((IML-IMRShift).^2,[i j]);
         DLtemp(x,y,d+1) = DLtemp(x,y,d+1) + dMat(x,y,k);
         k=k+1;
       end
   end
   DL(x,y,d+1)=DLtemp(x,y,d+1);
end
IMNew = IMR;
bestD1 = zeros(height,width);
 for i=1+sizeWindow:(height-sizeWindow)
     for j=1+sizeWindow:width-sizeWindow%-dmax
        [val,Ind] = min(DL(i,j,:));
        bestD1(i,j) = Ind-1;
        
        if(Ind~=1 && j+(Ind-1)<width)
            IMNew(i,j)=IML(i,j+Ind-1);
        end
     end
 end
 thresholdParasites = 0.8*max(max(bestD1));
 parasites=(bestD1>=thresholdParasites);
 bestD1(parasites) = bestD1(parasites)/100; 
 
% foreground = (bestD1 >= thresholdForeground);
% level2 = (bestD1 >= thresholdlevel3 & bestD1 < thresholdlevel2);
% level3 = (bestD1 >= thresholdBackground & bestD1 < thresholdlevel3);
 background = (bestD1 < thresholdBackground);
% bestD1(foreground)=2*bestD1(foreground);
% bestD1(level2)=1.5*bestD1(level2);
% bestD1(level3)=1.5*bestD1(level3);
bestD1(background)=thresholdBackground;
%G = fspecial('gaussian',10,3);
%# Filter it
%bestD1 = imfilter(bestD1,G,'same');
%# Display

figure(1);
subplot(1,2,1);
imshow(uint8(IML));
subplot(1,2,2);
imshow(uint8(IMR));
 imwrite(1.7*uint8(bestD1(sizeWindow:height-sizeWindow,dmax-sizeWindow:width-sizeWindow)),'PS2-2-1.png');
testD = bestD1;



DL = Inf(height,width,dmax+1);
DLtemp = zeros(height,width,dmax+1);
x= 1:height;
y= 1:width;%-dmax;
dMat = zeros(height,width,sizeWindow*sizeWindow);
for d=0 : dmax
    %y= 1:width-d;
    k=1;
   for i=-floor(sizeWindow/2):floor(sizeWindow/2)
       for j=-floor(sizeWindow/2):floor(sizeWindow/2)
         IMLShift = circshift(IML,[0 -d]);
         dMat(:,:,k)=circshift((IMR-IMLShift).^2,[i j]);
         DLtemp(x,y,d+1) = DLtemp(x,y,d+1) + dMat(x,y,k);
         k=k+1;
       end
   end
   DL(x,y,d+1)=DLtemp(x,y,d+1);
end
IMNew = IML;
bestD2 = zeros(height,width);
 for i=1+sizeWindow:(height-sizeWindow)
     for j=1+sizeWindow:width-sizeWindow%-dmax
        [val,Ind] = min(DL(i,j,:));
        bestD2(i,j) = Ind-1;
        
        if(Ind~=1 && j-(Ind-1)>0)
            IMNew(i,j)=IMR(i,j-(Ind-1));
        end
     end
 end
 thresholdParasites = 0.8*max(max(bestD2));
 parasites=(bestD2>=thresholdParasites);
 bestD2(parasites) = bestD2(parasites)/100; 

 background = (bestD2 < thresholdBackground);
 bestD2(background)=thresholdBackground;
  figure(3);
subplot(1,2,1);
imshow(1.7*uint8(bestD1),[0 200]);
axis([dmax-sizeWindow width 0 height ]);
%  figure(3);
subplot(1,2,2);
imshow(1.7*uint8(bestD2),[0 200]);
axis([sizeWindow width-dmax+sizeWindow 0 height ]);
imwrite(1.7*uint8(bestD2(sizeWindow:height-sizeWindow,sizeWindow:width-dmax+sizeWindow)),'PS2-2-2.png');
% imwrite(2.5*uint8(bestD2(sizeWindow:height-sizeWindow,sizeWindow:width-dmax+sizeWindow)),'PS2-2-Pair2-2.png');
toc