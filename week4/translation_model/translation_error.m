function err = translation_error(I_curr, I_old, p, mask)

    dfd = translation_dfd(I_curr, I_old, p);
    
    err = sum(sum((dfd .* mask).^2));
return

end