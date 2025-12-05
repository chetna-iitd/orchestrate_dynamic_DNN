delay=10:5:100;
accuracy=10:5:85;
compute_energy1=zeros(size(delay,2),size(accuracy,2));
compute_energy2=zeros(size(delay,2),size(accuracy,2));
communication_energy1=zeros(size(delay,2),size(accuracy,2)); 
communication_energy2=zeros(size(delay,2),size(accuracy,2));
tot_energy1=zeros(size(delay,2),size(accuracy,2));
tot_energy2=zeros(size(delay,2),size(accuracy,2));

for i=1:1:size(delay,2) %delay
    for j=1:1:size(accuracy,2) %accuracy
[compute_energy1(i,j), compute_energy2(i,j), communication_energy1(i,j), communication_energy2(i,j), tot_energy1(i,j), tot_energy2(i,j)]=weighted_fn1(delay(1,i),accuracy(1,j));
    end
end

tot_energy1;
i;
j;
figure
fig1=axes;
ax1=gca;
f1=subplot(1,2,2,ax1);
plot(f1,delay,tot_energy1(:,4),'kX-');
xlabel('Delay constraint')
ylabel('Total energy (J)')
title('(b) Accuracy constraint = 80%');
grid on
hold all
set(gca,'FontSize', 14);
f3=subplot(1,2,1);


figure
fig2=axes;
f2=subplot(1,2,2);
plot(f2,delay,compute_energy1(:,4),'o--');
hold all
plot(f2,delay,communication_energy1(:,4),'s:');
xlabel('Delay constraint')
ylabel('Energy (J)')
title('(b) Accuracy constraint = 80%');
grid on
set(gca,'FontSize', 14);
hold all;
f4=subplot(1,2,1);
plot(f4,accuracy,compute_energy1(18,:),'o--');
hold all
plot(f4,accuracy,communication_energy1(18,:),'s:');
xlabel('Accuracy constraint')
ylabel('Energy (J)')
title('(a) Delay constraint = 15 sec');
grid on
set(gca,'FontSize', 14);

axes(f1);
plot(f3,accuracy,tot_energy1(18,:),'bX-')
hold all
title(f3,'(a) Delay constraint = 15 sec');
grid(f3,'on')
set(f3,'FontSize', 14);
xlabel(f3,'Accuracy constraint')
ylabel(f3,'Total energy (J)')