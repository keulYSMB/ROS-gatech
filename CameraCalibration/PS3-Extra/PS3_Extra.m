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
data2D_a_modif= zeros(20,3);
data2D_b_modif= zeros(20,3);
%for i=1:nbPoints
cub = mean(data2D_b(:,1));
cvb = mean(data2D_b(:,2));

%end
bminusmeanu = data2D_b(:,1)-cub;
bminusmeanv = data2D_b(:,2)-cvb;
std1b =std(bminusmeanv);
std2b =std(bminusmeanu);
sb = max(std1b,std2b);
Tb= [std1b 0 0; 0 std2b 0;0 0 1]*[1 0 -cub; 0 1 -cvb; 0 0 1];

cua = mean(data2D_a(:,1));
cva = mean(data2D_a(:,2));
aminusmeanu = data2D_a(:,1)-cua;
aminusmeanv = data2D_a(:,2)-cva;
std1a =std(aminusmeanv);
std2a =std(aminusmeanu);
sa = max(std1a,std2a);
Ta= [std1a 0 0; 0 std2a 0;0 0 1]*[1 0 -cua; 0 1 -cva; 0 0 1];


for i=1:nbPoints
data2D_a_modif(i,:) = Ta*data2D_a(i,:)';
data2D_b_modif(i,:) = Tb*data2D_b(i,:)';
end



A = zeros(nbPoints, 9);

for i=1:nbPoints
    A(i,:) = [ data2D_b_modif(i,1)*data2D_a_modif(i,1) data2D_b_modif(i,1)*data2D_a_modif(i,2) data2D_b_modif(i,1) data2D_b_modif(i,2)*data2D_a_modif(i,1) data2D_b_modif(i,2)*data2D_a_modif(i,2) data2D_b_modif(i,2) data2D_a_modif(i,1) data2D_a_modif(i,2) 1];
end

[U,S,V]=svd(A,0);
festimate = ones(3,3);
festimate(1,:) = V(1:3,9);
festimate(2,:) = V(4:6,9);
festimate(3,:) = V(7:9,9);

[U2,S2,V2]=svd(festimate,0);
S3 = zeros(3,3);
S3(1:2,1:2) = S2(1:2,1:2);
festimate2 = U2*S3*V2';

fcorrected = Tb'*festimate2*Ta;

for j=1:nbPoints
   lb(j,:) = fcorrected*data2D_a(j,:)';
   lb(j,:) = lb(j,:)./lb(j,3);
end
imb = imread('pic_a.jpg');
[height width] = size(imb);

lL = cross([0 0 1],[height 0 1]);
lR = cross([0 width 1], [height width 1]);
figure(1);
imshow(imb);
hold on
for k=1:nbPoints
 Pl(k,:) = cross(lb(k,:)',lL');
 Pr(k,:) = cross(lb(k,:)',lR');
 Pl(k,:) = Pl(k,:)./Pl(k,3);
 Pr(k,:) = Pr(k,:)./Pr(k,3);
 plot([Pl(k,1),Pr(k,1)],[Pl(k,2),Pr(k,2)],'Color','r','LineWidth',1)
end
hold off;
title('Epipolar lines using crossproduct');
imwrite(figure(1),'coucou.png');
% imshow(imb);
% hold on

% for k=1:nbPoints
%     right_epipolar_x = 1:2*height;
%     right_epipolar_y = (-lb(k,3)-lb(k,1)*right_epipolar_x)/lb(k,2);
%     plot(right_epipolar_x, right_epipolar_y, 'r');
% end
% hold off;