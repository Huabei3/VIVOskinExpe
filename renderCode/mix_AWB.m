function [out_origin,out_gauss,out_bull,average_reference_white,cct_gauss,cct_origin]=mix_AWB(face,downsize,sigma,mode,spq,w,option)
%% 用于将图片分块处理进行AWB，并返回白点分布矩阵whitepoint

    white65=[95.04,100,108.89];
    grid_img=divide_img(face,downsize);
    rgbnew=cell(size(grid_img));
    rgbnew2=cell(size(grid_img));
    bull=cell(size(grid_img));
    
    predict_white=cell(size(grid_img));
    ccT=cell(size(grid_img));
    cct_gauss=cell(size(grid_img));
    duv=cell(size(grid_img));
    center0=cell(size(grid_img));
    center1=cell(size(grid_img));
    
    for i = 1:downsize+1
        for j=1:downsize+1
        [predict_white{i,j},rgbnew{i,j},t,d,bull{i,j},~,~,~,~,centert0,centert1]=memoryAWB(grid_img{i,j},mode,spq,w,option);
        ccT{i,j}=t;
        duv{i,j}=d;
        center0{i,j}=centert0;
        center1{i,j}=centert1;
        end
    end
    
    average_reference_white=predict_white;
    whitex=zeros(downsize+1);
    for k=1:3
        for i = 1:downsize+1
            for j=1:downsize+1
                whitex(i,j)=predict_white{i,j}(k);
                % sigma控制滤波器的标准差，可以调整以改变平滑程度
            end
        end
        new_whitex = imgaussfilt(whitex, sigma);
        for i = 1:downsize+1
            for j=1:downsize+1
                average_reference_white{i,j}(k)=new_whitex(i,j);
            end
        end
    end
    
    for i = 1:downsize+1
        for j=1:downsize+1
        [~,~,~,rgbnew2{i,j}]=imgcat(grid_img{i,j},average_reference_white{i,j},white65,white65,w,option);
        cct_gauss{i,j}=cct(average_reference_white{i,j});
        end
    end
    
    cct_origin=ccT;
    out_origin=zeros(size(face));

    
    [height,width,~]=size(face);
    [grid_height,grid_width,~]=size(rgbnew{1,1});
    for i=1:downsize+1
        for j=1:downsize+1
            
            start_row = (i-1) * grid_height + 1;
            end_row = i * grid_height;
            if end_row>height
                end_row=height;
            end 
            start_col = (j-1) * grid_width + 1;
            end_col = j * grid_width;
            if end_col > width
                end_col = width;
            end 
            out_origin(start_row:end_row, start_col:end_col, :)=rgbnew{i,j};
            out_gauss(start_row:end_row, start_col:end_col, :)=rgbnew2{i,j};
            out_bull(start_row:end_row, start_col:end_col, :)=bull{i,j};
        end
    end
%%   绘制3d分布图
    subplot(2,2,1);imshow(out_origin)
    title('分块白平衡')
    subplot(2,2,2);imshow(out_gauss)
    title('分块白平衡+高斯平滑')
    
    [m,n]=size(cct_gauss);
    [x, y] = meshgrid(1:m, 1:n);
    % 使用 surf 函数绘制三维曲面图
    
    subplot(2,2,3);surf(x, y, cell2mat(cct_origin));
    % 添加标题和标签
    title('CCT分布曲面图，未处理');
    xlabel('X ');
    ylabel('Y ');
    zlabel('CCT');
    
    subplot(2,2,4);surf(x, y, cell2mat(cct_gauss));
    title('CCT分布曲面图,高斯平滑后');
    xlabel('X ');
    ylabel('Y ');
    zlabel('CCT');
%     
%     figure;imshow([face out_origin out_gauss])
end