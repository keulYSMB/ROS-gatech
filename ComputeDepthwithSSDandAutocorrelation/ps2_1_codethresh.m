A = imread('PS1-1-1.png');
B = imread('PS1-1-2.png');

parasites=(A>=4);
A(parasites)=0;
parasites=(B>=4);
B(parasites)=0;

imshow(10*B);
imwrite(10*B,'PS1-1-2thresh.png');
imshow(10*A);
imwrite(10*A,'PS1-1-1thresh.png');