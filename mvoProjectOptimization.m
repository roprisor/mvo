function [success] = mvoProjectOptimization()

%Retrieve results obtained so far from files
oldR = importdata('fe1project/stockPriceData/Intermediate Data/returns30m.csv');
oldSigma = importdata('fe1project/stockPriceData/Intermediate Data/sigma30m.csv');
oldMean = importdata('fe1project/stockPriceData/Intermediate Data/means30m.csv');
oldNiu = importdata('fe1project/stockPriceData/Intermediate Data/niuYearly30m.csv');
removedStocks = importdata('fe1project/stockPriceData/removedStocksIndices.csv');

%Rebuild estimates for approved stocks, list of stocks to be removed is
%read from removedStocksIndices.csv
numRemoved = size(removedStocks,1);
m = size(oldR,1);
n = size(oldR,2);

%Initialize new matrices to store "approved" stock data
R = zeros(m, n-numRemoved);
sigma = zeros(n-numRemoved, n-numRemoved);
mean = zeros(n-numRemoved, 1);
niu = zeros(n-numRemoved, 1);

%Iterate through estimates and only keep the values we want
iIndex = 0;

for i=1:n
    %If stock is a keeper, populate the new sigma estimates for it
    if (~(any(removedStocks == i)))
        iIndex = iIndex +1;
        jIndex = 0;
        for j=1:n
            if (~(any(removedStocks == j)))
                jIndex = jIndex + 1;
                sigma(iIndex,jIndex) = oldSigma(i,j);
            end
        end
    end
end

%Ensure covariance matrix is PD
sigma = nearestSPD(sigma);
[~,p] = chol(sigma);

if (p ~= 0)
    success = 1;
    error('Oops! Sigma is not PD, abort! :(\n');
end

%If sigma passed the PD test, continue
jIndex = 0;

for j=1:n
    %If stock is a keeper, populate the mean and R estimates for it
    if (~(any(removedStocks == j)))
        jIndex = jIndex +1;
        mean(jIndex) = oldMean(j);
        niu(jIndex) = oldNiu(j);
        for i=1:m
            R(i,jIndex) = oldR(i,j);
        end
    end
end

%Set up helper variables and constraints
iterations = floor((max(niu)+abs(min(niu)))/0.01);
effR = zeros(iterations,1);
effSigma = zeros(iterations,1);
n = n - numRemoved;
X = zeros(n,iterations);
Aeq = ones(2,n);
Aeq(1,:) = niu;
options = optimset('Algorithm','active-set');

%Compute efficient frontier - no short selling
for i=1:iterations
    effR(i) = ceil(min(niu)) + i*0.01;
    [X(:,i),effSigma(i)] = quadprog(2*sigma,[],[eye(n); -1*eye(n)],[0.1*ones(n,1); -0.005*ones(n,1)],Aeq,[effR(i); 1],zeros(n,1),[],[],options);
end

figure('Name','Frontier w/o short selling');
plot(effSigma,effR);
title('Efficient Frontier w/o Shorts');
xlabel('Sigma');
ylabel('Return (yearly)');

%Export optimal portfolios for easy reading
csvwrite('fe1project/stockPriceData/Intermediate Data/optimalPortfolios30m.csv',X);
csvwrite('fe1project/stockPriceData/Intermediate Data/targetReturns30m.csv',effR);

%Create extended arrays for short selling
iterations = floor((2*max(niu)+abs(min(niu)))/0.01);
effRSS = zeros(iterations,1);
effSigmaSS = zeros(iterations,1);
XSS = zeros(n,iterations);

%Compute efficient frontier - with short selling
for i=1:iterations
    effRSS(i) = ceil(min(niu)) + i*0.01;
    [XSS(:,i),effSigmaSS(i)] = quadprog(2*sigma,[],[eye(n);-1*eye(n)],[ones(n,1);-1*ones(n,1)],Aeq,[effRSS(i); 1],[],[],[],options);
    if (abs(min(XSS(:,i))) <= 0.001)
        %error('Insignificant asset in at least one portfolio');
    end
end

figure('Name','Frontier w short selling');
plot(effSigmaSS, effRSS);
title('Efficient Frontier w Shorts');
xlabel('Sigma');
ylabel('Return (yearly)');

%Export optimal portfolios for easy reading
csvwrite('fe1project/stockPriceData/Intermediate Data/optimalPortfolios30mSS.csv',XSS);
csvwrite('fe1project/stockPriceData/Intermediate Data/targetReturns30mSS.csv',effRSS);

success = 0;

end
