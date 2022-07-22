function [R,O,C,S,tau_eff,sm] = wobbling(stark_effect_order)
% wobbling in a cone model of Kramer Nishda Fayer JCP 2016

%stark_effect_order = varargin{1};

%tau_eff = in.tau;
%theta_deg = in.theta_deg;

x0 = @(p) cos(p.theta_deg/180*pi);

S{1} = @(p) (1+x0(p))/2;
S{2} = @(p)  x0(p)*(1+x0(p))/2;
S{3} = @(p) (1+x0(p))*(5*x0(p)^2-1)/8;
S{4} = @(p)  x0(p)*(1+x0(p))*(7*x0(p)^2-3)/8;

D = @(p)1/(6*p.tr);
theta = @(p) p.theta_deg*pi/180;

% small angle approx
tau_eff{1} = @(p) theta(p)^2/D(p)*(7/24-55*theta(p)^2/1152);
tau_eff{2} = @(p) theta(p)^2/D(p)*(7/24-35*theta(p)^2/384);
tau_eff{3} = @(p) theta(p)^2/D(p)*(7/24-5*theta(p)^2/32);
tau_eff{4} = @(p) theta(p)^2/D(p)*(7/24-35*theta(p)^2/144);
sm = tau_eff;
 
tau_eff{1} = @(p) (-(1+x0(p))^2/(2*(1-x0(p)))*log((1+x0(p))/2)...
    -x0(p)*(4+x0(p)-x0(p)^2)/4)...
    /(D(p)*(1-S{1}(p)^2));

tau_eff{2} = @(p) (-x0(p)^2*(1+x0(p))^2*(log((1+x0(p))/2)+(1-x0(p))/2)...
    /(2*(1-x0(p)))...
    +(1-x0(p))*(6+8*x0(p)-x0(p)^2-12*x0(p)^3-7*x0(p)^4)/24 ...
    )...
    /(D(p)*(1-S{2}(p)^2));

tau_eff{3} = @(p) (-(1+x0(p))^2*(5*x0(p)^2-1)^2*log((1+x0(p))/2)...
    /(32*(1-x0(p)))...
    +(30-9*x0(p)+154*x0(p)^2+231*x0(p)^3-370*x0(p)^4-615*x0(p)^5+10*x0(p)^6+185*x0(p)^7)...
    /384 ...
    )...
    /(D(p)*(1-S{3}(p)^2));

%tau_eff{4} is left as an exercise for the reader... sorry.
%reader: rude
tau_eff{4} = @(p) (-x0(p)^2*(1+x0(p))^2*(7*x0(p)^2-3)^2*log((1+x0(p))/2)...
    /(32*(1-x0(p)))...
    +(260+68*x0(p)-1301*x0(p)^2-1895*x0(p)^3+6231*x0(p)^4+9597*x0(p)^5-7511*x0(p)^6-13517*x0(p)^7 + ...
    497*x0(p)^8 + 3731*x0(p)^9)...
    /3840 ...
    )...
    /(D(p)*(1-S{4}(p)^2));

C = cell(1,4);

for l = 1:4
    
    C{l} = @(p,t) S{l}(p)^2 + (1-S{l}(p)^2)*exp(-t./tau_eff{l}(p));
    
end


%R.para = @(p,x)(3/25)*((11.*C{1}(p,x) + 4*C{3}(p,x))./(1 + 0.8*C{2}(p,x)));
%R.perp = @(p,x)(3/25)*(( 7.*C{1}(p,x) - 2*C{3}(p,x))./(1 - 0.4*C{2}(p,x)));
%R.iso = @(p,x)C{1}(p,x);


switch stark_effect_order
    case 1 % from Kramer2015a
R.para = @(p,x)(3/25)*((11.*C{1}(p,x) + 4*C{3}(p,x))./(1 + 0.8*C{2}(p,x)));
R.perp = @(p,x)(3/25)*(( 7.*C{1}(p,x) - 2*C{3}(p,x))./(1 - 0.4*C{2}(p,x)));
R.iso = @(p,x)C{1}(p,x);
    case 2 % from 
R.para = @(p,x)(1/175)*((28 + 215.*C{2}(p,x) + 72*C{4}(p,x))./(1 + 0.8*C{2}(p,x)));
R.perp = @(p,x)(1/175)*((-14 + 155.*C{2}(p,x) - 36*C{4}(p,x))./(1 - 0.4*C{2}(p,x)));
R.iso = @(p,x)C{2}(p,x);
    otherwise
        error('only order 1 and 2 coded');
end

%orientation
%oPara = @(tau_o,t2) (1/9).*(1+4/5.*exp(-t2./tau_o));
%oPerp = @(tau_o,t2) (1/9).*(1-2/5.*exp(-t2./tau_o));

O.para = @(p,t)(1/9).*(1+4/5.*C{2}(p,t));
O.perp = @(p,t)(1/9).*(1-2/5.*C{2}(p,t));

