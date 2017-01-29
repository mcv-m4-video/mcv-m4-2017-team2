function grid_search

addpath('../datasets');
addpath('../datasets/KITTI_devkit');
addpath('../utils');
addpath('../week1');
%Choose sequence:
seq_id = 157;
%Initialize variables
frame_size = min(size(imread('../datasets/KITTI_devkit/data_stereo_flow/training/image_0/000045_10.png')));
block_size = zeros(1,50); 
search_area = zeros(1,50);
msen = zeros(1,50);
pepn = zeros(1,50);

for i=1:50
    block_size(i) = 2*randi([5, round(frame_size/20)]);
    search_area(i) = 2*randi([1, round(frame_size/20)]);
    
    [msen(i), pepn(i)]= task1_1(seq_id,block_size(i), search_area(i));
end

parameters = [block_size; search_area];
scores_conj = msen .* pepn;

if sum(scores_conj == min(scores_conj))>1
    index_minima = find(scores_conj == min(scores_conj),'first');
else
    index_minima = find(scores_conj == min(scores_conj));
end 

best_case_bs = parameters(1,index_minima);
best_case_sa = parameters(2,index_minima);

fprintf('\t\tWEEK 4 TASK 1.1 GRID SEARCH BEST RESULTS\n');
fprintf('Sequence\t\tBlock Size\t\tSearch Area\t\tMSEN\t\tPEPN\n');
fprintf('--------------------------------------------------\n');
fprintf(['Seq ',num2str(seq_id),'\t\t', num2str(best_case_bs),'\t\t', num2str(best_case_sa),'\t\t', num2str(msen(index_minima)), '\t\t', num2str(pepn(index_minima)*100),'\n']);

end