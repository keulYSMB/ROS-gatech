clear all;
IM1 = imread('ps1-input0-noise.png');
figure(1); % Figure 1 should be maximized
subplot(2,2,1);
imshow(IM1);
title('noised image');
%gaussian filter : http://stackoverflow.com/questions/2773606/gaussian-filter-in-matlab
%for i=20:5:60
G = fspecial('gaussian',30,3);
%# Filter it
Ig = imfilter(IM1,G,'same');
%# Display
subplot(2,2,2);
imshow(Ig)
title('noised image filtered with a gaussian filter : size : 30*30, sigma=3');
BW = edge(Ig,'roberts');%,0.025);
subplot(2,2,4);
imshow(BW);
title('edge detection on the filtered image');

BW2 = edge(IM1,'canny',0.6);
 subplot(2,2,3);
 imshow(BW2);
 title('edge detection on the original image');

%end
% I chose to keep sigma = 3 and size of filter 30

%% Hough transform on the filtered image
% Accumulator
[height,width] = size(BW);
hough_height = sqrt(height*height+width*width);
thetamax = 180; 
threshold = 1;
H = zeros(thetamax,2*(hough_height+1));
for i=1:height
    for j=1:width
       if(BW(i,j)==threshold)
           for theta=1:thetamax
               d=round(i*cosd(theta-1)-j*sind(theta-1)+hough_height+1); 
               % avoid negative values by adding hough_height+1
               H(theta,d) = H(theta,d)+1; % vote
           end
       end
    end
end
%figure(3);
%subplot(2,2,1);
%imshow(H);
%title('Filtered image : Hough Accumulator before threshold');
bestH=max(max(H));
%threshold on the H matrix
for i=1:2*hough_height
    for j=1:thetamax
        if(H(j,i)<bestH/1.85)
            H(j,i)=0;
        else
            H(j,i)=1;
        end
    end
end    
figure(2);
%subplot(2,2,3);
imshow(H);
title('Filtered image : Hough Accumulator after threshold');
index_line = 1;
index_column = 1;
index_image = 1:1:255;
%looking for lines
for theta = 1:thetamax
    for d = 1: 2*hough_height
        if(theta <= 45+1 || theta >=45+90+1)
            if(H(theta,d)==threshold)
                hl(index_image,index_line) = -tand(theta-1)*index_image + (d-round(hough_height+1))/cosd(theta-1);
                index_line = index_line + 1;
            end
        else
            if(H(theta,d)==threshold)
                vl(index_image,index_column) = -index_image/tand(theta-1) - (d-round(hough_height+1))/sind(theta-1);
                index_column = index_column +1;
            end
        end
    end
end

% ploting lines
figure(3);
subplot(1,2,1)
imshow(IM1)
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
     plot(index_image,hl,'r',vl,index_image,'r','LineWidth',4);
end
%%
%*****************************************************************
%%
%%Hough transform on the original image
[height,width] = size(BW2);
hough_height = sqrt(height*height+width*width);
thetamax = 180; 
threshold = 1;
H = zeros(thetamax,2*(hough_height+1));
for i=1:height
    for j=1:width
       if(BW2(i,j)==threshold)
           for theta=1:thetamax
               d=round(i*cosd(theta-1)-j*sind(theta-1)+hough_height+1); 
               % avoid negative values by adding hough_height+1
               H(theta,d) = H(theta,d)+1; % vote
           end
       end
    end
end
%figure(3);
%subplot(2,2,2);
%imshow(H);
%title('Original image : Hough accumulator before threshold');
%k=1;
bestH=max(max(H));
%threshold on the H matrix
for i=1:2*hough_height
    for j=1:thetamax
        if(H(j,i)<bestH/2-24)
            H(j,i)=0;
        else
            H(j,i)=1;
        end
    end
end    
%figure(7);
%plot(H,'*','MarkerEdgeColor','r');
%subplot(2,2,4);
%imshow(H);
%title('Original image : Hough accumulator after threshold');
index_line = 1;
index_column = 1;
index_image = 1:1:255;
%looking for lines
for theta = 1:thetamax
    for d = 1: 2*hough_height
        if(theta <= 45+1 || theta >=45+90+1)
            if(H(theta,d)==threshold)
                hl(index_image,index_line) = -tand(theta-1)*index_image + (d-round(hough_height))/cosd(theta-1);
                index_line = index_line + 1;
            end
        else
            if(H(theta,d)==threshold)
                vl(index_image,index_column) = -index_image/tand(theta-1) - (d-round(hough_height))/sind(theta-1);
                index_column = index_column +1;
            end
        end
    end
end

% ploting lines
figure(3);
subplot(1,2,2);
imshow(IM1)
title('Original image : lines detected');
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
     plot(index_image,hl,'r',vl,index_image,'r','LineWidth',4);
end
