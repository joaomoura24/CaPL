function b = receptive_fields_weighted_regression_local(model, S, U, Phi)
    % get right dimensions
    Nmodels = size(model.c,2); % number of local models
    Nphi = size(Phi,2); % number of regressors for pi_m
    Ndim = size(S,1);
    % compute receptive fields weighting 
    w_func = @(m) @(x) feval(@(y) exp(-0.5.*sum(bsxfun(@times, y, (model.var)*y))), bsxfun(@minus,x,model.c(:,m))).'; % importance weights W = [w1 w2 ... w_m ... w_M]
    Wm = zeros(length(S),Nmodels);
    for m=1:Nmodels
        wm_func = feval(w_func, m);
        Wm(:,m) = wm_func(S);
    end
    Wm = Wm./sum(Wm,2); % normalization
    Wm2 = Wm.^2;
    % compute linear local policy weights
    b = zeros(Nphi,Nmodels);
    for m=1:Nmodels
        RWm2 = Phi.*repelem(Wm2(:,m),Ndim,Nphi);
        b(:,m) = pinv(RWm2.'*Phi)*RWm2.'*U(:);
    end
end