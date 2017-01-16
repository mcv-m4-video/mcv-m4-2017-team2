function sequence_filled = fill_holes(sequence_in, connectivity)

% connectivity can be either 4 or 8.

nframes = size(sequence_in, 3);
sequence_filled = zeros(size(sequence_in));

for i = 1:nframes
    sequence_filled(:,:,i) = imfill(sequence_in(:,:,i), connectivity);
end

end