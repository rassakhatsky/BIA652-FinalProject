* Multiple Regression Analysis;
ods graphics on;

options ls=80 ps=50 nodate pageno=1;
*;
Title 'Group A - Multiple Regression Analysis';

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
if var12 = 'AUTO' then
   var12_a = 1 ;
else 
	var12_m = 1;
if var12 = 'AUTO' then
	var12_m = 0;
else
	var12_a = 0;

if var28 = 'GREE' then
   var28_g  = 1;
else
	var28_g  = 0;
if var28 = 'GREE' then
   var28_n  = 0;
else
	var28_n  = 1;


if var27 = 'NO' then
   var27_n  = 1;
else
	var27_n  = 0;
if var27 = 'NO'  then
   var27_e  = 0;
else
   var27_e  = 1;

if var16 = 'AMERICAN' then
   var16_a  = 1;
else
	var16_a  = 0;
if var16 = 'TOP LINE ASIAN' then
   var16_t  = 1;
else
   	var16_t  = 0;
if var16 = 'OTHER ASIAN' then
   var16_o  = 1;
else
	var16_o  = 0;

if var32<var34 then
	crap=1;
else
	crap=0;
run;

Proc Corr Data = Cars;
    Var VAR2 VAR3  VAR5 VAR6 
		VAR13 VAR15 VAR19 VAR20 VAR21
		VAR22 VAR23 VAR24 VAR25 VAR26 
		VAR32 VAR33 VAR34
		var12_a	var12_m	var28_g	var28_n	var27_n var27_e	var16_a var16_t	var16_o
		crap;
run;

Proc Reg Data = Cars plots(unpack);
	Model VAR34 = VAR2 VAR3  VAR5 VAR6 
		VAR13 VAR15 VAR19 VAR20 VAR21
		VAR22 VAR23 VAR24 VAR25 VAR26 
		VAR32 VAR33 
		var12_a	var12_m
		var28_g	var28_n
		var27_n var27_e
		var16_a var16_t	var16_o
		crap
/ STB Influence P R VIF Tol selection=stepwise SLEntry = 0.05 SLStay=0.05;
	Plot NQQ.*R. NPP.*R. RESIDUAL.*PREDICTED.; * NQQ.*R and NPP.*R request specific separate Normal Quantile and Normal Probability Plots;
RUN;