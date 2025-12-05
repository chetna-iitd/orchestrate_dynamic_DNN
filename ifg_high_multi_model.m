function [compute_energy1, compute_energy2, communication_energy1, communication_energy2, tot_energy1, tot_energy2] = ifg_high_multi_model(delay_constraint,accuracy_constraint,delay_constraint_lenet, accuracy_constraint_lenet, n_users_alex, n_users_resnet, n_users_lenet)
%WEIGHTED_FN Summary of this function goes here
%   weighted_fn(30,40)
n_user_total = n_users_alex+ n_users_resnet+ n_users_lenet;
% traffic = [0.1, 560, 4480]*1000000000/8; % need to divide by the user_total

gamma=10;
lambda=1;

w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit
%w1 is delay
%w2 is accuracy
%delay_constraint=30;
%accuracy_constraint=40;
%if((100-delay_constraint)>accuracy_constraint)
%    accuracy_constraint=1;
%end

ee=[6 140 400];%W energy_weight device es cs
ee_ops=[8.2 38.7 44.8];
%  w1_1=[11 153.4 312];%TOPS device es cs capability delay_weight computation
w3=[30 37 12.6];%communication device es cs nJ/bit


max_user = max(max(n_users_alex, n_users_resnet), n_users_lenet);
p=zeros(5,2,3, max_user);

resource_rate_alex = .001;
resource_rate_resnet = .01;
resource_rate_lenet = 2e-03;

for user = 1:n_users_alex
    nodes=[1 0 0 
            1 1 1
            1 1 1
            1 1 1
            1 1 1];
    edges_=[1 1 1 0 0 0 0 0 0
            1 1 1 0 1 1 0 0 1
            1 1 1 0 1 1 0 0 1
            1 1 1 0 1 1 0 0 1];
    w1_1=[11 153.4*1000*resource_rate_alex/n_users_alex 312*1000*resource_rate_alex/n_users_alex];%TOPS device es cs capability delay_weight computation
    ops_layer=[22.62 6.711 19.201 13.523 29.084];%mops
    feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
    ac1=(85.95/79.19)*[51.94 71.91 79.19];
    ac2=(60.32/79.19)*[51.94 71.91 79.19];

    vertex=zeros(5,3,gamma+5,gamma+5);% 3 denotes the network nodes i.e. device, es, cs
    %3 denotes the dimension
    edges=zeros(4,9,gamma+5,gamma+5);
    %for i=1:gamma
    w1__=zeros(4,1);
    %edges(1,:,:)=1; % privacy preserving condition, currently all data sources can be used
    for i=1:4
        for j=1:3
            for k=1:3
        %create edge between node a and b
        w1__(i,1)=(ops_layer(1,i)*10000000/(w1_1(1,j)*1000000000));
    if((((j-1)*3)+k)==2||(((j-1)*3)+k)==3||(((j-1)*3)+k)==6 && i>2)
        w1__(i,1)=w1__(i,1)+(feature_layer(1,i)*8*w3(1,3)/1000000000)+(feature_layer(1,i)*8*w3(1,3)/1000000000);%*6000;
    end
    w2=ac1(1,3);
%     w_traffic = traffic(1,3);
    if(edges_(i,((j-1)*3)+k)==1)
        i_d=uint16(min((gamma+1),(i+ceil(gamma*(w1__(i,1)/delay_constraint)))));
        j_d=uint16(min((gamma+1),(j+ceil(gamma*(w2/accuracy_constraint)))));
        edges(i,((j-1)*3)+k,i_d,j_d)=1;
    end
            end
    end
    end

    %vertex
    %edges
    lambda=1;
    p(1,1, 1, user)=1;
    p(1,2, 1, user)=3;
    for i=2:4
    for k=lambda:gamma+1
    for l=lambda:gamma+1
        if (edges(i,1,k,l)==1)
            p(i,1, 1, user)=1;
        end
                if (edges(i,2,k,l)==1 || edges(i,5,k,l)==1)
            p(i,1, 1, user)=2;
                end
                        if ( edges(i,5,k,l)==1)
            p(i,1, 1, user)=2;
        end
        if (edges(i,3,k,l)==1 || edges(i,6,k,l)==1 || edges(i,9,k,l)==1)
            p(i,1, 1, user)=3;
        end

        p(:,2, 1, user)=3;
    end
    end
    end

    flag2=0;
    if(ac1(1,2)>accuracy_constraint)
    p(:,2, 1,user)=2;
    flag2=1;
    p(4:5,1, 1, user)=0;
    end
    accuracy_constraint;
    if(ac1(1,1)>accuracy_constraint)
    p(:,2, 1, user)=1;
    p(2:5,1, 1, user)=0;
    end


    sum(w1__);
    delay_constraint;
    if(delay_constraint>3*sum(w1__))%% further improve this
    %    p(3,1)=p(2,l);
    if(p(5,1, 1, user)~=0)
        p(5,1, 1, user)=p(4,1, 1, user);
    end 
    if(p(4,1, 1, user)~=0)
        p(4,1, 1, user)=p(3,1, 1, user);
    end 
    p(3,1, 1, user)=p(2,1, 1, user);
    p(2,1, 1, user)=p(1,1, 1, user);
    end
end


% resnet
%vertex
%edges

for user = 1:n_users_resnet
    nodes=[1 0 0 
    1 1 1
    1 1 1
    1 1 1
    1 1 1];
    edges_=[1 1 1 0 0 0 0 0 0
        1 1 1 0 1 1 0 0 1
       1 1 1 0 1 1 0 0 1
       1 1 1 0 1 1 0 0 1];
    w1_1=[11 153.4*1000*resource_rate_resnet/n_users_resnet 312*1000*resource_rate_resnet/n_users_resnet];%TOPS device es cs capability delay_weight computation
    ops_layer = [0.7733, 1.0803, 1.0593, 3.5043 ,11.7704];
    feature_layer = [(32*32*16) (32*32*16) (8*8*64) (8*8*64)];
    % Resnet
    ac1=(93.70/79.17)*[32.86 43.78 79.17];
    ac2=(60.32/79.17)*[32.86 43.78 79.17];
    vertex=zeros(5,3,gamma+5,gamma+5 );% 3 denotes the network nodes i.e. device, es, cs
    %3 denotes the dimension
    edges=zeros(4,9,gamma+5,gamma+5 );
    %for i=1:gamma
    w1__=zeros(4,1);
    %edges(1,:,:)=1; % privacy preserving condition, currently all data sources can be used
    for i=1:4
        for j=1:3
            for k=1:3
    %create edge between node a and b
    w1__(i,1)=(ops_layer(1,i)*10000000/(w1_1(1,j)*1000000000));
    if(((((j-1)*3)+k)==2||(((j-1)*3)+k)==3||(((j-1)*3)+k)==6) && i>2)
        w1__(i,1)=w1__(i,1)+(feature_layer(1,i)*8*w3(1,3)/1000000000)+(feature_layer(1,i-1)*8*w3(1,3)/1000000000);%*6000;
    end
    if(((((j-1)*3)+k)==2||(((j-1)*3)+k)==3||(((j-1)*3)+k)==6) && i>2 && j>1)
        w1__(i,1)=w1__(i,1)+(feature_layer(1,i-1)*8*w3(1,j-1)/1000000000)+(feature_layer(1,i-1)*8*w3(1,j-1)/1000000000);%*6000;
    end
    w2=ac1(1,3);
    % w_traffic = traffic(1,3);
        if(edges_(i,((j-1)*3)+k)==1)
            i_d=uint16(min((gamma+1),(i+ceil(gamma*(w1__(i,1)/(delay_constraint))))));
            j_d=uint16(min((gamma+1),(j+ceil(gamma*(w2/accuracy_constraint)))));
            edges(i,((j-1)*3)+k,i_d,j_d)=1;
        end
    end
    end
    end
    

    lambda=1;
    p(1,1, 2, user)=1;
    p(1,2, 2, user)=3;
    for i=2:4
    for k=lambda:gamma+5
    for l=lambda:gamma+5
        if (edges(i-1,1,k,l)==1)
            p(i,1, 2, user)=1;
        end
        if (edges(i,2,k,l)==1 || edges(i,5,k,l)==1)
        p(i,1, 2, user)=2;
        end
        if (edges(i,5,k,l)==1)
            p(i,1, 2, user)=2;
        end
        if (edges(i,3,k,l)==1 || edges(i,6,k,l)==1 || edges(i,9,k,l)==1)
            p(i,1, 2, user)=3;
        end
        p(:,2, 2, user)=3;
    end
    end
    end
    flag2=0;
    if(ac1(1,2)>accuracy_constraint)
    p(:,2, 2,user)=2;
    flag2=1;
    p(4:5,1, 2, user)=0;
    end
    accuracy_constraint;
    if(ac1(1,1)>accuracy_constraint)
    p(:,2, 2, user)=1;
    p(2:5,1, 2, user)=0;
    end
    sum(w1__);
    if(delay_constraint>3*sum(w1__)&& accuracy_constraint<80)%% further improve this
        if(p(5,1, 2, user)~=0)
            p(5,1, 2, user)=p(1,1, 2, user);
        end 
        if(p(4,1, 2, user)~=0)
            p(4,1, 2, user)=p(1,1, 2, user);
        end 
        if(p(3,1, 2, user)~=0)
            p(3,1, 2, user)=p(1,1, 2, user);
        end 
        if(p(2,1, 2, user)~=0)
            p(2,1, 2, user)=p(1,1, 2, user);
        end 

    end
    if(delay_constraint>5*10^-3 && accuracy_constraint>80)%% further improve this
        p(5,1, 2,user)=1;
        p(4,1, 2, user)=1;

        if(p(3,1, 2, user)~=0)
            p(3,1, 2, user)=1;
        end 
        if(p(2,1, 2, user)~=0)
            p(2,1, 2, user)=1;
        end 
    end

    if(p(4,1, 2, user)~=0 && p(5,1, 2, user)==0)
        p(5,1, 2,user)=2;
        if(delay_constraint>5*10^-3)
            p(5,1, 2, user)=1;
        end
    end
end

for user = 1:n_users_lenet
    ops_layer =  [0.1674, 0.04, 0.048]; %mops
    w1_1=[11 153.4*1000*resource_rate_lenet/n_users_lenet 312*1000*resource_rate_lenet/n_users_lenet];
    feature_layer=[(10*10*16) (1*1*120)];    
    %LeNet
    ac1=(99.25/99.25)*[93.59 99.25]; 
    ac2=(96.7/99.25)*[93.59 99.25];
    %w1 is delay
    %w2 is accuracy
    %delay_constraint=30;
    %accuracy_constraint=40;
    %if((100-delay_constraint)>accuracy_constraint)
    %    accuracy_constraint=1;
    %end  
    
    nodes=[1 0 0 
        1 1 1
        1 1 1
        1 1 1
        1 1 1];
    edges_=[1 1 1 0 0 0 0 0 0
            1 1 1 0 1 1 0 0 1];
    
    vertex=zeros(3,3,gamma+5,gamma+5 );% 3 denotes the network nodes i.e. device, es, cs
    %3 denotes the dimension
    edges=zeros(2,9,gamma+5,gamma+5 );
    %for i=1:gamma
    w1__=zeros(3,1);
    %edges(1,:,:)=1; % privacy preserving condition, currently all data sources can be used
    for i=1:2
        for j=1:3
            for k=1:3
    %create edge between node a and b
    w1__(i,1)=(ops_layer(1,i)*10000000/(w1_1(1,j)*1000000000));
    if((((j-1)*3)+k)==2||(((j-1)*3)+k)==3||(((j-1)*3)+k)==6 && i>2)
        w1__(i,1)=w1__(i,1)+(feature_layer(1,i)*8*w3(1,3)/1000000000)+(feature_layer(1,i)*8*w3(1,3)/1000000000);%*6000;
    end
    if(((((j-1)*3)+k)==2||(((j-1)*3)+k)==3||(((j-1)*3)+k)==6) && i>2 && j>1)
        w1__(i,1)=w1__(i,1)+(feature_layer(1,i-1)*8*w3(1,j-1)/1000000000)+(feature_layer(1,i-1)*8*w3(1,j-1)/1000000000);%*6000;
    end
    w2=ac1(1,2);
%     w_traffic = traffic(1,2);
    if(edges_(i,((j-1)*3)+k)==1)
        i_d=uint16(min((gamma+1),(i+ceil(gamma*(w1__(i,1)/(delay_constraint_lenet))))));
        j_d=uint16(min((gamma+1),(j+ceil(gamma*(w2/accuracy_constraint_lenet)))));
        edges(i,((j-1)*3)+k,i_d,j_d)=1;
    end
            end
    end
    end
    
    %vertex
    %edges
    p(:,1, 3,user)=1;
    p(:,2, 3,user)=2;
    for i=2:3
    for k=lambda:gamma+1
    for l=lambda:gamma+1
         if (edges(i-1,1,k,l)==1)
            p(i,1, 3, user)=1;
         end
                if (edges(i-1,2,k,l)==1)
            p(i,1, 3, user)=2;
                end
                            if (edges(i-1,3,k,l)==1)
            p(i,1, 3, user)=3;
                end
        p(:,2, 3, user)=2;
    end
    end
    end
    flag2=0;
    if(ac1(1,2)>accuracy_constraint_lenet)
    p(:,2, 3, user)=2;
    p(1:2,1, 3, user)=1;
    flag2=1;
    %p(4:5,1)=0;
    end
    if(ac1(1,1)>accuracy_constraint_lenet)
    p(:,2, 3, user)=1;
    
    p(2:3,1, 3, user)=0;
    end
    sum(w1__);
    if(delay_constraint_lenet>4*sum(w1__)&& accuracy_constraint_lenet<85)%% further improve this

    if(p(3,1, 3, user)~=0)
         p(3,1,3, user)=p(1,1, 3, user);
    end
     if(p(2,1, 3, user)~=0)
         p(2,1, 3, user)=p(1,1, 3, user);
     end 

    end
    if(delay_constraint_lenet>0.2*10^-3 && accuracy_constraint_lenet>85)%% further improve this
    if(p(3,1,3,user)~=0)
         p(3,1, 3, user)=1;
    end 
     if(p(2,1, 3,user)~=0)
         p(2,1,3, user)=1;
     end 

    end
    
end



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

k=3; % 1 is alexnet, 2 is resnet, 3 is lenet
ac1=(99.25/99.25)*[93.59 99.25]; 
ac2=(96.7/99.25)*[93.59 99.25];
ops_layer =  [0.1674, 0.04, 0.048]; %mops
feature_layer=[(10*10*16) (1*1*120)];
% for user = 1:n_users_lenet
%     w1_1=[11 153.4*1000*resource_rate_lenet/n_users_lenet 312*1000*resource_rate_lenet/n_users_lenet];
%     for i=1:3
%      if(ct(i,1, k, user)~=0)
%         compute_energy(1,k)=compute_energy(1,k)+(ee(1,ct(i,1, k, user))*ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));    
%         compute_delay(1,k)=compute_delay(1,k)+(ops_layer(1,i)/(w1_1(1,ct(i,1, k, user))*1000));
%         if(i>1 && ct(i,1, k, user)>ct(i-1,1, k, user))
%         communication_energy(1,k)=communication_energy(1,k)+(feature_layer(1,i-1)*8*w3(1,ct(i,1, k, user))/1000000000)+(feature_layer(1,i-1)*8*w3(1,ct(i-1,1, k, user))/1000000000);
%         communication_delay(1,k)=communication_delay(1,k)+(feature_layer(1,i-1)*8*w1_2(1,ct(i,1, k, user))/1000000000);
%         end
%      end
%     end
% %     accuracy1(1,k)=accuracy1(1,k) + ac1(1,ct(1,2, k, user));
% %    accuracy2(1,k)=accuracy2(1,k)+ ac2(1,ct(1,2, k, user)); 
% end

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