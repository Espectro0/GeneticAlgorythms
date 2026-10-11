function R = AG(P, cfg)
    if nargin < 2, cfg = struct(); end
    cfg = completarCfg(cfg);
    if mod(cfg.n, 4) ~= 0
        error('AG:n', 'n debe ser múltiplo de 4 (recibí %d).', cfg.n);
    end
    sel = Seleccion();
    seleccionar = sel.(char(cfg.seleccion));
    nPad = cfg.n / 2;
    
    tic;
    % 0. Población inicial
    pob = P.poblacion(cfg.n, cfg.argsPob{:});
    f   = P.evaluarPoblacion(pob, cfg.argsEval{:});
    f   = f(:);
    [R.mejorF, i] = min(f);
    R.mejorX   = pob(i, :);
    R.historia = zeros(cfg.iter, 1);
    
    for g = 1:cfg.iter
        % 1. Selección: la mitad de la población pasa como padres
        idx    = seleccionar(f, nPad);
        padres = pob(idx, :);
        fPad   = f(idx);
    
        % 2. Cruce: parejas aleatorias, 2 hijos por pareja
        orden = randperm(nPad);
        hijos = zeros(nPad, size(pob, 2));
        for k = 1:2:nPad
            hijos(k:k+1, :) = P.cruzar(padres(orden(k), :), padres(orden(k+1), :), cfg.argsCruce{:});
        end
    
        % 3. Mutación (solo a los hijos)
        hijos = P.mutar(hijos, cfg.Pm, cfg.argsMut{:});
    
        % 4. Nueva población = padres + hijos
        fHij = P.evaluarPoblacion(hijos, cfg.argsEval{:});
        pob  = [padres; hijos];
        f    = [fPad(:); fHij(:)];
    
        % Mejor encontrado hasta ahora (la ruleta puede perder al mejor)
        [fMin, i] = min(f);
        if fMin < R.mejorF
            R.mejorF = fMin;
            R.mejorX = pob(i, :);
        end
        R.historia(g) = R.mejorF;
    end
    R.tiempo = toc;
    end
    
    function cfg = completarCfg(cfg)
    def = struct('n', 40, 'iter', 100, 'seleccion', 'torneo', 'Pm', 0.2, ...
        'argsPob', {{}}, 'argsEval', {{}}, 'argsCruce', {{}}, 'argsMut', {{}});
    campos = fieldnames(def);
    for k = 1:numel(campos)
        if ~isfield(cfg, campos{k})
            cfg.(campos{k}) = def.(campos{k});
        end
    end
end