function [fitresult, gof] = createFit_poly(x_fit, y_fit)
%CREATEFIT(X_FIT,Y_FIT)
%  创建一个拟合。
%
%  要进行 '无标题拟合 1' 拟合的数据:
%      X 输入: x_fit
%      Y 输出: y_fit
%  输出:
%      fitresult: 表示拟合的拟合对象。
%      gof: 带有拟合优度信息的结构体。
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 21-Jun-2025 10:59:50 自动生成


%% 拟合: '无标题拟合 1'。
[xData, yData] = prepareCurveData( x_fit, y_fit );

% 设置 fittype 和选项。
ft = fittype( 'poly4' );

% 对数据进行模型拟合。
[fitresult, gof] = fit( xData, yData, ft );

% 绘制数据拟合图。
figure( 'Name', '无标题拟合 1' );
h = plot( fitresult, xData, yData );
legend( h, 'y_fit vs. x_fit', '无标题拟合 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% 为坐标区加标签
xlabel( 'x_fit', 'Interpreter', 'none' );
ylabel( 'y_fit', 'Interpreter', 'none' );
grid on


