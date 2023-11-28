%Figure 4
%by Robert Alexander Fofrich Navarro
%
%Conducts stranded asset sensitivity analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except ii; close all

FUEL = 1;
CombineFuelTypeResults = 1;
PowerPlantFuel = ["Coal", "Gas", "Oil"];
saveyear = 0;%saves decommission year; anyother number loads decommission year
saveresults = 0;
randomsave = 0;%set to 1 to save MC randomization; zero value  loads MC randomization - section 11 only

years = 2021:2060;
StartYear = 1900;
EndYear = 2020;
Year = StartYear:EndYear;
CarbonTaxYear = 2020:2100;%sets the year for which the carbon tax is at its maximum

%Power plant ranges
LifeTimeRange = 20:5:60; 
CapacityFactorRange = .25:.05:.75;
AnnualHours = 8760;
DiscountRate = .03;%set to 3 and 7 percent

%coal assumptions
mean_coalCF = .85; %Capacity factor; 
mean_coalLife = 40; %Power plant life;

%plus/minus age
Age_span = 20;% Power plant age range

%plus/minus CF
CF_span = .25;% Power plant capacity factor range

%vary profits and costs....
%plot profits(y-axis) and costs(x-axis), stranded
%assets(z-axis)
load('../Data/Results/Coal_Plants');
load('../Data/Results/Coal_Plants_strings');
load('../Data/Results/CoalCostbyCountry')
load('../Data/WholeSaleCostofElectricityCoal');
CarbonTax19 = xlsread('../Data/CarbonTax1_9.xlsx');
CarbonTax26 = xlsread('../Data/CarbonTax2_6.xlsx');
load '../Data/Results/CoalColors'
load('../Data/Results/DecommissionYearCoal')
load('../Data/Results/OM_Costs_Coal.mat');

matrixsize = 61;

if randomsave == 1
    MC_values_1 = randi(matrixsize,10000,1);
    MC_values_2 = randi(matrixsize,10000,1);
    MC_values_3 = randi(matrixsize,10000,1);
    save("../Data/Results/MC_values.mat","MC_values_1","MC_values_2","MC_values_3")
elseif randomsave == 0 
    load("../Data/Results/MC_values.mat");
end
   


FuelCosts = F_Costs;
LifeLeft = mean_coalLife - Plants(:,2);

Plants(Plants==0)=nan;

sensitivity_range_fuel_costs = min(F_Costs(:)):(max(F_Costs(:))-min(F_Costs(:)))/(matrixsize-1):max(F_Costs(:));
sensitivity_range_capital_costs = min(Plants(:,6)):(max(Plants(:,6))-min(Plants(:,6)))/(matrixsize-1):max(Plants(:,6));
sensitivity_range_CT = 0:(1000-0)/(matrixsize-1):1000;%$dollars
sensitivity_range_WS = 0:(400-0)/(matrixsize-1):400;%min to max with 100 steps $dollars/kwh
CF_range = .4:(.9-.4)/(matrixsize-1):.9;

PowerPlantRevenue = zeros(length(Plants),length(sensitivity_range_WS));
PowerPlantCosts = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs));
PowerPlantCosts_CT = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs),length(sensitivity_range_CT));

Plants(isnan(Plants))=0;


for generator = 1:length(Plants)
    for sensitivity_range = 1:matrixsize
        PowerPlantRevenue(generator,sensitivity_range) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*sensitivity_range_WS(sensitivity_range));
    end
end

TotalPowerSectorRevenue = squeeze(nansum(PowerPlantRevenue,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
            PowerPlantCosts(generator,fuel_costs,capital_range) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7)))...%costs
            + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
       end
   end
end

TotalPowerSectorCosts = squeeze(nansum(PowerPlantCosts,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
           for CT = 1:matrixsize
                PowerPlantCosts_CT(generator,fuel_costs,capital_range,CT) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7))+Plants(generator,11)*(sensitivity_range_CT(CT)))...%costs
                + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
           end
       end
   end
end


TotalPowerSectorCosts_CT = squeeze(nansum(PowerPlantCosts_CT,1));
PowerSectorStrandedAssets = zeros(matrixsize,matrixsize,matrixsize,matrixsize);%wholesale price of electricity, fuel costs, capital costs, carbon tax



for WS = 1:matrixsize
    for fuel_costs = 1:matrixsize
        for capital = 1:matrixsize
            for CT = 1:matrixsize
                PowerSectorStrandedAssets(WS,fuel_costs,capital,CT) = TotalPowerSectorRevenue(WS) - ...
                    (TotalPowerSectorCosts(fuel_costs,capital) - TotalPowerSectorCosts_CT(fuel_costs,capital,CT))./(1 + DiscountRate).^1;
            end
        end
    end
end

StrandedAssets = zeros(matrixsize,matrixsize);%profits and costs

StrandedAssets(:,1) = PowerSectorStrandedAssets(:,1);

for i = 1:matrixsize
    for MC = 1:MC_values_1
        StrandedAssets(:,i) = (StrandedAssets(:,i) + PowerSectorStrandedAssets(:,MC_values_1(MC),MC_values_2(MC),MC_values_3(MC)))/2;%takes the mean of a monte carlo
    end
end

[CarbonTax,WholeSale] = meshgrid(sensitivity_range_CT,sensitivity_range_WS);
vals = squeeze(nanmean(nanmean(PowerSectorStrandedAssets,3),2))/1e12;%converts to trillions of dollars

contourrange = round(0:1:nanmax(vals(:)));

figure()
[WS,CT] = contourf(WholeSale,CarbonTax,vals,contourrange);
text_handle = clabel(WS,CT); 
xlabel('Wholesale Price');
ylabel('Carbon Tax');


load('../Data/Results/Gas_Plants');
load('../Data/Results/Gas_Plants_strings');
load('../Data/Results/GasCostbyCountry')
load('../Data/Results/WholeSaleCostofElectricityGas');
CarbonTax19 = xlsread('../Data/CarbonTax1_9.xlsx');
CarbonTax26 = xlsread('../Data/CarbonTax2_6.xlsx');
load '../Data/Results/GasColors'
load('../Data/Results/DecommissionYearGas')
load('../Data/Results/OM_Costs_Gas.mat');

matrixsize = 31;

if randomsave == 1
    MC_values_1 = randi(matrixsize,10000,1);
    MC_values_2 = randi(matrixsize,10000,1);
    MC_values_3 = randi(matrixsize,10000,1);
    save("../Data/Results/MC_values_Gas.mat","MC_values_1","MC_values_2","MC_values_3")
elseif randomsave == 0 
    load("../Data/Results/MC_values_Gas.mat");
end
   


FuelCosts = F_Costs;
LifeLeft = mean_coalLife - Plants(:,2);

Plants(Plants==0)=nan;

sensitivity_range_fuel_costs = min(F_Costs(:)):(max(F_Costs(:))-min(F_Costs(:)))/(matrixsize-1):max(F_Costs(:));
sensitivity_range_capital_costs = min(Plants(:,6)):(max(Plants(:,6))-min(Plants(:,6)))/(matrixsize-1):max(Plants(:,6));
sensitivity_range_CT = 0:(1000-0)/(matrixsize-1):1000;%$dollars
sensitivity_range_WS = 0:(400-0)/(matrixsize-1):400;%min to max with 100 steps $dollars/kwh
CF_range = .4:(.9-.4)/(matrixsize-1):.9;

PowerPlantRevenue = zeros(length(Plants),length(sensitivity_range_WS));
PowerPlantCosts = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs));
PowerPlantCosts_CT = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs),length(sensitivity_range_CT));

Plants(isnan(Plants))=0;


for generator = 1:length(Plants)
    for sensitivity_range = 1:matrixsize
        PowerPlantRevenue(generator,sensitivity_range) = (Plants(generator,1).*mean_GasCF.*AnnualHours.*sensitivity_range_WS(sensitivity_range));
    end
end

TotalPowerSectorRevenue = squeeze(nansum(PowerPlantRevenue,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
            PowerPlantCosts(generator,fuel_costs,capital_range) = (Plants(generator,1).*mean_GasCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7)))...%costs
            + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
       end
   end
end

TotalPowerSectorCosts = squeeze(nansum(PowerPlantCosts,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
           for CT = 1:matrixsize
                PowerPlantCosts_CT(generator,fuel_costs,capital_range,CT) = (Plants(generator,1).*mean_GasCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7))+Plants(generator,11)*(sensitivity_range_CT(CT)))...%costs
                + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
           end
       end
   end
end


TotalPowerSectorCosts_CT = squeeze(nansum(PowerPlantCosts_CT,1));
PowerSectorStrandedAssets = zeros(matrixsize,matrixsize,matrixsize,matrixsize);%wholesale price of electricity, fuel costs, capital costs, carbon tax



for WS = 1:matrixsize
    for fuel_costs = 1:matrixsize
        for capital = 1:matrixsize
            for CT = 1:matrixsize
                PowerSectorStrandedAssets(WS,fuel_costs,capital,CT) = TotalPowerSectorRevenue(WS) - ...
                    (TotalPowerSectorCosts(fuel_costs,capital) - TotalPowerSectorCosts_CT(fuel_costs,capital,CT))./(1 + DiscountRate).^1;
            end
        end
    end
end

StrandedAssets = zeros(matrixsize,matrixsize);%profits and costs

StrandedAssets(:,1) = PowerSectorStrandedAssets(:,1);

for i = 1:matrixsize
    for MC = 1:MC_values_1
        StrandedAssets(:,i) = (StrandedAssets(:,i) + PowerSectorStrandedAssets(:,MC_values_1(MC),MC_values_2(MC),MC_values_3(MC)))/2;%takes the mean of a monte carlo
    end
end

[CarbonTax,WholeSale] = meshgrid(sensitivity_range_CT,sensitivity_range_WS);
vals = squeeze(nanmean(nanmean(PowerSectorStrandedAssets,3),2))/1e12;%converts to trillions of dollars

contourrange = 0:.5:nanmax(vals(:));

figure()
[WS,CT] = contourf(WholeSale,CarbonTax,vals,contourrange);
text_handle = clabel(WS,CT); 
xlabel('Wholesale Price');
ylabel('Carbon Tax');


load('../Data/Results/Oil_Plants');
load('../Data/Results/Oil_Plants_strings');
load('../Data/Results/OilCostbyCountry')
load('../Data/Results/WholeSaleCostofElectricityOil');
CarbonTax19 = xlsread('../Data/CarbonTax1_9.xlsx');
CarbonTax26 = xlsread('../Data/CarbonTax2_6.xlsx');
load '../Data/Results/OilColors'
load('../Data/Results/DecommissionYearOil')
load('../Data/Results/OM_Costs_Oil.mat');

matrixsize = 31;

if randomsave == 1
    MC_values_1 = randi(matrixsize,10000,1);
    MC_values_2 = randi(matrixsize,10000,1);
    MC_values_3 = randi(matrixsize,10000,1);
    save("../Data/Results/MC_values_Oil.mat","MC_values_1","MC_values_2","MC_values_3")
elseif randomsave == 0 
    load("../Data/Results/MC_values_Oil.mat");
end
   

FuelCosts = F_Costs;
LifeLeft = mean_coalLife - Plants(:,2);

Plants(Plants==0)=nan;

sensitivity_range_fuel_costs = 20:(300-20)/(matrixsize-1):300;
sensitivity_range_capital_costs = min(Plants(:,6)):(max(Plants(:,6))-min(Plants(:,6)))/(matrixsize-1):max(Plants(:,6));
sensitivity_range_CT = 0:(1000-0)/(matrixsize-1):1000;%$dollars
sensitivity_range_WS = 0:(400-0)/(matrixsize-1):400;%min to max with 100 steps $dollars/kwh
CF_range = .4:(.9-.4)/(matrixsize-1):.9;

PowerPlantRevenue = zeros(length(Plants),length(sensitivity_range_WS));
PowerPlantCosts = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs));
PowerPlantCosts_CT = zeros(length(Plants),length(sensitivity_range_fuel_costs),length(sensitivity_range_capital_costs),length(sensitivity_range_CT));

Plants(isnan(Plants))=0;


for generator = 1:length(Plants)
    for sensitivity_range = 1:matrixsize
        PowerPlantRevenue(generator,sensitivity_range) = (Plants(generator,1).*mean_OilCF.*AnnualHours.*sensitivity_range_WS(sensitivity_range));
    end
end

TotalPowerSectorRevenue = squeeze(nansum(PowerPlantRevenue,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
            PowerPlantCosts(generator,fuel_costs,capital_range) = (Plants(generator,1).*mean_OilCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7)))...%costs
            + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
       end
   end
end

TotalPowerSectorCosts = squeeze(nansum(PowerPlantCosts,1));


for generator = 1:length(Plants)
   for fuel_costs = 1:matrixsize
       for capital_range = 1:matrixsize
           for CT = 1:matrixsize
                PowerPlantCosts_CT(generator,fuel_costs,capital_range,CT) = (Plants(generator,1).*mean_OilCF.*AnnualHours.*(sensitivity_range_fuel_costs(fuel_costs)./Plants(generator,7))+Plants(generator,11)*(sensitivity_range_CT(CT)))...%costs
                + Plants(generator,8)*Plants(generator,1) + sensitivity_range_capital_costs(capital_range)*Plants(generator,1).*DiscountRate;
           end
       end
   end
end


TotalPowerSectorCosts_CT = squeeze(nansum(PowerPlantCosts_CT,1));
PowerSectorStrandedAssets = zeros(matrixsize,matrixsize,matrixsize,matrixsize);%wholesale price of electricity, fuel costs, capital costs, carbon tax



for WS = 1:matrixsize
    for fuel_costs = 1:matrixsize
        for capital = 1:matrixsize
            for CT = 1:matrixsize
                PowerSectorStrandedAssets(WS,fuel_costs,capital,CT) = TotalPowerSectorRevenue(WS) - ...
                    (TotalPowerSectorCosts(fuel_costs,capital) - TotalPowerSectorCosts_CT(fuel_costs,capital,CT))./(1 + DiscountRate).^1;
            end
        end
    end
end

StrandedAssets = zeros(matrixsize,matrixsize);%profits and costs

StrandedAssets(:,1) = PowerSectorStrandedAssets(:,1);

MC_values_1 = MC_values_1(1:matrixsize,:);MC_values_2 = MC_values_2(1:matrixsize,:);MC_values_3 = MC_values_3(1:matrixsize,:);

for i = 1:matrixsize
    for MC = 1:MC_values_1
        StrandedAssets(:,i) = (StrandedAssets(:,i) + PowerSectorStrandedAssets(:,MC_values_1(MC),MC_values_2(MC),MC_values_3(MC)))/2;%takes the mean of a monte carlo
    end
end

[CarbonTax,WholeSale] = meshgrid(sensitivity_range_CT,sensitivity_range_WS);
vals = squeeze(nanmean(nanmean(PowerSectorStrandedAssets,3),2))/1e12;%converts to trillions of dollars
contourrange = 0:.1:nanmax(vals(:));

figure()
[WS,CT] = contourf(WholeSale,CarbonTax,vals,contourrange);
text_handle = clabel(WS,CT); 
xlabel('Wholesale Price');
ylabel('Carbon Tax');
