function [mean_matrix,variance_matrix] = adaptModel(frame, detection, mean_matrix, variance_matrix, rho)
    % background pixels: ~detection
    mean_matrix(~logical(detection)) = rho * frame(~logical(detection)) + (1 - rho) * mean_matrix(~logical(detection));
    variance_matrix(~logical(detection)) = sqrt(rho * (frame(~logical(detection)) - mean_matrix(~logical(detection))) .^2 + ...
        (1 - rho) * variance_matrix(~logical(detection)) .^ 2);
end