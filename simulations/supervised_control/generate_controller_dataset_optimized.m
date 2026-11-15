function flyback_dataset = generate_controller_dataset_optimized()
    % Kontrolör isimleri
    controllers = {'PI','Hinf','H2','Fuzzy','MuSyn'};
    nC = numel(controllers);

    % Test parametreleri
    [Vref, Rload, Ldev, Cdev, Dist, Tstep] = ndgrid(...
        [3.3,5,12], [50e3,100e3,220e3,470e3], [-20,0,20], [-20,0,20], [0,0.2,0.5], [1e-3,5e-3,10e-3]);
    scenarios = table(...
        Vref(:), Rload(:), Ldev(:), Cdev(:), Dist(:), Tstep(:), ...
        'VariableNames', {'Vref','Rload','Ldev','Cdev','Dist','Tstep'});
    nS = size(scenarios,1);

    % Genişletilmiş senaryo ve kontrolcü indeks dizileri
    [SC_idx, C_idx] = ndgrid(1:nS, 1:nC);
    SC_idx = SC_idx(:);
    C_idx  = C_idx(:);

    % Tek arrayfun çağrısıyla simülasyon + metrik
    results = arrayfun(@(s,c) simulate_and_metric(scenarios(s,:), controllers{c}), ...
                       SC_idx, C_idx, 'UniformOutput', false);

    % Sonuçları ayıkla
    M = cell2mat(cellfun(@(r) struct2array(r.metrics), results, 'UniformOutput', false));
    ctrlNames = controllers(C_idx)';

    % Tablo oluştur
    F = {'SSerr','SettTime','Overshoot','Effort','RMSE','Eff','Robust'};
    flyback_dataset = array2table(M, 'VariableNames', F);
    flyback_dataset.Controller = ctrlNames;

    % Normalize et
    flyback_dataset{:,F} = (flyback_dataset{:,F} - min(flyback_dataset{:,F})) ...
                          ./ (max(flyback_dataset{:,F}) - min(flyback_dataset{:,F}));

    fprintf('Oluşturulan örnek sayısı: %d\n', height(flyback_dataset));
end

function out = simulate_and_metric(sc, ctrl)
    % Tek fonksiyon içinde simülasyon ve metrik hesaplama
    % --- run_sim kısmı ---
    % (Buraya kendi sim kodun gelecek; aşağıda placeholder)
    N = 100;
    sim.error = randn(1,N);
    sim.duty  = rand(1,N);
    sim.time  = linspace(0, sc.Tstep*5, N);

    % --- calc_metrics kısmı ---
    e = sim.error; d = sim.duty; t = sim.time;
    m.SSerr     = abs(mean(e(end-10:end)));
    idxSettle   = find(abs(e)<0.02,1);
    m.SettTime  = t(idxSettle);
    m.Overshoot = max(e);
    m.Effort    = std(d);
    m.RMSE      = sqrt(mean(e.^2));
    m.Eff       = 1 - mean(d);
    m.Robust    = 100 - abs(sc.Ldev) - abs(sc.Cdev);

    out.metrics = m;
end
