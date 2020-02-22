t=linspace(0,2*pi,361);
x=10*cos(t);
y=10*sin(t);
h=fill(x,y,'b');
xlim([-12,12]);
ylim([-12,12]);
axis square
hold on
R=linspace(10,1,100);
for i=1:100
    x=R(i)*cos(t);
    y=R(i)*sin(t);
    set(h,'xdata',x);
    set(h,'ydata',y);
    pause(0.3)
end