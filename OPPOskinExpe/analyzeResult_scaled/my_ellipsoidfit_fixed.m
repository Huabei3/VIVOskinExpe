function [par,r,y] = my_ellipsoidfit_fixed(cielab,zscore,colorcenter)
% cielab should be m*3 matrix
% zscore should be m*1 vector

% if color center is preset, it will be fixed and not be optimized.
% output: par = [k1,k2,k3,k4,l0,a0,b0,k5,k6]

xdata = cielab;
ydata = zscore;

f = @(a,xdata)(1./(1+a(8)*exp(sqrt(a(1)*(xdata(:,1)-a(5)).^2+a(2)*(xdata(:,2)-a(6)).^2+ ...
    a(3)*(xdata(:,3)-a(7)).^2 +a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7))))))...
.*(a(1)*(xdata(:,1)-a(5)).^2+(a(2)*(xdata(:,2)-a(6)).^2+a(3)*(xdata(:,3)-a(7)).^2+ ...
a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7)))>=0);

rmax = 0;

for t = 1:400
    a0 = [rand, rand, rand, rand, 50 + 40 * rand, 20 * rand, 20 * rand, rand];
    % a0=[0.08 	0.11 	0.04 	-0.07 	51.44 	11.04 	10.75 	0.14 ];
    % a0 = [rand,rand,rand,rand,rand,rand,rand,rand];
    options = optimset('MaxFunEvals',200000);
    a = lsqcurvefit(f,a0,xdata,ydata, ...
        [0,0,0,-inf,colorcenter(1),colorcenter(2),colorcenter(3),-inf], ...
        [inf,inf,inf,inf,colorcenter(1),colorcenter(2),colorcenter(3),1],options);
    y = (1./(1+a(8)*exp(sqrt(a(1)*(xdata(:,1)-a(5)).^2+a(2)*(xdata(:,2)-a(6)).^2+ ...
    a(3)*(xdata(:,3)-a(7)).^2 +a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7))))))...
.*(a(1)*(xdata(:,1)-a(5)).^2+(a(2)*(xdata(:,2)-a(6)).^2+a(3)*(xdata(:,3)-a(7)).^2+ ...
a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7)))>=0);

    r = corr(y,ydata);
    if r >= rmax
        rmax = r;
        afinal = a;
    end
end

par = afinal;
a = afinal;
y = (1./(1+a(8)*exp(sqrt(a(1)*(xdata(:,1)-a(5)).^2+a(2)*(xdata(:,2)-a(6)).^2+ ...
    a(3)*(xdata(:,3)-a(7)).^2 +a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7))))))...
.*(a(1)*(xdata(:,1)-a(5)).^2+(a(2)*(xdata(:,2)-a(6)).^2+a(3)*(xdata(:,3)-a(7)).^2+ ...
a(4)*(xdata(:,2)-a(6)).*(xdata(:,3)-a(7)))>=0);
%    scatter(ydata,y);
r = corr(y,ydata);
fprintf('corralation coefficient is %.2f\n',r);
    

end