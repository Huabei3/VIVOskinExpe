function[resultwhite,T,duv,e,center]=findwhite(center,targetcenter,white) %迭代寻找白点，使得原图在计算得到的白点下进行rgb2lab变换得到的lab中心接近目标中心
    
    resultwhite=white;
    da=center(2)-targetcenter(2);
    db=center(3)-targetcenter(3);
    e=(da^2+db^2)^0.5;
    
    [x,y,z]=lab2xyz(center(1),center(2),center(3),white);%xyz作为循环不变量
    
    while(e>0.001)
        [resultwhite(1),resultwhite(2),resultwhite(3)]=lab2xyz(100,da,db,white);%计算新的白点
        [center(1),center(2),center(3)]=xyz2lab(x,y,z,resultwhite);%更换白点，使得原来的肤色中心xyz对应的lab点变换到新的中心，除去了全图肤色运算,计算新的肤色中心点
        da=center(2)-targetcenter(2);
        db=center(3)-targetcenter(3);
        e=(da^2+db^2)^0.5;
        white=resultwhite;
    end
    T=cct(resultwhite);%计算色温
    duv=Duv(resultwhite);
