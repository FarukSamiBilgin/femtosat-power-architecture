function K_hinf = get_Hinf_controller()
%GET_HINF_CONTROLLER  H∞ kontrolcüsünü oluşturur ve döner.

% --- 1) Flyback küçük-sinyal modeli P(s) ---
Vin   = 12;         % V
N     = 2;          % dönüşüm oranı
Cout  = 100e-9;     % F
Rload = 220e3;      % Ω
s = tf('s');
P = (Vin/N) * 1/(Rload*Cout) * 1/(s + 1/(Rload*Cout));

% --- 2) Ağırlık fonksiyonları ---
Wp = makeweight(10,2e3,0.1);  % LFC için
Wu = tf(0.001);               % kontrol çabası cezası (sabit)

% --- 3) Augment edilmiş sistem ---
Paug = augw(P, Wp, [], Wu);

% --- 4) H∞ sentez ---
nmeas = 1; nctrl = 1;
[K_hinf, ~, ~] = hinfsyn(Paug, nmeas, nctrl);

end
