t=linspace(-15,15,1000);
y=sin(4*t).*exp(cos(t));

for i=1:201
    x=(i-1)/20+t;
    h=plot(x,y);
    xlim([-15,35]);
    ylim([-4,4])
    set(h,'color',rand(1,3));
    set(h,'linewidth',2);
    m(:,i)=getframe
end

movie(m,1)