% NanoFlyback_FuzzyController_Corrected.m
% Mamdani tipi nano-flyback fuzzy kontrolcü (hata: error, hata değişimi: deltaError)

clear; close all; clc;

%% 1) FIS Nesnesi
fis = mamfis('Name','NanoFlybackFuzzy');

% Giriş değişkenleri
fis = addInput(fis, [-0.5  0.5], 'Name','error');
fis = addInput(fis, [-0.1  0.1], 'Name','deltaError');

% Çıkış değişkeni
fis = addOutput(fis, [0 1], 'Name','duty');

%% 2) Üyelik Fonksiyonları

% --- error için ---
fis = addMF(fis, 'error', 'trapmf', [-0.5 -0.5 -0.3 -0.1], 'Name','Neg');
fis = addMF(fis, 'error', 'trimf', [-0.3  0    0.3],    'Name','Zero');
fis = addMF(fis, 'error', 'trapmf', [ 0.1  0.3  0.5  0.5], 'Name','Pos');

% --- deltaError için ---
fis = addMF(fis, 'deltaError', 'trapmf', [-0.1 -0.1 -0.05 0],   'Name','Neg');
fis = addMF(fis, 'deltaError', 'trimf', [-0.05 0    0.05],    'Name','Zero');
fis = addMF(fis, 'deltaError', 'trapmf', [ 0    0.05 0.1  0.1], 'Name','Pos');

% --- duty için ---
fis = addMF(fis, 'duty', 'trapmf', [-0.1 0   0.1 0.3], 'Name','Low');
fis = addMF(fis, 'duty', 'trimf', [ 0.1 0.5 0.9 ],    'Name','Medium');
fis = addMF(fis, 'duty', 'trapmf', [ 0.7 0.9 1.0 1.0], 'Name','High');

%% 3) Kural Listesi
% [errorMF  deltaErrorMF  dutyMF  weight  operator]
ruleList = [
    1        1            1       1       1;  % if error Neg  & deltaError Neg  then duty Low
    1        2            1       1       1;  % if error Neg  & deltaError Zero then duty Low
    1        3            2       1       1;  % if error Neg  & deltaError Pos  then duty Medium
    2        1            1       1       1;  % if error Zero & deltaError Neg  then duty Low
    2        2            2       1       1;  % if error Zero & deltaError Zero then duty Medium
    2        3            3       1       1;  % if error Zero & deltaError Pos  then duty High
    3        1            2       1       1;  % if error Pos  & deltaError Neg  then duty Medium
    3        2            3       1       1;  % if error Pos  & deltaError Zero then duty High
    3        3            3       1       1;  % if error Pos  & deltaError Pos  then duty High
];

% Kuralları FIS'e ekle
fis = addRule(fis, ruleList);

%% 4) FIS’in Görselleştirilmesi (Opsiyonel)
% Tasarım ekranı aç:
% fuzzyLogicDesigner(fis);

% Üyelik fonksiyonlarını hızlı bakış:
figure('Name','Fuzzy MFs');
subplot(3,1,1), plotmf(fis,'input',1), title('Error MF');
subplot(3,1,2), plotmf(fis,'input',2), title('DeltaError MF');
subplot(3,1,3), plotmf(fis,'output',1), title('Duty MF');

%% 5) Basit Test
e_test  = 0.30;
de_test = 0.00;
u_test  = evalfis(fis, [e_test, de_test]);
fprintf('Test e=%.2f, de=%.2f  -> duty=%.3f\n', e_test, de_test, u_test);

%% 6) Zaman-Domain Simülasyonu (Opsiyonel)
% örnek bir sinyal üzerinden test et
t = 0:1e-5:1e-3;                          % 0–1 ms arası
ref = 3.3*ones(size(t));
vout = 3.0 + 0.1*sin(2*pi*500*t);         % örnek çıkış
error     = ref - vout;
deltaErr  = [0, diff(error)];            % yaklaşık türev
duty_out  = evalfis(fis, [error', deltaErr']);
figure('Name','Fuzzy Control over Time');
plot(t*1e3, duty_out,'LineWidth',1.4);
xlabel('Time (ms)'), ylabel('Duty');
title('Fuzzy Controller Output'); grid on;

%% 7) FIS Objeyi Kayıt Et (PSIM/Colab entegrasyonu için)
% saveCompactModel(fis,'nano_flyback_fuzzy.json');

% FIS’i bir .mat dosyasına kaydet
save('NanoFlyback_FuzzyController.mat','fis');


