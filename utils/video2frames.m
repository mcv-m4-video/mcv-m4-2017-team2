function video2frames(videoname, dirOut)


    addpath('../utils');
    
    video = VideoReader(videoname);

    t = 0;
    while hasFrame(video)
        t = t + 1;
        frame = readFrame(video);
        filenumber = sprintf('%06d', t);
        filename = strcat(dirOut, 'in', filenumber, '.jpg');
        imwrite(frame, filename)
    end

end