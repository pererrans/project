%testing file
dr = 0.08;
T = 3; 
inv_level = 11;
V = zeros(2,2,2,2,2,2,inv_level,T+1);
X = zeros(2,2,2,2,2,2,inv_level,T+1);
I = zeros(2,2,2,2,2,2,inv_level,T);
P = zeros(2,2,2,2,2,2,inv_level,T);

%demand
%TODO insert real demand figures
Demand = ones(1,T)*100;
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
                    
MinesOpened = [1 1 0 0 0 0];
[new_invs, prices, Arewards] = findPrice(T, MinesOpened, 0, 1, 0, 0, 0, D_prob, D_fluct, 1000, SupplyCurve(:,:,1), TotalIncentiveCurve);
