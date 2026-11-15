% mu_synthesis_flyback_with_proper_integral.m
% μ-Synthesis ile nano-flyback kontrolcüsü tasarımı; DC sapmayı sıfırlamak için stabil integratör

clear; close all; clc;

%% 1) Belirsiz Parametreler
dLm = ureal('Lm',   2.82e-6, 'Percentage', 20);   % ±20% indüktans
dR  = ureal('Rload',220e3,  'Percentage', 10);   % ±10% yük direnci

%% 2) Küçük-sinyal Model (Belirsiz)
Cout = 100e-9;   % [F]
Vin  = 12;      % [V]
N    = 2;       % Ns/Np

A_unc = [    0,     -N/dLm;
         N/Cout,  -1/(dR*Cout) ];
B_unc = [Vin/dLm;  0];
C_unc = [0 1];
D_unc = 0;

P_unc = ss(A_unc, B_unc, C_unc, D_unc);
P_unc.InputName  = 'duty';
P_unc.OutputName = 'vout';

%% 3) Ağırlık Fonksiyonları
s = tf('s');

% -- Performans Ağırlığı Wp_int --
%   • makeweight: 100 (DC kazancı), 1 kHz köşe, HF atten 0.01
%   • integratör: 10/(s + 1e-3) → s=0'da stabil pole
int_tf = tf(10, [1 1e-3]);  
Wp_int = makeweight(100, 2*pi*1e3, 0.01) * int_tf;

% -- Kontrol Çabası Wu --
%   • DC’de hafif cezai, HF’de daha agresif corner @5e5 rad/s
Wu = makeweight(0.01, 2*pi*5e5, 100);

% Augmented plant
P_aug = augw(P_unc, Wp_int, [], Wu);

%% 4) μ-Sentez
nmeas = 1;   % ölçülen çıkış sayısı
nctrl = 1;   % kontrol girişi sayısı
[K_mu, CL_mu, gamma_mu] = dksyn(P_aug, nmeas, nctrl);
fprintf('Yeni μ upper bound = %.3f\n', gamma_mu);

%% 5) Kapalı-Çevrim Transfer Fonksiyonları
T_mu = feedback(P_unc * K_mu, 1);   % r → vout
S_mu = feedback(1,     P_unc * K_mu);% disturbance hassasiyeti
U_mu = K_mu * S_mu;                 % r → duty

%% 6) Sonuçların Görselleştirilmesi

% 6.1 Bode (Ref → Vout)
figure('Name','μ-Synthesis Bode (Ref→Vout)');
bode(T_mu, {1e1, 1e6}); 
grid on;
title('Closed-Loop (Ref → V_{out}) with μ-Synthesis + Proper Integral');

% 6.2 Step Yanıtı (3.3 V referans)
t = linspace(0,0.01,1000);
y = step(T_mu * 3.3, t);
figure('Name','Step Response');
plot(t*1e3, y, 'LineWidth',1.4);
xlabel('Time (ms)'); ylabel('V_{out} (V)');
title('Step Response to 3.3V');
grid on;

% 6.3 Kontrol Çabası (Duty)
u = lsim(U_mu, 3.3*ones(size(t)), t);
figure('Name','Control Effort');
plot(t*1e3, u, 'r', 'LineWidth',1.4);
xlabel('Time (ms)'); ylabel('Duty');
title('Control Effort with μ-Synthesis + Proper Integral');
grid on;
