function K_hinf = get_Hinf_controller()
%GET_HINF_CONTROLLER Küçük-sinyal H∞ kontrolcüsünü döner
%
%   K_hinf = get_Hinf_controller();

    %% 1) Küçük-sinyal Flyback Modeli
    Lm    = 2.82e-6;    % [H]
    Cout  = 100e-9;     % [F]
    Rload = 220e3;      % [Ω]
    Vin   = 12;         % [V]
    N     = 2;          % Ns/Np

    A = [   0,     -N/Lm;
          N/Cout,  -1/(Rload*Cout) ];
    B = [Vin/Lm; 0];
    C = [0 1];
    D = 0;
    P = ss(A, B, C, D);
    P.InputName  = 'duty';
    P.OutputName = 'vout';

    %% 2) Ağırlık Fonksiyonları
    Wp = makeweight(100, 2*pi*1e3, 0.01);
    Wu = makeweight(0.01, 2*pi*1e6, 100);
    P_aug = augw(P, Wp, [], Wu);

    %% 3) H∞ Kontrolcü Sentezi
    try
        [K_hinf, ~, gamma_hinf] = hinfsyn(P_aug, 1, 1);
        fprintf('H∞ controller created successfully. γ = %.4f\n', gamma_hinf);
        
        % Verify the controller is stable
        if ~isstable(K_hinf)
            warning('H-infinity controller is not stable');
        end
        
    catch ME
        fprintf('Error in H-infinity synthesis: %s\n', ME.message);
        % Return a simple proportional controller as fallback
        K_hinf = tf(1, 1);
        warning('Using fallback proportional controller');
    end
end