close all;
clear all;


sizeWindow = 5;
dmax = 122;
IML = imread('proj2-pair1-L.png');
IMR = imread('proj2-pair1-R.png');
IML = rgb2gray(IML);
IMR = rgb2gray(IMR);
IML = double(IML);
IMR = double(IMR);
% moy = mean2(IMR);
% IMR = IMR - moy;
% IMR = IMR * 1.1;
% IMR = IMR + moy;
% moy = mean2(IML);
% IML = IML - moy;
% IML = IML * 1.1;
% IML = IML + moy;
%IMR = IMR + imnoise(IMR,'gaussian',mean2(IMR),0.1);
%IMR = IMR + randn(size(IMR)).*30;
%IMR = histeq(IMR,30);
[height,width] = size(IML);
DL = Inf(height,width,dmax+1);

DLtemp = zeros(height,width,dmax+1);
x= 1:height;
y= 1:width;%-dmax;
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
IMNew = IML;
bestD1 = zeros(height,width);
 for i=1+sizeWindow:(height-sizeWindow)
     for j=1+sizeWindow:width-sizeWindow%-dmax
        [val,Ind] = min(DL(i,j,:));
        bestD1(i,j) = Ind-1;
        
        if(Ind~=1 && j-(Ind-1)>0)
            IMNew(i,j)=IMR(i,j-(Ind-1));
        end
     end
 end
 
figure(1);
subplot(1,2,1);
imshow(uint8(IML));
subplot(1,2,2);
imshow(uint8(IMR));
figure(3);
subplot(1,2,1);
 imshow(uint8(bestD1));

imwrite(uint8(bestD1),'PS1-1-1.png');
testD = bestD1;

[height,width] = size(IML);
DL = Inf(height,width,dmax+1);

x= 1:height;
y= 1:width;%-dmax;
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

%  parasites=(bestD2>=4);
%  bestD2(parasites)=0;
figure(3);
subplot(1,2,2);
imshow(uint8(bestD2));
figure(2);
subplot(1,2,2);
imshow(uint8(IMNew));
imwrite(uint8(bestD2),'PS1-1-2.png');
testD = bestD2;

toc