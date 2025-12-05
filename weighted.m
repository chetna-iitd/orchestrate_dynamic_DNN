close all
clear all
load("config.mat");

ops_layer=[22.62 6.711 10.145 19.201 13.523 29.084];%mops
feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
ac1=(85.95/79.19)*[51.94 71.91 79.19];
ac2=(60.32/79.19)*[51.94 71.91 79.19];
w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit
%w1 is delay
%w2 is accuracy
delay_constraint=10;
accuracy_constraint=80;
p=zeros(5,2);
for i=1:5 %layer_num
    if (i==1)%% layer 1 constraint
        w1(i,1)=(ops_layer(1,1)*10000000/11000000000)*6000;
        w1(i,2)=(ops_layer(1,1)*10000000/11000000000)*600;
        w2(i,1)=ac1(1,1);
        w2(i,2)=ac2(1,1);
        we_1(i)=max(w1(i,1)/delay_constraint,accuracy_constraint/w2(i,1));
        p(1,1)=1;
        p(1,2)=1;
    else
        val_d=ops_layer(1,i)*10000000/11000000000;
        val_es=(ops_layer(1,i)*10000000/153400000000) + (feature_layer(1,i-1)*8*w1_2(1,2)/1000000000);
        val_cs=(ops_layer(1,i)*10000000/312000000000) + (feature_layer(1,i-1)*8*w1_2(1,3)/1000000000);
        if(i==3)
        w2(i,1)=ac1(1,2);
        w2(i,2)=ac2(1,2);
        elseif(i==5)
            w2(i,1)=ac1(1,3);
            w2(i,2)=ac2(1,3);
        else
            w2(i,1)=ac1(1,i-1);
            w2(i,2)=ac2(1,i-1);
        end
        w1(i,1)=min([val_d,val_es,val_cs])*6000;
        w1(i,2)=min([val_d,val_es,val_cs])*600;
        we_1(i)=max((w1(i,1))/delay_constraint,accuracy_constraint/w2(i,1));        
        if(val_d<val_es && (we_1(i)>0.8 || p((i-1),2)>=i) && p((i-1),1)==1)
            p(i,1)=1;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_d*6000;
            w1(i,2)=val_d*600;
        elseif(val_d>val_es && (we_1(i)>0.8 || p((i-1),2)>=i) && p((i-1),1)==1)
            p(i,1)=2;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_es*6000;
            w1(i,2)=val_es*600;
        elseif(val_es>val_cs && (we_1(i)>0.8 || p((i-1),2)>=i) && p((i-1),1)>=1)
            p(i,1)=3;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_cs*6000;
            w1(i,2)=val_cs*600;   
        end        
        we_1(i)=max((w1(i,1))/delay_constraint,accuracy_constraint/w2(i,1));        
    end
end
we_1
w1./delay_constraint
accuracy_constraint./w2
p

ee=[6 140 400];%W energy_weight device es cs
ee_ops=[8.2 38.7 44.8];
w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w3=[30 37 12.6];%communication device es cs nJ/bit

compute_energy=zeros(1,size(config,3));
communication_energy=zeros(1,size(config,3));
compute_delay=zeros(1,size(config,3));
communication_delay=zeros(1,size(config,3));
accuracy1=zeros(1,size(config,3));
accuracy2=zeros(1,size(config,3));

for k=1:size(config,3)
    ct=config(:,:,k);
    for i=1:5
     if(ct(i,1)~=0)
        compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1))*ops_layer(1,i)/(w1_1(1,ct(i,1))*1000));    
        compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1))*1000));
        if(i>1 && ct(i,1)>ct(i-1,1))
        communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1))/1000000000);
        communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1))/1000000000);
        end
     end
    end
    accuracy1(1,k)=ac1(1,ct(1,2));
   accuracy2(1,k)=ac2(1,ct(1,2)); 
end


compute_energy1=compute_energy.*6000;
compute_energy2=compute_energy.*600;
communication_energy1=communication_energy.*6000;
communication_energy2=communication_energy.*600;
tot_energy1=compute_energy1+communication_energy1;
tot_energy2=compute_energy2+communication_energy2;
tot_delay1=(compute_delay+communication_delay)*6000;
tot_delay2=(compute_delay+communication_delay)*600;
close all
%subplot(1,2,1)
figure
set(gca,'FontSize', 14);
plot3(tot_energy1,accuracy1,tot_delay1,'rx','MarkerSize',8,'LineWidth',1.5);
hold all
plot3(tot_energy2,accuracy2,tot_delay2,'k+','MarkerSize',8,'LineWidth',1.5);
set(gca,'FontSize', 14);
xlabel('Total Energy(J)');
ylabel('Accuracy (%)');
zlabel('Total Delay(sec)');
legend('CIFAR10','CIFAR100')
grid on
%subplot(1,2,2)
%plot(accuracy1)
%hold all
%plot(accuracy2)

acc_constraint=10:5:85;
delay_con=15;
data_source=zeros(1,size(acc_constraint,2));
best_config=zeros(1,size(acc_constraint,2));
best_energy=10000*ones(1,size(acc_constraint,2));
best_delay=zeros(1,size(acc_constraint,2));
best_communication_e=zeros(1,size(acc_constraint,2));
best_compute_e=zeros(1,size(acc_constraint,2));
for j=1:size(acc_constraint,2)
for i=1:size(config,3)
    if(accuracy1(1,i)>acc_constraint(1,j) && tot_energy1(1,i)<best_energy(1,j)&&config(1,1,i)==1 && tot_delay1(1,i)<delay_con)
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy1(1,i);
        data_source(1,j)=1;
        best_delay(1,j)=tot_delay1(1,i);
        best_communication_e(1,j)=communication_energy1(1,i);
        best_compute_e(1,j)=compute_energy1(1,i);
    end
    if(accuracy2(1,i)>acc_constraint(1,j) && tot_energy2(1,i)<best_energy(1,j)&&config(1,1,i)==1&&tot_delay2(1,i)<delay_con)
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy2(1,i);
        data_source(1,j)=2;
        best_delay(1,j)=tot_delay2(1,i);
        best_communication_e(1,j)=communication_energy2(1,i);
        best_compute_e(1,j)=compute_energy2(1,i);
    end
end
end



delay_constraint=15:5:70;
accuracy_constraint=80;
data_source_d=zeros(1,size(delay_constraint,2));
best_config_d=zeros(1,size(delay_constraint,2));
best_energy_d=10000*ones(1,size(delay_constraint,2));
best_delay=zeros(1,size(delay_constraint,2));
best_commun_enery_d=zeros(1,size(delay_constraint,2));
best_compute_energy_d=zeros(1,size(delay_constraint,2));
for j=1:size(delay_constraint,2)
    new_diff=50;
for i=1:size(config,3)
    if(tot_delay1(1,i)<delay_constraint(1,j) && (-tot_delay1(1,i)+delay_constraint(1,j))<=new_diff && tot_energy1(1,i)<best_energy_d(1,j) && accuracy1(1,i)>accuracy_constraint&&config(1,1,i)==1)
        best_config_d(1,j)=i;
        best_energy_d(1,j)=tot_energy1(1,i);
        data_source_d(1,j)=1;
        best_delay(1,j)=tot_delay1(1,i);
        best_commun_enery_d(1,j)=communication_energy1(1,i);
        best_compute_energy_d(1,j)=compute_energy1(1,i);
        new_diff=(delay_constraint(1,j)-tot_delay1(1,i));
    end
    if(tot_delay2(1,i)<delay_constraint(1,j) && abs(-tot_delay2(1,i)+delay_constraint(1,j))<=new_diff && tot_energy2(1,i)<best_energy_d(1,j) && accuracy2(1,i)>accuracy_constraint&&config(1,1,i)==1)
        best_config_d(1,j)=i;
        best_energy_d(1,j)=tot_energy2(1,i);
        data_source_d(1,j)=2;
        best_delay(1,j)=tot_delay2(1,i);
        best_commun_enery_d(1,j)=communication_energy2(1,i);
        best_compute_energy_d(1,j)=compute_energy2(1,i);
        new_diff=(delay_constraint(1,j)-tot_delay2(1,i));
    end
end
end
%close all
figure
set(gca,'FontSize', 14);
subplot(1,2,1)
set(gca,'FontSize', 14);
plot(acc_constraint,best_energy,'x--','MarkerSize',8,'LineWidth',1.5);
hold all
plot(acc_constraint,best_communication_e,'s:','MarkerSize',8,'LineWidth',1.5);
plot(acc_constraint,best_compute_e,'o--','MarkerSize',8,'LineWidth',1.5);
xlabel('Accuracy constraint (%)');
ylabel('Energy (J)');
title('(a) Delay constraint = 15 sec');
set(gca,'FontSize', 14);
grid on
subplot(1,2,2)
set(gca,'FontSize', 14);
plot(delay_constraint,best_energy_d,'x-','MarkerSize',8,'LineWidth',1.5);
hold all
plot(delay_constraint,best_commun_enery_d,'s:','MarkerSize',8,'LineWidth',1.5);
plot(delay_constraint,best_compute_energy_d,'o--','MarkerSize',8,'LineWidth',1.5);
legend('total','communication','compute')
xlabel('Delay constraint (in sec)');
ylabel('Energy (J)');
title('(b) Accuracy constraint = 80%');
grid on
set(gca,'FontSize', 14);