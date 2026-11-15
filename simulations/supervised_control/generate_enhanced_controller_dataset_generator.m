function generate_enhanced_controller_dataset()
% GENERATE_ENHANCED_CONTROLLER_DATASET
% Flyback konvertörü için farklı kontrolörlerin performans verilerini toplar
% Neural Network eğitimi için kapsamlı dataset oluşturur

fprintf('=== Enhanced Controller Dataset Generation ===\n\n');

%% 1) Test Senaryoları Tanımlama
test_scenarios = define_test_scenarios();
n_scenarios = length(test_scenarios);

%% 2) Kontrolörleri Hazırla
controllers = prepare_controllers();
n_controllers = length(controllers.names);

fprintf('Controllers prepared: %s\n', strjoin(controllers.names, ', '));
fprintf('Test scenarios: %d\n', n_scenarios);

%% 3) Dataset Arrays
dataset = initialize_dataset(n_scenarios, n_controllers);

%% 4) Her Senaryo için Test
fprintf('\nRunning simulations...\n');
for i = 1:n_scenarios
    if mod(i, 10) == 0
        fprintf('Progress: %d/%d scenarios completed\n', i, n_scenarios);
    end
    
    scenario = test_scenarios(i);
    
    % Her kontrolör için simülasyon
    for j = 1:n_controllers
        try
            % Simülasyon çalıştır
            result = run_controller_simulation(controllers, j, scenario);
            
            % Performance metrikleri hesapla
            metrics = calculate_performance_metrics(result, scenario);
            
            % Dataset'e kaydet
            dataset = store_results(dataset, i, j, scenario, metrics);
            
        catch ME
            fprintf('Warning: Error in scenario %d, controller %d: %s\n', ...
                    i, j, ME.message);
            % Default değerler ile doldur
            dataset = store_default_results(dataset, i, j, scenario);
        end
    end
end

%% 5) Dataset'i Normalize Et ve Kaydet
dataset_final = normalize_and_finalize(dataset);

% CSV olarak kaydet
writetable(dataset_final.table, 'flyback_controller_dataset.csv');

% MAT olarak da kaydet
save('flyback_controller_dataset.mat', 'dataset_final');

fprintf('\n=== Dataset Generation Complete ===\n');
fprintf('Total samples: %d\n', height(dataset_final.table));
fprintf('Features: %d\n', width(dataset_final.table) - n_controllers);
fprintf('Files saved: flyback_controller_dataset.csv, flyback_controller_dataset.mat\n');

% İstatistikleri göster
show_dataset_statistics(dataset_final);

end

%% ========================================================================
function scenarios = define_test_scenarios()
% Test senaryolarını tanımla

fprintf('Defining test scenarios...\n');

% Parametre aralıkları
ref_values = [3.3, 5.0, 12.0];                    % Referans voltaj
load_variations = [50e3, 100e3, 220e3, 470e3];   % Yük direnci
param_deviations = [-20, -10, 0, 10, 20];        % % sapma
disturbance_levels = [0, 0.1, 0.2, 0.5];         % Bozucu seviyesi

% Step değişim zamanları
step_times = [1e-3, 5e-3, 10e-3];

scenarios = [];
idx = 1;

for vref = ref_values
    for rload = load_variations
        for l_dev = param_deviations
            for c_dev = param_deviations
                for dist = disturbance_levels
                    for step_t = step_times
                        scenarios(idx).vref = vref;
                        scenarios(idx).rload = rload;
                        scenarios(idx).l_deviation = l_dev;
                        scenarios(idx).c_deviation = c_dev;
                        scenarios(idx).disturbance = dist;
                        scenarios(idx).step_time = step_t;
                        scenarios(idx).simulation_time = 20e-3; % 20ms
                        idx = idx + 1;
                    end
                end
            end
        end
    end
end

fprintf('Total scenarios generated: %d\n', length(scenarios));
end

%% ========================================================================
function controllers = prepare_controllers()
% Kontrolörleri hazırla

fprintf('Preparing controllers...\n');

controllers.names = {'PI', 'Hinf', 'H2', 'Fuzzy', 'MuSyn'};

try
    % PI Controller (basit)
    controllers.pi.kp = 1e4;
    controllers.pi.ki = 1e6;
    
    % H∞ Controller
    controllers.hinf = get_Hinf_controller();
    
    % H2 Controller  
    controllers.h2 = get_H2_controller();
    
    % Fuzzy Controller
    if exist('NanoFlyback_FuzzyController.mat', 'file')
        load('NanoFlyback_FuzzyController.mat', 'fis');
        controllers.fuzzy = fis;
    else
        controllers.fuzzy = create_simple_fuzzy();
    end
    
    % μ-Synthesis Controller
    controllers.musyn = get_mu_controller();
    
    fprintf('All controllers prepared successfully.\n');
    
catch ME
    fprintf('Warning: Some controllers failed to load: %s\n', ME.message);
    % Basit fallback kontrolörler oluştur
    controllers = create_fallback_controllers();
end

end

%% ========================================================================
function result = run_controller_simulation(controllers, ctrl_idx, scenario)
% Belirli bir kontrolör ve senaryo için simülasyon çalıştır

% Sistem parametreleri
Lm_base = 2.82e-6;
Cout_base = 100e-9;
Vin = 12;
N = 2;

% Sapmalı parametreler
Lm = Lm_base * (1 + scenario.l_deviation/100);
Cout = Cout_base * (1 + scenario.c_deviation/100);
Rload = scenario.rload;

% Simülasyon parametreleri
dt = 1e-6;  % 1 μs
t_sim = scenario.simulation_time;
t = 0:dt:t_sim;
n_steps = length(t);

% Başlangıç koşulları
vout = zeros(size(t));
il = zeros(size(t));
duty = zeros(size(t));
error_sig = zeros(size(t));

% Referans sinyal
vref = scenario.vref * ones(size(t));
% Step değişimi
step_idx = find(t >= scenario.step_time, 1);
if ~isempty(step_idx)
    vref(step_idx:end) = vref(step_idx:end) * 1.2; % %20 artış
end

% Bozucu sinyal
disturbance = scenario.disturbance * sin(2*pi*1000*t); % 1kHz

% PI integratörü
integral_error = 0;

% Simülasyon döngüsü
for k = 2:n_steps
    % Hata hesapla
    error_sig(k-1) = vref(k-1) - vout(k-1);
    
    % Kontrolör çıkışı hesapla
    switch ctrl_idx
        case 1 % PI
            integral_error = integral_error + error_sig(k-1) * dt;
            duty(k-1) = controllers.pi.kp * error_sig(k-1) + ...
                       controllers.pi.ki * integral_error;
            
        case 2 % H∞
            if k > 2
                % Basit diskretizasyon
                u_input = [error_sig(k-2); error_sig(k-1)];
                try
                    y_ctrl = lsim(controllers.hinf, u_input, [t(k-2) t(k-1)]);
                    duty(k-1) = y_ctrl(end);
                catch
                    duty(k-1) = 0.5; % Güvenli değer
                end
            else
                duty(k-1) = 0.5;
            end
            
        case 3 % H2
            if k > 2
                u_input = [error_sig(k-2); error_sig(k-1)];
                try
                    y_ctrl = lsim(controllers.h2, u_input, [t(k-2) t(k-1)]);
                    duty(k-1) = y_ctrl(end);
                catch
                    duty(k-1) = 0.5;
                end
            else
                duty(k-1) = 0.5;
            end
            
        case 4 % Fuzzy
            if k > 2
                error_norm = error_sig(k-1) / 5; % Normalize
                d_error = (error_sig(k-1) - error_sig(k-2)) / dt / 1000;
                try
                    duty(k-1) = evalfis(controllers.fuzzy, [error_norm, d_error]);
                catch
                    duty(k-1) = 0.5;
                end
            else
                duty(k-1) = 0.5;
            end
            
        case 5 % μ-Synthesis
            if k > 2
                u_input = [error_sig(k-2); error_sig(k-1)];
                try
                    y_ctrl = lsim(controllers.musyn, u_input, [t(k-2) t(k-1)]);
                    duty(k-1) = y_ctrl(end);
                catch
                    duty(k-1) = 0.5;
                end
            else
                duty(k-1) = 0.5;
            end
    end
    
    % Duty cycle sınırla
    duty(k-1) = max(0, min(1, duty(k-1)));
    
    % Plant dinamikleri (basitleştirilmiş)
    if duty(k-1) > 0
        dil_dt = Vin / Lm;
    else
        dil_dt = -N * vout(k-1) / Lm;
    end
    
    il(k) = max(0, il(k-1) + dil_dt * dt * duty(k-1));
    
    % Çıkış voltajı
    isec = il(k) / N;
    iload = vout(k-1) / Rload;
    dvout_dt = (isec - iload) / Cout;
    vout(k) = vout(k-1) + dvout_dt * dt + disturbance(k-1);
end

% Sonuçları yapılandır
result.time = t;
result.vout = vout;
result.vref = vref;
result.duty = duty;
result.current = il;
result.error = error_sig;

end

%% ========================================================================
function metrics = calculate_performance_metrics(result, scenario)
% Performance metriklerini hesapla

% Step response analizi
step_start_idx = find(result.time >= scenario.step_time, 1);
if isempty(step_start_idx)
    step_start_idx = 1;
end

% Steady state değeri (son %10'un ortalaması)
steady_start = round(0.9 * length(result.vout));
vout_ss = mean(result.vout(steady_start:end));
vref_final = result.vref(end);

% 1. Steady-state error
metrics.ss_error = abs(vref_final - vout_ss) / vref_final * 100; % %

% 2. Settling time (%2 band)
settling_band = 0.02 * vref_final;
settled_indices = find(abs(result.vout(step_start_idx:end) - vref_final) <= settling_band);
if ~isempty(settled_indices)
    metrics.settling_time = result.time(step_start_idx + settled_indices(1) - 1) - scenario.step_time;
else
    metrics.settling_time = scenario.simulation_time; % Yerleşmedi
end

% 3. Overshoot
vout_step = result.vout(step_start_idx:end);
max_overshoot = max(vout_step) - vref_final;
metrics.overshoot = max(0, max_overshoot / vref_final * 100); % %

% 4. Control effort (duty cycle değişim miktarı)
duty_variation = std(result.duty);
metrics.control_effort = duty_variation;

% 5. RMS error
metrics.rms_error = sqrt(mean(result.error.^2));

% 6. Power efficiency (yaklaşık)
avg_duty = mean(result.duty);
metrics.efficiency = min(100, (1 - avg_duty * 0.1) * 100); % Basit model

% 7. Robustness score (parametre sapmalarına dayanıklılık)
param_dev = abs(scenario.l_deviation) + abs(scenario.c_deviation);
if param_dev == 0
    metrics.robustness = 100;
else
    metrics.robustness = max(0, 100 - param_dev - metrics.ss_error);
end

end

%% ========================================================================
function dataset = initialize_dataset(n_scenarios, n_controllers)
% Dataset yapısını başlat

dataset.features = [];
dataset.labels = [];
dataset.scenario_info = [];

end

%% ========================================================================
function dataset = store_results(dataset, scenario_idx, ctrl_idx, scenario, metrics)
% Sonuçları dataset'e kaydet

% Feature vector oluştur
features = [
    scenario.vref,
    scenario.rload / 1e3,  % kΩ cinsinden
    scenario.l_deviation,
    scenario.c_deviation,
    scenario.disturbance,
    scenario.step_time * 1e3, % ms cinsinden
];

% Label vector (controller performance)
labels = [
    metrics.ss_error,
    metrics.settling_time * 1e3, % ms
    metrics.overshoot,
    metrics.control_effort,
    metrics.rms_error,
    metrics.efficiency,
    metrics.robustness,
    ctrl_idx  % Hangi kontrolör
];

% Dataset'e ekle
dataset.features = [dataset.features; features];
dataset.labels = [dataset.labels; labels];

% Senaryo bilgisi
scenario_info = [scenario_idx, ctrl_idx];
dataset.scenario_info = [dataset.scenario_info; scenario_info];

end

%% ========================================================================
function dataset = store_default_results(dataset, scenario_idx, ctrl_idx, scenario)
% Hata durumunda default değerler

features = [
    scenario.vref,
    scenario.rload / 1e3,
    scenario.l_deviation,
    scenario.c_deviation,
    scenario.disturbance,
    scenario.step_time * 1e3,
];

% Kötü performans değerleri
labels = [
    50,    % ss_error
    20,    % settling_time (ms)
    100,   % overshoot
    1,     % control_effort
    1,     % rms_error
    50,    % efficiency
    0,     % robustness
    ctrl_idx
];

dataset.features = [dataset.features; features];
dataset.labels = [dataset.labels; labels];
dataset.scenario_info = [dataset.scenario_info; scenario_info];

end

%% ========================================================================
function dataset_final = normalize_and_finalize(dataset)
% Dataset'i normalize et ve tablo formatına çevir

fprintf('Normalizing and finalizing dataset...\n');

% Feature isimleri
feature_names = {'Vref', 'Rload_kOhm', 'L_dev_pct', 'C_dev_pct', ...
                 'Disturbance', 'StepTime_ms'};

% Label isimleri  
label_names = {'SS_Error_pct', 'SettlingTime_ms', 'Overshoot_pct', ...
               'ControlEffort', 'RMS_Error', 'Efficiency_pct', ...
               'Robustness', 'Controller_ID'};

% Normalizasyon (Controller_ID hariç)
features_norm = dataset.features;
labels_norm = dataset.labels;

% Features normalize et
for i = 1:size(features_norm, 2)
    col_data = features_norm(:, i);
    features_norm(:, i) = (col_data - min(col_data)) / (max(col_data) - min(col_data));
end

% Labels normalize et (Controller_ID hariç)
for i = 1:size(labels_norm, 2)-1  % Son kolon Controller_ID
    col_data = labels_norm(:, i);
    if max(col_data) > min(col_data)
        labels_norm(:, i) = (col_data - min(col_data)) / (max(col_data) - min(col_data));
    end
end

% Tablo oluştur
all_data = [features_norm, labels_norm];
all_names = [feature_names, label_names];

dataset_final.table = array2table(all_data, 'VariableNames', all_names);
dataset_final.raw_features = dataset.features;
dataset_final.raw_labels = dataset.labels;
dataset_final.feature_names = feature_names;
dataset_final.label_names = label_names;

end

%% ========================================================================
function show_dataset_statistics(dataset_final)
% Dataset istatistiklerini göster

fprintf('\n=== Dataset Statistics ===\n');

% Controller dağılımı
controller_counts = histcounts(dataset_final.table.Controller_ID, 1:6);
controller_names = {'PI', 'Hinf', 'H2', 'Fuzzy', 'MuSyn'};

fprintf('Controller distribution:\n');
for i = 1:length(controller_names)
    fprintf('  %s: %d samples\n', controller_names{i}, controller_counts(i));
end

% Feature statistics
fprintf('\nFeature ranges (normalized):\n');
for i = 1:length(dataset_final.feature_names)
    col_data = dataset_final.table{:, i};
    fprintf('  %s: [%.3f, %.3f]\n', dataset_final.feature_names{i}, ...
            min(col_data), max(col_data));
end

end

%% ========================================================================
function controllers = create_fallback_controllers()
% Basit fallback kontrolörler

controllers.names = {'PI'};
controllers.pi.kp = 1e4;
controllers.pi.ki = 1e6;

end

%% ========================================================================
function fis = create_simple_fuzzy()
% Basit fuzzy kontrolör

fis = mamfis('Name','SimpleFuzzy');
fis = addInput(fis, [-1 1], 'Name', 'error');
fis = addOutput(fis, [0 1], 'Name', 'duty');

fis = addMF(fis, 'error', 'trimf', [-1 -1 0], 'Name', 'Neg');
fis = addMF(fis, 'error', 'trimf', [-0.5 0 0.5], 'Name', 'Zero');
fis = addMF(fis, 'error', 'trimf', [0 1 1], 'Name', 'Pos');

fis = addMF(fis, 'duty', 'trimf', [0 0 0.5], 'Name', 'Low');
fis = addMF(fis, 'duty', 'trimf', [0.25 0.5 0.75], 'Name', 'Med');
fis = addMF(fis, 'duty', 'trimf', [0.5 1 1], 'Name', 'High');

rules = [1 1 1 1; 2 2 1 1; 3 3 1 1];
fis = addRule(fis, rules);

end