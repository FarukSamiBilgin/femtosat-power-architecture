%% NanoFlyback_MPC_full_fixed.m
clear; close all; clc;

%% 1) Fiziksel Parametreler
Vin   = 12;           % [V]
N     = 2;            % Ns/Np
Cout  = 100e-9;       % [F]
Rload = 220e3;        % [Ω]
Vref  = 3.3;          % [V]

%% 2) Küçük-Sinyal Ortalama Model → Ayrık
A = -1/(Rload*Cout);
B =  Vin/(N*Rload*Cout);
C = 1;  D = 0;
Ts = 1e-5;
plant_c = ss(A,B,C,D);
plant_d = c2d(plant_c, Ts);

%% 3) MPC Oluştur ve Tünele
p = 10;    % prediction horizon
m = 2;     % control horizon
mpcobj = mpc(plant_d, Ts, p, m);

% MV sınırları
mpcobj.MV.Min = 0;
mpcobj.MV.Max = 1;

% Ağırlıklar
mpcobj.Weights.ManipulatedVariables     = 0.1;
mpcobj.Weights.ManipulatedVariablesRate = 0.1;
mpcobj.Weights.OutputVariables          = 1.0;

%% 4) MPC State’i Bir Kez Oluştur
x_mpc = mpcstate(mpcobj);
if ~isa(x_mpc,'mpcstate')
    error('MPCSTATE oluşturulamadı!');
end

%% 5) Simülasyon Hazırlığı
Tsim = 0.05;                 % Toplam simülasyon süresi [s]
time = 0:Ts:Tsim;
vout = zeros(size(time));   
duty = zeros(size(time));
vout(1)  = 0;                % Başlangıç çıkışı
duty(1)  = 0.1;              % İlk duty

%% 6) Kapanış Döngüsü
for k = 2:length(time)
    yk = vout(k-1);  
    % MPC adımı: uk ve güncellenmiş state
    [uk, x_mpc] = mpcmove(mpcobj, x_mpc, yk, Vref);
    duty(k) = uk;
    % Ortalama model entegrasyonu
    dv = (uk*Vin/N - vout(k-1)) / (Rload*Cout);
    vout(k) = vout(k-1) + dv*Ts;
end

%% 7) Sonuçların Çizimi
figure('Position',[100 100 700 450]);
subplot(2,1,1);
plot(time*1e3, vout, 'LineWidth',1.5);
grid on;
xlabel('Zaman [ms]'); ylabel('V_{out} [V]');
title('MPC Kontrollü Flyback: Çıkış Gerilimi');

subplot(2,1,2);
plot(time*1e3, duty, 'r', 'LineWidth',1.5);
grid on;
xlabel('Zaman [ms]'); ylabel('Duty');
title('MPC Çıkış Sinyali');
