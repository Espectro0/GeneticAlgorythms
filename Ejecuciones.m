%% EXPERIMENTOS
% Corre sección por sección (Ctrl+Enter en cada bloque %%)
% Las tablas se guardan en la carpeta resultados/ como .csv.
clear; clc;
if ~exist('resultados', 'dir'), mkdir resultados; end

nPruebas  = 20;      
n         = 120;     % tamaño de la población
dimAckley = 3;    

% ---- Configuración de cada problema ----
prob = struct([]);
prob(1).nombre = "Viajero";     prob(1).P = Viajero();
prob(1).argsPob = {};                     prob(1).argsEval = {};
prob(1).argsMut = {};                     prob(1).Pm = 0.2;   prob(1).optimo = NaN;

prob(2).nombre = "Ackley";      prob(2).P = Ackley();
prob(2).argsPob = {dimAckley, [-10 10]};  prob(2).argsEval = {};
prob(2).argsMut = {1};                    prob(2).Pm = 0.2;   prob(2).optimo = 3 - exp(1);

prob(3).nombre = "Inventario";  prob(3).P = Inventario();
prob(3).argsPob = {};                     prob(3).argsEval = {'cerrada'};   % o 'integral'
prob(3).argsMut = {0.1};                  prob(3).Pm = 0.2;   prob(3).optimo = NaN;

%% Estudio 1: método de selección (100 iteraciones)
metodos  = ["elitismo", "torneo", "ruleta"];
mejorSel = strings(1, 3);
for p = 1:3
    filas = table();
    for m = metodos
        cfg   = configurar(prob(p), n, 100, m);
        filas = [filas; resumen(prob(p), cfg, nPruebas, "Seleccion", m)]; %#ok<AGROW>
    end
    mostrarYGuardar(filas, "E1_seleccion_" + prob(p).nombre);
    [~, i] = min(filas.PromedioF);           % criterio: menor promedio
    mejorSel(p) = metodos(i);
end
disp("Mejor selección por problema:"); disp(mejorSel)

%% Estudio 2: número de iteraciones
iteraciones = [10 20 30 50 100 150 200 300 500];
for p = 1:3
    filas = table();
    for it = iteraciones
        cfg   = configurar(prob(p), n, it, mejorSel(p));
        filas = [filas; resumen(prob(p), cfg, nPruebas, "Iteraciones", it)]; %#ok<AGROW>
    end
    mostrarYGuardar(filas, "E2_iteraciones_" + prob(p).nombre);
end

%% Estudio 3: mutación
itElegidas = [100 150 500];                  % [viajero, ackley, inventario]

valoresPm  = [0 0.05 0.1 0.2 0.5 0.7 1];
magnitudes = {{}, {0.5, 1, 2}, {0.05, 0.1, 0.2, 0.3, 0.5}};   % viajero no tiene magnitud
mejorPm  = zeros(1, 3);
mejorMut = cell(1, 3);
for p = 1:3
    filas = table();
    lista = {};                              % argsMut de cada fila
    pms   = [];
    mags  = magnitudes{p};
    if isempty(mags), mags = {[]}; end
    for Pm = valoresPm
        for j = 1:numel(mags)
            if isempty(mags{j})
                argsMut  = {};
                etiqueta = sprintf('Pm=%.2f', Pm);
            else
                argsMut  = {mags{j}};
                etiqueta = sprintf('Pm=%.2f, sigma=%g', Pm, mags{j});
            end
            cfg   = configurar(prob(p), n, itElegidas(p), mejorSel(p), Pm, argsMut);
            filas = [filas; resumen(prob(p), cfg, nPruebas, "Mutacion", etiqueta)]; %#ok<AGROW>
            lista{end+1} = argsMut;          %#ok<SAGROW>
            pms(end+1)   = Pm;               %#ok<SAGROW>
        end
    end
    mostrarYGuardar(filas, "E3_mutacion_" + prob(p).nombre);
    [~, i] = min(filas.PromedioF);
    mejorPm(p)  = pms(i);
    mejorMut{p} = lista{i};
end

mejorPm(2) = 0.1;  mejorMut{2} = {1};

%% Estudio 4: número de dimensiones (solo Ackley)
dims = [2 3 10 20 50 100];
pr = prob(2);
filas = table();
for d = dims
    pr.argsPob = {d, [-10 10]};
    cfg   = configurar(pr, n, itElegidas(2), mejorSel(2), mejorPm(2), mejorMut{2});
    filas = [filas; resumen(pr, cfg, nPruebas, "Dimensiones", d)]; %#ok<AGROW>
end
mostrarYGuardar(filas, "E4_dimensiones_Ackley");

%% Curvas de convergencia: comparación de métodos de selección
metodos = ["elitismo", "torneo", "ruleta"];
for p = 1:3
    fig = figure('Name', prob(p).nombre);  hold on;
    for m = metodos
        cfg = configurar(prob(p), n, 100, m);
        plot(1:100, curva(prob(p), cfg, nPruebas), 'LineWidth', 1.5);
    end
    formatoCurva(prob(p), "Selección — " + prob(p).nombre);
    legend(metodos, 'Location', 'northeast');
    exportgraphics(fig, fullfile('resultados', "conv_seleccion_" + prob(p).nombre + ".png"), 'Resolution', 300);
end

%% Curvas de convergencia: configuración final
for p = 1:3
    fig = figure('Name', prob(p).nombre + " final");
    cfg = configurar(prob(p), n, 600, mejorSel(p), mejorPm(p), mejorMut{p});
    plot(1:600, curva(prob(p), cfg, nPruebas), 'LineWidth', 1.5);
    xline(itElegidas(p), '--', sprintf('%d iteraciones', itElegidas(p)));
    formatoCurva(prob(p), "Configuración final — " + prob(p).nombre);
    exportgraphics(fig, fullfile('resultados', "conv_final_" + prob(p).nombre + ".png"), 'Resolution', 300);
end

%% ===================== Funciones auxiliares =====================
function cfg = configurar(pr, n, iter, seleccion, Pm, argsMut)
    if nargin < 5, Pm = pr.Pm; end
    if nargin < 6, argsMut = pr.argsMut; end
    cfg = struct('n', n, 'iter', iter, 'seleccion', char(seleccion), 'Pm', Pm, ...
                 'argsPob', {pr.argsPob}, 'argsEval', {pr.argsEval}, ...
                 'argsCruce', {{}}, 'argsMut', {argsMut});
end

function T = resumen(pr, cfg, nPruebas, nombreParam, valor)
    F = zeros(nPruebas, 1);  t = zeros(nPruebas, 1);  X = cell(nPruebas, 1);
    for k = 1:nPruebas
        rng(k);                  % mismas semillas en todas las configuraciones
        R = AG(pr.P, cfg);
        F(k) = R.mejorF;  t(k) = R.tiempo;  X{k} = R.mejorX;
    end
    [mejor, i] = min(F);
    T = table(string(valor), mean(t), mejor, mean(F), std(F), ...
              'VariableNames', {char(nombreParam), 'Tiempo_s', 'MejorF', 'PromedioF', 'DesvEst'});
    if ~isnan(pr.optimo)
        T.RMSE = sqrt(mean((F - pr.optimo).^2));      % Ecuación 15
    end
    T.Individuo = textoIndividuo(pr, X{i});
end

function s = textoIndividuo(pr, x)
    if pr.nombre == "Viajero"
        s = string(pr.P.mostrar(x));
    else
        s = string(mat2str(x, 5));
    end
end

function mostrarYGuardar(T, nombre)
    fprintf('\n===== %s =====\n', nombre);
    disp(T);
    writetable(T, fullfile('resultados', nombre + ".csv"), 'Encoding', 'UTF-8');
end

function y = curva(pr, cfg, nPruebas)
    H = zeros(cfg.iter, nPruebas);
    for k = 1:nPruebas
        rng(k);
        R = AG(pr.P, cfg);
        H(:, k) = R.historia;
    end
    y = mean(H, 2);
    if ~isnan(pr.optimo)
        y = y - pr.optimo + eps;     
    end
end

function formatoCurva(pr, titulo)
    if ~isnan(pr.optimo)
        set(gca, 'YScale', 'log');
        ylabel('f - f^* (promedio de las pruebas)');
    else
        ylabel('Mejor f (promedio de las pruebas)');
    end
    xlabel('Iteración');  title(titulo);  grid on;  box on;
end