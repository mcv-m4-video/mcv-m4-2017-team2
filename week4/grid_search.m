function grid_search

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');
%Choose sequence:
seq_id = 157;
iter_bs = 6;
iter_sa = 10;
%Initialize variables
frame_size = min(size(imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_10.png')));
block_size = zeros(1,iter_bs); 
search_area = zeros(1,iter_sa);
msen = zeros(iter_bs,iter_sa);
pepn = zeros(iter_bs,iter_sa);

for i=1:iter_bs
    block_size(i) = 10 + i*10;%2*randi([10, round(frame_size/20)]);
    for n=1:iter_sa
        search_area(n) = 5*n;%2*randi([5, round(frame_size/20)]);
        [msen(i,n), pepn(i,n)]= task1_1(seq_id, block_size(i), search_area(n));
    end
end

%parameters = [block_size; search_area];
scores_conj = msen .* pepn;

if sum(scores_conj == min(min(scores_conj)))>1
    [index_minima_i,index_minima_j] = find(scores_conj == min(min(scores_conj)),'first');
else
    [index_minima_i,index_minima_j] = find(scores_conj == min(min(scores_conj)));
end 

best_case_bs = block_size(index_minima_i);
best_case_sa = search_area(index_minima_j);

fprintf('\t\tWEEK 4 TASK 1.1 GRID SEARCH BEST RESULTS\n');
fprintf('Sequence\t\tBlock Size\t\tSearch Area\t\tMSEN\t\tPEPN\n');
fprintf('--------------------------------------------------\n');
fprintf(['Seq ',num2str(seq_id),'\tBest Block size:\t', num2str(best_case_bs),'\tBest Search area:\t', num2str(best_case_sa),'\tMSEN:\t', num2str(msen(index_minima_i,index_minima_j)), '\tPEPN:\t', num2str(pepn(index_minima_i,index_minima_j)*100),'\n']);

filename = strcat('seq_',num2str(seq_id),'_results.mat');
save(filename,'msen','pepn' );
%GRAPH SWEEP
%figure()
%plot(search_area, pepn);
end