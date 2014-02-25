close all;
clear all;

data2D_b = [
    880  214 1;
 43  203 1;
270  197 1;
886  347 1;
745  302 1;
943  128 1;
476  590 1;
419  214 1;
317  335 1;
783  521 1;
235  427 1;
665  429 1;
655  362 1;
427  333 1;
412  415 1;
746  351 1;
434  415 1;
525  234 1;
716  308 1;
602  187 1
];

data2D_a = [
    731  238 1;
22   248 1;
204  230 1;
903  342 1;
635  316 1;
867  177 1;
958  572 1;
328  244 1;
426  386 1;
1064 470 1;
480  495 1;
964  419 1;
695  374 1;
505  372 1;
645  452 1;
692  359 1;
712  444 1;
465  263 1;
591  324 1;
447  213 1
];

nbPoints = 20;
A = zeros(nbPoints, 9);

for i=1:nbPoints
    A(i,:) = [ data2D_b(i,1)*data2D_a(i,1) data2D_b(i,1)*data2D_a(i,2) data2D_b(i,1) data2D_b(i,2)*data2D_a(i,1) data2D_b(i,2)*data2D_a(i,2) data2D_b(i,2) data2D_a(i,1) data2D_a(i,2) 1];
end

[U,S,V]=svd(A,0);
V
S
festimate = ones(3,3);
festimate(1,:) = V(1:3,9);
festimate(2,:) = V(4:6,9);
festimate(3,:) = V(7:9,9);

%festimate

[U2,S2,V2]=svd(festimate,0);
S3 = zeros(3,3);
S3(1:2,1:2) = S2(1:2,1:2);
festimate2 = U2*S3*V2';

%rank(festimate)
%rank(festimate2)

for j=1:nbPoints
   lb(j,:) = festimate2*data2D_a(j,:)';
   lb(j,:) = lb(j,:)./lb(j,3);
end
imb = imread('pic_a.jpg');
[height width] = size(imb);
%U x V = Ux*Vy-Uy*Vx
% using crossproduct

figure(1);
imshow(imb);
hold on
lL = cross([0 0 1],[height 0 1]);
lR = cross([0 width 1], [height width 1]);
for k=1:nbPoints
 Pl(k,:) = cross(lb(k,:)',lL');
 Pr(k,:) = cross(lb(k,:)',lR');
 Pl(k,:) = Pl(k,:)./Pl(k,3);
 Pr(k,:) = Pr(k,:)./Pr(k,3);
 plot([Pl(k,1),Pr(k,1)],[Pl(k,2),Pr(k,2)],'Color','r','LineWidth',1)
end
hold off;
title('Epipolar lines using crossproduct');

% figure(2);
% imshow(imb);
% hold on
% 
% % Using the eqn of line: ax+by+c=0; y = (-c-ax)/b
% %
% for k=1:nbPoints
%     right_epipolar_x = 1:2*height;
%     right_epipolar_y = (-lb(k,3)-lb(k,1)*right_epipolar_x)/lb(k,2);
%     plot(right_epipolar_x, right_epipolar_y, 'r');
%    
% end
% hold off;
% title('Epipolar lines using line equation');

% 
% for m=1:nbPoints
%     inv(festimate2)
%    la(m,:) = data2D_b(m,:)*inv(festimate2);
%    la(m,:) = la(m,:)./la(m,3);
% end
% ima = imread('pic_a.jpg');
% [height width] = size(ima);
% %U x V = Ux*Vy-Uy*Vx
% % using crossproduct
% 
% figure(2);
% imshow(ima);
% hold on
% lL = cross([0 0 1],[height 0 1]);
% lR = cross([0 width 1], [height width 1]);
% for j=1:nbPoints
%  Pla(j,:) = cross(la(j,:)',lL');
%  Pra(j,:) = cross(la(j,:)',lR');
%  Pla(j,:) = Pla(j,:)./Pla(j,3);
%  Pra(j,:) = Pra(j,:)./Pra(j,3);
%  plot([Pla(j,1),Pra(j,1)],[Pla(j,2),Pra(j,2)],'Color','r','LineWidth',1)
% end
% hold off;
% title('Epipolar lines using crossproduct');
