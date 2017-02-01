%This function develops a grid search through block size and search area parameters
%to obtain the best optical flow calculation performance with this naive
%approach.
%Input parameters are:
%   'seq_id'  =   the sequence which will be tested, between KITTI's
%                 dataset sequences 45 and 157.
%   
%   'iter_bs' =   amount of block sizes to test.
%   'iter_sa' =   amount of search area sizes to test.
%   NOTE: block sizes are tested starting from 20 pixels and jumping by 10,
%   in the case of search area, it starts at 2, and doubles each iteration.
%   It's needed to update the desired block sizes in the 'legend' item from
%   the graph in order to keep consistency with the desired output.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function grid_search

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');
%Choose sequence:
seq_id = 45;
iter_bs = 5;
iter_sa = 15;
%Initialize variables
frame_size = min(size(imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_10.png')));
block_size = zeros(1,iter_bs); 
search_area = zeros(1,iter_sa);
msen = zeros(iter_bs,iter_sa);
pepn = zeros(iter_bs,iter_sa);

for i=1:iter_bs
    block_size(i) = 20+i*10;
    for n=1:iter_sa
        search_area(n) = n*2;
        [msen(i,n), pepn(i,n)]= task1_1(seq_id, block_size(i), search_area(n));
    end
end

[index_minima_i,index_minima_j] = find(pepn == min(min(pepn)));

best_case_bs = block_size(index_minima_i);
best_case_sa = search_area(index_minima_j);

fprintf('\t\tWEEK 4 TASK 1.1 GRID SEARCH BEST RESULTS\n');
fprintf('Sequence\t\tBlock Size\t\tSearch Area\t\tMSEN\t\tPEPN\n');
fprintf('--------------------------------------------------\n');
fprintf(['Seq ',num2str(seq_id),'\tBest Block size:\t', num2str(best_case_bs),'\tBest Search area:\t', num2str(best_case_sa),'\tMSEN:\t', num2str(msen(index_minima_i,index_minima_j)), '\tPEPN:\t', num2str(pepn(index_minima_i,index_minima_j)*100),'\n']);

%SAVE DATA
filename = strcat('seq_',num2str(seq_id),'_results.mat');
save(filename,'msen','pepn' );

%GRAPH SWEEP
figure()
plot(search_area, pepn);
title(strcat({'PEPN vs search area for seq '},num2str(seq_id)));
xlabel('Search Area');
ylabel('PEPN');
legend('Block size: 30','Block size: 40','Block size: 50', 'Block size: 60','Block size: 70');
hold on;
plot(search_area(index_minima_j),pepn(index_minima_i,index_minima_j),'o');
text(search_area(index_minima_j),(pepn(index_minima_i,index_minima_j)-0.01),num2str(pepn(index_minima_i,index_minima_j)),'HorizontalAlignment','left');

end