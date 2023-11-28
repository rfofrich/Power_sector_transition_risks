%Figure 2
%by Robert Alexander Fofrich Navarro
%
%Generates scatter plots
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

