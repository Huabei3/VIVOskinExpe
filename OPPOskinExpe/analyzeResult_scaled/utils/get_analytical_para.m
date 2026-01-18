
function [hue_angle, chroma,long_axis,short_axis,theta,alpha] = get_analytical_para(i_nation_used,L)


    model_fupara_file=fullfile("D:\work\VIVOskinExpe\analyze\AnalyseResults_p\" , ...
        "efit_p\unscaled\model_fullpara\d65\i\non_model");
    fullpara_data=load(fullfile(model_fupara_file, ...
        strcat("01Preference_all_curve_params.mat")));

    
    a_alpha=fullpara_data.a_alpha_all(i_nation_used,:);
    a_CL=fullpara_data.a_CL_all(i_nation_used,:);
    a_hue_angle=fullpara_data.a_hue_angle_all(i_nation_used,:);
    a_long_axis=fullpara_data.a_long_axis_all(i_nation_used,:);
    a_short_axis=fullpara_data.a_short_axis_all(i_nation_used,:);
    a_theta=fullpara_data.a_theta_all(i_nation_used,:);
    
    hue_angle=a_hue_angle(1).*L + a_hue_angle(2);
    chroma=a_CL(1).*log(L) + a_CL(2);
    long_axis=a_long_axis(1).*L.^3 + a_long_axis(2).*L.^2 +...
        a_long_axis(3).*L + a_long_axis(4);
    short_axis=a_short_axis(1).*L.^3 + a_short_axis(2).*L.^2 +...
        a_short_axis(3).*L + a_short_axis(4);
    theta=a_theta(1).*L + a_theta(2);
    alpha=a_alpha(1).*L + a_alpha(2);
end