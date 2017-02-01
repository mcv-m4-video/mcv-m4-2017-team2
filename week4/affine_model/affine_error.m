function err = affine_error(I_curr, I_old, p)

    dfd = affine_dfd(I_curr, I_old, p);
    
    err = sum(sum(dfd.^2));
return

end