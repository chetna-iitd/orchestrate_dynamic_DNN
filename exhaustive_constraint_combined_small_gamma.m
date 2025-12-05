delay=3:1:15;
accuracy=10:5:85;
compute_energy1=zeros(size(delay,2),size(accuracy,2));
compute_energy2=zeros(size(delay,2),size(accuracy,2));
communication_energy1=zeros(size(delay,2),size(accuracy,2)); 
communication_energy2=zeros(size(delay,2),size(accuracy,2));
tot_energy1=zeros(size(delay,2),size(accuracy,2));
tot_energy2=zeros(size(delay,2),size(accuracy,2));

compute_energy1_ifg=zeros(size(delay,2),size(accuracy,2));
compute_energy2_ifg=zeros(size(delay,2),size(accuracy,2));
communication_energy1_ifg=zeros(size(delay,2),size(accuracy,2)); 
communication_energy2_ifg=zeros(size(delay,2),size(accuracy,2));
tot_energy1_ifg=zeros(size(delay,2),size(accuracy,2));
tot_energy2_ifg=zeros(size(delay,2),size(accuracy,2));

for i=1:1:size(delay,2) %delay
    for j=1:1:size(accuracy,2) %accuracy
[compute_energy1(i,j), compute_energy2(i,j), communication_energy1(i,j), communication_energy2(i,j), tot_energy1(i,j), tot_energy2(i,j)]=weighted_fn1(delay(1,i)*10^-3,accuracy(1,j));
[compute_energy1_ifg(i,j), compute_energy2_ifg(i,j), communication_energy1_ifg(i,j), communication_energy2_ifg(i,j), tot_energy1_ifg(i,j), tot_energy2_ifg(i,j)]=ifg_low(delay(1,i)*10^-3,accuracy(1,j));
    end
end

tot_energy11=tot_energy1;
i;
j;
figure
fig1=axes;
ax1=gca;
f1=subplot(1,2,2,ax1);
plot(f1,delay,tot_energy11(:,9),'kX-','MarkerSize',8,'LineWidth',1.5);
hold all
tot_energy1_ifg
plot(f1,delay,tot_energy1_ifg(:,11),'bs-','MarkerSize',8,'LineWidth',1.5);
xlabel('Inference time constraint (ms)')
ylabel('Total energy (J)')
title('(b) Accuracy constraint = 80%');
grid on
hold all
set(gca,'FontSize', 14);
f3=subplot(1,2,1);


figure
fig2=axes;
f2=subplot(1,2,2);
plot(f2,delay,communication_energy1(:,9),'bs:','MarkerSize',8,'LineWidth',1.5);
hold all;
plot(f2,delay,compute_energy1(:,9),'ro--','MarkerSize',6,'LineWidth',1.5);
hold all
xlabel('Inference time constraint (ms)')
ylabel('Energy (J)')
title('(b) Accuracy constraint = 80%');
grid on
set(gca,'FontSize', 14);
hold all;
f4=subplot(1,2,1);
plot(f4,accuracy,communication_energy1(12,:),'bs:','MarkerSize',8,'LineWidth',1.5);
hold all;
plot(f4,accuracy,compute_energy1(12,:),'ro--','MarkerSize',6,'LineWidth',1.5);
hold all
xlabel('Accuracy constraint')
ylabel('Energy (J)')
title('(a) Inference time constraint = 5 ms');
grid on
set(gca,'FontSize', 14);

axes(f3);
plot(f3,accuracy,tot_energy1(12,:),'kX-','MarkerSize',8,'LineWidth',1.5)
hold all
plot(f3,accuracy,tot_energy1_ifg(12,:),'bs-','MarkerSize',8,'LineWidth',1.5)
title(f3,'(a) Inference time constraint = 5 ms');
grid(f3,'on')
set(f3,'FontSize', 14);
xlabel(f3,'Accuracy constraint')
ylabel(f3,'Total energy (J)')

%%%%%%%%%%%%%%%% exhaustive_code

load("config.mat");

ee=[6 140 400];%W energy_weight device es cs
ee_ops=[8.2 38.7 44.8];
w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w3=[30 37 12.6];%communication device es cs nJ/bit
w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit
ops_layer=[22.62 6.711 10.145 19.201 13.523 29.084];%mops
feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
compute_energy=zeros(1,size(config,3));
communication_energy=zeros(1,size(config,3));
compute_delay=zeros(1,size(config,3));
communication_delay=zeros(1,size(config,3));
accuracy1=zeros(1,size(config,3));
accuracy2=zeros(1,size(config,3));
ac1=(85.95/79.19)*[51.94 71.91 79.19];
ac2=(60.32/79.19)*[51.94 71.91 79.19];
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


compute_energy1=compute_energy;%.*6000;
compute_energy2=compute_energy;%.*600;
communication_energy1=communication_energy;%.*6000;
communication_energy2=communication_energy;%.*600;
tot_energy1=compute_energy1+communication_energy1;
tot_energy2=compute_energy2+communication_energy2;
tot_delay1=(compute_delay+communication_delay);%*6000;
tot_delay2=(compute_delay+communication_delay);%*600;
%close all
%subplot(1,2,1)
figure
set(gca,'FontSize', 14);
plot3(tot_energy1,accuracy1,tot_delay1*10^3,'rx','MarkerSize',8,'LineWidth',1.5);
hold all
plot3(tot_energy2,accuracy2,tot_delay2*10^3,'k+','MarkerSize',8,'LineWidth',1.5);
set(gca,'FontSize', 14);
xlabel('Total Energy(J)');
ylabel('Accuracy (%)');
zlabel('Inference time (ms)');
legend('B-AlexNet(CIFAR10)','B-AlexNet(CIFAR100)')
grid on
%subplot(1,2,2)
%plot(accuracy1)
%hold all
%plot(accuracy2)

acc_constraint=10:5:85;
delay_con=5;
data_source=zeros(1,size(acc_constraint,2));
best_config=zeros(1,size(acc_constraint,2));
best_energy=10000*ones(1,size(acc_constraint,2));
best_delay=zeros(1,size(acc_constraint,2));
best_communication_e=zeros(1,size(acc_constraint,2));
best_compute_e=zeros(1,size(acc_constraint,2));
for j=1:size(acc_constraint,2)
for i=1:size(config,3)
    if(accuracy1(1,i)>acc_constraint(1,j) && tot_energy1(1,i)<best_energy(1,j)&&config(1,1,i)==1 && tot_delay1(1,i)<delay_con*10^-3)
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy1(1,i);
        data_source(1,j)=1;
        best_delay(1,j)=tot_delay1(1,i);
        best_communication_e(1,j)=communication_energy1(1,i);
        best_compute_e(1,j)=compute_energy1(1,i);
    end
    if(accuracy2(1,i)>acc_constraint(1,j) && tot_energy2(1,i)<best_energy(1,j)&&config(1,1,i)==1&&tot_delay2(1,i)<delay_con*10^-3)
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy2(1,i);
        data_source(1,j)=2;
        best_delay(1,j)=tot_delay2(1,i);
        best_communication_e(1,j)=communication_energy2(1,i);
        best_compute_e(1,j)=compute_energy2(1,i);
    end
end
end



delay_constraint=3:1:15;
accuracy_constraint=80;
data_source_d=zeros(1,size(delay_constraint,2));
best_config_d=zeros(1,size(delay_constraint,2));
best_energy_d=10000*ones(1,size(delay_constraint,2));
best_delay=zeros(1,size(delay_constraint,2));
best_commun_enery_d=zeros(1,size(delay_constraint,2));
best_compute_energy_d=zeros(1,size(delay_constraint,2));
for j=1:size(delay_constraint,2)
    new_diff=60*10^-3;
for i=1:size(config,3)
    if(tot_delay1(1,i)<delay_constraint(1,j)*10^-3 && (-tot_delay1(1,i)+delay_constraint(1,j)*10^-3)<=new_diff && tot_energy1(1,i)<best_energy_d(1,j) && accuracy1(1,i)>accuracy_constraint&&config(1,1,i)==1)
        best_config_d(1,j)=i;
        best_energy_d(1,j)=tot_energy1(1,i);
        data_source_d(1,j)=1;
        best_delay(1,j)=tot_delay1(1,i);
        best_commun_enery_d(1,j)=communication_energy1(1,i);
        best_compute_energy_d(1,j)=compute_energy1(1,i);
        new_diff=(delay_constraint(1,j)-tot_delay1(1,i));
    end
    if(tot_delay2(1,i)<delay_constraint(1,j)*10^-3 && abs(-tot_delay2(1,i)+delay_constraint(1,j)*10^-3)<=new_diff && tot_energy2(1,i)<best_energy_d(1,j) && accuracy2(1,i)>accuracy_constraint&&config(1,1,i)==1)
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
%figure
set(gca,'FontSize', 14);
%subplot(1,2,1)
set(gca,'FontSize', 14);
axes(f3);
plot(f3,acc_constraint,best_communication_e+best_compute_e,'gx--','MarkerSize',8,'LineWidth',1.5);
hold all
legend(f3,'MCP','FIN','OSL-opt')
axes(f4);
plot(f4,acc_constraint,best_communication_e,'s:','MarkerSize',8,'LineWidth',1.5);
plot(f4,acc_constraint,best_compute_e,'o--','MarkerSize',6,'LineWidth',1.5);
xlabel('Accuracy constraint (%)');
ylabel('Energy (J)');
title('(a) Inference time constraint = 5 ms');
set(gca,'FontSize', 14);
grid on
subplot(1,2,2)
set(gca,'FontSize', 14);
axes(f1);
plot(f1,delay_constraint,best_commun_enery_d+best_compute_energy_d,'gx-','MarkerSize',8,'LineWidth',1.5);
hold all
axes(f2);
plot(f2,delay_constraint,best_commun_enery_d,'s:','MarkerSize',8,'LineWidth',1.5);
plot(f2,delay_constraint,best_compute_energy_d,'o--','MarkerSize',6,'LineWidth',1.5);
legend('Commun. (weight)','Compute (weight)','Commun. (opt)','Compute(opt)');
xlabel('Inference time constraint (in ms)');
ylabel('Energy (J)');
title('(b) Accuracy constraint = 80%');
grid on
set(gca,'FontSize', 14);