function err = affine_error(I_curr, I_old, p, mask)

    dfd = affine_dfd(I_curr, I_old, p);
    
    err = sum(sum((dfd .* mask).^2));
return

end