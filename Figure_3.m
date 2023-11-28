%Figure 3
%by Robert Alexander Fofrich Navarro
%
%Produces Figure 3 and Figure S1
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



load 'Data/Results/PowerPlantFinances_byCompany_Coal'
load 'Data/Results/CoalAnnualEmissions.mat'
load 'Data/Results/colorschemecategoryCoal2'
load Data/Results/CoalCompanyCapacity.mat

RegionList = {'USA','Latin America','China','Europe',...
        'Middle East and Africa','Asia','Former Soviet','Australia, Canada, New Zealand','India'};
    
RGB_colors = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0; 0 0 0; 0 0.4470 0.7410; 0.8500 0.3250 0.0980];
    

Company_RGB_colors = zeros(length(CoalAnnualEmissions_Company),3);

for i = 1:length(CoalAnnualEmissions_Company)
    for j = 1:length(RegionList)
        if colorschemecategory(i) == j
            Coal_company_country_strings(i) = RegionList(j);
            Company_RGB_colors(i,:) = RGB_colors(j,:);
        end
    end
end

StrandedAssetsbyCompany = squeeze(PowerPlantFinances_byCompany(:,1,5));
CommittedEmissions_Company = sum(CoalAnnualEmissions_Company,2);

CommittedEmissions_Company(StrandedAssetsbyCompany==0) = 0;
StrandedAssetsbyCompany(CommittedEmissions_Company==0) = 0;

[Sorted_for_strings,String_Indx] = sort(StrandedAssetsbyCompany,"descend");
Sorted_Company_strings = AnnualEmissionsByCompany_Coal_strings(String_Indx);

CommittedEmissions_Company(CommittedEmissions_Company==0)=[];
Company_RGB_colors(StrandedAssetsbyCompany==0,:)=[];
StrandedAssetsbyCompany(StrandedAssetsbyCompany==0)=[];

CDF_Share_Company_Emissions = zeros(length(CommittedEmissions_Company),1);

[Sorted_SA,Indx] = sort(StrandedAssetsbyCompany,"descend");
Sorted_Emissions = CommittedEmissions_Company(Indx);
Company_RGB_colors = Company_RGB_colors(Indx,:);



for i = 1:length(CDF_Share_Company_Emissions)
    if i==1
        CDF_Share_Company_Emissions(i,1) = Sorted_Emissions(i,1);
    else
        CDF_Share_Company_Emissions(i,1) = Sorted_Emissions(i,1) + CDF_Share_Company_Emissions(i-1,1);
    end
end


edges = zeros(length(CDF_Share_Company_Emissions)+1,1);
edges(2:end,1) = CDF_Share_Company_Emissions;
vals = Sorted_SA;


center = (edges(1:end-1) + edges(2:end))/2;
width = diff(edges);

figure()
hold on
for i=1:length(center)
    bar(center(i),vals(i),width(i),'FaceColor', Company_RGB_colors(i,:))
end
hold off
set(gca,'yscale','log')
ylim([0 1e12])
cx = gca;
% exportgraphics(cx,['../Plots/Coal_CDF.eps'],'ContentType','vector');   



load('Data/Results/EmissionsPerStrandedAssets_coal.mat')
EmissionsbyCompany_coal = EmissionsbyCompany;

load('Data/Results/EmissionsPerStrandedAssets_max_coal.mat')
EmissionsPerStrandedAssets_coal_max = EmissionsPerStrandedAssets; 

load('Data/Results/EmissionsPerStrandedAssets_min_coal.mat')
EmissionsPerStrandedAssets_coal_min = EmissionsPerStrandedAssets;

EmissionsPerStrandedAssets_coal_average = (EmissionsPerStrandedAssets_coal_min+EmissionsPerStrandedAssets_coal_max)/2;

figure;
scatter(EmissionsbyCompany_coal, EmissionsPerStrandedAssets_coal_average, 75, Company_RGB_colors, 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
for i = 1:length(EmissionsbyCompany_coal)
    line([EmissionsbyCompany_coal(i), EmissionsbyCompany_coal(i)], [EmissionsPerStrandedAssets_coal_min(i), EmissionsPerStrandedAssets_coal_max(i)], 'Color', 'k', 'LineStyle', '--');
end
ylim([0,60])
set(gca,'xscale','log')
xlim([1.5e6,1e9])
hold off;
ax = gca;
% exportgraphics(ax,'../Plots/scatter emissions per stranded assets coal.eps','ContentType','vector');




load('Data/Results/EmissionsPerStrandedAssets_oil.mat')
EmissionsbyCompany_oil = EmissionsbyCompany;

load('Data/Results/EmissionsPerStrandedAssets_max_oil.mat')
EmissionsPerStrandedAssets_oil_max = EmissionsPerStrandedAssets; 

load('Data/Results/EmissionsPerStrandedAssets_min_oil.mat')
EmissionsPerStrandedAssets_oil_min = EmissionsPerStrandedAssets;

EmissionsPerStrandedAssets_oil_average = (EmissionsPerStrandedAssets_oil_min+EmissionsPerStrandedAssets_oil_max)/2;

figure;
scatter(EmissionsbyCompany_oil, EmissionsPerStrandedAssets_oil_average, 75, Company_RGB_colors, 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
for i = 1:length(EmissionsbyCompany_oil)
    line([EmissionsbyCompany_oil(i), EmissionsbyCompany_oil(i)], [EmissionsPerStrandedAssets_oil_min(i), EmissionsPerStrandedAssets_oil_max(i)], 'Color', 'k', 'LineStyle', '--');
end
ylim([0,110])
set(gca,'xscale','log')
hold off;
ax = gca;
% exportgraphics(ax,'../Plots/scatter emissions per stranded assets oil.eps','ContentType','vector');




load('Data/Results/EmissionsPerStrandedAssets_gas.mat')
EmissionsbyCompany_gas = EmissionsbyCompany;

load('Data/Results/EmissionsPerStrandedAssets_max_gas.mat')
EmissionsPerStrandedAssets_gas_max = EmissionsPerStrandedAssets; 

load('Data/Results/EmissionsPerStrandedAssets_min_gas.mat')
EmissionsPerStrandedAssets_gas_min = EmissionsPerStrandedAssets;

EmissionsPerStrandedAssets_gas_average = (EmissionsPerStrandedAssets_gas_min+EmissionsPerStrandedAssets_gas_max)/2;

figure;
scatter(EmissionsbyCompany_gas, EmissionsPerStrandedAssets_gas_average, 75, Company_RGB_colors, 'filled', 'MarkerFaceAlpha', 0.5);
hold on;
for i = 1:length(EmissionsbyCompany_gas)
    line([EmissionsbyCompany_gas(i), EmissionsbyCompany_gas(i)], [EmissionsPerStrandedAssets_gas_min(i), EmissionsPerStrandedAssets_gas_max(i)], 'Color', 'k', 'LineStyle', '--');
end
ylim([0,60])
set(gca,'xscale','log')
hold off;
ax = gca;
% exportgraphics(ax,'../Plots/scatter emissions per stranded assets gas.eps','ContentType','vector');

