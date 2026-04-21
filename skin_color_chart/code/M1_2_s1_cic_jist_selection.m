% CIC-JIST paper method: equal-cube sampling for uniform LAB selection
clear; clc; close all;

% Data source (same as M1_2_s1)
load("lab_data.mat","lab_all","lab_pre");
attr_type = "pre"; % "all" or "pre"
if strcmp(attr_type,"all")
    lab1 = lab_all;
    attr_serial = "2";
else
    lab1 = lab_pre;
    attr_serial = "1";
end

% Target number of samples and sampling approach
N = 70;   
% N = 200;              % set your target N here
phase = "I";          % "I", "II", or "auto"
itmax = 20;           % bisection iterations
verbose = true;

% Run CIC-JIST equal-cube selection
[centers_sel, sl, phase_used, startv, nv] = ...
    select_centers_by_bisection(lab1, N, phase, itmax, verbose);

% Assign samples to cubes (same grid as centers)
[lin_idx, valid_idx] = map_samples_to_grid(lab1, startv, sl, nv);
cube_samples = accumarray(lin_idx, valid_idx, [prod(nv) 1], @(x){x}, {[]});

% For each selected center: choose nearest sample in its cube (or global if hole)
idselect = zeros(size(centers_sel,1),1);
for i = 1:size(centers_sel,1)
    c = centers_sel(i,:);
    idxL = round((c(1) - startv(1)) / sl) + 1;
    idxA = round((c(2) - startv(2)) / sl) + 1;
    idxB = round((c(3) - startv(3)) / sl) + 1;
    lin = sub2ind(nv, idxL, idxA, idxB);
    idxs = cube_samples{lin};
    if ~isempty(idxs)
        d2 = sum((lab1(idxs,:) - c).^2, 2);
        [~, k] = min(d2);
        idselect(i) = idxs(k);
    else
        d2 = sum((lab1 - c).^2, 2);
        [~, k] = min(d2);
        idselect(i) = k;
    end
end

labs = lab1(idselect,:);

% Save results
save_folder = fullfile("res", attr_type, "cic_jist_selection",phase);
if ~exist(save_folder,"dir")
    mkdir(save_folder);
end
save(fullfile(save_folder,"lab_selected.mat"), ...
    "idselect","labs","lab1","centers_sel","sl","phase_used","startv","nv","attr_type","attr_serial");

% Optional quick check plot
pic_folder = fullfile(save_folder, "pic");
if ~exist(pic_folder,"dir")
    mkdir(pic_folder);
end
h_ab = figure;
plot(lab1(:,2), lab1(:,3), '.', 'Color', [0.8 0.8 0.8], 'MarkerSize', 6); hold on;
plot(labs(:,2), labs(:,3), 'k*', 'MarkerSize', 4);
grid on; axis equal;
xlabel('a*'); ylabel('b*');
title(sprintf('CIC-JIST selection: N=%d, sl=%.4f, phase=%s', N, sl, phase_used));
exportgraphics(h_ab, fullfile(pic_folder, sprintf("ab_cic_jist_%s.jpg", attr_serial)), "Resolution", 150);

% L*-C* plot
C_all = sqrt(lab1(:,2).^2 + lab1(:,3).^2);
C_sel = sqrt(labs(:,2).^2 + labs(:,3).^2);
hc = figure;
plot(C_all, lab1(:,1), '.', 'Color', [0.8 0.8 0.8], 'MarkerSize', 6); hold on;
plot(C_sel, labs(:,1), 'k*', 'MarkerSize', 4);
grid on; axis equal;
xlabel('C*'); ylabel('L*');
title(sprintf('CIC-JIST L*-C*: N=%d', N));
exportgraphics(hc, fullfile(pic_folder, sprintf("lc_cic_jist_%s.jpg", attr_serial)), "Resolution", 150);

% ===== local helpers =====
function [centers_sel, sl_best, phase_used, startv, nv] = ...
    select_centers_by_bisection(lab, N, phase, itmax, verbose)

lab = double(lab);
mins = min(lab,[],1);
maxs = max(lab,[],1);
aves = (mins + maxs) / 2;

span = maxs - mins;
sl0 = mean(span) / max(N^(1/3), 1);
sl0 = max(1.0, sl0);

phases = {"I","II"};
if strcmpi(phase,"I") || strcmpi(phase,"II")
    phases = {char(phase)};
end

% Find slS (smaller) with Nsum > N, slL (larger) with Nsum < N
slS = max(sl0/2, 0.5); slL = sl0*2;
evS = []; evL = [];
for rep = 1:20
    evS = best_phase_eval(lab, mins, aves, maxs, slS, phases, N);
    if evS.Nsum > N, break; end
    slS = slS / 1.4;
    if slS < 0.2, break; end
end
for rep = 1:20
    evL = best_phase_eval(lab, mins, aves, maxs, slL, phases, N);
    if evL.Nsum < N, break; end
    slL = slL * 1.4;
    if slL > 200, break; end
end

best = evS;
if isempty(best) || (~isempty(evL) && abs(evL.Nsum - N) < abs(best.Nsum - N))
    best = evL;
end

for it = 1:itmax
    slA = (slS + slL) / 2;
    evA = best_phase_eval(lab, mins, aves, maxs, slA, phases, N);
    if isempty(best) || abs(evA.Nsum - N) < abs(best.Nsum - N)
        best = evA;
    end
    if evA.Nsum == N
        best = evA;
        break;
    end
    if evA.Nsum < N
        slL = slA;
    else
        slS = slA;
    end
end

centers_sel = best.centers;
sl_best = best.sl;
phase_used = best.phase;
startv = best.startv;
nv = best.nv;

if verbose
    fprintf('CIC-JIST: sl=%.4f phase=%s Nnec=%d Nh=%d Nsum=%d -> N=%d\n', ...
        best.sl, best.phase, best.Nnec, best.Nh, best.Nsum, N);
end

end

function ev = best_phase_eval(lab, mins, aves, maxs, sl, phases, N)
ev = [];
for i = 1:numel(phases)
    e = eval_sl(lab, mins, aves, maxs, sl, phases{i});
    if isempty(ev)
        ev = e;
    else
        if abs(e.Nsum - N) < abs(ev.Nsum - N)
            ev = e;
        end
    end
end
end

function ev = eval_sl(lab, mins, aves, maxs, sl, phase)
[centers, startv, nv] = make_centers(mins, aves, maxs, sl, phase);
idxL = round((lab(:,1) - startv(1)) / sl) + 1;
idxA = round((lab(:,2) - startv(2)) / sl) + 1;
idxB = round((lab(:,3) - startv(3)) / sl) + 1;
valid = idxL>=1 & idxL<=nv(1) & idxA>=1 & idxA<=nv(2) & idxB>=1 & idxB<=nv(3);
occ = false(nv);
lin = sub2ind(nv, idxL(valid), idxA(valid), idxB(valid));
occ(lin) = true;
holes = internal_holes(~occ);
Nnec = nnz(occ);
Nh = nnz(holes);
centers_sel = centers(occ | holes, :);
ev = struct('Nnec', Nnec, 'Nh', Nh, 'Nsum', Nnec+Nh, ...
    'sl', sl, 'phase', phase, 'centers', centers_sel, ...
    'startv', startv, 'nv', nv);
end

function [centers, startv, nv] = make_centers(mins, aves, maxs, sl, phase)
startv = zeros(1,3);
nv = zeros(1,3);
centers1 = cell(1,3);
for i = 1:3
    if strcmpi(phase,'I')
        kmin = ceil((mins(i) - aves(i)) / sl);
        kmax = floor((maxs(i) - aves(i)) / sl);
        c = aves(i) + (kmin:kmax) * sl;
        if c(1) - mins(i) >= sl/2, c = [c(1)-sl, c]; end
        if maxs(i) - c(end) >= sl/2, c = [c, c(end)+sl]; end
    else
        start = aves(i) - sl/2;
        kmin = ceil((mins(i) - start) / sl);
        kmax = floor((maxs(i) - start) / sl);
        c = start + (kmin:kmax) * sl;
        if c(1) - mins(i) >= sl/2, c = [c(1)-sl, c]; end
        if maxs(i) - c(end) >= sl/2, c = [c, c(end)+sl]; end
    end
    centers1{i} = c(:);
    startv(i) = centers1{i}(1);
    nv(i) = numel(centers1{i});
end
[L,A,B] = ndgrid(centers1{1}, centers1{2}, centers1{3});
centers = [L(:), A(:), B(:)];
end

function holes_mask = internal_holes(empt)
sz = size(empt);
ext = false(sz);
q = java.util.ArrayDeque();
for i = 1:sz(1)
    for j = 1:sz(2)
        for k = 1:sz(3)
            if ~(i==1 || j==1 || k==1 || i==sz(1) || j==sz(2) || k==sz(3))
                continue;
            end
            if empt(i,j,k)
                ext(i,j,k) = true;
                q.add([i j k]);
            end
        end
    end
end
nbr = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
while ~q.isEmpty()
    v = q.remove();
    i = v(1); j = v(2); k = v(3);
    for t = 1:6
        ii = i + nbr(t,1);
        jj = j + nbr(t,2);
        kk = k + nbr(t,3);
        if ii<1 || jj<1 || kk<1 || ii>sz(1) || jj>sz(2) || kk>sz(3)
            continue;
        end
        if empt(ii,jj,kk) && ~ext(ii,jj,kk)
            ext(ii,jj,kk) = true;
            q.add([ii jj kk]);
        end
    end
end
holes_mask = empt & ~ext;
end

function [lin_idx, valid_idx] = map_samples_to_grid(lab, startv, sl, nv)
idxL = round((lab(:,1) - startv(1)) / sl) + 1;
idxA = round((lab(:,2) - startv(2)) / sl) + 1;
idxB = round((lab(:,3) - startv(3)) / sl) + 1;
valid = idxL>=1 & idxL<=nv(1) & idxA>=1 & idxA<=nv(2) & idxB>=1 & idxB<=nv(3);
valid_idx = find(valid);
lin_idx = sub2ind(nv, idxL(valid), idxA(valid), idxB(valid));
end
