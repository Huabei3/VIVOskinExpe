function  [aa,bb,h,x0,y0,r,delta] = my_ellipsefig1(a,b,c,d,e,f,color_str)
% function  [aa,bb,aerfa,x0,y0] = my_ellipsefig1(a,b,c,d,e,f,color_str)
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
h = plot(xy(1,:)-x0,xy(2,:)-y0, 'Color',color_str, 'linewidth', 1);
%h = plot(xy(2,:)-y0,xy(1,:)-x0, 'k', 'linewidth', 2);
%     A=-a/f;B=-b/f;C=-c/f;D=-d/f;E=-e/f;
%     x0 = (B*E-2*C*D)/(4*A*C-B^2);
%     y0 = (B*D-2*A*E)/(4*A*C-B^2);
%     aa=sqrt(2*(A*x0^2+C*y0^2+B*x0*y0-1)/(A+C+sqrt((A-C)^2+B^2)));
%     bb=sqrt(2*(A*x0^2+C*y0^2+B*x0*y0-1)/(A+C-sqrt((A-C)^2+B^2)));
%     aerfa=(1/2)*atan(B/(A-C));
%     plot_ellipse(x0,y0,aa,bb,aerfa);

end

function plot_ellipse(x0,y0,aa,bb,aerfa)
    t0=100;
    t=linspace(1,t0+1,t0);
    x=aa*cos(2*pi/t0*t)*cos(aerfa)-bb*sin(2*pi/t0*t)*sin(aerfa)+x0;
    y=aa*cos(2*pi/t0*t)*sin(aerfa)+bb*sin(2*pi/t0*t)*cos(aerfa)+y0;
    plot(x,y,'r'); 
end
