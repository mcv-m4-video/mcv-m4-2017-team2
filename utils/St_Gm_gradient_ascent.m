function theta = St_Gm_gradient_ascent(theta0, delta, gamma, maxiter, K, videoname, T1, T2)

theta = theta0;
flag = 1;
iter = 0;

while(flag)
    iter = iter + 1;
    fprintf('\nIteration %i\n', iter)
    fprintf('theta = (%8.4f, %8.4f, %8.4f),   F = ', theta(1), theta(2), theta(3))
    [F, gradF] = get_gradF(theta, K, videoname, T1, T2);
    fprintf('%8.4f\n', F)
    fprintf('gradF = (%8.4f, %8.4f, %8.4f),   norm(gradF) / sqrt(3) = %10.6f\n', ...
        gradF(1), gradF(2), gradF(3), norm(gradF) / sqrt(3))
    theta = theta + gamma * gradF;
    if(norm(gradF) / sqrt(3) < delta)
        flag = 0;
    end
    if(iter >= maxiter)
        flag = 0;
    end
end

fprintf('\nFinished in %i iterations.\n', iter)
fprintf('theta = (%8.4f, %8.4f, %8.4f),   F = %8.4f\n', ...
    theta(1), theta(2), theta(3), get_F(theta, K, videoname, T1, T2))

return

end


function [F, gradF] = get_gradF(theta, K, videoname, T1, T2)

    epsilon = 0.1;
    
    F = get_F(theta, K, videoname, T1, T2);
    F_e1 = get_F(theta + [epsilon, 0, 0], K, videoname, T1, T2);
    F_e2 = get_F(theta + [0, epsilon, 0], K, videoname, T1, T2);
    F_e3 = get_F(theta + [0, 0, epsilon], K, videoname, T1, T2);
    
    gradF = [(F_e1 - F) / epsilon, (F_e2 - F) / epsilon, (F_e3 - F) / epsilon];

return

end


function F = get_F(theta, K, videoname, T1, T2)

    % Threshold = theta(1)
    % Rho = theta(2)
    % THG = theta(3)

    % Compute detection:
    sequence = MultG_fun(theta(1), T1, T2, K, theta(2), theta(3), videoname);
    % Evaluate detection:
    [~, ~, F] = test_sequence(sequence, videoname, T1);
return

end