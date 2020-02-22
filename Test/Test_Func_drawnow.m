t=linspace(0,35,1000);
y=sin(2*t).*exp(-t/5);
h=plot(t,y);
xlim([0,50]);
for i=1:200
    x=i/20+t;
    set(h,'xdata',x);
    drawnow;
end