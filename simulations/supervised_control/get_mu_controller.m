function K_mu = get_mu_controller()
    % Karışık hassasiyet (mixsyn ile μ-approx)
    Vin=12; N=2; Cout=100e-9; Rload=220e3;
    s = tf('s');
    P = (Vin/N)/(Rload*Cout) * 1/(s + 1/(Rload*Cout));
    Wp = makeweight(10,2*pi*1e3,0.1);
    Wu = makeweight(0.001,2*pi*1e6,100);
    Paug = augw(P, Wp, [], Wu);
    [K_mu,~,~] = mixsyn(Paug,1,1);
end
