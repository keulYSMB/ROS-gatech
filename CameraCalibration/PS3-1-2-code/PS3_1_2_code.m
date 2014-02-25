close all;
clear all;

data2D = [
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


data3D = [
    312.747 309.140 30.086 1;
305.796 311.649 30.356 1;
307.694 312.358 30.418 1;
310.149 307.186 29.298 1;
311.937 310.105 29.216 1;
311.202 307.572 30.682 1;
307.106 306.876 28.660 1;
309.317 312.490 30.230 1;
307.435 310.151 29.318 1;
308.253 306.300 28.881 1;
306.650 309.301 28.905 1;
308.069 306.831 29.189 1;
309.671 308.834 29.029 1;
308.255 309.955 29.267 1;
307.546 308.613 28.963 1;
311.036 309.206 28.913 1;
307.518 308.175 29.069 1;
309.950 311.262 29.990 1;
312.160 310.772 29.080 1;
311.988 312.709 30.514 1
];


n=1;
Res = zeros(10,3);
for nSample = 8:4:16
%  nSample = 8;  
ComputedPoints3D=zeros(4,4,10);
m = ones(3,4,10);

for loop=1:10
%loop=1;
    Indexes = randperm(20);
    Sample2D = data2D(Indexes(1:nSample), :); 
    Sample3D = data3D(Indexes(1:nSample), :); 
    k=1;

    for i=1:nSample
        A(k,:) = [ Sample3D(i,1) Sample3D(i,2) Sample3D(i,3) 1 0 0 0 0 -Sample2D(i,1)*Sample3D(i,1) -Sample2D(i,1)*Sample3D(i,2) -Sample2D(i,1)*Sample3D(i,3) -Sample2D(i,1)];
        A(k+1,:) = [0 0 0 0 Sample3D(i,1) Sample3D(i,2) Sample3D(i,3) 1  -Sample2D(i,2)*Sample3D(i,1) -Sample2D(i,2)*Sample3D(i,2) -Sample2D(i,2)*Sample3D(i,3) -Sample2D(i,2)];
        k=k+2;
    end
    [U,S,V]=svd(A,0);
    
    m(1,:,loop) = V(1:4,12);
    m(2,:,loop) = V(5:8,12);
    m(3,:,loop) = V(9:12,12);
    m(:,:,loop)
   
    TestPoints2D = data2D(Indexes(nSample+1:nSample+4),:);
    TestPoints3D = data3D(Indexes(nSample+1:nSample+4),:);
    for points=1:4
        temp = m(:,:,loop)*TestPoints3D(points,:)';
        temp = temp.*(1/temp(3)) ; 
        TestPoints2D(points,:)';
        temp = temp-TestPoints2D(points,:)';
        Res(loop,n)= Res(loop,n) +sqrt(temp(1)^2+temp(2)^2) ;
    end
    Res(loop,n) = Res(loop,n)/4;
end
Res = abs(Res);
[val,idx]=min(Res(:,n));
MM(:,:,n) = m(:,:,idx);
n=n+1;
end
[val,idx]=min(min(Res));
BestM = MM(:,:,3);
C = -1*inv(BestM(1:3,1:3))*BestM(:,4);

