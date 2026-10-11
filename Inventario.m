function P = Inventario()
    P.params           = parametros();
    P.evaluar          = @evaluar;
    P.evaluarIndividuo = @(x, varargin) evaluar(x(1:5), x(6:10), x(11:15), varargin{:});
    P.poblacion        = @poblacion;
    P.evaluarPoblacion = @evaluarPoblacion;
    P.completar        = @completar;
    P.limites          = @limites;
    P.cruzar           = @cruzar;
    P.mutar            = @mutar;
end

% 3.1  Función Objetivo

function Z = evaluar(Q, S, K, metodo)
    if nargin < 4, metodo = 'integral'; end
    p = parametros();
    Z = 0;
    for i = 1:5
        R  = S(i) + K(i);                  
        mu = p.mu(i);  sg = p.sigma(i);
        switch metodo
            case 'integral'
                f = @(x) (x - R) .* exp(-0.5*((x - mu)/sg).^2) / (sg*sqrt(2*pi));
                L = integral(f, R, Inf);
            case 'cerrada'
                z = (R - mu)/sg;
                L = sg*exp(-z^2/2)/sqrt(2*pi) + (mu - R)*0.5*erfc(z/sqrt(2));
            otherwise
                error('Método desconocido: %s', metodo);
        end
        Z = Z + p.D(i)/(Q(i)*p.m(i)) * L;
    end
end

% 3.2 Población Inicial

function pob = poblacion(n)
    [lo, hi] = limites();
    libres = [1:4, 6:15];               
    pob = zeros(n, 15);
    k = 0;
    while k < n
        x = zeros(1, 15);
        x(libres) = lo(libres) + (hi(libres) - lo(libres)) .* rand(1, 14);
        [x, ok] = completar(x);
        if ok
            k = k + 1;
            pob(k, :) = x;
        end
    end
end

function [x, ok] = completar(x)
    p = parametros();
    [lo, hi] = limites();
    x(5) = 2*(p.I - sum(x(6:10))) - sum(x(1:4));
    ok = x(5) >= lo(5) && x(5) <= hi(5);
end

function [lo, hi] = limites()
    p = parametros();
    lo = [p.Qmin*ones(1,5), zeros(1,5), zeros(1,5)];
    hi = [p.Qmax*ones(1,5), p.Smax,     p.Kmax];
end

function f = evaluarPoblacion(pob, metodo)
    if nargin < 2, metodo = 'integral'; end
    n = size(pob, 1);
    f = zeros(n, 1);
    for k = 1:n
        x = pob(k, :);
        f(k) = evaluar(x(1:5), x(6:10), x(11:15), metodo);
    end
end

% 3.3 Apareamiento

function hijos = cruzar(p1, p2)
lam = rand;
hijos = [lam*p1 + (1-lam)*p2;
    (1-lam)*p1 + lam*p2];
end

% 3.4 Mutación

function pob = mutar(pob, Pm, sigmaRel)
    if nargin < 3, sigmaRel = 0.1; end
    [lo, hi] = limites();
    libres = [1:4, 6:15];
    for k = 1:size(pob, 1)
        if rand < Pm
            for intento = 1:20
                x = pob(k, :);
                i = libres(randi(14));
                x(i) = x(i) + sigmaRel*(hi(i) - lo(i))*randn;
                x(i) = min(max(x(i), lo(i)), hi(i));
                [x, ok] = completar(x);
                if ok
                    pob(k, :) = x;
                    break
                end
            end
        end
    end
end

%% Datos

function p = parametros()
    p.D     = [12000 80000 150000 50000 100000];
    p.m     = [20 220 900 120 180];
    p.mu    = [300 4000 7000 2000 3500];
    p.sigma = [100 1200 2500 700 1100];
    p.Smax  = [200 1200 2500 800 1500];
    p.Kmax  = [500 2000 5000 1500 3000];
    p.I     = 8000;
    p.Qmin  = 10;
    p.Qmax  = 4000;
end