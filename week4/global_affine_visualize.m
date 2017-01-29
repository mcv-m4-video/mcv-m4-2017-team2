function global_affine_visualize(I_old, p, step)

    nrow = size(I_old, 1);
    ncol = size(I_old, 2);

    % Positions:
    [r2, r1] = meshgrid(1:step:ncol, 1:step:nrow);

    % Displacement:
    [D1, D2] = affine_transform(r1, r2, p);

    % Visualize:
    figure()
    imshow(I_old)
    hold on
    quiver(r2, r1, D2, D1)
return

end
