clear all;
close all;

sizeWindow = 5;
dmax = 122;
IML = imread('leftTest.png');
IMR = imread('rightTest.png');
IML = double(IML);
IMR = double(IMR);
[height,width] = size(IML);
DL = Inf(height,width,dmax+1);

DLtemp = zeros(height,width,dmax+1);
x= 1:height;
y= 1:width;%-dmax;
for d=0 : dmax
   
     IMRShift = circshift(IMR,[0 d]);
     d1 = (IML-IMRShift).^2;
     d2 = circshift(d1,[-1 -1]);
     d3 = circshift(d1,[0 -1]);
     d4 = circshift(d1,[1 -1]);
     d5 = circshift(d1,[-1 0]);
     d6 = circshift(d1,[1 0]);
     d7= circshift(d1,[-1 1]);
     d8 = circshift(d1,[0 1]);
     d9 = circshift(d1,[1 1]);
     
     DL(x,y,d+1) = d1(x,y) + d2(x,y) + d3(x,y) + d4(x,y) + d5(x,y) + d6(x,y) + d7(x,y) + d8(x,y) + d9(x,y);

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
 
figure(1);
subplot(1,2,1);
imshow(uint8(IML));
subplot(1,2,2);
imshow(uint8(IMR));
figure(3);
subplot(1,2,1);
imshow(10*uint8(bestD1));
figure(2);
subplot(1,2,1);
imshow(uint8(IMNew));
imwrite(uint8(bestD1),'PS1-1-1.png');
testD = bestD1;




IML = imread('leftTest.png');
IMR = imread('rightTest.png');
IML = double(IML);
IMR = double(IMR);
[height,width] = size(IML);
DL = Inf(height,width,dmax+1);

x= 1:height;
y= 1:width;%-dmax;
DL = Inf(height,width,dmax+1);
DLtemp = zeros(height,width,dmax+1);
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

figure(3);
subplot(1,2,2);
imshow(10*uint8(bestD2));
figure(2);
subplot(1,2,2);
imshow(uint8(IMNew));
imwrite(uint8(bestD2),'PS1-1-2.png');
testD = bestD2;