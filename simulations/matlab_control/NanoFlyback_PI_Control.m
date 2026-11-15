% flyback_control_extended.m
clear; clc; close all;

%% 1) Parametreler
fsw   = 10e6;           % 10 MHz
Ts    = 1/fsw;          % 100 ns
Tsim  = 50e-3;          % 50 ms
N     = floor(Tsim/Ts);

Vin    = 12;            % V
Lm     = 2.82e-6;       % H
NsNp   = 2;             % dönüşüm oranı
Cout   = 10e-9;         % 10 nF (daha hızlı tepki)
Rload  = 100e3;         % 100 kΩ
Imax   = 1e-3;          % 1 mA sınırı

% Daha agresif PI ayarları
Kpv    = 1e5;           
Kiv    = 5e7;           

%% 2) Durum Değişkenleri
Vout   = zeros(1,N);
IL     = zeros(1,N);
duty   = zeros(1,N);
int_v  = 0;

Vout(1) = 0;
IL(1)   = 0;

%% 3) Zaman Döngüsü
for k = 1:N-1
    % Ölçümler
    v_meas = Vout(k);
    i_meas = IL(k);
    
    % Voltage-PI
    err_v  = 3.3 - v_meas;
    int_v  = int_v + err_v*Ts;
    i_ref  = Kpv*err_v + Kiv*int_v;
    i_ref  = max(0, min(i_ref, Imax));
    
    % Peak-Current Mode
    d = i_ref * Lm / (Vin * Ts);
    if i_meas >= i_ref
        d = 0;
    end
    d = max(0, min(d, 1));
    duty(k) = d;
    
    % Plant
    if d>0
        dIL = (Vin/Lm)*d*Ts;
    else
        dIL = -(NsNp * v_meas / Lm)*Ts;
    end
    IL(k+1) = max(0, IL(k) + dIL);
    
    Isec      = IL(k)/NsNp;
    dVout     = (Isec - v_meas/Rload)*Ts/Cout;
    Vout(k+1) = Vout(k) + dVout;
end

%% 4) Grafikler
time = (0:N-1)*Ts;

figure;
subplot(3,1,1);
plot(time, Vout,'LineWidth',1.2); ylabel('V_{out} (V)');
title('Çıkış Gerilimi (50 ms simülasyonu)');

subplot(3,1,2);
plot(time, IL*1e6,'LineWidth',1.2); ylabel('I_L (µA)');

subplot(3,1,3);
plot(time, duty,'LineWidth',1.2); ylabel('Duty'); xlabel('Time (s)');
sgtitle('Geliştirilmiş Nano-Flyback Kontrol Simülasyonu');
