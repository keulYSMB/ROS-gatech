clear all;
IM2 = imread('ps1-input1.jpg');

im = rgb2gray(IM2);
G = fspecial('gaussian',30,3);
%# Filter it
Ig = imfilter(im,G,'same');
%# Display
figure(1); % Figure 1 should be maximized
 subplot(1,2,1);
 imshow(Ig)
 title('noised image filtered with a gaussian filter : size : 30*30, sigma=3');
 BW = edge(Ig,'roberts');%,0.025);
 subplot(1,2,2);
 imshow(BW);
 title('edge detection on the filtered image: roberts');

% 
%% Hough transform on the filtered image
% Accumulator
margin = 5;
[height,width] = size(BW);
BW2=zeros(height,width);
BW2(margin:height-margin,margin:width-margin)=BW(margin:height-margin,margin:width-margin);
BW=BW2; % removing edges on the side of the image

hough_height = sqrt(height*height+width*width);
thetamax = 180; 
threshold = 1;
H = zeros(thetamax,2*round(hough_height));
for i=1:height
    for j=1:width
       if(BW(i,j)==threshold)
           for theta=1:thetamax
               d=round(-i*cosd(theta-1)+j*sind(theta-1)+hough_height); 
               % avoid negative values by adding hough_height+1
               H(theta,d) = H(theta,d)+1; % vote
           end
       end
    end
end
bestH=max(max(H));
%threshold on the H matrix
for i=1:2*hough_height
    for j=1:thetamax
        if(H(j,i)<bestH/1.3)
            H(j,i)=0;
        else
            H(j,i)=1;
        end
    end
end    
figure(2);
%subplot(2,1,2);
imshow(H);
title('Filtered image : Hough Accumulator after threshold');
index_line = 1;
index_column = 1;
index_image = 1:1:hough_height*2;
%looking for lines
for theta = 1:thetamax
    for d = 1: 2*hough_height
        if(theta < 45+1 || theta >=45+90+1)
            if(H(theta,d)==threshold)
                hl(index_line,index_image) =-1*( -tand(theta-1)*index_image + (d-round(hough_height))/cosd(theta-1));
                index_line = index_line + 1;
            end
        else
            if(H(theta,d)==threshold)
                vl(index_column,index_image) =-1*(-index_image/tand(theta-1) - (d-round(hough_height))/sind(theta-1));
                index_column = index_column +1;
            end
        end
    end
end

% ploting lines
figure(3);
%subplot(1,2,1)
imshow(im)
title('Filtered image : lines detected');
hold on;
if(index_line==1)
    if(index_column~=1)
        plot(vl,index_image,'r','LineWidth',4);
    % if index_column==1 nothing to plot
    end
    
elseif(index_column==1)
    if(index_line~=1)
          plot(index_image,hl,'r','LineWidth',4);
    % if index_line==1 nothing to plot
    end
else
index_image2 = hough_height*2:-1:1;
     plot(index_image,hl,'g',vl,index_image,'r','LineWidth',2);
     axis([0 width 0 height ]);
end


% transformation of the referential to match lines and pens (change the
% sign during computation of cos and sin)
% remove the edges at the borders of the image
% threshold = Hmax/1.3
