function [compute_energy1, compute_energy2, communication_energy1, communication_energy2, tot_energy1, tot_energy2] = weighted_fn1_multi_model(delay_constraint,accuracy_constraint,delay_constraint_lenet, accuracy_constraint_lenet, n_users_alex, n_users_resnet, n_users_lenet)
%WEIGHTED_FN Summary of this function goes here
%   weighted_fn(30,40)
n_user_total = n_users_alex+ n_users_resnet+ n_users_lenet;
% traffic = [0.1, 560, 4480]*1000000000/8; % need to divide by the user_total

w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit

%w1 is delay
%w2 is accuracy
%w_traffic is the communication traffic Gbps
%delay_constraint=30;
%accuracy_constraint=40;
%if((100-delay_constraint)>accuracy_constraint)
%    accuracy_constraint=1;
%end

max_user = max(max(n_users_alex, n_users_resnet), n_users_lenet);
resource_rate_alex = .001;
resource_rate_resnet = .01;
resource_rate_lenet = 2e-03;
p=zeros(5,2,3, max_user); % 1 is alexnet, 2 is resnet, 3 is lenet
% update p(:,:,2)
for user = 1:n_users_alex
    ops_layer=[22.62 6.711 19.201 13.523 29.084];%mops
    feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
    ac1=(85.95/79.19)*[51.94 71.91 79.19];
    ac2=(60.32/79.19)*[51.94 71.91 79.19];

    for i=1:5 %layer_num
        if (i==1)%% layer 1 constraint
            w1(i,1)=(ops_layer(1,1)*10000000/11000000000000);%*6000;
            w1(i,2)=(ops_layer(1,1)*10000000/11000000000000);%*600;
            w2(i,1)=ac1(1,1);
            w2(i,2)=ac2(1,1);
%             w_traffic(i,1) = traffic(1,1);
%             w_traffic(i,2) = traffic(1,1);
            we_1(i)= max(0.5*w1(i,1)/delay_constraint,accuracy_constraint/w2(i,1));%, w_traffic(i,1)/feature_layer(i)); % communication constraints
            p(1,1, 1, user)=1;
            p(1,2, 1, user)=3;
        else
            val_d=ops_layer(1,i)*10000000/11000000000000;
            val_es=(ops_layer(1,i)*10000000*n_user_total/(resource_rate_alex*153400000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,2)/1000000000);
            val_cs=(ops_layer(1,i)*10000000*n_user_total/(resource_rate_alex*312000000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,3)/1000000000);
            if(i==3)
            w2(i,1)=ac1(1,2);
            w2(i,2)=ac2(1,2);
%             w_traffic(i,1)= traffic(1,2)/n_user_total;
%             w_traffic(i,2)= traffic(1,2)/n_user_total;
            elseif(i==5)
                w2(i,1)=ac1(1,3);
                w2(i,2)=ac2(1,3);
%                 w_traffic(i,1)= traffic(1,3)/n_user_total;
%                 w_traffic(i,2)= traffic(1,3)/n_user_total;

            else
                w2(i,1)=ac1(1,i-1);
                w2(i,2)=ac2(1,i-1);
%                 w_traffic(i,1)= traffic(1,i-1)/n_user_total;
%                 w_traffic(i,2)= traffic(1,i-1)/n_user_total;
            end
            w1(i,1)=min([val_d,val_es,val_cs]);%*6000;
            w1(i,2)=min([val_d,val_es,val_cs]);%*600

            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint,accuracy_constraint/w2(i,1));        

            if(val_d<val_es && (we_1(i)>0.85 || p((i-1),2)>=i) && p((i-1),1)==1)
                p(i,1, 1, user)=1;     
                if(i<4)
                    p(:,2, 1, user)=min(i,2);
                else
                    p(:,2, 1, user)=min(i,3);
                end
                w1(i,1)=val_d;%*6000;
                w1(i,2)=val_d;%*600;
            elseif(val_d>val_es && (we_1(i)>0.85|| p((i-1),2)>=i) && p((i-1),1, user)==1)
                p(i,1, 1, user)=2;     
                if(i<4)
                    p(:,2, 1, user)=min(i,2);
                else
                    p(:,2, 1, user)=min(i,3);
                end
                w1(i,1)=val_es;%*6000;
                w1(i,2)=val_es;%*600;
            elseif(val_es>val_cs && (we_1(i)>0.85 || p((i-1),2, 1, user)>=i) && p((i-1),1, 1, user)>=1)
                p(i,1, 1, user)=3;     
                if(i<4)
                    p(:,2, 1, user)=min(i,2);
                else
                    p(:,2, 1, user)=min(i,3);
                end
                w1(i,1)=val_cs;%*6000;
                w1(i,2)=val_cs;%*600;   
            end        
            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint,accuracy_constraint/w2(i,1));        
        end
    end
end

% update p(:,:,2)
for user = 1:1:n_users_resnet
    ops_layer = [0.7733, 1.0803, 1.0593, 3.5043 ,11.7704];
    feature_layer = [(32*32*16) (32*32*16) (8*8*64) (8*8*64)];
    ac1=(93.70/79.17)*[32.86 43.78 79.17];
    ac2=(60.32/79.17)*[32.86 43.78 79.17];

    for i=1:5 %layer_num
        if (i==1)%% layer 1 constraint
            w1(i,1)=(ops_layer(1,1)*10000000/11000000000000);%*6000;
            w1(i,2)=(ops_layer(1,1)*10000000/11000000000000);%*600;
            w2(i,1)=ac1(1,1);
            w2(i,2)=ac2(1,1);
%             w_traffic(i,1) = traffic(1,1);
%             w_traffic(i,2) = traffic(1,1);
            we_1(i)= max(0.5*w1(i,1)/delay_constraint,accuracy_constraint/w2(i,1)); % communication constraints
            p(1,1, 2, user)=1;
            p(1,2, 2, user)=3;
        else
            val_d=ops_layer(1,i)*10000000/11000000000000;
            val_es=(ops_layer(1,i)*10000000/(resource_rate_resnet*153400000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,2)/1000000000);
            val_cs=(ops_layer(1,i)*10000000/(resource_rate_resnet*312000000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,3)/1000000000);
            if(i==3)
            w2(i,1)=ac1(1,2);
            w2(i,2)=ac2(1,2);
%             w_traffic(i,1)= traffic(1,2)/n_user_total;
%             w_traffic(i,2)= traffic(1,2)/n_user_total;
            elseif(i==5)
                w2(i,1)=ac1(1,3);
                w2(i,2)=ac2(1,3);
%                 w_traffic(i,1)= traffic(1,3)/n_user_total;
%                 w_traffic(i,2)= traffic(1,3)/n_user_total;

            else
                w2(i,1)=ac1(1,i-1);
                w2(i,2)=ac2(1,i-1);
%                 w_traffic(i,1)= traffic(1,i-1)/n_user_total;
%                 w_traffic(i,2)= traffic(1,i-1)/n_user_total;
            end
            w1(i,1)=min([val_d,val_es,val_cs]);%*6000;
            w1(i,2)=min([val_d,val_es,val_cs]);%*600;

            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint,accuracy_constraint/w2(i,1));        

            if(val_d<val_es && (we_1(i)>0.85 || p((i-1),2,user)>=i) && p((i-1),1,user)==1)
                p(i,1,2,user)=1;     
                if(i<4)
                    p(:,2, 2, user)=min(i,2);
                else
                    p(:,2, 2, user)=min(i,3);
                end
                w1(i,1)=val_d;%*6000;
                w1(i,2)=val_d;%*600;
            elseif(val_d>val_es && (we_1(i)>0.85|| p((i-1),2, 2,user)>=i) && p((i-1),1, 2, user)==1)
                p(i,1, 2, user)=2;     
                if(i<4)
                    p(:,2, 2, user)=min(i,2);
                else
                    p(:,2, 2, user)=min(i,3);
                end
                w1(i,1)=val_es;%*6000;
                w1(i,2)=val_es;%*600;
            elseif(val_es>val_cs && (we_1(i)>0.85 || p((i-1),2, 2, user)>=i) && p((i-1),1,2, user)>=1)
                p(i,1, 2, user)=3;     
                if(i<4)
                    p(:,2, 2, user)=min(i,2);
                else
                    p(:,2, 2, user)=min(i,3);
                end
                w1(i,1)=val_cs;%*6000;
                w1(i,2)=val_cs;%*600;   
            end        
            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint,accuracy_constraint/w2(i,1));        
        end
    end
end

% update p(:,:,3)
for user = 1:n_users_lenet
    %LeNet
    ops_layer = [0.1674, 0.04, 0.048]; %mops
    feature_layer=[(10*10*16) (1*1*120)];
    ac1=(99.25/99.25)*[93.59 99.25]; 
    ac2=(96.7/99.25)*[93.59 99.25];
    for i=1:2 %layer_num
        if (i==1)%% layer 1 constraint
            w1(i,1)=(ops_layer(1,1)*10000000/11000000000000);%*6000;
            w1(i,2)=(ops_layer(1,1)*10000000/11000000000000);%*600;
            w2(i,1)=ac1(1,1);
            w2(i,2)=ac2(1,1);
%             w_traffic(i,1) = traffic(1,1);
%             w_traffic(i,2) = traffic(1,1);
            we_1(i)=max(0.5*w1(i,1)/delay_constraint_lenet,accuracy_constraint_lenet/w2(i,1));
            p(1,1, 3, user)=1;
            p(1,2, 3, user)=1;
        else
            val_d=ops_layer(1,i)*10000000/11000000000;
            val_es=(ops_layer(1,i)*10000000/(resource_rate_lenet*153400000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,2)/1000000000);
            val_cs=(ops_layer(1,i)*10000000/(resource_rate_lenet*312000000000000)) + ((feature_layer(1,i-1)+feature_layer(1,i-1))*8*w1_2(1,3)/1000000000);
            if(i==3)
            w2(i,1)=ac1(1,2);
            w2(i,2)=ac2(1,2);
%             w_traffic(i,1) = traffic(1,2)/n_user_total;
%             w_traffic(i,2) = traffic(1,2)/n_user_total;
            else
                w2(i,1)=ac1(1,i-1);
                w2(i,2)=ac2(1,i-1);
%                 w_traffic(i,1) = traffic(1,3)/n_user_total;
%                 w_traffic(i,2) = traffic(1,3)/n_user_total;
            end
            w1(i,1)=min([val_d,val_es,val_cs]);%*6000;
            w1(i,2)=min([val_d,val_es,val_cs]);%*600;
            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint_lenet,accuracy_constraint_lenet/w2(i,1));        

            if(val_d<val_es && (we_1(i)>0.85 || p((i-1),2, 3, user)>=i) && p((i-1),1, 3, user)==1)
                p(i,1, 3, user)=1;     
                if(i<2)
                    p(:,2, 3, user)=min(i,2);
                else
                    p(:,2, 3, user)=min(i,3);
                end
                w1(i,1)=val_d;%*6000;
                w1(i,2)=val_d;%*600;
            elseif(val_d>val_es && (we_1(i)>0.85|| p((i-1),2, 3, user)>=i) && p((i-1),1, 3, user)==1)
                p(i,1, 3, user)=2;     
                if(i<2)
                    p(:,2, 3, user)=min(i,2);
                else
                    p(:,2, 3, user)=min(i,3);
                end
                w1(i,1)=val_es;%*6000;
                w1(i,2)=val_es;%*600;
            elseif(val_es>val_cs && (we_1(i)>0.85 || p((i-1),2,3, user)>=i) && p((i-1),1,3, user)>=1)
                p(i,1, 3)=3;     
                if(i<2)
                    p(:,2, 3, user)=min(i,2);
                else
                    p(:,2, 3, user)=min(i,3);
                end
                w1(i,1)=val_cs;%*6000;
                w1(i,2)=val_cs;%*600;   
            end
            we_1(i)=max(0.5*sum(w1(1:i,1))/delay_constraint_lenet,accuracy_constraint_lenet/w2(i,1));
        end
    end
end


we_1;
w1./delay_constraint;
accuracy_constraint./w2;
%if(delay_constraint==25 && accuracy_constraint==80)
%p;
%end

ee=[6 140 400];%W energy_weight device es cs
ee_ops=[8.2 38.7 44.8];
w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w3=[30 37 12.6];%communication device es cs nJ/bit

compute_energy = zeros(1,3);
compute_delay = zeros(1,3);
communication_energy = zeros(1,3);
communication_delay = zeros(1,3);
accuracy1 = zeros(1,3);
accuracy2 = zeros(1,3);

%for k=1:size(config,3)
    ct=p;%config(:,:,k);
k=1; % 1 is alexnet, 2 is resnet, 3 is lenet
ops_layer=[22.62 6.711 19.201 13.523 29.084];%mops
ac1=(85.95/79.19)*[51.94 71.91 79.19];
ac2=(60.32/79.19)*[51.94 71.91 79.19];


for user = 1: n_users_alex
    w1_1=[11 153.4*resource_rate_alex*1000/n_users_alex 312*resource_rate_alex/n_users_alex];%TOPS device es cs capability delay_weight computation
    for i=1:5
     if(ct(i,1, k, user)~=0)
        compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
        compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
        if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
        communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1, k, user))/1000000000);
        communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
        end
     end
    end
%     accuracy1(1,k)=accuracy1(1,k)+ac1(1,ct(1,2, k, user));
%    accuracy2(1,k)=accuracy2(1,k)+ac2(1,ct(1,2, k, user)); 
end

% for user = 1: n_users_alex
%     w1_1=[11 153.4*resource_rate_alex*1000/n_users_alex 312*resource_rate_alex*1000/n_users_alex]*1000;%TOPS device es cs capability delay_weight computation
%     w1_1
%     for i=1:5
%     if(ct(i,1, k, user)~=0)
%         compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
%         compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
%         if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
%         communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1, k, user))/1000000000);
%         communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
%         end
%     end
%     end
% %     accuracy1(1,k)=accuracy1(1,k)+ac1(1,ct(1,2, k, user));
% %    accuracy2(1,k)=accuracy2(1,k)+ac2(1,ct(1,2, k, user)); 
% end

k=2; % 1 is alexnet, 2 is resnet, 3 is lenet
ops_layer = [0.7733, 1.0803, 1.0593, 3.5043 ,11.7704];
ac1=(93.70/79.17)*[32.86 43.78 79.17];
ac2=(60.32/79.17)*[32.86 43.78 79.17];


for user = 1:n_users_resnet
    w1_1=[11 153.4*resource_rate_resnet*1000/n_users_resnet 312*resource_rate_resnet*1000/n_users_resnet];%TOPS device es cs capability delay_weight computation
    w1_1
    for i=1:5
     if(ct(i,1, k, user)~=0)
        compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
        compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
        if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
        %communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1,k, user))/1000000000);
        communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1, k, user))/1000000000);
        communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
        end
     end
    end
%     accuracy1(1,k)=accuracy1(1,k)+ac1(1,ct(1,2, k, user));
%    accuracy2(1,k)=accuracy2(1,k)+ac2(1,ct(1,2, k, user)); 
end



% for user = 1:n_users_resnet
%     w1_1=[11 153.4*resource_rate_resnet*1000/n_users_resnet 312*resource_rate_resnet*1000/n_users_resnet];%TOPS device es cs capability delay_weight computation
%     for i=1:5
%      if(ct(i,1, k, user)~=0)
%         compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
%         compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
%         if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
%         communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1,k, user))/1000000000);
%         communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
%         end
%      end
%     end
% %     accuracy1(1,k)=accuracy1(1,k)+ac1(1,ct(1,2, k, user));
% %    accuracy2(1,k)=accuracy2(1,k)+ac2(1,ct(1,2, k, user)); 
% end

k=3; % 1 is alexnet, 2 is resnet, 3 is lenet
ac1=(99.25/99.25)*[93.59 99.25]; 
ac2=(96.7/99.25)*[93.59 99.25];
ops_layer =  [0.1674, 0.04, 0.048]; %mops
feature_layer=[(10*10*16) (1*1*120)];
for user = 1:n_users_lenet
    w1_1=[11 153.4*1000*resource_rate_lenet/n_users_lenet 312*1000*resource_rate_lenet/n_users_lenet];
    for i=1:3
    if(ct(i,1, k, user)~=0)
        compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
        compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
        if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
        communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1, k, user))/1000000000);
        communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
        end
    end
    end
%     accuracy1(1,k)=accuracy1(1,k) + ac1(1,ct(1,2, k, user));
%    accuracy2(1,k)=accuracy2(1,k)+ ac2(1,ct(1,2, k, user)); 
end
% Getting the total for all elements
% compute_energy = sum(compute_energy);
% compute_delay = sum(compute_delay);
% communication_energy = sum(communication_energy);
% communication_delay = sum(communication_delay);


compute_energy1=compute_energy;%.*6000;
compute_energy2=compute_energy;%.*600;
communication_energy1=communication_energy;%.*6000;
communication_energy2=communication_energy;%.*600;
tot_energy1=compute_energy1+communication_energy1;
tot_energy2=compute_energy2+communication_energy2;
tot_delay1=(compute_delay+communication_delay);%*6000;
tot_delay2=(compute_delay+communication_delay);%*600;

end

