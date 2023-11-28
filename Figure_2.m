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


load '../Data/Results/PowerPlantFinances_byCompany_Coal'
load '../Data/Results/PowerPlantFinances_byCountry_Coal'
load '../Data/Results/CoalAnnualEmissions.mat'
load ../Data/Results/CoalCompanyCapacity.mat
load ../Data/Results/CoalRevenue.mat
load '../Data/Results/colorschemecategoryCoal2'

RegionList = {'USA','Latin America','China','Europe',...
    'Middle East and Africa','Asia','Former Soviet','Australia, Canada, New Zealand','India'};

RGB_colors = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0; 0 0 0; 0 0.4470 0.7410; 0.8500 0.3250 0.0980];
Coal_company_country_strings = strings(length(CoalAnnualEmissions_Company),1);
Company_RGB_colors = zeros(length(CoalAnnualEmissions_Company),3);

for i = 1:length(CoalAnnualEmissions_Company)
    for j = 1:length(RegionList)
        if colorschemecategory(i) == j
            Coal_company_country_strings(i) = RegionList(j);
            Company_RGB_colors(i,:) = RGB_colors(j,:);
        end
    end
end



ProfitsByCompany_CarbonTax = squeeze(PowerPlantFinances_byCompany(:,1,2));%company,year,variable
StrandedAssetsbyCompany = squeeze(PowerPlantFinances_byCompany(:,1,5));
EmissionsbyCompany = squeeze(CoalAnnualEmissions_Company(:,1));
AnnualCapacityByCompany = squeeze(AnnualCapacityByCompany(:,1));
NumberofPlantsperCompanyperYear = squeeze(NumberofPlantsperCompanyperYear(:,1));
Lifeleft = mean_coalLife - PowerPlantLife_byCompany(:,1);

AnnualEmissionsByCompany_Coal_strings(EmissionsbyCompany==0)=[];
CommittedEmissions(EmissionsbyCompany==0)=[];
StrandedAssetsbyCompany(EmissionsbyCompany == 0)=[];
ProfitsByCompany_CarbonTax(EmissionsbyCompany ==0)=[];
RevenuebyCompany(EmissionsbyCompany == 0)= [];
colorschemecategory(EmissionsbyCompany==0)=[];
AnnualCapacityByCompany(EmissionsbyCompany==0)=[];
NumberofPlantsperCompanyperYear(EmissionsbyCompany==0)=[];
Coal_company_country_strings(EmissionsbyCompany==0)=[];
Company_RGB_colors(EmissionsbyCompany==0,:)=[];
Lifeleft(EmissionsbyCompany==0)=[];
EmissionsbyCompany(EmissionsbyCompany ==0)=[];

CommittedEmissions(ProfitsByCompany_CarbonTax==0)=[];
AnnualEmissionsByCompany_Coal_strings(ProfitsByCompany_CarbonTax==0)=[];
StrandedAssetsbyCompany(ProfitsByCompany_CarbonTax==0)=[];
RevenuebyCompany(ProfitsByCompany_CarbonTax == 0) = [];
EmissionsbyCompany(ProfitsByCompany_CarbonTax==0)=[];
colorschemecategory(ProfitsByCompany_CarbonTax==0)=[];
Coal_company_country_strings(ProfitsByCompany_CarbonTax==0)=[];
AnnualCapacityByCompany(ProfitsByCompany_CarbonTax==0)=[];
NumberofPlantsperCompanyperYear(ProfitsByCompany_CarbonTax==0)=[];
Company_RGB_colors(ProfitsByCompany_CarbonTax==0,:)=[];
Lifeleft(ProfitsByCompany_CarbonTax==0)=[];
ProfitsByCompany_CarbonTax(ProfitsByCompany_CarbonTax==0)=[];


[StrandedAssetsbyCompany,Indx] = maxk(StrandedAssetsbyCompany,100);
AnnualEmissionsByCompany_Coal_strings = AnnualEmissionsByCompany_Coal_strings(Indx);
RevenuebyCompany = RevenuebyCompany(Indx);
ProfitsByCompany_CarbonTax = ProfitsByCompany_CarbonTax(Indx);
colorschemecategory = colorschemecategory(Indx);
AnnualCapacityByCompany = AnnualCapacityByCompany(Indx);
NumberofPlantsperCompanyperYear = NumberofPlantsperCompanyperYear(Indx);
EmissionsbyCompany = EmissionsbyCompany(Indx);
CommittedEmissions = CommittedEmissions(Indx);
Coal_company_country_strings =Coal_company_country_strings(Indx);
Company_RGB_colors = Company_RGB_colors(Indx,:);
Lifeleft = Lifeleft(Indx,:);
OilRevenue = cell2mat(struct2cell(load('../Data/Results/revenuebycompany_oil.mat')));
GasRevenue = cell2mat(struct2cell(load('../Data/Results/revenuebycompany_gas.mat')));
CoalRevenue = cell2mat(struct2cell(load('../Data/Results/revenuebycompany_coal.mat')));
Revenue = [OilRevenue CoalRevenue GasRevenue];

Lifeleft(Lifeleft<=0)=0.75;% ensures historically overaged plants have no remaining life. Shifted from 0 to help with data visualization and prevent data from being plotted on the axis.

LegendColor = 1:1:9;

figure()% color legend for both panels
scatter(LegendColor',LegendColor',LegendColor*100,RGB_colors,'filled')
text(LegendColor,LegendColor,RegionList)
legend(RegionList{:})


Standardized_size = (StrandedAssetsbyCompany./RevenuebyCompany)*100;% resizes all circles equally to help with visualization

figure() %Figure 2, panel a
scatter(EmissionsbyCompany,StrandedAssetsbyCompany,Standardized_size,Company_RGB_colors,'filled')
set(gca,'xscale','log')
set(gca,'yscale','log')
set(gca,'zscale','log')
xlabel('CO2 emissions')
ylabel('Stranded assets')
xlim([1e6,1e9])
ylim([1e10,1e12])


figure() %Figure S1, panel a
scatter(Lifeleft,StrandedAssetsbyCompany,Standardized_size,Company_RGB_colors,'filled')
set(gca,'yscale','log')
set(gca,'zscale','log')
xlabel('Years to retirement')
ylabel('Stranded assets')
ylim([1e10,1e12])
ax = gca;
% exportgraphics(ax,'../Plots/coal scatter stranded assets remaining life standardized size.eps','ContentType','vector');

