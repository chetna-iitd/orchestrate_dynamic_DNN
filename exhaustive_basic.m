load("config.mat");

ee=[6 140 400];%W energy_weight device es cs
ee_ops=[8.2 38.7 44.8];
w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w3=[30 37 12.6];%communication device es cs nJ/bit
ops_layer=[22.62 6.711 10.145 19.201 13.523 29.084];%mops
feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
compute_energy=zeros(1,size(config,3));
communication_energy=zeros(1,size(config,3));
accuracy1=zeros(1,size(config,3));
accuracy2=zeros(1,size(config,3));
ac1=(85.95/79.19)*[51.94 71.91 79.19];
ac2=(60.32/79.19)*[51.94 71.91 79.19];
for k=1:size(config,3)
    ct=config(:,:,k);
    for i=1:5
     if(ct(i,1)~=0)
        compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1))*ops_layer(1,i)/(w1_1(1,ct(i,1))*1000));        
        if(i>1 && ct(i,1)>ct(i-1,1))
        communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1))/1000000000);
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
close all
subplot(1,2,1)
plot(compute_energy1);
hold all
plot(communication_energy1);
subplot(1,2,2)
plot(accuracy1)
hold all
plot(accuracy2)

acc_constraint=10:5:85;
data_source=zeros(1,size(acc_constraint,2));
best_config=zeros(1,size(acc_constraint,2));
best_energy=10000*ones(1,size(acc_constraint,2));
for j=1:size(acc_constraint,2)
for i=1:size(config,3)
    if(accuracy1(1,i)>acc_constraint(1,j) && tot_energy1(1,i)<best_energy(1,j))
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy1(1,i);
        data_source(1,j)=1;
    end
    if(accuracy2(1,i)>acc_constraint(1,j) && tot_energy2(1,i)<best_energy(1,j))
        best_config(1,j)=i;
        best_energy(1,j)=tot_energy2(1,i);
        data_source(1,j)=2;
    end
end
end
figure
plot(acc_constraint,best_energy,'x-');
