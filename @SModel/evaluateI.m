
% EVALAUTEI Bridge function to evaluate spectroscopic inverse model (J > T). 
% Author:   Timothy Sipkens
%=========================================================================%

function [Tout] = evaluateI(smodel,x)

J = smodel.J; % local copy of stored incandescence
prop = smodel.prop; % local copy of matl/experimental properties

if nargin > 1 % check if there is a mismatch in size of x
    if length(x)==length(smodel.x)
        for ii=1:length(smodel.x)
            prop.(smodel.x{ii}) = x(ii);
        end
    else
        warning('Warning: QoIs parameter size mismatch.');
    end
end

Tout = smodel.IModel(J); % call IModel function

end

