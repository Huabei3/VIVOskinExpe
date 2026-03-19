function EnglishLabel = ch2eng(ChineseInput)

    keys = ["喜好的", "有吸引力的", "女性化的", "友善的", "年轻的", ...
            "健康的", "真实还原的", "与环境适配的", "白皙的", "红润的"];
            
    values = ["Preference", "Attractiveness", "Feminine", "Cooperative", ...
              "Youth", "Healthy", "Fidelity", "Harmony", "Fair", "Ruddy"];
    EnglishLabel=ChineseInput;
    for i_key=1:length(keys)
        if contains(EnglishLabel,keys(i_key))
            EnglishLabel=strrep(EnglishLabel,keys(i_key),values(i_key));
        end
    end


end