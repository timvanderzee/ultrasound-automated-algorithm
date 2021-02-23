function[err] = hough_cost(Cainput, parms)

% parms.Cainput = Cainput;

parms.mu = Cainput(1);
parms.sig = Cainput(2);
parms.amp = Cainput(3);

parms.CaFreeMethod = 'Sinusoid';
% Tperiod = 1/parms.targetfreq;

[t,X] = ode113(@dCdt_simplest,parms.tspan,[0; 0], odeset('Reltol',1e-8,'AbsTol',1e-8),parms);

% resample
Force = X(:,2);


tnew = 0:.001:(t(end));
Force_Int = interp1(t, Force, tnew);

% Ftarget = .5 - .5*cos(parms.targetfreq * 2*pi*tnew);
% Ftarget(tnew>Tperiod) = 0;

gaus = @(x,mu,sig,amp)amp*exp(-(((x-mu).^2)/(2*sig.^2)))
Ftarget = gaus(tnew,1,parms.gaus_sds,1);





[maxval, maxloc] = max(Ftarget);
[maxval1, maxloc1] = max(Force_Int);

err2 = (maxval-maxval1).^2;%  + (maxloc-maxloc1).^2;
err = mean((Ftarget-Force_Int).^2,'omitnan') + 2*err2;


figure(100);
plot(tnew, [Force_Int(:) Ftarget(:)]);
axis([0 2 0 1.5])


% disp(['Cainput = ', num2str(Cainput)])
% disp(['Error = ', num2str(err)])
end