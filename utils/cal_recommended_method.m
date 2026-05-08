function p = cal_recommended_method(score_level)
    score_level1=round(score_level);
    cata=[-3,-2,-1,1,2,3];
    sum_matrix=[];cumu_matrix=[];
    for i_renPic=1:size(score_level1,1)
        for i_cata=1:length(cata)
            sum_matrix(i_renPic,i_cata)=sum(score_level1(i_renPic,:)==cata(i_cata));
            cumu_matrix(i_renPic,i_cata)=sum(sum_matrix(i_renPic,1:i_cata));
        end
    end
    p_matrix=cumu_matrix./n_file;
    p=ones(size(p_matrix,1),1)-p_matrix(:,3);
end