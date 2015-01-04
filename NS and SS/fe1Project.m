%Compute the estimated quantities necessary for MVO (returns, covariances,
%etc.). Then store them for use in optimization function.
err = fe1ProjectEstimates('fe1project/stockPriceData/stockPrice30m.csv','fe1project/stockPriceData/tsx6030m.csv');
if err~= 0
    error('Unexpected error in fe1ProjectEstimates. Pls investigate!');
end

%Use the computed estimates to run MVO and get set of portfolios for
%Efficient Frontier. Plot efficient frontiers.
err = fe1ProjectOptimization();
if err~= 0
    error('Unexpected error in fe1ProjectOptimization. Pls investigate!');
end

%Test the MVO portfolios on out of sample data going in the future. Plot
%results.
err = fe1ProjectBackTest();
if err~= 0
    error('Unexpected error in fe1ProjectBackTest. Pls investigate!');
end