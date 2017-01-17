function write_st_gm(videoname)

addpath('../utils');

% Select T1:
if (strcmp(videoname, 'highway'))
    T1 = 1050;
elseif (strcmp(videoname, 'fall'))
    T1 = 1460;
elseif (strcmp(videoname, 'traffic'))
    T1 = 950;
else
    error('videoname not recognized.')
end

% Compute detection with Stauffer and Grimson:
sequence = detection_st_gm(videoname);

% Directory to write:
dirResults = strcat('./st_gm_sequences/', videoname, '/');

write_sequence(sequence, dirResults, T1)

end