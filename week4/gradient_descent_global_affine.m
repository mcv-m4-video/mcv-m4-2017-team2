function p = gradient_descent_global_affine(I_curr, I_old, p0, dt, maxiter, delta)

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
    
    
    error = compute_error(I_curr, I_old, p);
    fprintf('Iteration %i.\n', iter)
    fprintf('delta = %8.4f\n', norm(p - pold) / sqrt(6))
    fprintf('Error: %8.4f\n\n', error)
    
    
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
error = compute_error(I_curr, I_old, p);
fprintf('Parameters found: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', p)
fprintf('Error: %8.4f\n\n', error)

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function error = compute_error(I_curr, I_old, p)

    r = zeros(2,1);
    error = 0;
    for i = 1:size(I_old, 1)
        for j = 1:size(I_old, 2)
            r(1) = i;
            r(2) = j;
            dfd = compute_dfd(I_curr, I_old, r, p);
            error = error + dfd^2;
        end
    end
    error = error / (size(I_curr,1) * size(I_curr,2));

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gradient = compute_gradient_error(I_curr, I_old, p)

    r = zeros(2,1);
    gradient = zeros(6,1);
    for i = 1:size(I_old, 1)
        for j = 1:size(I_old, 2)
            r(1) = i;
            r(2) = j;
            dfd = compute_dfd(I_curr, I_old, r, p);
            dfd_grad = compute_gradient_dfd(I_old, r, p);
            gradient = gradient + 2 * dfd * dfd_grad;
        end
    end
    gradient = gradient / (size(I_curr,1) * size(I_curr,2));

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dfd = compute_dfd(I_curr, I_old, r, p)

    D = affine_transform(r, p);
    rprime = get_rprime(r, D, size(I_old));
    dfd = I_curr(r(1), r(2)) - I_old(rprime(1), rprime(2));

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dfd_grad = compute_gradient_dfd(I_old, r, p)
    
    % Gradients of motion compensated image (just at position r):
    [I_comp_grad_i, I_comp_grad_j] = I_comp_gradients(I_old, r, p);

    dfd_grad = zeros(6,1);
    dfd_grad(1) = I_comp_grad_i * r(1);
    dfd_grad(2) = I_comp_grad_i * r(2);
    dfd_grad(3) = I_comp_grad_j * r(1);
    dfd_grad(4) = I_comp_grad_j * r(2);
    dfd_grad(5) = I_comp_grad_i;
    dfd_grad(6) = I_comp_grad_j;

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function D = affine_transform(r, p)

    D = zeros(2,1);
    D(1) = round((1 - p(1)) * r(1) - p(2) * r(2) - p(5));
    D(2) = round(-p(3) * r(1) + (1 - p(4)) * r(2) - p(6));

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rprime = get_rprime(r, D, size_I_old)

rprime = r - D;

% Fit to the size of the image:
rprime(1) = min(rprime(1), size_I_old(1));
rprime(1) = max(rprime(1), 1);
rprime(2) = min(rprime(2), size_I_old(2));
rprime(2) = max(rprime(2), 1);

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I_comp_grad_i, I_comp_grad_j] = I_comp_gradients(I_old, r, p)

    % Check if we are in the right or down margins of the image:
    if(r(1) == size(I_old,1))
        top_down = 1;
    else
        top_down = 0;
    end
    if(r(2) == size(I_old,2))
        top_right = 1;
    else
        top_right = 0;
    end

    % Displacement (just at position r):
    D = affine_transform(r, p);

    % Motion compensated image (at position r):
    rprime = get_rprime(r, D, size(I_old));
    I_comp_r = I_old(rprime(1), rprime(2));

    % Gradients of motion compensated image(just at position r):
    if(top_down)
        Dnew = D;
        Dnew(1) = Dnew(1) + 1;
        rprime = get_rprime(r, Dnew, size(I_old));
        I_comp_up = I_old(rprime(1), rprime(2));
        I_comp_grad_i = I_comp_r - I_comp_up;
    else
        Dnew = D;
        Dnew(1) = Dnew(1) - 1;
        rprime = get_rprime(r, Dnew, size(I_old));
        I_comp_down = I_old(rprime(1), rprime(2));
        I_comp_grad_i = I_comp_down - I_comp_r;
    end
    if(top_right)
        Dnew = D;
        Dnew(2) = Dnew(2) + 1;
        rprime = get_rprime(r, Dnew, size(I_old));
        I_comp_left = I_old(rprime(1), rprime(2));
        I_comp_grad_j = I_comp_r - I_comp_left;
    else
        Dnew = D;
        Dnew(2) = Dnew(2) - 1;
        rprime = get_rprime(r, Dnew, size(I_old));
        I_comp_right = I_old(rprime(1), rprime(2));
        I_comp_grad_j = I_comp_right - I_comp_r;
    end

return

end


