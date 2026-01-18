function[resultwhite,T,duv,E,center]=findwhitev2(center,targetcenter,white,spq) %第二版，添加L方向的修正
    round=0;
    resultwhite=white;
    dl=center(1)-targetcenter(1);%原图-dlab
    da=center(2)-targetcenter(2);
    db=center(3)-targetcenter(3);
    k1=targetcenter(4);
    k2=targetcenter(5);
    k3=targetcenter(6);
    k4=targetcenter(7);
    alpha=targetcenter(8);
    
    E=(k1*dl^2+k2*da^2+k3*db^2+k4*da*db)^0.5;
    p0=(1+exp(E-alpha))^-1;
    [x,y,z]=lab2xyz(center(1),center(2),center(3),white);%xyz作为循环不变量
    %此时这个xyz是mask求出的肤色可信区域里面的lab平均值center转的xyz
    
    while(p0<spq)
        [resultwhite(1),resultwhite(2),resultwhite(3)]=lab2xyz(100+dl,da,db,white);%计算新的白点
        %新的白点就是[100 0 0]+[dl da db]
        center=xyz2lab([x,y,z],'user',resultwhite);%更换白点，使得原来的肤色中心xyz对应的lab点变换到新的中心，除去了全图肤色运算,计算新的肤色中心点
        dl=center(1)-targetcenter(1);
        da=center(2)-targetcenter(2);
        db=center(3)-targetcenter(3);
        
        E=(k1*dl^2+k2*da^2+k3*db^2+k4*da*db)^0.5;
        p0=(1+exp(E-alpha))^-1;
        
        white=resultwhite;
        round=round+1;
        if round>100
            break;
        end
         
    end
    T=cct(resultwhite);%计算色温
    duv=Duv(resultwhite);

