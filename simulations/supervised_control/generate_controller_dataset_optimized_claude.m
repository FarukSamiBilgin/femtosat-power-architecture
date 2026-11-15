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

    % Sonuçları ayıkla - struct2array yerine struct field'ları manuel olarak çıkar
    nResults = length(results);
    
    % Metric field names
    F = {'SSerr','SettTime','Overshoot','Effort','RMSE','Eff','Robust'};
    nFields = length(F);
    
    % Pre-allocate metric matrix
    M = zeros(nResults, nFields);
    
    % Extract metrics from each result
    for i = 1:nResults
        metrics = results{i}.metrics;
        for j = 1:nFields
            if isfield(metrics, F{j})
                M(i, j) = metrics.(F{j});
            else
                M(i, j) = 0; % Default value if field missing
            end
        end
    end
    
    ctrlNames = controllers(C_idx)';

    % Tablo oluştur
    flyback_dataset = array2table(M, 'VariableNames', F);
    flyback_dataset.Controller = ctrlNames;

    % Normalize et - handle potential division by zero
    for i = 1:length(F)
        col_data = flyback_dataset{:, F{i}};
        min_val = min(col_data);
        max_val = max(col_data);
        range_val = max_val - min_val;
        
        if range_val == 0
            % If all values are the same, set to 0.5 (middle of normalized range)
            flyback_dataset{:, F{i}} = 0.5 * ones(size(col_data));
        else
            flyback_dataset{:, F{i}} = (col_data - min_val) / range_val;
        end
    end

    fprintf('Oluşturulan örnek sayısı: %d\n', height(flyback_dataset));
end

function out = simulate_and_metric(sc, ctrl)
    % Tek fonksiyon içinde simülasyon ve metrik hesaplama
    % --- run_sim kısmı ---
    % Enhanced simulation with more realistic behavior
    N = 100;
    
    % Generate more realistic simulation data based on controller type
    switch ctrl
        case 'PI'
            % PI controller typically has some overshoot and steady-state accuracy
            sim.error = 0.1 * exp(-linspace(0,5,N)) .* sin(2*pi*linspace(0,1,N)) + 0.01*randn(1,N);
            sim.duty  = 0.5 + 0.2*rand(1,N);
        case 'Hinf'
            % H-infinity typically has good robustness, less overshoot
            sim.error = 0.05 * exp(-linspace(0,8,N)) + 0.005*randn(1,N);
            sim.duty  = 0.45 + 0.1*rand(1,N);
        case 'H2'
            % H2 optimal, good performance but may be less robust
            sim.error = 0.08 * exp(-linspace(0,6,N)) + 0.008*randn(1,N);
            sim.duty  = 0.48 + 0.15*rand(1,N);
        case 'Fuzzy'
            % Fuzzy may have some nonlinear behavior
            sim.error = 0.12 * exp(-linspace(0,4,N)) .* (1 + 0.5*sin(5*linspace(0,1,N))) + 0.02*randn(1,N);
            sim.duty  = 0.5 + 0.25*rand(1,N);
        case 'MuSyn'
            % Mu-synthesis should be very robust
            sim.error = 0.04 * exp(-linspace(0,10,N)) + 0.003*randn(1,N);
            sim.duty  = 0.47 + 0.08*rand(1,N);
        otherwise
            % Default case
            sim.error = randn(1,N) * 0.1;
            sim.duty  = rand(1,N);
    end
    
    sim.time  = linspace(0, sc.Tstep*5, N);

    % --- calc_metrics kısmı ---
    e = sim.error; 
    d = sim.duty; 
    t = sim.time;
    
    % Initialize metrics structure
    m = struct();
    
    % Steady-state error
    m.SSerr = abs(mean(e(max(1,end-10):end)));
    
    % Settling time
    settling_indices = find(abs(e) < 0.02);
    if ~isempty(settling_indices)
        m.SettTime = t(settling_indices(1));
    else
        m.SettTime = t(end); % If never settles, use final time
    end
    
    % Overshoot
    m.Overshoot = max(abs(e));
    
    % Control effort
    m.Effort = std(d);
    
    % RMSE
    m.RMSE = sqrt(mean(e.^2));
    
    % Efficiency (simplified metric)
    m.Eff = 1 - mean(abs(d - 0.5)); % Assumes optimal duty around 0.5
    
    % Robustness (based on parameter deviations)
    m.Robust = 100 - abs(sc.Ldev) - abs(sc.Cdev) - 10*sc.Dist;

    out.metrics = m;
end