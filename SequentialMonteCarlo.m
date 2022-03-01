% Sequential Monte Carlo for two generators
% Landon J. Walker

% G1 = 80 MW L1 = 0.01 failure/day M1 = 8 days
% G2 = 50 MW L2 = 0.012 failure/day M2 6 days
% Ln = Lambdan , Mn = Mun

% Define Constants
% Lambdas
L1 = 0.01;
L2 = 0.012;

% Mus
M1 = 1/8; % 8 days
M2 = 1/6; % 6 days

% Create  arrays to store values during simulation

% n is how many simulations as many as you want, the higher the better
n = 10000000;
% time
t = zeros(n,1);
% state 1 and state 2 can be up or down
St1 = zeros(n,1);
St2 = zeros(n,1);
% zeros
z1 = zeros(n,1);
z2 = zeros(n,1);
% time zeros happened at
t1 = zeros(n,1);
t2 = zeros(n,1);

% Generate two random numbers 0 to 1 individually
% random numbers for each generator 0 to 1
z1(1) = rand();
z2(1) = rand();  
% Time to change for Time 0
T1 = -log(z1(1))/L1;
T2 = -log(z2(1))/L2;

% store our initial T1 and T2 before FOR Loop
t1(1) = T1;
t2(1) = T2;

% change1 counts how many times we jump from 1U 2D to  
change1 = 0;
change2 = 0;


% Count how many downstates. Starts at 0 since we start in 1UP 2UP
Tdownstate = 0;

% Creat the states for the generators. 1 = UP , 0 = DOWN
St1(1) = 1;
St2(1) = 1;

% COMMENT THIS MUCH BETTER
%FOR LOOP
for i=2:n
%IF
% When T1<T2 new Random number for 1 and keep 2's random number
    if T1<T2
         t(i) = t(i-1)+T1;
         T2 = T2-T1;
         z1(i) = rand();
         if St1(i-1)==0 && St2(i-1)==0
             Tdownstate = Tdownstate+T1;
         end
         if St1(i-1) == 1
             % in down state
             St1(i) = 0;
             % reset clock for G1 into new value, and use M1 since it needs repaired 
             T1 = -log(z1(i))/M1;
         else
             % in up state
             St1(i) = 1;
             % reset clock for G1 into new value, and use L1 sine it is UP
             T1 = -log(z1(i))/L1;         
         end
         % states
         St2(i) = St2(i-1);
         % times
         t1(i) = T1;
         t2(i) = T2;
        % When T2<T1
     elseif T2<T1 
         t(i) = t(i-1)+T2;
         T1 = T1-T2;
         z2(i) = rand();
         % if we are in a down state IE 1D2D
         if St1(i-1)==0 && St2(i-1)==0
             Tdownstate = Tdownstate+T2;
         end
        % use == comparitor to see if state 2 is UP or DOWN
         if St2(i-1) == 1
             % goes to down state
             St2(i) = 0;
             % reset clock for G2 into  new value
             T2 = -log(z2(i))/M2;
         else
             St2(i) = 1;%Now goes to up state
             T2 = -log(z2(i))/L2;%reset clock for G1 into  new value
         end
        
       St1(i) = St1(i-1);
       t1(i) = T1;
       t2(i) = T2;
    end
%END OF IF
       
end
%END OF FOR LOOP

% tot is equal to number_of_runs just checking
tot = change1 + change2;

% Generate table for values from FOR loop
table = [t z1 z2 t1 t2 St1 St2]; 
% Count the down states
% 0 since we start in 1U2U
numberofdownstate=0;
for j=1:n
    % state 1 == state 2 checking for 1D2D
    if table(j,6)==0 && table(j,7)==0
        numberofdownstate = numberofdownstate+1;
    end
end

% Steady state probability to encounter overlapping failure states
P = Tdownstate/t(n);

% Frequency of encountering overlapping failures
F = numberofdownstate/t(n);

% MTTTF
Meantime = zeros(n,1);
k = 1;
l = 1;
temp1 = 1;

for k=1:n
  % finding time differnece in the down states  
  if table(k,6)==0 && table(k,7)==0  
  % temp1 = temp1+k;
  Meantime(l) = t(k)-t(temp1);
  temp1 = k;
  l = l+1;
  
  end
end

% find the total time of all the states
sum=0;
for m=1:l
    sum = sum + Meantime(m);
end
% divide total time by actual length of time
MTTF = sum/l;

% TYPE P for steady state probablity of the first 1D2D 
% Type F for frequency of overlapping failures
% Type MTTF for mean time to fail
disp(P)
disp(F)
disp(MTTF)