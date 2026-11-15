function fis = get_fuzzy_controller()
    % Basit Mamdani FIS
    fis = mamfis('Name','FlybackFuzzy');
    fis = addInput(fis,[-1 1],'Name','error');
    fis = addInput(fis,[-1 1],'Name','deltaError');
    fis = addOutput(fis,[-0.2 0.2],'Name','deltaD');
    % Üyelik fonksiyonları
    fis = addMF(fis,'error','trapmf',[-1 -1 -0.5 0],'Name','Neg');
    fis = addMF(fis,'error','trimf',[-0.5 0 0.5],'Name','Zero');
    fis = addMF(fis,'error','trapmf',[0 0.5 1 1],'Name','Pos');
    fis = addMF(fis,'deltaError','trapmf',[-1 -1 -0.5 0],'Name','Neg');
    fis = addMF(fis,'deltaError','trimf',[-0.5 0 0.5],'Name','Zero');
    fis = addMF(fis,'deltaError','trapmf',[0 0.5 1 1],'Name','Pos');
    fis = addMF(fis,'deltaD','trapmf',[-0.2 -0.2 -0.1 0],'Name','Neg');
    fis = addMF(fis,'deltaD','trimf',[-0.1 0 0.1],'Name','Zero');
    fis = addMF(fis,'deltaD','trapmf',[0 0.1 0.2 0.2],'Name','Pos');
    % Kural listesi
    ruleList = [
       1 1 1 1 1;
       1 2 1 1 1;
       1 3 2 1 1;
       2 2 2 1 1;
       2 3 3 1 1;
       3 1 2 1 1;
       3 2 3 1 1;
       3 3 3 1 1;
    ];
    fis = addRule(fis, ruleList);
end
