function task3

close all

addpath('../utils');

videonames = {'highway','traffic','fall'};
for v=1:numel(videonames)
    
    videoname = videonames{v};
    %Best Sequence
    % Compute detection with Stauffer and Grimson:
    dir_seq = strcat('task2_results/',videoname,'/');
    sequence = read_sequence(dir_seq);
       
    sizes = 15;
    elements = {'square','diamond','disk'}; 
    
    best_element = '';
    best_morpho_operetor = '';
    best_element_size = 0;
    best_auc = 0;
    for e=1:numel(elements)
        str_element = elements{e};
        for Size=3:sizes
            se = strel(str_element,Size);
            fprintf(strcat('calculando strel:',str_element));
            fprintf(' size %f\n',Size);
            %test opening
            auc = apply_morpho(sequence, videoname, se, 'opening');
            if(auc > best_auc)
                best_auc = auc;
                best_element = str_element;
                best_morpho_operetor = 'opening';
                best_element_size = Size;
            end
            %test opening
            auc = apply_morpho(sequence, videoname, se, 'closing');
            if(auc > best_auc)
                best_auc = auc;
                best_element = str_element;
                best_morpho_operetor = 'closing';
                best_element_size = Size;
                
            end
            %test opening
            auc = apply_morpho(sequence, videoname, se, 'both');
            if(auc > best_auc)
                best_auc = auc;
                best_element = str_element;
                best_morpho_operetor = 'both';
                best_element_size = Size;
                
            end
        end
    end
    % Evaluate detection:
    fprintf('Best auc: %f\n', best_auc)
    sprintf('element: %s\n', best_element)
    fprintf('size: %f\n', best_element_size)
    sprintf('morpho_operator: %s\n', best_morpho_operetor)
    
    result_file = strcat('best_morpho_',videoname,'.mat');
    save(result_file,'best_auc','best_element','best_element_size','best_morpho_operetor');
end
end

function AUC = apply_morpho(sequence, videoname, se, morpho_operator)

seq_size = size(sequence,3);
for i=1:seq_size
    if(strcmp(morpho_operator,'opening'))
        sequence(:,:,i) = imopen(sequence(:,:,i),se);
    elseif(strcmp(morpho_operator,'closing'))
        sequence(:,:,i) = imclose(sequence(:,:,i),se);
    elseif(strcmp(morpho_operator,'both'))
        sequence(:,:,i) = imopen(sequence(:,:,i),se);
        sequence(:,:,i) = imclose(sequence(:,:,i),se);
    end
end
[precision, recall, F1, AUC] = test_sequence_2val(sequence, videoname, false, false, '',true);
%     fprintf('Precision: %f\n', precision)
%     fprintf('Recall: %f\n', recall)
%     fprintf('F1: %f\n', F1)
end