function [compute_energy1, compute_energy2, communication_energy1, communication_energy2, tot_energy1, tot_energy2] = weighted_fn(delay_constraint,accuracy_constraint)
%WEIGHTED_FN Summary of this function goes here
%   weighted_fn(30,40)

ops_layer=[22.62 6.711 10.145 19.201 13.523 29.084];%mops
feature_layer=[(27*27*256) (13*13*384) (13*13*384) (13*13*256)];
ac1=(85.95/79.19)*[51.94 71.91 79.19];
ac2=(60.32/79.19)*[51.94 71.91 79.19];
w1_2=[10 0.00178 0.00022];%communication delay_weight (1/bitrate) nanosec per bit
%w1 is delay
%w2 is accuracy
%delay_constraint=30;
%accuracy_constraint=40;
if((100-delay_constraint)>accuracy_constraint)
    accuracy_constraint=1;
end
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
        we_1(i)=max(w1(i,1)/delay_constraint,accuracy_constraint/w2(i,1));        
        if(val_d<val_es && (we_1(i)>0.5 || p((i-1),2)>=i) && p((i-1),1)==1)
            p(i,1)=1;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_d*6000;
            w1(i,2)=val_d*600;
        elseif(val_d>val_es && (we_1(i)>0.5 || p((i-1),2)>=i) && p((i-1),1)==1)
            p(i,1)=2;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_es*6000;
            w1(i,2)=val_es*600;
        elseif(val_es>val_cs && (we_1(i)>0.5 || p((i-1),2)>=i) && p((i-1),1)>=1)
            p(i,1)=3;     
            if(i<4)
                p(:,2)=min(i,2);
            else
                p(:,2)=min(i,3);
            end
            w1(i,1)=val_cs*6000;
            w1(i,2)=val_cs*600;   
        end        
        we_1(i)=max(w1(i,1)/delay_constraint,accuracy_constraint/w2(i,1));        
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

compute_energy=0;
communication_energy=0;
compute_delay=0;
communication_delay=0;
accuracy1=0;
accuracy2=0;

%for k=1:size(config,3)
    ct=p;%config(:,:,k);
    k=1;
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
%end


compute_energy1=compute_energy.*6000
compute_energy2=compute_energy.*600
communication_energy1=communication_energy.*6000
communication_energy2=communication_energy.*600
tot_energy1=compute_energy1+communication_energy1
tot_energy2=compute_energy2+communication_energy2
tot_delay1=(compute_delay+communication_delay)*6000
tot_delay2=(compute_delay+communication_delay)*600



end

