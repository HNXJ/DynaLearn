%% 3-layer neocortical model

%% Model parameters

clear;clc;
fprintf("Initialization...\n");

% Population sizes
Ne = 12;     % # of E cells per layer
Ni = Ne/4;  % # of I cells per layer
Nio = 6; % # of Input cells
k1 = 0.5; % Difference between min and max connectivity weights (uniform random)
k2 = 0.1; % Min connectivity weight

% Connectivity matrices

% E->I
Kei = k1*rand(Ne, Ni) + k2; % all-to-all, connectivity from E cells to I cells; mid, sup, deep
% I->E
Kie = k1*rand(Ni, Ne) + k2; % all-to-all, connectivity from I cells to E cells; mid, sup, deep

% E->E
Kee = k1*rand(Ne, Ne) + k2; % recurrent E-to-E: mid, sup, deep
Kii = k1*rand(Ni, Ni) + k2; % recurrent I-to-I: mid, sup, deep
Kffee = k1*rand(Ne, Ne) + k2; % feedforward E-to-E: mid->sup, sup->deep
Kffie = k1*rand(Ni, Ne) + k2; % feedforward I-to-E: mid->deep

kzio = zeros(Nio, Nio);

% Manual weight adjustment
KmidEmidI = Kei;
% KmidEmidI(1:3, 1) = 0.1*rand(3, 1) + 0.9;
% KmidEmidI(4:6, 2) = 0.1*rand(3, 1) + 0.9;

KmidEsupE = Kee;

KmidEdeepE = Kee;
KmidEdeepE(1:3, 1:6) = 0.1*rand(3, 6) + 0.9;
KmidEdeepE(4:6, 7:12) = 0.1*rand(3, 6) + 0.9;

KsupEdeepE = Kee;

KmidIdeepE = Kie;
% KmidIdeepE(1, 7:12) = 0.1*rand(1, 6) + 0.9;
% KmidIdeepE(2, 7:12) = 0.1*rand(1, 6) + 0.9;

% Time constants
tauGABA_gamma = 3; % ms, decay time constant of inhibition for gamma (50Hz)
tauGABA_beta = 20; % ms, decay time constant of inhibition for beta (25Hz)
tauAMPA = 3; % ms, decay time constant of fast excitation (AMPA)

% Maximal synaptic strengths
gAMPA_ei = .2; % E->I within layer
gAMPA_ffee = .2; % feedforward E->E, mid->sup, sup->deep
gGABAa_ffie = .1; % feedforward I->E, mid->deep

gAMPA_ee = 0; % E->E within layer
gGABAa_ie = 5; % I->E within layer
gGABAa_ii = 0; % I->I within layer

% neuronal dynamics
eqns = 'dV/dt = (Iapp + @current + noise*randn(1,Npop))/C; Iapp=0; noise=0; C=1';

% SPN
g_l_D1 = 0.096;      % mS/cm^2, Leak conductance for D1 SPNs 
g_l_D2 = 0.1;        % mS/cm^2, Leak conductance for D2 SPNs
g_cat_D1 = 0.018;    % mS/cm^2, Conductance of the T-type Ca2+ current for D1 SPNs
g_cat_D2 = 0.025;    % mS/cm^2, Conductance of the T-type Ca2+ current for D2 SPNs

g_poisson = 1e-4;

% cell type
spn_cells = {'spn_iNa','spn_iK','spn_iLeak','spn_iM','spn_iCa','spn_CaBuffer','spn_iKca', 'ctx_iPoisson'};
ctx_cells = {'iNa','iK', 'ctx_iPoisson'};

cell_type = ctx_cells; % choose spn_cells and ctx_cells

% create DynaSim specification structure

% PING template
ping=[];

% E-cells
ping.populations(1).name = 'E';
ping.populations(1).size = Ne;
ping.populations(1).equations = eqns;
ping.populations(1).mechanism_list = cell_type;
ping.populations(1).parameters = {'Iapp',5,'noise', 60, 'g_poisson',g_poisson,'onset_poisson',0,'offset_poisson',0};

% I-cells
ping.populations(2).name = 'I';
ping.populations(2).size = Ni;
ping.populations(2).equations = eqns;
ping.populations(2).mechanism_list = cell_type;
ping.populations(2).parameters = {'Iapp',0,'noise', 16, 'g_poisson',g_poisson,'onset_poisson',0,'offset_poisson',0};

% E/I connectivity
ping.connections(1).direction = 'E->I';
ping.connections(1).mechanism_list = {'iAMPActx'};
ping.connections(1).parameters = {'gAMPA',gAMPA_ei,'tauAMPA',tauAMPA,'netcon',Kei};

ping.connections(2).direction = 'E->E';
ping.connections(2).mechanism_list = {'iAMPActx'};
ping.connections(2).parameters = {'gAMPA',gAMPA_ee,'tauAMPA',tauAMPA,'netcon',Kee};

ping.connections(3).direction = 'I->E';
ping.connections(3).mechanism_list = {'iGABActx'};
ping.connections(3).parameters = {'gGABAa',gGABAa_ie,'tauGABA',tauGABA_gamma,'netcon',Kie};

ping.connections(4).direction = 'I->I';
ping.connections(4).mechanism_list = {'iGABActx'};
ping.connections(4).parameters = {'gGABAa',gGABAa_ii,'tauGABA',tauGABA_gamma,'netcon',Kii};

% PING template
IOping=[];

% E-cells
IOping.populations(1).name = 'E';
IOping.populations(1).size = Nio;
IOping.populations(1).equations = eqns;
IOping.populations(1).mechanism_list = cell_type;
IOping.populations(1).parameters = {'Iapp',1,'noise', 10, 'g_poisson',g_poisson,'onset_poisson',0,'offset_poisson',0};

% I-cells
IOping.populations(2).name = 'I';
IOping.populations(2).size = Nio;
IOping.populations(2).equations = eqns;
IOping.populations(2).mechanism_list = cell_type;
IOping.populations(2).parameters = {'Iapp',1,'noise', 10, 'g_poisson',g_poisson,'onset_poisson',0,'offset_poisson',0};

% E/I connectivity
IOping.connections(1).direction = 'E->I';
IOping.connections(1).mechanism_list = {'iAMPActx'};
IOping.connections(1).parameters = {'gAMPA',gAMPA_ei,'tauAMPA',tauAMPA,'netcon',kzio};

IOping.connections(2).direction = 'E->E';
IOping.connections(2).mechanism_list = {'iAMPActx'};
IOping.connections(2).parameters = {'gAMPA',gAMPA_ee,'tauAMPA',tauAMPA,'netcon',kzio};

IOping.connections(3).direction = 'I->E';
IOping.connections(3).mechanism_list = {'iGABActx'};
IOping.connections(3).parameters = {'gGABAa',gGABAa_ie,'tauGABA',tauGABA_gamma,'netcon',kzio};

IOping.connections(4).direction = 'I->I';
IOping.connections(4).mechanism_list = {'iGABActx'};
IOping.connections(4).parameters = {'gGABAa',gGABAa_ii,'tauGABA',tauGABA_gamma,'netcon',kzio};

% create independent layers
sup = dsApplyModifications(ping,{'E','name','supE'; 'I','name','supI'}); % superficial layer (~gamma)
mid = dsApplyModifications(ping,{'E','name','midE'; 'I','name','midI'}); % middle layer (~gamma)
deep = dsApplyModifications(ping,{'E','name','deepE'; 'I','name','deepI'}); % deep layer (~beta)
stimuli = dsApplyModifications(IOping,{'E','name','SA'; 'I','name','SB'}); % I/O layer (stimuli)
contex = dsApplyModifications(IOping,{'E','name','Cx1'; 'I','name','Cx2'}); % I/O layer (contex)

% uppdate deep layer parameters to produce beta rhythm (25Hz)
deep = dsApplyModifications(deep,{'deepI->deepE','tauGABA',tauGABA_beta});

% create full cortical specification
s = dsCombineSpecifications(sup, mid, deep, stimuli, contex);

% connect the layers and inputs

fprintf("Connecting separate layers and inputs...\n");

% Input SA -> midE [1-3]
tempconn = zeros(Nio, Ne);
Aconn = tempconn;
Aconn(:, 1:3) =  1;

c = length(s.connections) + 1;
s.connections(c).direction = 'SA->midE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee*3,'tauAMPA',tauAMPA,'netcon',Aconn};

% Input SB -> midE [4-6]
Bconn = tempconn;
Bconn(:, 4:6) =  1;

c = length(s.connections)+1;
s.connections(c).direction = 'SB->midE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee*3,'tauAMPA',tauAMPA,'netcon',Bconn};

% Contex Cx1 -> midE [7-9]
Cx1conn = tempconn;
Cx1conn(:, 7:9) =  1;

c = length(s.connections)+1;
s.connections(c).direction = 'Cx1->midE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee*3,'tauAMPA',tauAMPA,'netcon',Cx1conn};

% Contex Cx2 -> midE [10-12]
Cx2conn = tempconn;
Cx2conn(:, 10:12) =  1;

c = length(s.connections)+1;
s.connections(c).direction = 'Cx2->midE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee*3,'tauAMPA',tauAMPA,'netcon',Cx2conn};

% midE -> supE
c = length(s.connections)+1;
s.connections(c).direction = 'midE->supE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee,'tauAMPA',tauAMPA,'netcon',KmidEsupE};

% midE -> deepE
c = length(s.connections)+1;
s.connections(c).direction = 'midE->deepE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee,'tauAMPA',tauAMPA,'netcon',KmidEdeepE};

% midI -> deepE
c = length(s.connections)+1;
s.connections(c).direction = 'midI->deepE';
s.connections(c).mechanism_list={'iGABActx'};
s.connections(c).parameters={'gGABAa',gGABAa_ffie,'tauGABA',tauGABA_beta,'netcon',KmidIdeepE};

% supE -> deepE
c = length(s.connections)+1;
s.connections(c).direction = 'supE->deepE';
s.connections(c).mechanism_list={'iAMPActx'};
s.connections(c).parameters={'gAMPA',gAMPA_ffee,'tauAMPA',tauAMPA,'netcon',KsupEdeepE};

% Outputs: deepE [1-6] as O1
% deepE [7-12] as O2



%% Simulate

fprintf("Running simulation ...\n");
simulator_options = {'solver','rk1','dt',.01,'downsample_factor',10,'verbose_flag',1};
tspan = [0 500]; % [beg, end] (ms)

% vary = {'supI->supE','tauGABA',[2]; 
%        'deepI->deepE','tauGABA',[2 20]};

vary = {'SA','g_poisson',[g_poisson]; 'SA','DC_poisson', [1e7];'SA','AC_poisson', [0]; 'SA', 'onset_poisson', [300 400]; 'SA', 'offset_poisson', [400];
       'SB','g_poisson',[g_poisson]; 'SB','DC_poisson', [1e7];'SB','AC_poisson', [0]; 'SB', 'onset_poisson', [300 400]; 'SB', 'offset_poisson', [400];
       'Cx1','g_poisson',[g_poisson]; 'Cx1','DC_poisson', [1e7];'Cx1','AC_poisson', [0]; 'Cx1', 'onset_poisson', [300]; 'Cx1', 'offset_poisson', [400];
       'Cx2','g_poisson',[g_poisson]; 'Cx2','DC_poisson', [1e7];'Cx2','AC_poisson', [0]; 'Cx2', 'onset_poisson', [400]; 'Cx2', 'offset_poisson', [400]};
   
data=dsSimulate(s,'vary',vary,'tspan',tspan,simulator_options{:});
fprintf("Simulation done.\n");

%% Extract outputs & compare

clc;

pool1 = 1:6;
pool2 = 7:12;

figure();
patch([300 400 400 300], [0 0 40*[1 1]], [0.8 0.8 0.8]);hold("on");

for i = 1:4
    t = data(i).time;
    x = data(i).deepE_V;
    raster = computeRaster(t, x);

    O1 = 1e3 * NWepanechnikovKernelRegrRaster(t, raster, pool1, 49, 1, 1);
    O2 = 1e3 * NWepanechnikovKernelRegrRaster(t, raster, pool2, 49, 1, 1);
    
%     subplot(2, 2, i);
    plot(t, O1-O2, 'o');hold("on");

end

grid("on");title("iFR(O1) - iFR (O2)");
legend("Target interval", "A&B", "only A", "only B", "No stimulus");

fprintf("Done.\n");

%% Plots results

dsPlot(data); % Normal
dsPlot(data,'plot_type','raster'); % Raster

%% iFR & comparison

clc;
pool1 = [1:6];
pool2 = [7:12];

t = data.time;
x = data.midE_V;
lname = "mid";

raster = computeRaster(t, x);

ifr1 = 1e3 * NWepanechnikovKernelRegrRaster(t, raster, pool1, 49, 1, 1);
ifr2 = 1e3 * NWepanechnikovKernelRegrRaster(t, raster, pool2, 49, 1, 1);

figure();

subplot(2, 2, 1);plot(t, ifr1);title("S4: iFR for " + lname + "E cells 1-8");grid("on");
subplot(2, 2, 2);plot(t, x(:, pool1));title('V(t)');
subplot(2, 2, 3);plot(t, ifr2);title("iFR for " + lname + "E cells 9-16");grid("on");
subplot(2, 2, 4);plot(t, x(:, pool2));title('V(t)');

%%

clc;
plot_rasters(data(1));

%%
