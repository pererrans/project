function [ new_invs, prices, Arewards ] = findPrice(T, MinesOpened, old_inv, t, a, b, c, D_prob, D_fluct, Demand_t, SupplyCurve_t, IncentiveCurve)
%find price in the market given the demand, supplycurve, states, actions
%return a vector of inventories and prices and reward for A that correspond to the
%three demand scenarios

%inventory levels bin width
inv_bin=100;
inv_zero = 5;

%start creating the relevant updated supply curve
newSupply = [SupplyCurve_t; zeros(6,3)];
l = length(SupplyCurve_t);

%stitch together old supply and already opened mines
for m=1:length(MinesOpened)
    if(MinesOpened(m)==1)
        newSupply(l+m,:) = IncentiveCurve(m,1:3);
    end
end

%add the mines opened this period, keep track of capex
newOpenings = [(a==1),(a==2),(b==1),(b==2),(c==1),(c==2)];
capex = 0;
for m=1:length(newOpenings)
    if(MinesOpened(m)==1)
        newSupply(l+m,:) = IncentiveCurve(m, 1:3);
        capex = capex + IncentiveCurve(m, 4);
    end
end

%figure out the supply given the expected demand
newSupply=sortrows(newSupply,3);    %sort supply by price
newSupply = [newSupply cumsum(newSupply(:,2))]; %add a column for cumulative supply
prices=zeros(1,3);
new_invs=zeros(1,3);
index = zeros(1,3);
Demand = [Demand_t*(1-D_fluct), Demand_t, Demand_t*(1+D_fluct)] - (old_inv-inv_zero)*inv_bin;
excess_old_inv = max(-Demand,0);
Demand = max(Demand,0);
operatingSupply=0;

for i=1:length(newSupply)
    if(index(1)==0 && newSupply(i,4)>=Demand(1))
        index(1)=i;
        prices(1)=newSupply(i,3);
    end
    if(index(2)==0 && newSupply(i,4)>=Demand(2))
        prices(2)=newSupply(i,3);
        index(2)=i;
        %firms make operating decision based on expected demand, not fluctuation
        operatingSupply = newSupply(i,4);
    end
    if(newSupply(i,4)>=Demand(3))
        prices(3)=newSupply(i,3);
        index(3)=i;
        break;
    end
end
new_invs = ones(1,3)*operatingSupply - Demand;    
new_invs = new_invs + excess_old_inv;
%change inventory to categorical variable. inv_zero represents inv 0 to 99, etc. 
new_invs = max(min(round(new_invs./inv_bin)+inv_zero,10),0);

%calculate the reward this period
Arewards=zeros(1,3);
for i=1:index(3)    %go only until the marginal supplier for the high demand case
    if(newSupply(i,1)==1)   %if mine belongs to A
        if(i<=index(1))
            Arewards = Arewards + (prices - newSupply(i,3)).*newSupply(i,2);
        elseif(i<=index(2))
            Arewards = Arewards + [0, (prices(2:3) - newSupply(i,3)).*newSupply(i,2)];
        else
            Arewards = Arewards + [0, 0, (prices(3) - newSupply(i,3)).*newSupply(i,2)];
        end
    end
end

%substract capex
Arewards = Arewards-capex;

end

