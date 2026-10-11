function P = Viajero()
    P.T                = tablaTiempos();
    P.nombres          = nombresMunicipios();
    P.evaluar          = @evaluar;
    P.aIndices         = @nombre2idx;
    P.mostrar          = @mostrarRuta;
    P.poblacion        = @poblacion;
    P.evaluarPoblacion = @evaluarPoblacion;
    P.cruzar           = @cruzar;
    P.mutar            = @mutar;
end

% 3.1  Función Objetivo

function t = evaluar(ruta, regresar)
    if nargin < 2, regresar = false; end
    if isstring(ruta) || iscellstr(ruta) || ischar(ruta)
        ruta = nombre2idx(ruta);
    end
    T = tablaTiempos();
    ruta = ruta(:)';                      

    if ~all(ismember(ruta, 1:13))                    
        t = NaN; return
    end
    valida = isequal(sort(ruta), 1:13);            

    if regresar
        ruta = [ruta ruta(1)];                   
    end
    idx = sub2ind(size(T), ruta(1:end-1), ruta(2:end)); 
    t = sum(T(idx));

    if ~valida
        t = t + 10000;                               
    end
end

% 3.2 Población Inicial

function pob = poblacion(n)
    pob = zeros(n, 13);
    for k = 1:n
        pob(k, :) = randperm(13);
    end
end

function f = evaluarPoblacion(pob, regresar)
    if nargin < 2, regresar = false; end
    n = size(pob, 1);
    f = zeros(n, 1);
    for k = 1:n
        f(k) = evaluar(pob(k, :), regresar);
    end
end

% 3.3 Apareamiento

function hijos = cruzar(p1, p2)
    hijos = [ox(p1, p2); ox(p2, p1)];
end

function h = ox(p1, p2)
    n = numel(p1);
    c = sort(randperm(n, 2));  a = c(1);  b = c(2);  
    h = zeros(1, n);
    h(a:b) = p1(a:b);                        
    orden = p2([b+1:n, 1:b]);                        
    orden = orden(~ismember(orden, h(a:b)));        
    h([b+1:n, 1:a-1]) = orden;                        
end

% 3.4 Mutación

function pob = mutar(pob, Pm)
for k = 1:size(pob, 1)
    if rand < Pm
        pob(k, :) = intercambio(pob(k, :));
    end
end
end

function x = intercambio(x)
pos = randperm(numel(x), 2);
x(pos) = x(fliplr(pos));
end

%% Datos

function T = tablaTiempos()
T = [ 0  10  35  29  16  30  40  27  56  44  67  54  81;
      6   0  32  31  16  32  34  28  52  44  63  56  83;
     34  32   0  29  45  58  35  57  26  73  91  83 110;
     29  29  28   0  32  47  57  31  49  61  67  70  99;
     18  18  46  33   0  23  52  19  68  39  54  41  69;
     30  30  58  46  25   0  46  36  79  39  71  62  90;
     40  37  36  59  52  54   0  64  61  80 104  89 117;
     32  32  57  32  18  36  65   0  82  50  41  51  82;
     55  52  23  48  67  80  56  73   0  95 116 101 130;
     47  47  76  62  42  37  73  53  97   0 102  81 111;
     79  79 106  80  66  87 110  59 148 101   0  97 100;
     59  59  86  74  44  65  90  55 107  80  93   0  29;
     89  89 116 104  74  96 119  86 137 110 103  33   0];
end

function n = nombresMunicipios()
    n = ["UCO","Rionegro","La Ceja","El Carmen","Marinilla","Guarne", ...
         "El Retiro","Santuario","La Unión","San Vicente","Cocorná", ...
         "El Peñol","Guatapé"];
end

function idx = nombre2idx(ruta)
    lista = normalizar(nombresMunicipios());
    ruta  = string(ruta);
    [esta, idx] = ismember(normalizar(ruta), lista);
    if ~all(esta)
        error('No reconozco: %s', strjoin(ruta(~esta), ', '));
    end
end

function s = normalizar(s)
    s = lower(strtrim(s));
    s = replace(s, ["á","é","í","ó","ú","ñ"], ["a","e","i","o","u","n"]);
end

function texto = mostrarRuta(ruta)
    n = nombresMunicipios();
    texto = strjoin(n(ruta), " → ");
end