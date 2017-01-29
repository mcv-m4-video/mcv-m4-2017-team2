function p = gradient_descent_random_search(I_curr, I_old, pmin, pmax, maxiter)

fprintf('Computing global affine model by random search...\n')

results = zeros(1,7);

figure()

for iter = 1:maxiter
    % Select random parameters:
    p = pmin + rand(1,6) .* (pmax - pmin);
    
    % Compute error:
    error = compute_transform(I_old, I_curr, p);
        
    % Save result:
    results(iter,1:6) = p;
    results(iter,7) = error;
end

% Look for best results:
casemin = 1;
errormin = results(1,7);
for i = 1:maxiter
    
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








