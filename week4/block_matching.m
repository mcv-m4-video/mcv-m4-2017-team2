function [ x_movement, y_movement ] = block_matching( img1, img2, block_size, search_area)
%BLOCK_MATCHING Summary of this function goes here
%   Detailed explanation goes here

x_movement = zeros(size(img2));
y_movement = zeros(size(img2));

[ni, nj] = size(img2);
for i = 1:block_size:ni
    for j = 1:block_size:nj
        min_error = inf; %initialize the min error with infinito
        
        %boundary constraints for the current_block
        if ( i+block_size-1 > ni ) || ( j+block_size-1 > nj )
            continue
        end
        % Save the current block in a variable
        current_block = img1(i:i+block_size-1, j:j+block_size-1);
        %calculate the boundary constraints for the area of search
        begin_search_area_x = max(1, i-search_area);
        end_search_area_x   = min(ni-block_size,i+block_size-1+search_area);
        begin_search_area_y = max(1, j-search_area);
        end_search_area_y   = min(nj-block_size,j+block_size-1+search_area);
        
        %search the current block in the past img
        for step_x = begin_search_area_x:1:end_search_area_x
            for step_y = begin_search_area_y:1:end_search_area_y
                fut_block = img2(step_x:step_x+block_size-1, step_y:step_y+block_size-1);
                %difference between the 2 blocks
                error = sum(sum((current_block-fut_block).^2));
                if error < min_error
                    min_error = error;
                    %save the movement in the same position of the current block
                    x_movement(i:i+block_size-1,j:j+block_size-1) = step_x-i;
                    y_movement(i:i+block_size-1,j:j+block_size-1) = step_y-j;
                end
            end
        end
    end
end

end

