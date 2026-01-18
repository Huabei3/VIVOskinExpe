function[dl,dc,dh]= dlch(lab1,lab2)
    dl=lab1(:,1)-lab2(:,1);
    dc=sqrt(lab1(:,2).^2+lab1(:,3).^2)-sqrt(lab2(:,2).^2+lab2(:,3).^2);
    dh=atan2d(lab1(:,3),lab1(:,2))-atan2d(lab2(:,3),lab2(:,2));
end