function P = Ackley()
    P.evaluar          = @evaluar;
    P.optimo           = 3 - exp(1);          
    P.limites          = [-10 10];       
    P.poblacion        = @poblacion;
    P.evaluarPoblacion = @evaluar;
    P.cruzar           = @cruzar;
    P.mutar            = @mutar;
end

% 3.1  Función Objetivo

function f = evaluar(X)
    a = 20; b = 0.2; c = 2*pi;
    if isvector(X), X = X(:)'; end   % un individuo como fila
    d = size(X, 2);
    f = -a*exp(-b*sqrt(sum(X.^2, 2)/d)) - exp(sum(cos(c*X), 2)/d) + a + 3;
end

% 3.2 Población Inicial

function pob = poblacion(n, d, limites)
    if nargin < 3, limites = [-10 10]; end
    lo = min(limites);
    hi = max(limites);
    pob = lo + (hi - lo) * rand(n, d);
end

% 3.3 Apareamiento

function hijos = cruzar(p1, p2, alfa, limites)
    if nargin < 3, alfa = 0.5; end
    if nargin < 4, limites = [-10 10]; end
    lo = min(p1, p2);   hi = max(p1, p2);   I = hi - lo;
    a  = lo - alfa*I;   b  = hi + alfa*I;
    hijos = a + (b - a) .* rand(2, numel(p1));
    hijos = min(max(hijos, min(limites)), max(limites)); 
end

% 3.4 Mutación

function pob = mutar(pob, Pm, sigma, limites)
    if nargin < 3, sigma = 1; end
    if nargin < 4, limites = [-10 10]; end
    [n, d] = size(pob);
    for k = 1:n
        if rand < Pm
            i = randi(d);
            pob(k, i) = pob(k, i) + sigma*randn;
            pob(k, i) = min(max(pob(k, i), min(limites)), max(limites));
        end
    end
end