function[coef] = fit_apo(apox, apoy, parms, fit_order)

% default: unconstrained fitting
coef = polyfit(apox,apoy, fit_order);

% optional: find optimum fit, given constraint on max angle
if fit_order == 1
    
    % calc angle of unconstrained fit to determine necessity
    fit_angle = -atan2d(coef(1),1);
    
    % if max angle is enforced, do constrained fit
    if fit_angle > parms.maxangle && strcmp(parms.fit_method, 'enforce_maxangle')  
        coef = fmincon(@(p) costfun(p, apox, apoy), [1; 1], [-1 0], tand(parms.maxangle),[],[],[],[],[], optimoptions('fmincon','Display','none'));
    end
end

% cost function for constrained fitting
function[cost] = costfun(p, apox, apoy)

fy = p(1)*apox + p(2);
cost = sum((fy-apoy).^2);

end
end