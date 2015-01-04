%Compute the estimated quantities necessary for MVO (returns, covariances,
%etc.). Then store them for use in optimization function.
err = mvoProjectEstimates('fe1project/stockPriceData/stockPrice30m.csv','fe1project/stockPriceData/tsx6030m.csv');
if err~= 0
    error('Unexpected error in mvoProjectEstimates. Pls investigate!');
end

%Use the computed estimates to run MVO and get set of portfolios for
%Efficient Frontier. Plot efficient frontiers.
err = mvoProjectOptimization();
if err~= 0
    error('Unexpected error in mvoProjectOptimization. Pls investigate!');
end

%Test the MVO portfolios on out of sample data going in the future. Plot
%results.
err = mvoProjectBackTest();
if err~= 0
    error('Unexpected error in mvoProjectBackTest. Pls investigate!');
end
