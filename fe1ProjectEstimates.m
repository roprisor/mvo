function [success] = fe1ProjectEstimates(sPriceFile, iPriceFile)

%Retrieve data
stockPrices = importdata(sPriceFile);
indexPrices = importdata(iPriceFile);

%Extract data from information retrieved (combine both stock and index prices)
m = size(stockPrices.data,1);
n = size(stockPrices.data,2);

sPrice = zeros(m,n+1);
sPrice = stockPrices.data;
for i=1:m
    sPrice(i,n+1) = indexPrices.data(i,1);
end

%Re-adjust size for return array
m = m-1;
n = n+1;

%Computer simple returns, last column is for index entry
R = zeros(m, n);
for i=1:m
    for j=1:n
        R(i,j) = (sPrice(i+1,j)-sPrice(i,j))/sPrice(i,j);
    end
end

%Clean data
for i=1:m
    for j=1:n
        if R(i,j) == NaN
            R(i,j) = 0;
        end
    end
end

%Calculate niu and mean returns for each month
niu = ones(n,1);
mean = zeros(n,1);

for i=1:m
    for j=1:n
        mean(j) = mean(j) + R(i,j);
        niu(j) = niu(j) * (1+R(i,j));
    end
end

%Get time weighted returns and means of returns over 30 month period
for j=1:n
    mean(j) = mean(j)/m;
    niu(j) = power(niu(j),1/m) - 1;
end

%Get standard deviations of returns & correlations
sigma = cov(R);

RHO = corrcoef(R);
corrToIndex = RHO(:,n);

%Get stdev from covariance matrix
var = zeros(n,1);
for i=1:n
    var(i) = sqrt(sigma(i,i));
end

%Output results so far to files for easy reading/processing for report
csvwrite('fe1project/stockPriceData/Intermediate Data/returns30m.csv',R);
csvwrite('fe1project/stockPriceData/Intermediate Data/sigma30m.csv',sigma);
csvwrite('fe1project/stockPriceData/Intermediate Data/corr30m.csv',RHO);
csvwrite('fe1project/stockPriceData/Intermediate Data/means30m.csv',mean);
csvwrite('fe1project/stockPriceData/Intermediate Data/niu30m.csv',niu);
csvwrite('fe1project/stockPriceData/Intermediate Data/corrToIndex.csv',corrToIndex);

success = 0;

end