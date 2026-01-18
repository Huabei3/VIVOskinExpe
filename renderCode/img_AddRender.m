function [outnew,  out_of_gamut_ratio] = img_AddRender(img, bull, string,delta_Lab)
    % outnew 鏄?(targetwhite)鏍囧噯D65锛孻=100浣滀负鍙傝?冪櫧鏃剁殑缁撴灉锛屽浘鍍忎寒搴褰掍竴鍖栧埌0-100锛屾墍鏈夊儚绱犵殑xyz鍧囦箻浠ヤ寒搴︾郴鏁発L锛屽彲浠ヤ綔涓烘覆鏌撶粨鏋滀娇鐢紝鍥犱负鍙傝?冨厜婧愭亽瀹氫负D65锛孻=100
    % outxyz鍚岀悊锛屼娇鐢╕=100鏍囧噯D65杞崲鍒發ab

    
    % outnew2 鏄?(targetwhite)D65锛屼寒搴︿繚鎸佸師鍥句寒搴︾殑缁撴灉锛寈yz娌℃湁涔樼郴鏁帮紝鑰屾槸鍙傝?冪櫧D65鐨勪寒搴=100*kL,鍙互鐢ㄤ綔鐧藉钩琛★紝鍥犱负姣忎釜鍙傝?冪櫧閮芥牴鎹浘鐗囦寒搴﹀仛浜嗛?傚簲
    switch string
        case 'srgb'
            matrix = 1;
        case 'polynomial'
            matrix = 2;
        case 'LUT'
            matrix = 3;
    end

    [m, n, p] = size(img);
    out = reshape(img, [m * n, p]); % 灞曞紑
    xyz2 = zeros(size(out));
    bull_reshaped=reshape(bull, [m * n, p])./255;
    bull_reshaped = double(bull_reshaped);
    logicalIndex = all(bull_reshaped == 0, 2);
    % 璁＄畻浜害绯绘暟鍜屼慨姝ｇ殑鐧界偣

    datai_file = 'LUT3d_results\datai_sorted40_3.mat';

    % RGB 杞崲鍒? XYZ
    if matrix == 1
        xyz1 = srgb2xyz(out);
    elseif matrix == 2
        xyz1 = rgb2xyz(out, w);
    elseif matrix == 3
        out = out * 255;
        xyz1 = lut3d_rgb2xyz1(out, datai_file);
        disp(['lut3d_rgb2xyz1 over: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')]);

    end
    XYZw=load(datai_file);
    XYZw=XYZw.XYZw;


    [lab1] = xyz2lab(xyz1,'user',XYZw);
    lab2=lab1 + repmat(delta_Lab, length(lab1), 1);
    [xyz2] = lab2xyz2(lab2,'user',XYZw);

    % xyz2 = SimpleTwostepCAT(xyz1, whitemodify, targetwhite, white0, 'CAT16', 1, 1);
    xyz2(logicalIndex, :) = xyz1(logicalIndex, :);
%%
    

    if matrix==1
        [rgbnew, flag,out_of_gamut_ratio] = xyz2srgb(xyz2);
    elseif matrix==3
        datafile = 'LUT3d_results\data_sorted40_3.mat';

        if any(logicalIndex)
            noFaceRGB=out(logicalIndex, :);
        else
            noFaceRGB = [];
        end
        
        % 瀵? bull_reshaped==1 鐨勯儴鍒嗚繘琛岃绠?
        if any(~logicalIndex)            
            [rgbnew_bull1,out_of_gamut_ratio] = lut3d_xyz2rgbKDitp1(xyz2(~logicalIndex, :), datafile);
        else
            rgbnew_bull1 = [];
        end
    
    %     outofgamut=(cached_outofgamut+outofgamut_bull1)/(size(cachedRGB,1)+size(rgbnew_bull1,1));
    %     fprintf("outofgamut pecent\\cel%d\n",outofgamut);
        
        
        % 鍚堝苟 bull_reshaped==0 鍜? bull_reshaped==1 鐨勭粨鏋?
        rgbnew = zeros(size(xyz2));
        if ~isempty(noFaceRGB)
            rgbnew(logicalIndex, :) = noFaceRGB;
        end
        if ~isempty(rgbnew_bull1)
            rgbnew(~logicalIndex, :) = rgbnew_bull1;
        end
        % try
        %     save("tempCache.mat");
        % catch E
        %     % 濡傛灉淇濆瓨澶辫触锛屾樉绀鸿鍛婁俊鎭紝浣嗙户缁墽琛?
        %     warning('Failed to save tempCache.mat: %s. Error ID: %s', E.message, E.identifier);
        % end
        rgbnew=rgbnew./255;
    end
    %%
    % 璁＄畻 xyz3 杞崲鍥? RGB 鐨勭粨鏋?

    % 閲嶅杈撳嚭
    outxyz = reshape(xyz2, [m, n, p]);
    outnew = reshape(rgbnew, [m, n, p]);
end
