function p = gradient_descent_global_affine4(I_curr, I_old, p0, dt, maxiter, delta)

fprintf('Computing global affine model by gradient descent...\n')

pold = p0; % Introduce the initial condition.

iterate = 1; % Flag to decide when to stop iterating.
iter = 0; % Number of iterations counter.

while(iterate)
    iter = iter + 1;
    
    % Compute gradient of error measure with parameters p:
    gradient = compute_gradient_error(I_curr, I_old, pold);
    
    % Update p:
    p = pold - dt * gradient;
    
    if(~rem(iter, 1000))
        error = compute_error(I_curr, I_old, p);
        fprintf('Iteration %i.\n', iter)
        fprintf('p: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', p)
        fprintf('delta = %10.6f\n', norm(p - pold) / sqrt(6))
        fprintf('Error: %10.6f\n\n', error)
    end
    
    
    % Test de parada:
    if(iter == maxiter) % Número máximo de iteraciones.
        fprintf('Reached maximum number of iterations.\n')
        iterate = 0;
    elseif(norm(p - pold) / sqrt(6) < delta) % Iterantes consecutivos muy similares.
        fprintf('Stop test satisfied.\n')
        iterate = 0;
    end
    
    % Load new p as old iterator:
    pold = p;
end

% Compute error with final parameters:
fprintf('Parameters found: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', p)
fprintf('Error: %10.6f\n\n', error)

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gradient = compute_gradient_error(I_curr, I_old, p)
    
    p1 = p;
    p2 = p;
    p3 = p;
    p4 = p;
    p5 = p;
    p6 = p;

    epsilon = 0.05;

    p1(1) = p(1) + epsilon;
    p2(2) = p(2) + epsilon;
    p3(3) = p(3) + epsilon;
    p4(4) = p(4) + epsilon;
    p5(5) = p(5) + epsilon;
    p6(6) = p(6) + epsilon;

    error0 = compute_error(I_curr, I_old, p);
    error1 = compute_error(I_curr, I_old, p1);
    error2 = compute_error(I_curr, I_old, p2);
    error3 = compute_error(I_curr, I_old, p3);
    error4 = compute_error(I_curr, I_old, p4);
    error5 = compute_error(I_curr, I_old, p5);
    error6 = compute_error(I_curr, I_old, p6);

    gradient = zeros(6,1);
    gradient(1) = (error1 - error0) / epsilon;
    gradient(2) = (error2 - error0) / epsilon;
    gradient(3) = (error3 - error0) / epsilon;
    gradient(4) = (error4 - error0) / epsilon;
    gradient(5) = (error5 - error0) / epsilon;
    gradient(6) = (error6 - error0) / epsilon;

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error = compute_error(I_curr, I_old, p)

    nrow = size(I_curr, 1);
    ncol = size(I_curr, 2);

    % Positions:
    [r2, r1] = meshgrid(1:ncol, 1:nrow);

    % Displacement:
    [D1, D2] = affine_transform(r1, r2, p);
    
    % New positions:
    rprime1 = r1 - D1;
    rprime2 = r2 - D2;
    
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
    
    % Displaced frame difference:
    dfd = I_curr - I_comp;
    
    % Error:
    error = sum(sum(dfd.^2)) / (nrow * ncol);
return

end






