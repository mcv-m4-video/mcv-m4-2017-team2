function visualize_optical_flow(image, vx, vy, step)

    [nrow, ncol] = size(image);

    [x, y] = meshgrid(1:step:ncol, 1:step:nrow);
    
    vx_short = vx(1:step:nrow,1:step:ncol);
    vy_short = vy(1:step:nrow,1:step:ncol);
    
    mean(vx(:))
    mean(vy(:))

    figure()
    imshow(image)
    hold on
    quiver(x, y, vx_short, vy_short, 0)
%     quiver(x, y, vx_short, vy_short)


return

end