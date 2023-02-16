
beta= 15;%in sec delay constraint
alpha= 50;%in % accuracy constraint
device=[1 1];
es=[1];
config=3*ones(5,2,1);
counter=1;
%layer_num(row) deployment(0-not_deployed 1-d, 2-es, 3-cs), ee( 1-exit1, 2-exit2, 3-exit3)
layers=[1 3 %layer1+exit1
     1 3 %layer2
     1 3 %layer3+exit2
     1 3 %layer4
     1 3];%layer5+exit5

%for beta=5:5:30
 %   for alpha=10:5:80
  %      energy
  energy=zeros(5,3);
  for i=1:5
      for j=1:4
            layers(6-i,1)=4-j;
        for k=1:6-i
            if (layers(k,1)>(4-j) || layers(k,1)==0)                
                layers(k,1)=4-j;
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end    
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end
       % layers
      end     
  end
for j=1:4
      for i=1:5
            layers(6-i,1)=4-j;
        for k=1:6-i
            if (layers(k,1)>(4-j) || layers(k,1)==0)                
                layers(k,1)=4-j;
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end    
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end        
        %layers
      end     
end
layers(:,1)=3;
layers(:,2)=3;

  for j=1:4
      for i=1:5
            layers(i,1)=j-1;
        for k=5:-1:2
            for l=1:k
            if (layers(l,1)>layers(k,1) || (layers(l,1)==0 && layers(k,1)~=0))                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end        
        %layers
      end     
  end

  layers(:,1)=3;
  layers(:,2)=3;
    for i=1:5
      for j=1:4
            layers(i,1)=j-1;
        for k=5:-1:2
            for l=1:k
            if (layers(l,1)>layers(k,1) || (layers(l,1)==0 && layers(k,1)~=0))                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end        
        %layers
      end     
  end

  layers(:,1)=3;
  layers(:,2)=3;
    for i=1:5
      for j=4:-1:1
            layers(i,1)=j-1;
        for k=5:-1:2
            for l=1:k
            if (layers(l,1)>layers(k,1) || (layers(l,1)==0 && layers(k,1)~=0))                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end        
       % layers
      end     
  end
  
layers=0*ones(5,2);
   for j=4:-1:1
      for i=5:-1:1
            layers(i,1)=4-j;
        for k=2:5
            for l=1:k
            if (layers(l,1)>layers(k,1) || layers(l,1)==0)                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end    
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end
        %layers
      end     
  end

  layers=[1 2
      2 2
      3 2
      0 2
      0 2];
   for i=5:-1:1
      for j=4:-1:1
            layers(i,1)=4-j;
        for k=2:5
            for l=1:k
            if ((layers(l,1)>layers(k,1) || layers(l,1)==0) && (layers(k,1)~=0))                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end    
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end
        %layers
      end     
  end

  for pp=1:3
    layers=pp*ones(5,2);
      for i=5:-1:1
      for j=4:-1:1
            layers(i,1)=4-j;
        for k=2:5
            for l=1:k
            if ((layers(l,1)>layers(k,1) || layers(l,1)==0) && (layers(k,1)~=0))                
                layers(l,1)=layers(k,1);
                if(layers(1,1)==0)
                    layers(1,1)=1;
                end
            end
            end
        end      
        if(layers(5,1)==0)
            layers(:,2)=2;
            layers(4,1)=0;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            else
                layers(:,2)=2;
            end
        else
            layers(:,2)=3;
            if(layers(3,1)==0)
                layers(:,2)=1;
                layers(2,1)=0;
            end
        end    
        flag=1;
        for(tt=1:size(config,3))
            if(layers==config(:,:,tt))
                flag=0;
            end
        end
        if(flag==1)
                config(:,:,tt+1)=layers;
                counter=counter+1;                
        end
        %layers
      end     
  end

  end
  
 config
save('config.mat','config');
