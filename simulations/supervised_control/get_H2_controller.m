function K_h2 = get_H2_controller()
%GET_H2_CONTROLLER Küçük-sinyal H2 kontrolcüsünü döner
%
%   K_h2 = get_H2_controller();

  %% 1) Aynı küçük-sinyal plant
  Lm    = 2.82e-6;
  Cout  = 100e-9;
  Rload = 220e3;
  Vin   = 12;
  N     = 2;
  A = [   0,     -N/Lm;
        N/Cout,  -1/(Rload*Cout) ];
  B = [Vin/Lm; 0];
  C = [0 1];
  D = 0;
  P = ss(A,B,C,D);

  %% 2) Ağırlık fonksiyonları (H2 cezası için benzer seçim)
  Wp = makeweight(100, 2*pi*1e3, 0.01);
  Wu = makeweight(0.01, 2*pi*1e6, 100);
  P_aug = augw(P, Wp, [], Wu);

  %% 3) H2 sentezi
  % 1 ölçülen çıktı, 1 kontrol girişi
  [K_h2, ~, ~] = h2syn(P_aug, 1, 1);
  fprintf('H2 controller hazır.\n');
end
