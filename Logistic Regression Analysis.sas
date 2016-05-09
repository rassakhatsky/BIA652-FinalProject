* Logistic Regression Analysis;
ods graphics on;

options ls=80 ps=50 nodate pageno=1;
*;
Title 'Group A - Logistic Regression Analysis';

* 60% of data;
proc import datafile="C:\training.csv" out=Cars dbms=csv replace;
	delimiter=",";
	getnames=no;
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

data Cars;
set Cars;
if var32<var34 then
	crap=1;
else
	crap=0;
run;

* 40% of final data;
proc import datafile="C:\training_test.csv" out=Cars_test dbms=csv replace;
	delimiter=",";
	getnames=no;
run;

data Cars_test;
set Cars;
if var32<var34 then
	crap=1;
else
	crap=0;
run;

* EVENT=’category’ | keyword
*        specifies the event category for the binary response model.
*;
* SELECTION = option specifies the method used to select the explanatory variables in the model. 
*             STEPWISE requests stepwise selection;
*;
* SLENTRY = option specifies the significance level for entry into the model
* SLSTAY = option specifies the significance level for staying in the model
*;
* DETAILS option produces detailed printout at each step of the model-building process
*;
* LACKFIT requests Hosmer and Lemeshow goodness-of-fit test
*;
* RSQUARE displays generalized R^2
*;
* CTABLE option requests the printing of a classification table for the final model produced by the procedure.
*;
* PPROB = option specifies possibly multiple cutpoints used to classify observations for the CTABLE option.
*         The values must be between 0 and 1. If the PPROB= option is not specified, the
*         default is to print the classification for a range of probabilities from the smallest estimated
*         probability (rounded below to the nearest .02) to the highest estimated probability (rounded above
*         to the nearest .02) with 0.02 increments. Note that the PPROB= option has no effect unless the
*         CTABLE option is also specified.
*;
*;

*Don't use VAR4, VAR5, VAR10, VAR 29, VAR30, VAR31 because they work almost as an id;
Proc Logistic Data = Cars;
		CLASS VAR31 	(PARAM=EFFECT) VAR16 	(PARAM=EFFECT) VAR17 	(PARAM=EFFECT) 
				VAR18 	(PARAM=EFFECT) VAR27 	(PARAM=EFFECT) VAR28 	(PARAM=EFFECT) 
				VAR7 	(PARAM=EFFECT) VAR8 	(PARAM=EFFECT) VAR9 	(PARAM=EFFECT) 
				VAR10 	(PARAM=EFFECT) VAR11 	(PARAM=EFFECT) VAR12 	(PARAM=EFFECT) 
				VAR13 	(PARAM=EFFECT) VAR14 	(PARAM=EFFECT) VAR4 	(PARAM=EFFECT);
	*Model VAR2(event='0') =  VAR5  VAR6  VAR7  VAR15	VAR19  VAR20  VAR21  VAR22
							VAR23  VAR24  VAR25  VAR26 VAR32  VAR33  VAR34
						/ Selection=Stepwise SLEntry=0.05 SLStay=0.05 Details 
							LackFit RSquare CTable PProb =(0 to 1 by .10);
				Model VAR2(event='0') =  VAR3  VAR6  VAR7  
							 VAR9   VAR11  VAR12  VAR13  VAR14  VAR15
							 VAR16  VAR17  VAR18  VAR19  VAR20  VAR21  VAR22
							 VAR23  VAR24  VAR25  VAR26  VAR27  VAR28	VAR32
							 VAR33  VAR34 crap
						/ Selection=Stepwise SLEntry=0.05 SLStay=0.05 Details 
							LackFit RSquare CTable  PProb =(0 to 1 by .10); *CTable;
run;

*;
* Final Resultant Model and Output Model
VAR6 VAR27 VAR15 VAR31
VAR5 VAR20	VAR22 VAR23	VAR25	VAR33	VAR34
*;
Proc Logistic Data = Cars OutModel=CarsModel;
	CLASS VAR27 	(PARAM=EFFECT)
		  VAR17 	(PARAM=EFFECT)	VAR9 	(PARAM=EFFECT);
	Model VAR2(event='0') = VAR6 VAR27 VAR15 var7 VAR32 VAR17 VAR3 VAR24 VAR26 VAR9
						/ Selection=Stepwise SLEntry=0.1 SLStay=0.1 Details
							LackFit RSquare CTable PProb =(0.40 to 0.60 by .01);
run;

Proc Logistic InModel=CarsModel;
	Score Data = Cars (Keep = VAR2 VAR6 VAR27 VAR15 VAR32 VAR17 VAR3 VAR24 VAR26 VAR9) Out = CarsModelScore_orig;
run;

Proc Logistic InModel=CarsModel;
	Score Data = Cars_test (Keep = VAR2 VAR6 VAR27 VAR15 VAR32 VAR17 VAR3 VAR24 VAR26 VAR9) Out = CarsModelScore;
run;


Proc Print Data = CarsModelScore;
Proc Freq Data = CarsModelScore;
	Table F_VAR2 * I_VAR2;
run;

Proc Freq Data = CarsModelScore_orig;
	Table F_VAR2 * I_VAR2;
run;
