function p = translation_gradient_descent(I_curr, I_old, p0, dt, maxiter, delta, mask)

fprintf('Computing global affine model by gradient descent...\n')

pold = p0; % Introduce the initial condition.

iterate = 1; % Flag to decide when to stop iterating.
iter = 0; % Number of iterations counter.

while(iterate)
    iter = iter + 1;
    
    % Compute gradient of error measure with parameters p:
    gradient = compute_gradient_error(I_curr, I_old, pold, mask);
    
    % Update p:
    p = pold - dt * gradient;
    
    if(~rem(iter, 100))
        err = translation_error(I_curr, I_old, p, mask);
        fprintf('Iteration %i.\n', iter)
        fprintf('p: %8.4f %8.4f\n', p)
        fprintf('delta = %10.6f\n', norm(p - pold) / sqrt(2))
        fprintf('Error: %10.6f\n\n', err)
    end
    
    
    % Test de parada:
    if(iter == maxiter) % Número máximo de iteraciones.
        fprintf('Reached maximum number of iterations.\n')
        iterate = 0;
    elseif(norm(p - pold) / sqrt(2) < delta) % Iterantes consecutivos muy similares.
        fprintf('Stop test satisfied.\n')
        iterate = 0;
    end
    
    % Load new p as old iterator:
    pold = p;
end

% Compute error with final parameters:
err = translation_error(I_curr, I_old, p, mask);
fprintf('Parameters found: %8.4f %8.4f\n', p)
fprintf('Error: %10.6f\n\n', err)

return

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gradient = compute_gradient_error(I_curr, I_old, p, mask)
    
    p1 = p;
    p2 = p;

%     epsilon = 0.005;
%     epsilon = 0.05;
    epsilon = 0.5;

    p1(1) = p(1) + epsilon;
    p2(2) = p(2) + epsilon;

    error0 = translation_error(I_curr, I_old, p, mask);
    error1 = translation_error(I_curr, I_old, p1, mask);
    error2 = translation_error(I_curr, I_old, p2, mask);

    gradient = zeros(2,1);
    gradient(1) = (error1 - error0) / epsilon;
    gradient(2) = (error2 - error0) / epsilon;

return

end








