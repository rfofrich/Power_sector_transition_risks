%Figure 1
%by Robert Alexander Fofrich Navarro
%
%Produces figure showing coal stranded assets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except ii; close all

FUEL = 1;
CombineFuelTypeResults = 1;
PowerPlantFuel = ["Coal", "Gas", "Oil"];
saveyear = 0;%saves decommission year; anyother number loads decommission year
saveresults = 0;

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

load('../Data/Results/CoalAnnualEmissions.mat');
load ../Data/Results/PowerPlantFinances_byCompany_Coal.mat
load ../Data/Results/PowerPlantFinances_byCountry_Coal.mat
load ../Data/Results/CoalStrandedAssets.mat
Coal_strings = PowerPlantString_ByCountry;


PowerPlantFinances_byCompany_Coal = PowerPlantFinances_byCompany;
PowerPlantFinances_byCountry_Coal = PowerPlantFinances_byCountry;
PowerPlantFinances_byCompany_Coal(PowerPlantFinances_byCompany_Coal<0) = 0;
PowerPlantFinances_byCountry_Coal(PowerPlantFinances_byCountry_Coal<0) = 0;

load('../Data/Results/GasAnnualEmissions.mat');
load ../Data/Results/PowerPlantFinances_byCompany_Gas.mat
load ../Data/Results/PowerPlantFinances_byCountry_Gas.mat
load ../Data/Results/GasStrandedAssets.mat
Gas_strings = PowerPlantString_ByCountry;

PowerPlantFinances_byCompany_Gas = PowerPlantFinances_byCompany;
PowerPlantFinances_byCountry_Gas = PowerPlantFinances_byCountry;
PowerPlantFinances_byCompany_Gas(PowerPlantFinances_byCompany_Gas<0) = 0;
PowerPlantFinances_byCountry_Gas(PowerPlantFinances_byCountry_Gas<0) = 0;

load('../Data/Results/OilAnnualEmissions.mat');
load ../Data/Results/PowerPlantFinances_byCompany_Oil.mat
load ../Data/Results/PowerPlantFinances_byCountry_Oil.mat
load ../Data/Results/OilStrandedAssets.mat
Oil_strings = PowerPlantString_ByCountry;

PowerPlantFinances_byCompany_Oil = PowerPlantFinances_byCompany;
PowerPlantFinances_byCountry_Oil = PowerPlantFinances_byCountry;
PowerPlantFinances_byCompany_Oil(PowerPlantFinances_byCompany_Oil<0) = 0;
PowerPlantFinances_byCountry_Oil(PowerPlantFinances_byCountry_Oil<0) = 0;


CountrySA = [squeeze(PowerPlantFinances_byCountry_Coal(:,1,5)); squeeze(PowerPlantFinances_byCountry_Gas(:,1,5)); squeeze(PowerPlantFinances_byCountry_Oil(:,1,5))];
CountrySA(isnan(CountrySA)) = 0;
CountryEmissions = [CoalAnnualEmissions_Country' GasAnnualEmissions_Country' OilAnnualEmissions_Country'];
CountryEmissions_strings = cat(1,AnnualEmissionsByCountry_Coal_strings,AnnualEmissionsByCountry_Gas_strings,AnnualEmissionsByCountry_Oil_strings);
Country_strings = cat(1,Coal_strings,Gas_strings,Oil_strings);

CountryStrings =  Country_strings(~cellfun('isempty',Country_strings));
CountryStrings = unique(CountryStrings);

CountryEmissionsUnique = zeros(length(CountryStrings),40);
CountrySAUnique = zeros(length(CountryStrings),1);

for  i = 1:length(CountryStrings)
    for j = 1:length(Country_strings)
        if strcmpi(Country_strings{j,1},CountryStrings{i,1})
           CountryEmissionsUnique(i,:) = CountryEmissionsUnique(i,:) + CountryEmissions(:,j)';
           CountrySAUnique(i,:) = CountrySAUnique(i,:) + CountrySA(j,:);
        end
    end
end

Newcolorbar = autumn(length(1:7));
COLORS = zeros(length(CountryEmissionsUnique),3);

[Top_Countries_Emissions indx_country] =maxk(CountryEmissionsUnique,10);

Top_Countries_strings = CountryStrings(indx_country(:,1),1);
RestofCountriesEmissions = nansum(CountryEmissionsUnique,1)-nansum(Top_Countries_Emissions,1);
CountryEmissions = [RestofCountriesEmissions' Top_Countries_Emissions']';

CountryStrings2 = cell(length(Top_Countries_strings)+1,1);
CountryStrings2(2:end,1) = Top_Countries_strings;
CountryStrings2{1,1} = 'Rest of world';

Top_Countries_strings = CountryStrings2;

CountryEmissions = CountryEmissions./1000000000;%conversts from tons to gigatons 


StrandedAssetsbyCompany = [squeeze(PowerPlantFinances_byCompany_Coal(:,:,5))' squeeze(PowerPlantFinances_byCompany_Gas(:,:,5))' squeeze(PowerPlantFinances_byCompany_Oil(:,:,5))'];

CompanyEmissions = [CoalAnnualEmissions_Company' GasAnnualEmissions_Company' OilAnnualEmissions_Company'];
CompanyEmissions_strings = cat(1,AnnualEmissionsByCompany_Coal_strings,AnnualEmissionsByCompany_Gas_strings,AnnualEmissionsByCompany_Oil_strings);

CompanyStrings =  CompanyEmissions_strings(~cellfun('isempty',CompanyEmissions_strings));
CompanyStrings = unique(CompanyStrings);

CompanyEmissionsUnique = zeros(length(CompanyStrings),40);
CompanySA_Unique = zeros(length(CompanyStrings),1);

Newcolorbar = autumn(length(CompanyEmissionsUnique));
ColorMatrix = zeros(length(CompanyEmissionsUnique),2);           

for  i = 1:length(CompanyStrings)
    for j = 1:length(CompanyEmissions_strings)
        if strcmpi(CompanyEmissions_strings{j,1},CompanyStrings{i,1})
           CompanyEmissionsUnique(i,:) = CompanyEmissionsUnique(i,:) + CompanyEmissions(:,j)';
        end
    end
end

CompanySA_Unique(isnan(CompanySA_Unique)) = 0;
ColorMatrix(:,1) = 1:length(CompanyEmissionsUnique);
ColorMatrix(:,2) = CompanySA_Unique;
ColorMatrix(ColorMatrix == 0) = nan;
ColorMatrix = sort(ColorMatrix,2);
ColorMatrix(isnan(ColorMatrix)) = 0;

[NextNinety_Emissions indx] =maxk(CompanyEmissionsUnique,100);%extracts the top 100 companies
[NextNinety_Emissions indx] =mink(NextNinety_Emissions,90);%subtracts the top 10
[TopTen_Emissions indx] =maxk(CompanyEmissionsUnique,10);
TopColors = Newcolorbar(ColorMatrix(indx(:,1),1),:);
COLORS = [TopColors; Newcolorbar(1,:,:)];

RestStrandedEmissions = nansum(CompanyEmissionsUnique,1);
NextNinety_Emissions = nansum(NextNinety_Emissions,1);
TopTen_Emissions = nansum(TopTen_Emissions,1);
RestStrandedEmissions = RestStrandedEmissions - NextNinety_Emissions - TopTen_Emissions;
StrandedEmissions = [RestStrandedEmissions' NextNinety_Emissions' TopTen_Emissions'];

StrandedEmissions = StrandedEmissions./1000000000;%conversts from tons to gigatons 


TotalStrandedAssets_Global_19_ByFuel = [nansum(AnnualStrandedAssetByCompany19_globalpricing_Coal,1); nansum(AnnualStrandedAssetByCompany19_globalpricing_Gas,1); nansum(AnnualStrandedAssetByCompany19_globalpricing_Oil,1)];
TotalStrandedAssets_Global_26_ByFuel  = [nansum(AnnualStrandedAssetByCompany26_globalpricing_Coal,1); nansum(AnnualStrandedAssetByCompany26_globalpricing_Gas,1); nansum(AnnualStrandedAssetByCompany26_globalpricing_Oil,1)];

TotalStrandedAssets_Regional_19_ByFuel = [nansum(AnnualStrandedAssetByCompany19_regionalpricing_Coal,1); nansum(AnnualStrandedAssetByCompany19_regionalpricing_Gas,1); nansum(AnnualStrandedAssetByCompany19_regionalpricing_Oil,1)];
TotalStrandedAssets_Regional_26_ByFuel = [nansum(AnnualStrandedAssetByCompany26_regionalpricing_Coal,1); nansum(AnnualStrandedAssetByCompany26_regionalpricing_Gas,1); nansum(AnnualStrandedAssetByCompany26_regionalpricing_Oil,1)];


figure()
bar(1,TotalStrandedAssets_Global_19_ByFuel(:,1),'stacked')
hold on
bar(2,TotalStrandedAssets_Global_26_ByFuel(:,1),'stacked')
legend('Coal','Gas','Oil')
ylim([0 14e12])
ylabel('Stranded Assets (USD $)')
aY = gca;

TotalStrandedAssets_Global_19_ByFuel =  TotalStrandedAssets_Global_19_ByFuel(:,1);
TotalStrandedAssets_Global_26_ByFuel =  TotalStrandedAssets_Global_26_ByFuel(:,1);


TotalStrandedAssets_Country_Global_19 = [AnnualStrandedAssetByCountry19_globalpricing_Coal; AnnualStrandedAssetByCountry19_globalpricing_Gas; AnnualStrandedAssetByCountry19_globalpricing_Oil];
TotalStrandedAssets_Country_Global_26 = [AnnualStrandedAssetByCountry26_globalpricing_Coal; AnnualStrandedAssetByCountry26_globalpricing_Gas; AnnualStrandedAssetByCountry26_globalpricing_Oil];

TotalStrandedAssets_Country_Regional_26 = [AnnualStrandedAssetByCountry26_regionalpricing_Coal; AnnualStrandedAssetByCountry26_regionalpricing_Gas; AnnualStrandedAssetByCountry26_regionalpricing_Oil];
TotalStrandedAssets_Country_Regional_19 = [AnnualStrandedAssetByCountry19_regionalpricing_Coal; AnnualStrandedAssetByCountry19_regionalpricing_Gas; AnnualStrandedAssetByCountry19_regionalpricing_Oil];


CountryassetsUnique19_global = zeros(length(CountryStrings),40);
CountryassetsUnique26_global = zeros(length(CountryStrings),40);

CountryassetsUnique19_regional = zeros(length(CountryStrings),40);
CountryassetsUnique26_regional = zeros(length(CountryStrings),40);

for  i = 1:length(CountryStrings)
    for j = 1:length(CountryEmissions_strings)
        if strcmpi(CountryEmissions_strings{j,1},CountryStrings{i,1})
           CountryassetsUnique19_global(i,:) = CountryassetsUnique19_global(i,:) + TotalStrandedAssets_Country_Global_19(j,:);
           CountryassetsUnique26_global(i,:) = CountryassetsUnique26_global(i,:) + TotalStrandedAssets_Country_Global_26(j,:);
           
           CountryassetsUnique19_regional(i,:) = CountryassetsUnique19_regional(i,:) + TotalStrandedAssets_Country_Regional_19(j,:);
           CountryassetsUnique26_regional(i,:) = CountryassetsUnique26_regional(i,:) + TotalStrandedAssets_Country_Regional_26(j,:);
        end
    end
end

[~, indx] = maxk(CountryassetsUnique19_global(:,1),4);%extracts the top 10
Top_Countries_assets_global19 = CountryassetsUnique19_global(indx,:);
RestofCountriesEmissions_global19 = nansum(CountryassetsUnique19_global,1)-nansum(Top_Countries_assets_global19,1);
CountryAssets_global19 = [RestofCountriesEmissions_global19' Top_Countries_assets_global19']';
Top_Countries_strings = cell(5,1);
Top_Countries_strings(1,1) = {'REST OF WORLD'};
Top_Countries_strings(2:end,1) = CountryStrings(indx(:,1),1);


CountryNames = {'Albania', 'Australia', 'Austria', 'Belgium', 'Bosnia-Herzegovina', 'Bulgaria', 'Canada',...
                'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Guam', 'Hungary',...
                'Iceland', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Montenegro', 'Netherlands', 'New Zealand',...
                'Norway', 'Poland', 'Portugal', 'Puerto Rico', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', ...
                'North Macedonia', 'Turkey', 'United Kingdom', 'USA','ENGLAND & WALES','Scotland','Ireland','Moldova','Ukraine','Russia'};

Europe_Assets = 0;
for Nation = 1:length(CountryStrings)
    for National_name = 1:length(CountryNames)
        if strcmp(CountryStrings{Nation}, CountryNames{National_name})
           Europe_Assets = Europe_Assets + CountryassetsUnique19_global(Nation,1);
        end
    end
end

US_Assets = CountryassetsUnique19_global(217,1);

figure()
bar(1,CountryAssets_global19(:,1),'stacked')
legend('Rest of the world','China','USA', 'India','Germany')
ylim([0 14e12])
ylabel('Stranded Assets (USD $)')


CountryAssets_global19 = CountryAssets_global19(:,1);
[~, indx] = maxk(nansum(CountryassetsUnique26_global,2),4);%extracts the top 10
Top_Countries_assets_global26 = CountryassetsUnique26_global(indx,:);
RestofCountriesEmissions_global26 = nansum(TotalStrandedAssets_Country_Global_26,1)-nansum(Top_Countries_assets_global26,1);
CountryAssets_global26 = [RestofCountriesEmissions_global26' Top_Countries_assets_global26']';
Top_Countries_strings = cell(5,1);
Top_Countries_strings(1,1) = {'REST OF WORLD'};
Top_Countries_strings(2:end,1) = CountryStrings(indx(:,1),1);


figure()
bar(1,CountryAssets_global26(:,1),'stacked')
legend('Rest of the world','China','USA', 'India','Germany')
ylim([0 14e12])
ylabel('Stranded Assets (USD $)')
CountryAssets_global26 = CountryAssets_global26(:,1);


[~, indx] = maxk(nansum(CountryassetsUnique19_regional,2),10);%extracts the top 10
Top_Countries_assets_regional19 = CountryassetsUnique19_regional(indx,:);
RestofCountriesEmissions_regional19 = nansum(TotalStrandedAssets_Country_Regional_19,1)-nansum(Top_Countries_assets_regional19,1);
CountryAssets_regional19 = [RestofCountriesEmissions_regional19' Top_Countries_assets_regional19']';
Top_Countries_strings = cell(11,1);
Top_Countries_strings(1,1) = {'REST OF WORLD'};
Top_Countries_strings(2:end,1) = CountryStrings(indx(:,1),1);

[~, indx] = maxk(nansum(CountryassetsUnique26_regional,2),10);%extracts the top 10
Top_Countries_assets_regional26 = CountryassetsUnique26_regional(indx,:);
RestofCountriesEmissions_regional26 = nansum(TotalStrandedAssets_Country_Regional_26,1)-nansum(Top_Countries_assets_regional26,1);
CountryAssets_regional26 = [RestofCountriesEmissions_regional26' Top_Countries_assets_regional26']';
Top_Countries_strings = cell(11,1);
Top_Countries_strings(1,1) = {'REST OF WORLD'};
Top_Countries_strings(2:end,1) = CountryStrings(indx(:,1),1);

TotalStrandedAssets_Company_Global_19 = [AnnualStrandedAssetByCompany19_globalpricing_Coal; AnnualStrandedAssetByCompany19_globalpricing_Gas; AnnualStrandedAssetByCompany19_globalpricing_Oil];
TotalStrandedAssets_Company_Global_26 = [AnnualStrandedAssetByCompany26_globalpricing_Coal; AnnualStrandedAssetByCompany26_globalpricing_Gas; AnnualStrandedAssetByCompany26_globalpricing_Oil];

TotalStrandedAssets_Company_Regional_26 = [AnnualStrandedAssetByCompany26_regionalpricing_Coal; AnnualStrandedAssetByCompany26_regionalpricing_Gas; AnnualStrandedAssetByCompany26_regionalpricing_Oil];
TotalStrandedAssets_Company_Regional_19 = [AnnualStrandedAssetByCompany19_regionalpricing_Coal; AnnualStrandedAssetByCompany19_regionalpricing_Gas; AnnualStrandedAssetByCompany19_regionalpricing_Oil];

CompanyAssetsUnique_global19 = zeros(length(CompanyStrings),40); CompanyAssetsUnique_global26 = zeros(length(CompanyStrings),40);
CompanyAssetsUnique_regional19 = zeros(length(CompanyStrings),40); CompanyAssetsUnique_regional26 = zeros(length(CompanyStrings),40);
 

for  i = 1:length(CompanyStrings)
    for j = 1:length(CompanyEmissions_strings)
        if strcmpi(CompanyEmissions_strings{j,1},CompanyStrings{i,1})
           CompanyAssetsUnique_global19(i,:) = CompanyAssetsUnique_global19(i,:) + TotalStrandedAssets_Company_Global_19(j,:);
           CompanyAssetsUnique_global26(i,:) = CompanyAssetsUnique_global26(i,:) + TotalStrandedAssets_Company_Global_26(j,:);
           CompanyAssetsUnique_regional19(i,:) = CompanyAssetsUnique_regional19(i,:) + TotalStrandedAssets_Company_Regional_19(j,:);
           CompanyAssetsUnique_regional26(i,:) = CompanyAssetsUnique_regional26(i,:) + TotalStrandedAssets_Company_Regional_26(j,:);
        end
    end
end

NextNinety_Assets = maxk(CompanyAssetsUnique_global19,100);%extracts the top 100 companies
NextNinety_Assets = mink(NextNinety_Assets,90);%subtracts the top 10
TopTen_Assets = maxk(CompanyAssetsUnique_global19,10);

RestStrandedAssets = nansum(CompanyAssetsUnique_global19,1);
NextNinety_Assets = nansum(NextNinety_Assets,1);
TopTen_Assets = nansum(TopTen_Assets,1);
RestStrandedAssets = RestStrandedAssets - NextNinety_Assets - TopTen_Assets;
StrandedAssets = [RestStrandedAssets' NextNinety_Assets' TopTen_Assets'];

figure()
bar(1,StrandedAssets(1,:),'stacked')
legend('Rest','Next 90','Top 10')
ylim([0 14e12])
ylabel('Stranded Assets (USD $)')

StrandedAssetsbycompany19 = StrandedAssets(1,:);

NextNinety_Assets = maxk(CompanyAssetsUnique_global26,100);%extracts the top 100 companies
NextNinety_Assets = mink(NextNinety_Assets,90);%subtracts the top 10
TopTen_Assets = maxk(CompanyAssetsUnique_global26,10);

RestStrandedAssets = nansum(CompanyAssetsUnique_global26,1);
NextNinety_Assets = nansum(NextNinety_Assets,1);
TopTen_Assets = nansum(TopTen_Assets,1);
RestStrandedAssets = RestStrandedAssets - NextNinety_Assets - TopTen_Assets;
StrandedAssets = [RestStrandedAssets' NextNinety_Assets' TopTen_Assets'];

figure()
bar(1,StrandedAssets(1,:),'stacked')
legend('Rest','Next 90','Top 10')
ylim([0 14e12])
ylabel('Stranded Assets (USD $)')