* Factor Analysis;
ods graphics on;
ODS PDF FILE='SAS_Output_Factor_Analysis.pdf'; 
options ls=80 ps=50 nodate pageno=1;
*;
Title 'Group A - Factor Analysis';

* Read in the full dataset;
proc import datafile="C:\Users\psvenson\Downloads\kicked-in-data.csv" out=Cars dbms=csv replace;
	delimiter=",";
	getnames=no;
run;

* Create new dataset with variable to be inlcuded in analysis;
Data Cars;
	Set Cars (Keep = VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32 VAR33);
	Label VAR1 = 'VAR1 - RefID'
          VAR2 = 'VAR2 - IsBadBuy'
		  VAR3 = 'VAR3 - PurchDate'
		  VAR4 = 'VAR4 - Auction'
          VAR5 = 'VAR5 - VehYear'
		  VAR6 = 'VAR6 - VehicleAge'
		  VAR7 = 'VAR7 - Make'
          VAR8 = 'VAR8 - Model'
		  VAR9 = 'VAR9 - Trim'
		  VAR10 = 'VAR10 - SubModel'
          VAR11 = 'VAR11 - Color'
		  VAR12 = 'VAR12 - Transmission'
		  VAR13 = 'VAR13 - WheelTypeID'
          VAR14 = 'VAR14 - WheelType'
		  VAR15 = 'VAR15 - VehOdo'
		  VAR16 = 'VAR16 - Nationality'
          VAR17 = 'VAR17 - Size'
		  VAR18 = 'VAR18 - TopThreeAmericanName'
		  VAR19 = 'VAR19 - MMRAcquisitionAuctionAveragePrice'
          VAR20 = 'VAR20 - MMRAcquisitionAuctionCleanPrice'
		  VAR21 = 'VAR21 - MMRAcquisitionRetailAveragePrice'
		  VAR22 = 'VAR22 - MMRAcquisitonRetailCleanPrice'
          VAR23 = 'VAR23 - MMRCurrentAuctionAveragePrice'
		  VAR24 = 'VAR24 - MMRCurrentAuctionCleanPrice'
		  VAR25 = 'VAR25 - MMRCurrentRetailAveragePrice'
          VAR26 = 'VAR26 - MMRCurrentRetailCleanPrice'
		  VAR27 = 'VAR27 - PRIMEUNIT'
          VAR28 = 'VAR28 - AUCGUART'
		  VAR29 = 'VAR29 - BYRNO'
		  VAR30 = 'VAR30 - VNZIP'
          VAR31 = 'VAR31 - VNST'
		  VAR32 = 'VAR32 - VehBCost'
		  VAR33 = 'VAR33 - IsOnlineSale'
          VAR34 = 'VAR34 - WarrantyCost';
run;

*Print the dataset;
*Proc Print Data = Cars;
*run;

*Principal Components Analysis - All Variables;
*RESULTS: Scree plot and variance explained plot tells us there should be 4 factors;
Proc Princomp Data = Cars Plots = ALL;
    Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32 VAR33;
run;

************ All Variables - Method=Principal Rotation: None ****************;

*First Exploratory Factor Analysis Rotate=NONE All Variables;
*RESULTS: VAR33 has the smallest MSA, remove for next Proc Factor;
Proc Factor Data = Cars Method=Principal Rotate=None NFactors=4 Simple MSA Plots = Scree MINEIGEN=0 Reorder;
    Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32 VAR33;
run;

*Second Exploratory Factor Analysis Rotate=NONE All Variables;
*RESULTS: MSA for all variables is above the 0.5 threshold, keep this subset of variables and try VARIMAX;
Proc Factor Data = Cars Method=Principal Rotate=None NFactors=4 Simple MSA Plots = Scree MINEIGEN=0 Reorder;
    Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32;
run;

************ Subset of Variables - Method=Principal Rotation: Varimax ****************;

*Rotated Exploratory Factor Analysis On Subset Rotate=Varimax All Variables;
*RESULTS: Factor loadings superior to non-rotational factor analysis, mainly because this fixes dual loadings present;
Proc Factor Data = Cars Method=Principal Rotate=Varimax NFactors=4 Print Score Simple MSA Plots = Scree MINEIGEN=0 Reorder;
    Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32;
run;

*Use previous procedure and print out stats to FactOut;
Proc Factor Data = Cars Outstat=FactOut Method=Principal Rotate=Varimax NFactors=4 Print Score Simple MSA Plots = ALL MINEIGEN=0 Reorder;
	Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32;
run;

*Create scores;
Proc Score Data = Cars Score=FactOut Out=FScore;
      Var VAR5 VAR6 VAR12 VAR14 VAR15 VAR19 VAR20 VAR21 VAR22 VAR23 VAR24 VAR25 VAR26 VAR32;
run;
*Proc Print Data = FactOut;
*run;
*Proc Print Data = FScore;
*run;

************  Compute Factor and Summated Correlations ****************; 

*Create four summated scales for the four factors;
Data FScore; 
	Set FScore;
    Label SumScale1 = 'SumScale1 - Acquisition Prices/Costs';
	Label SumScale2 = 'SumScale2 - Vehicle Age'; 
	Label SumScale3 = 'SumScale3 - Mileage'; 
	Label SumScale4 = 'SumScale4 - Transmission'; 
	SumScale1 = (VAR19 + VAR20 + VAR21 + VAR22 + VAR23 + VAR24 + VAR25 + VAR26 + VAR32)/10;
	SumScale2 = (VAR5 + VAR14 - VAR6)/3;
	SumScale3 = VAR15;
	SumScale4 = VAR12;
run;
Proc Print Data = FScore;run;
Proc Means Data = FScore;
   Var Factor1 Factor2 Factor3 Factor4 SumScale1 SumScale2 SumScale3 SumScale4;
run;

*Compute summated correlations;
Proc Corr Data = FScore;
   Var Factor1 Factor2 Factor3 Factor4 SumScale1 SumScale2 SumScale3 SumScale4;
run;

ODS PDF CLOSE;
