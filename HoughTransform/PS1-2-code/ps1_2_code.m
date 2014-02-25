clear all;

thres = 0.1;
IM0 = imread('ps1-input0.png');
BW2 = edge(IM0,'roberts',thres);

%% Hough transform
% Accumulator
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
figure(1);
subplot(2,1,1);
imshow(H);
title('Hough accumulator before threshold');
k=1;
bestH=max(max(H));
% threshold on the H matrix
for i=1:2*hough_height
    for j=1:thetamax
        if(H(j,i)<bestH-2)
            H(j,i)=0;
        else
            H(j,i)=1;
            dd(k) = i;
            dth(k) = j;
            k=k+1;
        end
    end
end    
%figure(2);
%plot(H,'*','MarkerEdgeColor','r');
subplot(2,1,2);
imshow(H);
title('Hough accumulator after threshold');
index_line = 1;
index_column = 1;
index_image = 1:1:255;
% looking for lines
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
out=figure(3);
imshow(IM0)
title('Original image with the lines detected represented in red');
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


