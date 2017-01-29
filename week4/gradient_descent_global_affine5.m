function p = gradient_descent_global_affine5(I_curr, I_old, p0, dt, maxiter, delta)

fprintf('Computing global affine model by gradient descent...\n')

pold = p0; % Introduce the initial condition.

iterate = 1; % Flag to decide when to stop iterating.
iter = 0; % Number of iterations counter.

figure()

while(iterate)
    iter = iter + 1;
    
    % Compute gradient of error measure with parameters p:
    gradient = compute_gradient_error(I_curr, I_old, pold);
    
    % Update p:
    p = pold - dt * gradient;
    
%     if(~rem(iter, 1000))
        error = compute_transform(I_old, I_curr, p);
        fprintf('Iteration %i.\n', iter)
        fprintf('p: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', p)
        fprintf('delta = %10.6f\n', norm(p - pold) / sqrt(6))
        fprintf('Error: %10.6f\n\n', error)
        % Visualize:
        step = 20;
%         close all
        global_affine_visualize2(I_old, p, step)
%     end
    
    
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
    
    error0 = compute_transform(I_old, I_curr, p);
    error1 = compute_transform(I_old, I_curr, p1);
    error2 = compute_transform(I_old, I_curr, p2);
    error3 = compute_transform(I_old, I_curr, p3);
    error4 = compute_transform(I_old, I_curr, p4);
    error5 = compute_transform(I_old, I_curr, p5);
    error6 = compute_transform(I_old, I_curr, p6);

    gradient = zeros(6,1);
    gradient(1) = (error1 - error0) / epsilon;
    gradient(2) = (error2 - error0) / epsilon;
    gradient(3) = (error3 - error0) / epsilon;
    gradient(4) = (error4 - error0) / epsilon;
    gradient(5) = (error5 - error0) / epsilon;
    gradient(6) = (error6 - error0) / epsilon;

return

end








