function sequence = read_sequence(dir)
results_files = list_files(dir);
files_number = size(results_files,1);
for i=1:files_number
    name = results_files(i).name;
    sequence(:,:,i) = imread(strcat(dir,name));
end