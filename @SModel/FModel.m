
% FMODEL  Evaluates forward model (T > J) using given E(m) and temperature decay.
% AUTHOR: Timothy Sipkens
%=========================================================================%

function [Jout] = FModel(smodel, prop, T, Em)

p3 = Em(smodel.l, prop.dp0) ./ ...
    (smodel.l .* 1e-9) ./ smodel.data_sc;  % deal with signal scaling

J = smodel.blackbody(T,smodel.l);  % evaluate Planck's Law

% Multiply Planck's Law by necessary values 
% to return incandescence.
Jout = bsxfun(@times, J, reshape(p3, 1, 1, []));

end

