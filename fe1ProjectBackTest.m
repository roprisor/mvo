function [success] = fe1ProjectBackTest()

%Retrieve results obtained so far from files
X = importdata('fe1project/stockPriceData/Intermediate Data/optimalPortfolios30m.csv');
effR = importdata('fe1project/stockPriceData/Intermediate Data/targetReturns30m.csv');
stockPrice = importdata('fe1project/stockPriceData/stockPriceOutOfSample.csv');
indexPrice = importdata('fe1project/stockPriceData/tsx60OutOfSample.csv');
removedStocks = importdata('fe1project/stockPriceData/removedStocksIndices.csv');

%Rebuild estimates for approved stocks
sPrice = stockPrice.data;
iPrice = indexPrice.data;
numRemoved = size(removedStocks,1);
m = size(sPrice,1);
n = size(sPrice,2);
p = size(X,2);

R = zeros(n - numRemoved,1);
RP = zeros(p,2);

jIndex = 0;

for j=1:n
    %If stock is a keeper, populate the R estimates for it
    if (~(any(removedStocks == j)))
        jIndex = jIndex + 1;
        R(jIndex) = (sPrice(m,j)-sPrice(1,j))/sPrice(1,j);
    end
end

%Compute portfolio returns
iReturn = (iPrice(m)-iPrice(1))/iPrice(1); %Index return over out of sample time

%Without shortselling
for i=1:p %for each portfolio
    RP(i,1) = X(:,i)'*R;
    RP(i,2) = iReturn;
    effR(i) = (1+effR(i))^12 - 1;
end

figure('Name','Comparative portfolio returns - w/o short selling');
plot(effR,RP);
title('MVO vs Index comparison (yearly)');
xlabel('Target return');
ylabel('Achieved return');
legend('MVO', 'Index');

csvwrite('fe1project/stockPriceData/Intermediate Data/oosReturns.csv',R);
RP(:,2) = effR(:);
csvwrite('fe1project/stockPriceData/Intermediate Data/oosPortfolioReturns.csv',RP);

success = 0;

end