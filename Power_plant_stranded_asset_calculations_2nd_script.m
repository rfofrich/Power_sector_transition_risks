%Power plant stranded asset calculations
%by Robert Alexander Fofrich Navarro
%
%Calculates thenet present values and stranded assets for each power plant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except ii; close all

FUEL = 1;

PowerPlantFuel = ["Coal", "Gas", "Oil"];
saveyear = 0;%saves decommission year; anyother number loads decommission year
saveresults = 0;
randomsave = 0;%set to 1 to save MC randomization; zero value  loads MC randomization - section 11 only

years = 2021:2060;
StartYear = 1900;
EndYear = 2020;
Year = StartYear:EndYear;

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

load('Data/Results/Coal_Plants');
load('Data/Results/Coal_Plants_strings');
load('Data/Results/CoalCostbyCountry')
load('Data/WholeSaleCostofElectricityCoal');
CarbonTax19 = xlsread('Data/CarbonTax1_9.xlsx');
CarbonTax26 = xlsread('Data/CarbonTax2_6.xlsx');
load 'Data/Results/CoalColors'

clear PowerPlantProfits

PowerPlantRevenue = zeros(length(Plants),1);

for generator = 1:length(Plants)
    PowerPlantRevenue(generator,1) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,1));
end

FuelCosts = F_Costs;
LifeLeft = mean_coalLife - Plants(:,2);

if saveyear == 1 %ensures not all overaged plants are shut down at once but rather closures occur over the next 5 years
    for generator = 1:length(Plants)
        if LifeLeft(generator,1) <=0 
            DecommissionYear(generator,1) = 2020 + randi(5);
        elseif LifeLeft(generator,1) > 0
            DecommissionYear(generator,1) = 2020 + LifeLeft(generator,1);
        end
    end
    save('Data/Results/DecommissionYearCoal','DecommissionYear');
elseif saveyear ~=1
    load('Data/Results/DecommissionYearCoal')
end


for generator = 1:length(Plants)%%
    PowerPlantProfits(generator,1) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,1))...%gains
    -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,1))./Plants(generator,7)))...%costs
    - Plants(generator,8)*Plants(generator,1) - Plants(generator,6)*Plants(generator,1).*DiscountRate;

    OM_annual_increase(generator) = PowerPlantProfits(generator,1)./(DecommissionYear(generator,1) - 2020);%Allows plants to shut down in line with historical norms
end

for generator = 1:length(Plants)
    for yr = 2:mean_coalLife
     PowerPlantProfits(generator,yr) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,1))...%gains
    -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,1))./Plants(generator,7)))...%costs
    - Plants(generator,8)*Plants(generator,1)-OM_annual_increase(generator)*yr - Plants(generator,6)*Plants(generator,1).*DiscountRate;


    PowerPlant_StringInformation(generator,1) = Plants_string(generator,1);%name of the plant
    PowerPlant_StringInformation(generator,2) = Plants_string(generator,2);%corporate owner of the plant
    PowerPlant_StringInformation(generator,3) = Plants_string(generator,3);%national location of the plant
    PowerPlant_StringInformation(generator,4) = Plants_string(generator,4);%state or province location of the plant
    end
end


PowerPlantProfits(PowerPlantProfits<0)  = 0;% prevents power plant operators from carrying debt, instead power plants are shut down when costs exceed revenue 


for generator = 1:length(Plants)
    for yr = 1:mean_coalLife
        PresentAssetValue(generator,yr) = PowerPlantProfits(generator,yr)./(1 + DiscountRate).^yr;
    end
end 

for generator = 1:length(Plants)%%add in carbon tax portion
    for yr = 1:mean_coalLife
        for tax = 1:4%1 - global carbon tax 1.9, 2 - region specific 1.9, 3 - global carbon tax 2.6, 4 - region specific 2.6
            if tax == 1
                PowerPlantProfits_CarbonTax(generator,yr,tax) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,yr))...%gains
                -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,yr))./Plants(generator,7))+Plants(generator,11)*CarbonTax19(yr,7)) ...%costs  
                - Plants(generator,8)*Plants(generator,1)-OM_annual_increase(generator)*yr - Plants(generator,6)*Plants(generator,1).*DiscountRate;
            elseif tax == 2
                PowerPlantProfits_CarbonTax(generator,yr,tax) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,yr))...%gains
                -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,yr))./Plants(generator,7))+Plants(generator,11)*CarbonTax19(yr,Plants(generator,12)+1)) ...%costs  
                - Plants(generator,8)*Plants(generator,1)-OM_annual_increase(generator)*yr - Plants(generator,6)*Plants(generator,1).*DiscountRate;
            elseif tax == 3
                PowerPlantProfits_CarbonTax(generator,yr,tax) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,yr))...%gains
                -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,yr))./Plants(generator,7))+Plants(generator,11)*CarbonTax26(yr,7)) ...%costs  
                - Plants(generator,8)*Plants(generator,1)-OM_annual_increase(generator)*yr - Plants(generator,6)*Plants(generator,1).*DiscountRate;
            elseif tax == 4
                PowerPlantProfits_CarbonTax(generator,yr,tax) = (Plants(generator,1).*mean_coalCF.*AnnualHours.*WholeSaleCostofElectricity(generator,yr))...%gains
                -(Plants(generator,1).*mean_coalCF.*AnnualHours.*((FuelCosts(generator,yr))./Plants(generator,7))+Plants(generator,11)*CarbonTax26(yr,Plants(generator,12)+1)) ...%costs  
                - Plants(generator,8)*Plants(generator,1)-OM_annual_increase(generator)*yr - Plants(generator,6)*Plants(generator,1).*DiscountRate;
            end
        end
    end
end

PowerPlantProfits_CarbonTax(PowerPlantProfits_CarbonTax<0) = 0;
                      
for generator = 1:length(Plants)
    for yr = 1:mean_coalLife
        for i = 1:4
            PresentAssetValue_Carbontax(generator,yr,i) =  PowerPlantProfits_CarbonTax(generator,yr,i)./(1 + DiscountRate).^yr;
        end
    end
end 
            
StrandedAssetValue = zeros(size(PowerPlantProfits_CarbonTax));
for generator = 1:length(Plants)
    for yr = 1:mean_coalLife
        for i = 1:4
            StrandedAssetValue(generator,yr,i) = (PowerPlantProfits(generator,yr)-PowerPlantProfits_CarbonTax(generator,yr,i))./(1 + DiscountRate).^yr;
        end
    end
end 

AnnualStrandedAssets = StrandedAssetValue;
StrandedAssetValue = squeeze(nansum(StrandedAssetValue,2));

CorporateOwners = unique(PowerPlant_StringInformation(:,2));
CountryLocations = unique(PowerPlant_StringInformation(:,3));
PowerPlantFinances_byCompany = zeros(length(CorporateOwners),mean_coalLife,5);
RevenuebyCompany = zeros(length(CorporateOwners),1);
colorschemecategory = nan(length(CorporateOwners),length(colorschemecategoryCoal));
StrandedAssetValuebyCompany = zeros(length(CorporateOwners),4);
PresentAssetValuebyCompany = zeros(length(CorporateOwners),1);


for generator = 1:length(PowerPlant_StringInformation)
    for Company = 1:length(CorporateOwners)
        if strcmpi(PowerPlant_StringInformation{generator,2},CorporateOwners{Company,1})
            for yr = 1:mean_coalLife
                PowerPlantFinances_byCompany(Company,yr,1) = PowerPlantFinances_byCompany(Company,yr,1) + PowerPlantProfits(generator,yr);
                PowerPlantFinances_byCompany(Company,yr,2) = PowerPlantFinances_byCompany(Company,yr,2) + PowerPlantProfits_CarbonTax(generator,yr);
                PowerPlantFinances_byCompany(Company,yr,3) = PowerPlantFinances_byCompany(Company,yr,3) + PresentAssetValue(generator,yr);
                PowerPlantFinances_byCompany(Company,yr,4) = PowerPlantFinances_byCompany(Company,yr,4) + PresentAssetValue_Carbontax(generator,yr);
                
                PresentAssetValuebyCompany(Company,:) = PresentAssetValuebyCompany(Company,:) + nansum(PresentAssetValue(generator,:),2);
                PowerPlantString_ByCompany(Company,:) = PowerPlant_StringInformation(generator,2);

                for i = 1:4
                    StrandedAssetValuebyCompany(Company,i) = StrandedAssetValuebyCompany(Company,i) + StrandedAssetValue(generator,i);
                end
            end
            RevenuebyCompany(Company,1) = RevenuebyCompany(Company,1) + PowerPlantRevenue(generator,1);
            PowerPlantFinances_byCompany(Company,1,5) = PowerPlantFinances_byCompany(Company,1,5) + StrandedAssetValue(generator,1);
            colorschemecategory(Company,generator) = colorschemecategoryCoal(generator);
        end
    end
end

TotalPowerPlantCapacitybyCompany = zeros(length(CorporateOwners),1);
PowerPlantLife_byCompany = zeros(length(CorporateOwners),mean_coalLife);

Capacity = Plants(:,1);

for generator = 1:length(Plants)
    for yr = 1:mean_coalLife 
        PlantAge_Coal(generator,yr) = (years(yr) - Plants(generator,4)); % saves age of power plant
    end
end

PlantAge_Coal(isnan(PlantAge_Coal)) = 0;% if data is missing then age is zero

for Company = 1:length(CorporateOwners)
    for generator = 1:length(PowerPlant_StringInformation)
        if strcmpi(PowerPlant_StringInformation{generator,2},CorporateOwners{Company,1})
            TotalPowerPlantCapacitybyCompany(Company,1) = TotalPowerPlantCapacitybyCompany(Company,1) + Capacity(generator,1);
        end
    end
end

for Company = 1:length(CorporateOwners)
    for generator = 1:length(PowerPlant_StringInformation)
        if strcmpi(PowerPlant_StringInformation{generator,2},CorporateOwners{Company,1})
            PowerPlantLife_byCompany(Company,:) = PowerPlantLife_byCompany(Company,:) + PlantAge_Coal(generator,:).*(Capacity(generator,1)./TotalPowerPlantCapacitybyCompany(Company));
        end
    end
end

PowerPlantLife_byCompany = round(PowerPlantLife_byCompany);
PowerPlantFinances_byCountry = zeros(length(CountryLocations),mean_coalLife,5);
RevenuebyCountry = zeros(length(CountryLocations),1);

for generator = 1:length(PowerPlant_StringInformation)
    for country = 1:length(CountryLocations)
        if strcmpi(PowerPlant_StringInformation{generator,3},CountryLocations{country,1})
            for yr = 1:mean_coalLife
                PowerPlantFinances_byCountry(country,yr,1) = PowerPlantFinances_byCountry(country,yr,1) + PowerPlantProfits(generator,yr);
                PowerPlantFinances_byCountry(country,yr,2) = PowerPlantFinances_byCountry(country,yr,2) + PowerPlantProfits_CarbonTax(generator,yr);
                PowerPlantFinances_byCountry(country,yr,3) = PowerPlantFinances_byCountry(country,yr,3) + PresentAssetValue(generator,yr);
                PowerPlantFinances_byCountry(country,yr,4) = PowerPlantFinances_byCountry(country,yr,4) + PresentAssetValue_Carbontax(generator,yr);
                
                PowerPlantString_ByCountry(country,:) = PowerPlant_StringInformation(generator,3);
                PowerPlantStrandedAssets_byCountry(country,yr,:) = AnnualStrandedAssets(generator,yr,:);
            end
            RevenuebyCountry(country,1) = RevenuebyCountry(country,1) + PowerPlantRevenue(generator,1);
            PowerPlantFinances_byCountry(country,1,5) = PowerPlantFinances_byCountry(country,1,5) + StrandedAssetValue(generator,1);
        end
    end
end

colorschemecategory  = mode(colorschemecategory,2);
colorschemecategory(colorschemecategory == 0) = 8; % sets new color scheme based on desired power plant regions.
