function functionHandle = def_weighted_linear_model(model, Phi)
    functionHandle = @weightedLinearModelPolicy;
    % Model variables:
    c = model.c;
    var = model.var;
    b = model.b;
    function output = weightedLinearModelPolicy(q)
        W = feval(@(y) exp(-0.5.*sum(bsxfun(@times, y, var*y))), bsxfun(@minus,q,c)).'; % importance weights W = [w1 w2 ... w_m ... w_M]
        W_bar = W./sum(W);
        output = (Phi(q)*b*W_bar); % correct version
    end
end
