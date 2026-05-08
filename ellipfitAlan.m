function [p,r]=ellipfitAlan(cielab,ydata)

    prob_ori=ydata;
 
    %x0=xx;
%     x_lb=[-0.004,-0.006,-0.006,-0.01,-0.01,-0.01,0.6];
%     x_ub=[-0.0005,-0.0001,-0.0001,0.01,0.01,0.01,1];
    x_lb=[0.146390983,68.36675,28.38262039,19.87038012,83.64869573,23.31346616,24.85860247,0.855486966];
    x_ub=[-0.014241728,-19.81425519,-7.563857018,-42.72781359,51.44040997,11.29222954,11.11389293,...
        -0.468360915];
    %%
    
    %%
    x0=x_lb+rand([1,8]).*(x_ub-x_lb);
    % fun_test=@(xx)xx(7).*exp(xx(1).*(L-ave_L).^2+xx(2).*(a-ave_a).^2+xx(3).*(b-ave_b).^2+ ...
    %    xx(4).*(L-ave_L).*(a-ave_a)+xx(5).*(L-ave_L).*(b-ave_b)+xx(6).*(a-ave_a).*(b-ave_b));
    % fun_gauss=@(x)(norm(x(7).*exp(x(1).*(L-ave_L).^2+x(2).*(a-ave_a).^2+x(3).*(b-ave_b).^2+ ...
    %     x(4).*(L-ave_L).*(a-ave_a)+x(5).*(L-ave_L).*(b-ave_b)+x(6).*(a-ave_a).*(b-ave_b))-prob_ori));
    
    f = @(a,cielab)(1./(1+(a(8)*exp(a(1)*sqrt((cielab(:,1)-a(5)).^2+a(2)*(cielab(:,2)-a(6)).^2 ...
            +a(3)*(cielab(:,3)-a(7)).^2+a(4)*(cielab(:,2)-a(6)).*(cielab(:,3)-a(7)))))) ...
            .*(((cielab(:,1)-a(5)).^2+a(2)*(cielab(:,2)-a(6)).^2+a(3)*(cielab(:,3)-a(7)).^2 ...
            +a(4)*(cielab(:,2)-a(6)).*(cielab(:,3)-a(7)))>=0));
    
    %% 1粒子群算法
    p1=zeros([1,8]);
    r1=0;
    %粒子群最慢，因此放最后
    %% 2模拟退火算法
     OP2= optimoptions('simulannealbnd','FunctionTolerance',1e-10,...
         'MaxIterations',50000);
    
    [p2,~,~,~]  =simulannealbnd(f,(p1+x0)/2,x_lb,x_ub,OP2)
    prob_test1=f(p2,cielab);
    r2=corr(prob_ori,prob_test1)
    
    %% 3遗传算法
%     OP3 = optimoptions('ga','FunctionTolerance',1e-10,...
%         'MaxGenerations',5000);
%     [p3,~,~,~]  =ga(f,8,[],[],[],[],x_lb,x_ub,OP3)
%     
%     prob_test1=f(p3,cielab);
%     r3=corr(prob_ori,prob_test1)
    
    %% 4模式搜索算法
    OP4 = optimoptions('patternsearch','FunctionTolerance',1e-10,...
        'MaxIterations',50000);
    [p4,~,~,~]  =patternsearch(f,(p1+x0)/2,[],[],[],[],x_lb,x_ub,OP4)
    prob_test1=f(p4,cielab);
    r4=corr(prob_ori,prob_test1)
    
    %% 5全局搜索算法
    try
        opts = optimoptions(@fmincon,'Algorithm','interior-point');
        problem = createOptimProblem('fmincon','objective',...
        f,'x0',(p1+x0)/2,'lb',x_lb,'ub',x_ub,'options',opts);
        gs = GlobalSearch;
        [p5,~] = run(gs,problem)
        
        prob_test1=f(p5,cielab);
        r5=corr(prob_ori,prob_test1)
    catch
        p5=0*p1;
        r5=0*r1;
    end
    
    %% 6多起点搜索算法
    try
    opts = optimoptions(@fmincon,'Algorithm','interior-point'); 
    % 创建优化问题
    problem = createOptimProblem('fmincon','objective',...
        f,'x0',(p1+x0)/2,'lb',x_lb,'ub',x_ub,'options',opts);
    % 指定优化求解器
    ms =MultiStart;
    % 求解
    [p6,~] = run(ms,problem,64)
    prob_test1=f(p6,cielab);
    r6=corr(prob_ori,prob_test1)
    catch
        p6=0*p1;
        r6=0*r1;
    end
    %% 1粒子群算法
    OP1 = optimoptions('particleswarm','SwarmSize',3000,'FunctionTolerance',1e-10,...
        'HybridFcn',@patternsearch,'MaxStallIterations',300,'MaxIterations',3000);
    [p1,~,~,~]  = particleswarm(f,8,x_lb,x_ub,OP1)
    
    prob_test1=f(p1,cielab);
    r1=corr(prob_ori,prob_test1)
    %%
%     p=[p1;p2;p3;p4;p5;p6];
%     r=[r1,r2,r3,r4,r5,r6];
    p=[p1;p2;p4;p5;p6];
    r=[r1,r2,r4,r5,r6];
    r=r';
%     p=[p,zeros(6,1),r];

end