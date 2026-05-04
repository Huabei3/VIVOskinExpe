%% 测试 writecell 基本功能
clear; clc;

OUT_DIR = 'D:\work\VIVOskinExpe\analyze\AnalyseResults_p\efit_p\unscaled\model_fullpara\d65\new\i\non_model\parameters_table';
if ~exist(OUT_DIR, 'dir')
    mkdir(OUT_DIR);
end
OUT_FILE = fullfile(OUT_DIR, 'test_writecell.xlsx');

% 测试1: 基本 writecell
C1 = {'A', 'B'; '1', '2'};
writecell(C1, OUT_FILE, 'Sheet', 'Test1');
fprintf('测试1通过: 写入 %s (Sheet=Test1)\n', OUT_FILE);

% 测试2: 追加第二个 sheet
C2 = {'X', 'Y'; '10', '20'};
writecell(C2, OUT_FILE, 'Sheet', 'Test2');
fprintf('测试2通过: 追加 Sheet Test2\n');

% 测试3: 覆盖第一个 sheet
C3 = {'AA', 'BB'; '100', '200'};
writecell(C3, OUT_FILE, 'Sheet', 'Test1');
fprintf('测试3通过: 覆盖 Sheet Test1\n');

fprintf('\n所有测试通过！\n');
