%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D1, D2] = translation_transform(r1, r2, p)

    D1 = - p(1) * ones(size(r1, 1), size(r1, 2));
    D2 = - p(2) * ones(size(r1, 1), size(r1, 2));

return

end