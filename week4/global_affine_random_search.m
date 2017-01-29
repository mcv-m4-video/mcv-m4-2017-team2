function p = global_affine_random_search(I_curr, I_old, pmin, pmax, maxiter)

fprintf('Computing global affine model by random search...\n')

results = zeros(1,7);

figure()

for iter = 1:maxiter
    fprintf('Trial %i\n', iter)
    
    % Select random parameters:
    p = pmin + rand(1,6) .* (pmax - pmin);
    
    % Compute error:
    error = compute_transform1(I_old, I_curr, p);
        
    % Save result:
    results(iter,1:6) = p;
    results(iter,7) = error;
end

% Look for best results:
casemin = 1;
errormin = results(1,7);
i = 1;
while(isnan(errormin))
    i = i + 1;
    errormin = results(i,7);
end
for i = 1:maxiter
    if(~isnan(results(i,7)))
        if(results(i,7) < errormin)
            errormin = results(i,7);
            casemin = i;
        end
    end
end


% Compute error with final parameters:
fprintf('Parameters found: %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n', results(casemin,1:6))
fprintf('Error: %10.6f\n\n', errormin)

return

end







