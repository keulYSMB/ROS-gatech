clear all;
thres = 0.1;
IM0 = imread('ps1-input0.png');
BW1 = edge(IM0,'sobel',thres);
figure(1);
subplot(2,3,1);
imshow(BW1);
title('Edge detection : Sobel''s method');

BW2 = edge(IM0,'roberts',thres);
%figure(2);
subplot(2,3,2);
imshow(BW2);
title('Edge detection : Roberts method');

BW3 = edge(IM0,'prewitt',thres);
%figure(3);
subplot(2,3,3);
imshow(BW3);
title('Edge detection : Prewitt''s method');

BW4 = edge(IM0,'log');
%figure(4);
subplot(2,3,4);
imshow(BW4);
title('Edge detection : Log method');

BW5 = edge(IM0,'canny');
%figure(5);
subplot(2,3,5);
imshow(BW5);
title('Edge detection : Canny''s method');

% FIGURE1 SHOULD BE MAXIMIZED
%
%
% We can see here that the log edge detection is the less efficient of these
% five edge detection methods. 
% The canny method isn't very good because there are errors in the center
% of the image and in the corner
% We can also observe that prewitt and sobel methods giv the same results 
% regarding the cross in the center of the image :
%               - the cross is misplaced beacause 2 of the four sides of the
%                 cross are misplaced (figures 1 and 3)
% The Roberts method give a better result because only one of the 4 sides
% of the cross is misplaced and every corner has the good shape.