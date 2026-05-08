clc;clear;close all;
%%
data_Jack=[62.59, 17.66, 17.86;
    59.19, 14.59, 17.83;
    48.26, 14.53, 15.57;
    37.86, 14.21, 13.51;
    30.68, 13.23, 12.30;
    20.49, 11.48, 9.45];

contrast=[62.2, 18.9, 20.4;%PMCC
    62.66, 18.31, 19.12;%Cherry
    60.5, 20.7, 24.4];%Zeng
contrast_labCh=[contrast,sqrt(contrast(:,2).^2+contrast(:,3).^2),...
    atan2d(contrast(:,3),contrast(:,2))];


%L-C
L=data_Jack(:,1);
C=sqrt(data_Jack(:,2).^2+data_Jack(:,3).^2);
figure(1);
for i_para=1:size(data_Jack,1)
    hold on;
    scatter(C(i_para),L(i_para), 40, '+','LineWidth', 1); 
    plot(contrast_labCh(1,4),contrast_labCh(1,1), ...
    's', 'MarkerFaceColor', 'm', 'MarkerSize', 5);
    plot(contrast_labCh(2,4),contrast_labCh(2,1), ...
    'p', 'MarkerFaceColor', 'g', 'MarkerSize', 5);
    plot(contrast_labCh(3,4),contrast_labCh(3,1), ...
    'p', 'MarkerFaceColor', 'b', 'MarkerSize', 5);
    text( C(i_para)+10, L(i_para),strcat('{\it L*=}',num2str(data_Jack(i_para,1))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
            'FontSize', 10);
    
end

% L_C(:,1)=L;
% L_C(:,2)=1/1.242926153.*C;
% L_C(:,3)=0.73815/1.242926153.*C;
% save("Z:\homes\Peggy\VIVOskinExpe\Hassel_downsampled\HD65\cropped\CardMasked\L_C.mat","L_C");
%%
%拟合直线
    xdata = C(:);
    ydata = L;
    
    f = @(a,xdata)(a(1).*xdata+a(2));
   
    rmax = 0;

    for t = 1:500
        a0 = [rand,rand];
        options = optimset('MaxFunEvals',200000);
        a = lsqcurvefit(f,a0,xdata,ydata,[-inf,-inf],[inf,inf],options);
        y = a(1).*xdata+a(2);
   
        r = corr(y,ydata);
        if r >= rmax
            rmax = r;
            afinal = a;
        end
    end
    r_LC_Jack=rmax;
    a_LC_Jack = afinal;
%%
%45°
axis equal;
x = 0:0.1:30;
y= x;
text( 30,30,'45°', ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10);
plot(x,y);
%画拟合直线
x = 0:0.1:30;
y= a_LC_Jack(1)*x+a_LC_Jack(2);

plot(x,y);

%设置坐标
ax = gca; ax.XLim = [0 30];
ay = gca; ay.YLim = [0 90];
xlabel('C_{ab}*','FontAngle','italic');
ylabel('L*','FontAngle', 'italic');
title('L*-C_{ab}*','FontAngle', 'italic');
% output_folder="L_C_jack";
% saveas(1,['ellip_pic\linear\m\L_C.jpg']);