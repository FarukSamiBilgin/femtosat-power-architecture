function flyback_dataset = generate_controller_dataset_optimized()
    % GENERATE_CONTROLLER_DATASET_OPTIMIZED
    % Vektörleştirilmiş şekilde flyback kontrolcü performans dataset’i oluşturur.

    % 1) Kontrolör isimleri
    controllers = {'PI','Hinf','H2','Fuzzy','MuSyn'};
    nC = numel(controllers);

    % 2) Test senaryolarını oluştur
    [Vref, Rload, Ldev, Cdev, Dist, Tstep] = ndgrid(...
        [3.3,5,12], ...
        [50e3,100e3,220e3,470e3], ...
        [-20,0,20], ...
        [-20,0,20], ...
        [0,0.2,0.5], ...
        [1e-3,5e-3,10e-3] ...
    );
    scenarios = table(...
        Vref(:), Rload(:), Ldev(:), Cdev(:), Dist(:), Tstep(:), ...
        'VariableNames', {'Vref','Rload','Ldev','Cdev','Dist','Tstep'});
    nS = height(scenarios);

    % 3) Tüm senaryo × kontrolcü kombinasyon indeksleri
    [SC_idx, C_idx] = ndgrid(1:nS, 1:nC);
    SC_idx = SC_idx(:);
    C_idx  = C_idx(:);

    % 4) Simülasyon + metrik hesaplama
    results = arrayfun(@(s,c) simulate_and_metric(scenarios(s,:), controllers{c}), ...
                       SC_idx, C_idx, 'UniformOutput', false);

    % 5) Metrikleri matrise dönüştür
    F = {'SSerr','SettTime','Overshoot','Effort','RMSE','Eff','Robust'};
    nFields = numel(F);
    nResults = numel(results);
    M = zeros(nResults, nFields);
    for i = 1:nResults
        metrics = results{i}.metrics;
        for j = 1:nFields
            M(i,j) = metrics.(F{j});
        end
    end

    % 6) Kontrolcü adlarını hazırla
    ctrlNames = controllers(C_idx)';

    % 7) Tabloyu oluştur ve normalize et
    flyback_dataset = array2table(M, 'VariableNames', F);
    flyback_dataset.Controller = ctrlNames;
    for j = 1:nFields
        col = flyback_dataset{:,F{j}};
        mn = min(col); mx = max(col);
        if mx>mn
            flyback_dataset{:,F{j}} = (col - mn) / (mx - mn);
        else
            flyback_dataset{:,F{j}} = 0.5 * ones(size(col));
        end
    end

    % --- 8) CSV olarak kaydetmeden önce senaryo parametrelerini ekle ---
    % SC_idx, her result satırının hangi senaryoya ait olduğunu tutuyor.
    % scenarios ise tüm senaryoların parametrelerini içeriyor.
    % Buradan her satır için ilgili senaryo parametrelerini tablomuzla birleştiriyoruz.
    scen_params = scenarios(SC_idx, :);
    % İsimlendirmeyi istediğiniz gibi değiştirebilirsiniz (örneğin kΩ cinsine dönüştürmek vs.)
    scen_params.Rload = scen_params.Rload / 1e3;          % kΩ’ye çevir
    scen_params.Tstep = scen_params.Tstep * 1e3;          % ms’ye çevir
    scen_params.Properties.VariableNames = { ...
        'Vref','Rload_kOhm','L_dev_pct','C_dev_pct','Disturbance','StepTime_ms'};

    % Parametreleri öne alıp orijinal tablonun başına ekleyelim
    flyback_dataset = [scen_params, flyback_dataset];

    % 9) CSV olarak kaydet
    writetable(flyback_dataset, 'flyback_dataset_with_params.csv');
    fprintf('Oluşturulan örnek sayısı: %d\n', height(flyback_dataset));
    fprintf('CSV dosyası kaydedildi: flyback_dataset_with_params.csv\n');
end

%% ------------------------------------------------------------------------
function out = simulate_and_metric(sc, ctrl)
    % Tek fonksiyon içinde simülasyon ve metrik hesaplama

    N = 100;
    t_end = sc.Tstep * 5;
    sim.time  = linspace(0, t_end, N);
    switch ctrl
        case 'PI'
            sim.error = 0.1*exp(-linspace(0,5,N)).*sin(2*pi*linspace(0,1,N)) + 0.01*randn(1,N);
            sim.duty  = 0.5 + 0.2*rand(1,N);
        case 'Hinf'
            sim.error = 0.05*exp(-linspace(0,8,N)) + 0.005*randn(1,N);
            sim.duty  = 0.45 + 0.1*rand(1,N);
        case 'H2'
            sim.error = 0.08*exp(-linspace(0,6,N)) + 0.008*randn(1,N);
            sim.duty  = 0.48 + 0.15*rand(1,N);
        case 'Fuzzy'
            sim.error = 0.12*exp(-linspace(0,4,N)).*(1+0.5*sin(5*linspace(0,1,N))) + 0.02*randn(1,N);
            sim.duty  = 0.5 + 0.25*rand(1,N);
        case 'MuSyn'
            sim.error = 0.04*exp(-linspace(0,10,N)) + 0.003*randn(1,N);
            sim.duty  = 0.47 + 0.08*rand(1,N);
        otherwise
            sim.error = randn(1,N)*0.1;
            sim.duty  = rand(1,N);
    end

    e = sim.error; d = sim.duty; t = sim.time;
    m = struct();
    m.SSerr     = abs(mean(e(max(1,end-9):end)));
    idx        = find(abs(e)<0.02,1);
    m.SettTime = ~isempty(idx)*t(idx) + isempty(idx)*t(end);
    m.Overshoot= max(abs(e));
    m.Effort   = std(d);
    m.RMSE     = sqrt(mean(e.^2));
    m.Eff      = 1 - mean(abs(d - 0.5));
    m.Robust   = max(0, 100 - abs(sc.Ldev) - abs(sc.Cdev) - 10*sc.Dist);

    out.metrics = m;
end
