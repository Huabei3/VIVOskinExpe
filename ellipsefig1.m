function  [aa,bb,h] = ellipsefig1(a,b,c,d,e,f)
% 画一般椭圆：ax*x+bx*y+c*y*y+d*x+e*y = f
delta = b^2-4*a*c;
if delta >= 0
    warning('这不是一个椭圆')
    return;
end
x0 = (b*e-2*c*d)/delta;
y0 = (b*d-2*a*e)/delta;
r = a*x0^2 + b*x0*y0 +c*y0^2 + f;
if r <= 0
    warning('这不是一个椭圆')
    return;
end


aa = sqrt(r/a); 
bb = sqrt(-4*a*r/delta);
t = linspace(0, 2*pi, 60);
xy = [1 -b/(2*a);0 1]*[aa*cos(t);bb*sin(t)];
h = plot(xy(1,:)-x0,xy(2,:)-y0, 'Color',[0 0 1], 'linewidth', 1);
%h = plot(xy(2,:)-y0,xy(1,:)-x0, 'k', 'linewidth', 2);

