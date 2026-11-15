function generate_controller_dataset()
    % Clear workspace but keep the function scope
    
    % 1) H∞ ve H2 kontrolcüleri hazırla
    fprintf('Creating H-infinity controller...\n');
    K_hinf = get_Hinf_controller();
    
    fprintf('Creating H2 controller...\n');
    K_h2 = get_H2_controller();
    
    % 2) Fuzzy FIS'i script ile workspace'e getir
    fprintf('Loading Fuzzy controller...\n');
    % Load the saved FIS instead of running the script to avoid clearing variables
    if exist('NanoFlyback_FuzzyController.mat', 'file')
        load('NanoFlyback_FuzzyController.mat', 'fis');
    else
        % If .mat file doesn't exist, create the FIS directly
        fis = create_fuzzy_controller();
    end
    
    % Verify controllers are loaded
    if ~exist('K_hinf', 'var') || isempty(K_hinf)
        error('H-infinity controller not loaded properly');
    end
    if ~exist('K_h2', 'var') || isempty(K_h2)
        error('H2 controller not loaded properly');
    end
    if ~exist('fis', 'var') || isempty(fis)
        error('Fuzzy controller not loaded properly');
    end
    
    fprintf('All controllers loaded successfully.\n');
    
    % 3) (e,de) grid'i
    Ngrid   = 201;
    e_list  = linspace(-1, 1, Ngrid);
    de_list = linspace(-1, 1, Ngrid);
    [E, DE] = meshgrid(e_list, de_list);
    pts     = [E(:), DE(:)];
    
    % 4) lsim için kısa zaman vektörü
    Tsim = [0 1e-4];
    tvec = linspace(Tsim(1), Tsim(2), 2);
    
    nPts = size(pts, 1);
    d_hinf  = zeros(nPts, 1);
    d_h2    = zeros(nPts, 1);
    
    fprintf('Computing controller outputs for %d points...\n', nPts);
    
    % Progress indicator
    progress_step = floor(nPts / 10);
    
    for k = 1:nPts
        if mod(k, progress_step) == 0
            fprintf('Progress: %d%%\n', round(100 * k / nPts));
        end
        
        uin = pts(k, :).';
        
        try
            % Use step response instead of lsim for better stability
            y1 = step(K_hinf, tvec);
            y2 = step(K_h2, tvec);
            
            % Scale by input magnitude
            input_magnitude = norm(uin);
            d_hinf(k) = y1(end) * input_magnitude;
            d_h2(k) = y2(end) * input_magnitude;
            
        catch ME
            fprintf('Warning: Error at point %d: %s\n', k, ME.message);
            d_hinf(k) = 0;
            d_h2(k) = 0;
        end
    end
    
    % 5) Fuzzy çıktısı
    fprintf('Computing fuzzy outputs...\n');
    try
        % Scale inputs to fuzzy controller range
        pts_scaled = pts;
        pts_scaled(:,1) = pts_scaled(:,1) * 0.5; % error range [-0.5, 0.5]
        pts_scaled(:,2) = pts_scaled(:,2) * 0.1; % deltaError range [-0.1, 0.1]
        
        d_fuzzy = evalfis(fis, pts_scaled);
    catch ME
        fprintf('Error in fuzzy evaluation: %s\n', ME.message);
        d_fuzzy = 0.5 * ones(nPts, 1); % Default to mid-range
    end
    
    % 6) [0…1] aralığına kırp ve normalize
    d_hinf = normalize_output(d_hinf);
    d_h2 = normalize_output(d_h2);
    d_fuzzy = max(0, min(1, d_fuzzy));
    
    % 7) CSV yaz
    fprintf('Writing to CSV...\n');
    T = table(pts(:,1), pts(:,2), d_hinf, d_h2, d_fuzzy, ...
              'VariableNames', {'e', 'de', 'duty_hinf', 'duty_h2', 'duty_fuzzy'});
    
    writetable(T, 'controller_dataset.csv');
    fprintf('controller_dataset.csv created successfully with %d data points.\n', nPts);
    
    % Display some statistics
    fprintf('\nDataset Statistics:\n');
    fprintf('H-inf duty range: [%.3f, %.3f]\n', min(d_hinf), max(d_hinf));
    fprintf('H2 duty range: [%.3f, %.3f]\n', min(d_h2), max(d_h2));
    fprintf('Fuzzy duty range: [%.3f, %.3f]\n', min(d_fuzzy), max(d_fuzzy));
end

function output_norm = normalize_output(output)
    % Normalize output to [0, 1] range
    output_min = min(output);
    output_max = max(output);
    
    if output_max == output_min
        output_norm = 0.5 * ones(size(output));
    else
        output_norm = (output - output_min) / (output_max - output_min);
    end
end

function fis = create_fuzzy_controller()
    % Create fuzzy controller directly without clearing variables
    fis = mamfis('Name','NanoFlybackFuzzy');
    
    % Input variables
    fis = addInput(fis, [-0.5  0.5], 'Name','error');
    fis = addInput(fis, [-0.1  0.1], 'Name','deltaError');
    
    % Output variable
    fis = addOutput(fis, [0 1], 'Name','duty');
    
    % Membership functions for error
    fis = addMF(fis, 'error', 'trapmf', [-0.5 -0.5 -0.3 -0.1], 'Name','Neg');
    fis = addMF(fis, 'error', 'trimf', [-0.3  0    0.3],    'Name','Zero');
    fis = addMF(fis, 'error', 'trapmf', [ 0.1  0.3  0.5  0.5], 'Name','Pos');
    
    % Membership functions for deltaError
    fis = addMF(fis, 'deltaError', 'trapmf', [-0.1 -0.1 -0.05 0],   'Name','Neg');
    fis = addMF(fis, 'deltaError', 'trimf', [-0.05 0    0.05],    'Name','Zero');
    fis = addMF(fis, 'deltaError', 'trapmf', [ 0    0.05 0.1  0.1], 'Name','Pos');
    
    % Membership functions for duty
    fis = addMF(fis, 'duty', 'trapmf', [0 0   0.1 0.3], 'Name','Low');
    fis = addMF(fis, 'duty', 'trimf', [ 0.1 0.5 0.9 ],    'Name','Medium');
    fis = addMF(fis, 'duty', 'trapmf', [ 0.7 0.9 1.0 1.0], 'Name','High');
    
    % Rule list
    ruleList = [
        1        1            1       1       1;
        1        2            1       1       1;
        1        3            2       1       1;
        2        1            1       1       1;
        2        2            2       1       1;
        2        3            3       1       1;
        3        1            2       1       1;
        3        2            3       1       1;
        3        3            3       1       1;
    ];
    
    fis = addRule(fis, ruleList);
end