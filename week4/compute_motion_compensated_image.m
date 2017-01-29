function compute_motion_compensated_image(I_old, rprime1, rprime2, nrow, ncol)

    % Motion compensated image:
    I_comp = zeros(nrow, ncol);
    for i = 1:nrow
        for j = 1:ncol
            if(rprime1(i,j) > nrow || rprime1(i,j) <= 0 ||...
                    rprime2(i,j) > ncol || rprime2(i,j) <= 0)
                I_comp(i,j) = 0;
            else
                r1low = floor(rprime1(i,j));
                r1high = ceil(rprime1(i,j));
                r2low = floor(rprime2(i,j));
                r2high = ceil(rprime2(i,j));
                if(r1high - r1low < 0.5)
                    r1high = r1low + 1;
                end
                if(r2high - r2low < 0.5)
                    r2high = r2low + 1;
                end
                % low low
                peso_low_low = sqrt((r1low-rprime1(i,j))^2 + (r2low-rprime2(i,j))^2);
                if(r1low <= 0 || r2low <= 0)
                    pixel_low_low = 0;
                else
                    pixel_low_low = I_old(r1low, r2low);
                end
                % low high
                peso_low_high = sqrt((r1low-rprime1(i,j))^2 + (r2high-rprime2(i,j))^2);
                if(r1low <= 0 || r2high > ncol)
                    pixel_low_high = 0;
                else
                    pixel_low_high = I_old(r1low, r2high);
                end
                % high low
                peso_high_low = sqrt((r1high-rprime1(i,j))^2 + (r2low-rprime2(i,j))^2);
                if(r1high > nrow || r2low <= 0)
                    pixel_high_low = 0;
                else
                    pixel_high_low = I_old(r1high, r2low);
                end
                % high high
                peso_high_high = sqrt((r1high-rprime1(i,j))^2 + (r2high-rprime2(i,j))^2);
                if(r1high > nrow || r2high > ncol)
                    pixel_high_high = 0;
                else
                    pixel_high_high = I_old(r1high, r2high);
                end
                % Ponderación:
                suma_pesos = peso_low_low + peso_low_high + peso_high_low + peso_low_low;
                I_comp(i,j) = (peso_low_low * pixel_low_low + peso_low_high * pixel_low_high + ...
                    peso_high_low * pixel_high_low + peso_high_high * pixel_high_high) / suma_pesos;
            end
        end
    end


return

end