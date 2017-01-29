function err = compute_transform(I_old, I_curr, p)

    nrow = size(I_old, 1);
    ncol = size(I_old, 2);

    % Positions:
    [r2, r1] = meshgrid(1:ncol, 1:nrow);

    % Displacement:
    [D1, D2] = affine_transform2(r1, r2, p);
    
    % Visualize:
%     step = 20;
%     global_affine_visualize2(I_old, p, step)

    r1prime = r1 + D1;
    r2prime = r2 + D2;

    r1low = max(sum(~(r1prime>=1))) + 1;
    r1high = min(sum(r1prime<=nrow));
    r2low = max(sum(~(r2prime>=1), 2)) + 1;
    r2high = min(sum(r2prime<=ncol, 2));

%     subI_old = I_old(r1low:r1high, r2low:r2high);
    subD1 = D1(r1low:r1high, r2low:r2high);
    subD2 = D2(r1low:r1high, r2low:r2high);
    
    subr1 = r1(r1low:r1high, r2low:r2high);
    subr2 = r2(r1low:r1high, r2low:r2high);
    
    subr1prime = subr1 + subD1;
    subr2prime = subr2 + subD2;
    
    if(sum(sum(subr1prime<=0)) + ...
            sum(sum(subr1prime>nrow)) + ...
            sum(sum(subr2prime<=0)) + ...
            sum(sum(subr2prime>ncol)))
        error('We are going out of the image...')
    end
    
    % Motion compensated image:
    dfd = zeros(nrow, ncol);
    for i = r1low:r1high
        for j = r2low:r2high
            iprime = i+D1(i,j);
            jprime = j+D2(i,j);
            
%             I_curr_int = interpolate_I_curr(I_curr, iprime, jprime, nrow, ncol);
            
            r1low_int = floor(iprime);
            r1high_int = ceil(iprime);
            r2low_int = floor(jprime);
            r2high_int = ceil(jprime);
            if(r1high_int - r1low_int < 0.5)
                if(r1high_int == nrow)
                    r1low_int = r1high_int - 1;
                else
                    r1high_int = r1low_int + 1;
                end
            end
            if(r2high_int - r2low_int < 0.5)
                if(r2high_int == ncol)
                    r2low_int = r2high_int - 1;
                else
                    r2high_int = r2low_int + 1;
                end
            end
            
            % low low
            peso_low_low = sqrt((r1low_int-iprime)^2 + (r2low_int-jprime)^2);
            pixel_low_low = I_curr(r1low_int, r2low_int);
            % low high
            peso_low_high = sqrt((r1low_int-iprime)^2 + (r2high_int-jprime)^2);
            pixel_low_high = I_curr(r1low_int, r2high_int);
            % high low
            peso_high_low = sqrt((r1high_int-iprime)^2 + (r2low_int-jprime)^2);
            pixel_high_low = I_curr(r1high_int, r2low_int);
            % high high
            peso_high_high = sqrt((r1high_int-iprime)^2 + (r2high_int-jprime)^2);
            pixel_high_high = I_curr(r1high_int, r2high_int);
            % Ponderación:
            suma_pesos = peso_low_low + peso_low_high + peso_high_low + peso_low_low;
            I_curr_int = (peso_low_low * pixel_low_low + peso_low_high * pixel_low_high + ...
                peso_high_low * pixel_high_low + peso_high_high * pixel_high_high) / suma_pesos;
            
            dfd(i,j) = I_curr_int - I_old(i,j);
        end
    end
    
%     dfd_abs = abs(dfd);
%     imshow(dfd_abs, [0, max(max(dfd_abs))])
    
    nrowsub = length(r1low:r1high);
    ncolsub = length(r2low:r2high);
    err = sum(sum(dfd.^2)) / (nrowsub * ncolsub);
    
return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = interpolate_I_curr(I_curr, iprime, jprime, nrow, ncol)

    r1low_int = floor(iprime);
    r1high_int = ceil(iprime);
    r2low_int = floor(jprime);
    r2high_int = ceil(jprime);
    if(r1high_int - r1low_int < 0.5)
        if(r1high_int == nrow)
            r1low_int = r1high_int - 1;
        else
            r1high_int = r1low_int + 1;
        end
    end
    if(r2high_int - r2low_int < 0.5)
        if(r2high_int == ncol)
            r2low_int = r2high_int - 1;
        else
            r2high_int = r2low_int + 1;
        end
    end
    % low low
    peso_low_low = sqrt((r1low_int-iprime)^2 + (r2low_int-jprime)^2);
    pixel_low_low = I_curr(r1low_int, r2low_int);
    % low high
    peso_low_high = sqrt((r1low_int-iprime)^2 + (r2high_int-jprime)^2);
    pixel_low_high = I_curr(r1low_int, r2high_int);
    % high low
    peso_high_low = sqrt((r1high_int-iprime)^2 + (r2low_int-jprime)^2);
    pixel_high_low = I_curr(r1high_int, r2low_int);
    % high high
    peso_high_high = sqrt((r1high_int-iprime)^2 + (r2high_int-jprime)^2);
    pixel_high_high = I_curr(r1high_int, r2high_int);
    % Ponderación:
    suma_pesos = peso_low_low + peso_low_high + peso_high_low + peso_low_low;
    res = (peso_low_low * pixel_low_low + peso_low_high * pixel_low_high + ...
        peso_high_low * pixel_high_low + peso_high_high * pixel_high_high) / suma_pesos;

return

end
