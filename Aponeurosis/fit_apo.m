function[coef] = fit_apo(apox, apoy, parms)

if parms.order == 1
    A = [-1 0];
    B = tand(parms.maxangle);

    coef = fmincon(@(p) costfun(p, apox, apoy), [1; 1], A, B,[],[],[],[],[], optimoptions('fmincon','Display','none'));

    % figure
    % 
    % plot(apox, apoy); hold on
    % 
    % plot(apox, polyval(coef, apox))
    
else
     coef = polyfit(apox,apoy,parms.order);
end


function[cost] = costfun(p, apox, apoy)

fy = p(1)*apox + p(2);
cost = sum((fy-apoy).^2);

end
end