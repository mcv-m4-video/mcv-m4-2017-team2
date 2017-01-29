function p = gradient_descent_global_affine2(I_curr, I_old, p0, dt, maxiter, delta)

fprintf('Computing global affine model by gradient descent...\n')

pold = p0; % Introduce the initial condition.

iterate = 1; % Flag to decide when to stop iterating.
iter = 0; % Number of iterations counter.

while(iterate)
    iter = iter + 1;
    
    % Compute gradient of error measure with parameters p:
    [gradient, error] = compute_gradient_error(I_curr, I_old, pold);
    
    % Update p:
    p = pold - dt * gradient;
    
    
    fprintf('Iteration %i.\n', iter)
    fprintf('p: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', p)
    fprintf('delta = %10.6f\n', norm(p - pold) / sqrt(6))
    fprintf('Error: %10.6f\n\n', error)
    
    
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
function [gradient, error] = compute_gradient_error(I_curr, I_old, p)

    nrow = size(I_curr, 1);
    ncol = size(I_curr, 2);

    % Positions:
    [r2, r1] = meshgrid(1:ncol, 1:nrow);

    % Displacement:
    [D1, D2] = affine_transform(r1, r2, p);
    
    % New positions:
    rprime1 = r1 - D1;
    rprime2 = r2 - D2;
    
    % Fit positions to size of image:
    rprime1 = min(rprime1, nrow);
    rprime1 = max(rprime1, 1);
    rprime2 = min(rprime2, ncol);
    rprime2 = max(rprime2, 1);
    
    % Motion compensated image:
    I_comp = zeros(nrow, ncol);
    for i = 1:nrow
        for j = 1:ncol
            I_comp(i,j) = I_old(rprime1(i,j), rprime2(i,j));
        end
    end
    
    % Gradients of compensated image:
    I_comp_gradi = zeros(nrow, ncol);
    I_comp_gradi(1:(nrow-1),:) = I_comp(2:nrow,:) - I_comp(1:(nrow-1),:);
    I_comp_gradj = zeros(nrow, ncol);
    I_comp_gradj(:,1:(ncol-1)) = I_comp(:,2:ncol) - I_comp(:,1:(ncol-1));
    
    % Displaced frame difference:
    dfd = I_curr - I_comp;
    
    % Error:
    error = sum(sum(dfd.^2)) / (nrow * ncol);
    
    % Gradient, with respect to p, of displaced frame difference:
    dfd_grad = compute_gradient_dfd(I_comp_gradi, I_comp_gradj, rprime1, rprime2, nrow, ncol);
    
    % Gradient of error (error = sum(dfd^2) / size(im))
    gradient = zeros(6, 1);
    gradient(1) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,1)));
    gradient(2) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,2)));
    gradient(3) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,3)));
    gradient(4) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,4)));
    gradient(5) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,5)));
    gradient(6) = 2 / (nrow * ncol) * sum(sum(dfd .* dfd_grad(:,:,6)));

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dfd_grad = compute_gradient_dfd(I_comp_gradi, I_comp_gradj, rprime1, rprime2, nrow, ncol)

    dfd_grad = zeros(nrow, ncol, 6);
    dfd_grad(:,:,1) = I_comp_gradi .* rprime1;
    dfd_grad(:,:,2) = I_comp_gradi .* rprime2;
    dfd_grad(:,:,3) = I_comp_gradj .* rprime1;
    dfd_grad(:,:,4) = I_comp_gradj .* rprime2;
    dfd_grad(:,:,5) = I_comp_gradi;
    dfd_grad(:,:,6) = I_comp_gradj;

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D1, D2] = affine_transform(r1, r2, p)

    D1 = round((1 - p(1)) * r1 - p(2) * r2 - p(5));
    D2 = round(-p(3) * r1 + (1 - p(4)) * r2 - p(6));

return

end



