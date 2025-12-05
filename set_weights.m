
edge_all=ones(7,6);
edge_or=[1 0 0 0 0 0%source
    1 1 1 0 0 0%device
    0 1 1 1 1 1%e1
    0 1 1 1 1 1%e2
    0 0 0 1 1 1%c1
    0 0 0 1 1 1%c2
    0 0 0 1 1 1];%c3 %columns d e1 e2 c1 c2 c3
exit_map=[1 0 1 0 1];%whether exit after specified layer
ee=[6 140 400];%energy_weight device es cs
w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit
w2=[51.94 71.91 79.19];%accuracy_weight of each exit 
w3=[30 37 12.6];%communication device es cs nJ/bit

Samples=[600 6000];
epochs=1;
%%%all on device
commun_energy_d=0;
computation_energy_d=(44.8+38.7+8.2)*1000000*6/11000000000; %J
energy_d=commun_energy_d+computation_energy_d;
delay_d=(44.8+38.7+8.2)*1000000/11000000000;%minutes

accuracy2=85.95;
accuracy1=60.32;

%%%Configuration-1 Fig 4 d(l1-l2)-es(l3-l4-l5)
%%%13x13x384 features communicated
%8 bits per feature
%%commun_energy_d1=27*27*256*8*0.5*(30+37)/(1000000*epochs); %microj
commun_energy_d1=(13*13*384*8*1)*30/(10^9); %J
commun_energy_es1=(13*13*384*8*1)*37/(10^9); %J
computation_energy_d1=(8.2)*1000000*6/11000000000;%J
computation_energy_es1=(38.7+44.8)*1000000*140/153400000000;%J
energy_d1=computation_energy_d1;
energy_es1=computation_energy_es1;%commun_energy_d1;
delay_d1=(8.2)*1000000/11000000000;%sec
delay_es1=((38.7+44.8)*1000000/(1534000000000)) + (13*13*384*8*1.1*w1_2(1,1)/1000000000);%sec
accuracy_d1= (51.94/79.19);
accuracy_es1= 1;




%%%Configuration-2 d(l1-l2)-es(l3-l4)-cs(l5)
%%%13x13x384 features communicated d to es and 13x13x256 features
%8 bits per feature
%%commun_energy_d1=27*27*256*8*0.5*(30+37)/(1000000*epochs); %microj
commun_energy_d2=(13*13*384*8*1)*30/(10^9); %J
commun_energy_es2=((13*13*384*8*1)*37/(10^9)) + (13*12*256*8*37/(10^9)); %J
commun_energy_cs2=(13*12*256*8*12.6/(10^9)); %J
computation_energy_d2=(8.2)*1000000*6/11000000000;%J
computation_energy_es2=(38.7)*1000000*140/153400000000;%J
computation_energy_cs2=(44.8)*1000000*400/312000000000;%J
energy_d2=computation_energy_d2;
energy_es2=computation_energy_es2;
energy_cs2=computation_energy_cs2;
delay_d2=(8.2)*1000000/11000000000;%sec
delay_es2=((38.7)*1000000/(1534000000000)) + (13*13*384*8*1.1*w1_2(1,1)/1000000000);%sec
delay_cs2=delay_es2+((44.8)*1000000/(3120000000000)) + (13*13*256*8*1.1*w1_2(1,2)/1000000000);%sec


accuracy_d2= (51.94/79.19);
accuracy_es2= (71.91/79.19);
accuracy_cs2=1;

%vals1=[delay_d*Samples(1,1)*epochs accuracy1 energy_d*Samples(1,1)*epochs 0
%     delay_d*Samples(1,2)*epochs accuracy2 energy_d*Samples(1,2)*epochs 0
%     delay_d1*Samples(1,1)*epochs accuracy1*accuracy_d1 energy_d1*Samples(1,1)*epochs commun_energy_d1*Samples(1,1)
%     delay_es1*Samples(1,1)*epochs accuracy1*accuracy_es1 energy_es1*Samples(1,1)*epochs commun_energy_es1*Samples(1,1)
%     delay_d1*Samples(1,2)*epochs accuracy2*accuracy_d1 energy_d1*Samples(1,2)*epochs commun_energy_d1*Samples(1,2)
%     delay_es1*Samples(1,2)*epochs accuracy2*accuracy_es1 energy_es1*Samples(1,2)*epochs commun_energy_es1*Samples(1,2)
%     ];
vals1=[delay_d*Samples(1,1)*epochs accuracy1 energy_d*Samples(1,1)*epochs 0    
    delay_d1*Samples(1,1)*epochs accuracy1*accuracy_d1 energy_d1*Samples(1,1)*epochs commun_energy_d1*Samples(1,1)
    delay_es1*Samples(1,1)*epochs accuracy1*accuracy_es1 energy_es1*Samples(1,1)*epochs commun_energy_es1*Samples(1,1)
    delay_d2*Samples(1,1)*epochs accuracy1*accuracy_d2 energy_d2*Samples(1,1)*epochs commun_energy_d2*Samples(1,1)
    delay_es2*Samples(1,1)*epochs accuracy1*accuracy_es2 energy_es2*Samples(1,1)*epochs commun_energy_es2*Samples(1,1)
    delay_cs2*Samples(1,1)*epochs accuracy1*accuracy_cs2 energy_cs2*Samples(1,1)*epochs commun_energy_cs2*Samples(1,1)
    ];

vals2=[delay_d*Samples(1,2)*epochs accuracy2 energy_d*Samples(1,2)*epochs 0    
    delay_d1*Samples(1,2)*epochs accuracy2*accuracy_d1 energy_d1*Samples(1,2)*epochs commun_energy_d1*Samples(1,2)
    delay_es1*Samples(1,2)*epochs accuracy2*accuracy_es1 energy_es1*Samples(1,2)*epochs commun_energy_es1*Samples(1,2)
    delay_d2*Samples(1,2)*epochs accuracy2*accuracy_d2 energy_d2*Samples(1,2)*epochs commun_energy_d2*Samples(1,2)
    delay_es2*Samples(1,2)*epochs accuracy2*accuracy_es2 energy_es2*Samples(1,2)*epochs commun_energy_es2*Samples(1,2)
    delay_cs2*Samples(1,2)*epochs accuracy2*accuracy_cs2 energy_cs2*Samples(1,2)*epochs commun_energy_cs2*Samples(1,2)
    ];
subplot(1,2,1)
bar(vals1)
set(gca,'FontSize', 14);
legend('Delay (comput.+commun., in sec.)', 'Accuracy (%)', 'Computation Energy (J)', 'Communication Energy (J)');
xticklabels({'D-only' '(D)' '(ES)' '(D)' '(ES)' '(CS)'})
title('(a) CIFAR100')
ylabel('Value')
grid on
hold all;
subplot(1,2,2)
bar(vals2)
set(gca,'FontSize', 14);
%legend('Delay (comput.+commun., in sec.)', 'Accuracy (%)', 'Computation Energy (J)', 'Communication Energy (J)');
xticklabels({'D-only' '(D)' '(ES)' '(D)' '(ES)' '(CS)'})
title('(b) CIFAR10')
ylabel('Value')
grid on




