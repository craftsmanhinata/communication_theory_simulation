clc;clear;
t=linspace(0,(2-1/6)*pi,12);
x=6*cos(t);
y=6*sin(t);
h1=plot(x,y,'*r');
axis equal
xlim([-8,8]);
ylim([-8,8]);
hold on
h2=plot([0,5.5],[0,0]);
set(h2,'linewidth',4);
i = 0;
while i<=269
    i=i+1;
    rotate(h2,[0,0,1],1)
    pause(0.2);
end