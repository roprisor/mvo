Mean Variance Optimization project

Input:
- set of asset prices

Output:
- intermediary:
	various metrics necessary to generate an optimal portfolio stored in stockPriceData/Intermediate Data
	charts to show the efficient frontier for normal (no short-selling) and SS (with short-selling) optimal portfolios
	charts to show the results of back testing on out of sample data versus the benchmark
- final: a set of optimal portofolios and their metrics

Usage:
- run mvoProject.m
- update mvoProject.m to call mvoProjectEstimates w/ your price files in the same format as the originals
- removedStockIndices holds the indices of the assets you decided to remove from the optimization problem
