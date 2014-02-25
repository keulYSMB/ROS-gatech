clear all;
IM2 = imread('ps1-input1.jpg');

figure(1); % Figure 1 should be maximized
imshow(IM2);
title('circles image');

% Usually we use the green channel because it's the more reliable
im=IM2(:,:,2);
%im = rgb2gray(IM2);
G = fspecial('gaussian',30,3);
%# Filter it
Ig = imfilter(im,G,'same');
%# Display
figure(2);
 subplot(1,2,1);
 imshow(Ig)
 title('image filtered with a gaussian filter : size : 30*30, sigma=3');
 BW = edge(Ig,'roberts',0.02);
 subplot(1,2,2);
 imshow(BW);
 %title('edge detection on the filtered image: roberts');

%% Hough transform on the filtered image
% Accumulator
thetamax = 360;
radiusmax = 30;
margin = 5;
[height,width] = size(BW);
BW2=zeros(height,width);
BW2(margin:height-margin,margin:width-margin)=BW(margin:height-margin,margin:width-margin);
BW=BW2;
H = zeros(width,1024,radiusmax);

 
 for i= 1:height
    for j = 1:width
         if (BW(i,j)==1)
             for radius = 20:1:radiusmax
                 for theta = 0:10:thetamax
                    a=int32(i-radius*cosd(theta)+60);
                    b=int32(j+radius*sind(theta)+60);
                    H(a,b,radius)=H(a,b,radius)+1;%radius/10;%voting 
                end
            end
         end
    end
    i
 end
 
  bestH = max(max(max(H)))/1.7;

%http://www.mathworks.fr/matlabcentral/newsreader/view_thread/250840
relevant = (H >= bestH);
irrelevant = (H < bestH);
H(relevant)=1;
H(irrelevant)=0;
 figure(1);
 for radius= 20:1:radiusmax
     for a = 61:1:683
         for b = 61:2:1024
            if (H(a,b,radius) == 1 )%&& H(a+1,b,radius))% && H(a,b+1,radius) )&& H(a-1,b,radius) && H(a,b-1,radius))
                y=a-60;x=b-60;
                hold on;
                %http://matlab.wikia.com/wiki/FAQ#How_do_I_create_a_circle.3F
               xCenter = x;
               yCenter = y;
               theta = 0 : thetamax;
               x = radius * cosd(theta) + xCenter;
               y = radius * sind(theta) + yCenter;
               plot(x, y,'r','LineWidth',1);
            %   radius = radiusmax;
            %a= a+10;
           % b = b+10;
             end
 
          end
      end
end

 axis([0 width 0 height])
 
 % execution time on sample image : 23s
