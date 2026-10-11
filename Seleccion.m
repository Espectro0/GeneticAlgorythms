function S = Seleccion()
    S.elitismo = @elitismo;
    S.torneo   = @torneo;
    S.ruleta   = @ruleta;
end

% Elitismo (3.3.1)
function idx = elitismo(f, nSel)
    [~, orden] = sort(f(:)', 'ascend');
    idx = orden(1:nSel);
end

% Torneo (3.3.2)
function idx = torneo(f, nSel, tam, ganadores)
    if nargin < 3, tam = 4; end
    if nargin < 4, ganadores = 2; end
    n = numel(f);
    idx = [];
    while numel(idx) < nSel
        disponibles = setdiff(1:n, idx);
        disponibles = disponibles(randperm(numel(disponibles)));
        for ini = 1:tam:numel(disponibles)
            grupo = disponibles(ini:min(ini+tam-1, end));
            [~, o] = sort(f(grupo));
            idx = [idx, grupo(o(1:min(ganadores, numel(grupo))))];
            if numel(idx) >= nSel, break; end
        end
    end
    idx = idx(1:nSel);
end

% Ruleta (3.3.3)
function idx = ruleta(f, nSel)
    w = 1 ./ f(:)';
    disponibles = 1:numel(f);
    idx = zeros(1, nSel);
    for k = 1:nSel
        p = w(disponibles) / sum(w(disponibles));
        j = find(cumsum(p) >= rand, 1);
        if isempty(j), j = numel(p); end     % por redondeo de cumsum
        idx(k) = disponibles(j);
        disponibles(j) = [];
    end
end