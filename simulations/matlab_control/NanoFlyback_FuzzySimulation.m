%% NanoFlyback_FuzzySimulation_minimal.m
clear; close all; clc;

%% 1) Basit FIS Oluştur
fis = mamfis('Name','FlybackFuzzy');

% 2 Giriş
fis = addInput(fis,[-1 1],'Name','error');
fis = addInput(fis,[-1 1],'Name','deltaError');
% 1 Çıkış
fis = addOutput(fis,[-0.2 0.2],'Name','deltaD');

%% 2) Üyelik Fonksiyonları
% error (giriş1)
fis = addMF(fis,'error','trapmf',[-1 -1 -0.5 0],'Name','Neg');
fis = addMF(fis,'error','trimf',[-0.5 0 0.5],'Name','Zero');
fis = addMF(fis,'error','trapmf',[0 0.5 1 1],'Name','Pos');

% deltaError (giriş2)
fis = addMF(fis,'deltaError','trapmf',[-1 -1 -0.5 0],'Name','Neg');
fis = addMF(fis,'deltaError','trimf',[-0.5 0 0.5],'Name','Zero');
fis = addMF(fis,'deltaError','trapmf',[0 0.5 1 1],'Name','Pos');

% deltaD (çıkış)
fis = addMF(fis,'deltaD','trapmf',[-0.2 -0.2 -0.1 0],'Name','Neg');
fis = addMF(fis,'deltaD','trimf',[-0.1 0 0.1],'Name','Zero');
fis = addMF(fis,'deltaD','trapmf',[0 0.1 0.2 0.2],'Name','Pos');

%% 3) Kural Listesi (m+n+2 = 2+1+2 = 5 sütun)
% [errorIdx deltaErrorIdx deltaDIdx weight operator]
ruleList = [
   1  1  1 1 1;   % If error=Neg AND dE=Neg then dD=Neg
   1  2  1 1 1;   % If error=Neg AND dE=Zero then dD=Neg
   1  3  2 1 1;   % If error=Neg AND dE=Pos  then dD=Zero
   2  2  2 1 1;   % If error=Zero AND dE=Zero then dD=Zero
   2  3  3 1 1;   % If error=Zero AND dE=Pos  then dD=Pos
   3  1  2 1 1;   % If error=Pos AND dE=Neg then dD=Zero
   3  2  3 1 1;   % If error=Pos AND dE=Zero then dD=Pos
   3  3  3 1 1;   % If error=Pos AND dE=Pos  then dD=Pos
];

% Kuralı ekle
fis = addRule(fis, ruleList);

%% 4) Test: Tek bir nokta
test_e  = 0.4;   % normalize edilmiş error
test_de = -0.1;  % normalize edilmiş deltaError
out = evalfis(fis, [test_e, test_de]);
disp(['Test çıkış (deltaD) = ', num2str(out)]);

% Eğer yukarıda *hiç* hata almaz, simülasyon döngüsünü ekleyebilirsiniz.

%% … önceki kod aynı …

%% 5) Çıkış Eğrisi: error değişirken deltaError sabit
figure; hold on; grid on;
de_fixed = 0;                 
e_vec     = linspace(-1,1,200)';
out_vec   = evalfis(fis, [e_vec, de_fixed*ones(size(e_vec))]);
plot(e_vec, out_vec, 'LineWidth',1.5);
xlabel('error'); ylabel('deltaD');
title(['Fuzzy Çıkışı (deltaError = ',num2str(de_fixed),')']);



%% … önceki kod aynı …

%% 6) 2-Boyutlu Çıkış Yüzeyi
[Err, dErr] = meshgrid(linspace(-1,1,100), linspace(-1,1,100));
Inp          = [Err(:), dErr(:)];
Out          = evalfis(fis, Inp);
Out          = reshape(Out, size(Err));

figure;
surf(Err, dErr, Out, 'EdgeColor','none');
xlabel('error'); ylabel('deltaError'); zlabel('deltaD');
title('Fuzzy Çıkış Yüzeyi');
colorbar; view(45,30);

% Alternatif olarak kontur haritası:
figure;
contourf(Err, dErr, Out,20,'LineColor','none');
xlabel('error'); ylabel('deltaError');
title('Çıkış Kontur Haritası');
colorbar;


%% … önceki kod aynı …

%% 5) Basit Dinamik Simülasyon ve vout Çizimi
% Parametreler
Vin    = 12;      % Giriş [V]
N      = 2;       % Ns/Np dönüşüm oranı
Cout   = 100e-9;  % [F]
Rload  = 220e3;   % [Ω]
Vref   = 3.3;     % Referans çıkış [V]
Tsim   = 0.05;    % Toplam simülasyon süresi [s]
dt     = 1e-5;    % Zaman adımı [s]
time   = 0:dt:Tsim;

% Ön tanımlamalar
vout      = zeros(size(time));
vout(1)   = 0;      % Başlangıç
duty      = 0.1;    % İlk duty
e_old     = 0;
for k = 2:length(time)
    % 1) Hata & deltaError normalize et (–1…1 aralığı)
    e    = (Vref - vout(k-1))/Vref;
    de   = (e - e_old);
    e_old = e;
    % sınırla
    e    = max(-1,min(1,e));
    de   = max(-1,min(1,de));

    % 2) Fuzzy’den deltaDuty al
    dd   = evalfis(fis, [e, de]);

    % 3) duty güncelle ve sınırla
    duty = duty + dd;
    duty = max(0,min(1,duty));

    % 4) Ortalama model integrasyonu:
    %    Vsec = duty * Vin / N
    %    dv/dt = (Vsec - vout)/ (Rload * Cout)
    dv = (duty*Vin/N - vout(k-1)) / (Rload*Cout);
    vout(k) = vout(k-1) + dv*dt;
end

%% 6) Sonuçların Çizimi
figure;
plot(time*1e3, vout, 'LineWidth',1.5);
xlabel('Zaman [ms]');
ylabel('V_{out} [V]');
title('Fuzzy Kontrollü Flyback Çıkış Gerilimi');
grid on;

