%T is the number of periods. dr is the discount rate
%Future points of modification
%%1. competitor response based on price
%%2. end of life V is not zero, but a value reflecting the decisions made?
%%3. incentive curve from non-big-three coming online according to
%%incentive price (instead of static supply curve)
%%4. starting year restriction for incentive supply

%initialize variables
dr = 0.08;
T = 3; 
inv_level = 11;
V = zeros(2,2,2,2,2,2,inv_level,T+1);
X = zeros(2,2,2,2,2,2,inv_level,T+1);
I = zeros(2,2,2,2,2,2,inv_level,T);
P = zeros(2,2,2,2,2,2,inv_level,T);

%demand
%TODO insert real demand figures
Demand = ones(1,T)*1000;
%fluctuation range and prob
D_fluct = 0.1;
D_prob = [0.1, 0.8, 0.1];

%supply
%%Supply curve - assume it doesn't change over time
%% structure is owner, quantity, price
SupplyCurve = zeros(44,3,T);
SupplyCurve(:,:,1) = [1	289	49
            1	12	65
            1	5	86
            2	74	39
            2	40	46
            2	42	47
            2	24	48
            2	25	49
            3	46	40
            3	2	40
            3	50	42
            3	9	43
            3	3	44
            3	102	46
            3	24	47
            3	5	54
            3	4	55
            3	2	66
            3	6	76
            3	21	76
            3	9	96
            4	0	5
            4	16	15
            4	9	25
            4	15	35
            4	49	45
            4	169	55
            4	209	65
            4	150	75
            4	95	85
            4	72	95
            4	70	105
            4	48	115
            4	15	125
            4	22	135
            4	27	145
            4	4	155
            4	4	165
            4	2	175
            4	1	185
            4	3	195
            4	3	205
            4	3	225
            4	2000	245];  %inflate highest price Q to never run out of supply
SupplyCurve(:,:,2) = SupplyCurve(:,:,1);
SupplyCurve(:,:,3) = SupplyCurve(:,:,1);

incentiveCurveA = [1	70	43	560
                    1	50	47	1025
                    1	50	49	1042];

incentiveCurveB = [2	50	52	963
                    2	110	57	2821
                    2	55	49	1075];

incentiveCurveC = [3	90	54	1670
                    3	45	54	544
                    3	45	67	1135];

TotalIncentiveCurve = [incentiveCurveA(1:2, :); 
                        incentiveCurveB(1:2, :);
                        incentiveCurveC(1:2, :)];


%competitor response
%in the future, revise to be based on price
b_prob = [0.8 0.1 0.1]; %unlikely to open
c_prob = [0.8 0.1 0.1]; %unlikely to open

%solve terminal period
V(:,:,:,:,:,:,:,T+1) = 0;
X(:,:,:,:,:,:,:,T+1) = 0;

for t=T:-1:1
    for A1=0:1
        for A2=0:1
            for B1=0:1
                for B2=0:1
                    for C1=0:1
                        for C2=0:1
                            for inv=0:inv_level-1
                                bestV=0;
                                x=0;
                                p=0;
                                i=0;
                                for a=0:2
                                    %skip this loop if a is not feasible
                                    %given the states
                                    if(a==1 && A1==1)
                                        break;
                                    elseif(a==2 && A2==1)
                                        break;
                                    end
                                    Exp_V = zeros(3,3);
                                    Exp_R = zeros(3,3);
                                    Exp_P = zeros(3,3);
                                    Exp_I = zeros(3,3);
                                    for b=0:2
                                        %skip this loop if a is not feasible
                                        %given the states
                                        if(b==1 && B1==1)
                                            break;
                                        elseif(b==2 && B2==1)
                                            break;
                                        end
                                        for c=0:2
                                            %check to see if action set is
                                            %feasible. if not, skip the loop
                                            if(c==1 && C1==1)
                                                break;
                                            elseif(c==2 && C2==1)
                                                break;
                                            end
                                            %modify the probability vector
                                            %of b and c based on the
                                            %existing states. Moving prob
                                            %mass to not opening
                                            b_prob_new = [b_prob(1)+b_prob(2)*(B1==1)+b_prob(3)*(B2==1), 
                                                            b_prob(2)*(B1==0), 
                                                            b_prob(3)*(B2==0)];
                                            c_prob_new = [c_prob(1)+c_prob(2)*(C1==1)+c_prob(3)*(C2==1), 
                                                            c_prob(2)*(C1==0), 
                                                            c_prob(3)*(C2==0)];            
                                            minesOpened = [A1, A2, B1, B2, C1, C2];
                                            %calculate expected new_inv and
                                            %market price and rewards for A
                                            [new_invs, prices, Arewards] = findPrice(T, minesOpened, inv, t, a, b, c, D_prob, D_fluct, Demand(t), SupplyCurve(:,:,t), TotalIncentiveCurve);
                                            %calculate expected reward and
                                            %prices
                                            Exp_R(b+1,c+1) = sum(Arewards.*D_prob);
                                            Exp_P(b+1,c+1) = sum(prices.*D_prob);
                                            Exp_I(b+1,c+1) = sum(new_invs.*D_prob);
                                            %calculate future expected V
                                            v = zeros(1,3);
                                            for d=1:length(D_prob)
                                                %state transition NOT CORRECT - TODO CODE -
                                                %because not dependent on
                                                %states
                                                v(d) = D_prob(d)*V((a==1)+1,(a==2)+1,(b==1)+1,(b==2)+1,(c==1)+1,(c==2)+1,new_invs(d),t+1);
                                            end
                                            Exp_V(b+1,c+1) = b_prob(b+1)*c_prob(c+1)*sum(v);
                                        end
                                    end
                                    %Calculate the total value for action a
                                    %and record the action and exp. price
                                    totalV = sum(sum(b_prob_new'*c_prob_new.*Exp_R + (1-dr).*Exp_V));
                                    if(totalV>bestV)
                                        bestV=totalV;
                                        x=a;
                                        p=sum(sum(Exp_P));
                                        i=round(sum(sum(Exp_I)));
                                    end
                                end
                                V(A1+1,A2+1,B1+1,B2+1,C1+1,C2+1,inv+1,t) = bestV;
                                X(A1+1,A2+1,B1+1,B2+1,C1+1,C2+1,inv+1,t) = x;
                                P(A1+1,A2+1,B1+1,B2+1,C1+1,C2+1,inv+1,t) = p;
                                I(A1+1,A2+1,B1+1,B2+1,C1+1,C2+1,inv+1,t) = i;
                                
                            end
                        end
                    end
                end
            end
        end
    end
end


