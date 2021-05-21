function b = receptive_fields_weighted_regression_global(model, S, U, Phi)
    % get right dimensions
    Nmodels = size(model.c,2); % number of local models
    Ndim = size(S,1);
    % compute receptive fields weighting 
    w_func = @(m) @(x) feval(@(y) exp(-0.5.*sum(bsxfun(@times, y, (model.var)*y))), bsxfun(@minus,x,model.c(:,m))).'; % importance weights W = [w1 w2 ... w_m ... w_M]
    Wm = zeros(length(S),Nmodels);
    for m=1:Nmodels
        wm_func = feval(w_func, m);
        Wm(:,m) = wm_func(S);
    end
    Wm = Wm./sum(Wm,2);
    % learn model parameters
    b_vec = lsqminnorm(khatrirao(repelem(Wm,Ndim,1)',Phi')',U(:));
    b = reshape(b_vec,[],Nmodels);
end