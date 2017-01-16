function filled_detect = filling(detection)
    SE= strel('disk',30,60);
    filled_detect= step(SE, detection);
end