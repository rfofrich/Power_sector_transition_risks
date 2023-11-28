%Asset value
%
%Created June 24 2021
%by Robert Alexander Fofrich Navarro
%
%Aggregates power plant information into a single matrix for later use.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except ii; close all

FUEL = 1;

PowerPlantFuel = ["Coal", "Gas", "Oil"];
saveyear = 0;%saves decommission year; anyother number loads decommission year

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

Country = readcell('Data/Countries.xlsx');
O_M_costs = readcell('Data/Average_O_M_costs.xlsx');
Wholesale_Electricity_Costs_strings = readcell('Data/PriceOfElectricity_Worldbank.xlsx');
Wholesale_Electricity_Costs = xlsread('Data/PriceOfElectricity_Worldbank.xlsx');
Wholesale_Electricity_Costs = Wholesale_Electricity_Costs(2:end,7)*1000./100;%retrieves data and converts it to KWh and to U.S. dollars

for i = 2:length(Wholesale_Electricity_Costs_strings)
    Wholesale_Electricity_Costs_Country_strings{i-1,1} = upper(Wholesale_Electricity_Costs_strings{i,1});%converts lower case strings to upper case for strcmpi to work
end

for gentype = FUEL
        clear Plants

        [Operating_data, Opr_Strings, Countries] = retrieve_plant_data(['Data/' PowerPlantFuel{gentype} '.xlsx']);

        Countries = unique(Countries);
        Plants = Operating_data;
        Plants_string = Opr_Strings;


        [UniqueName, ~, idc] = unique(Opr_Strings(:,2));

        CapitalCosts_strings = readcell('Data/Capital_costs_Data_Power_sectors.xlsx');
        CapitalCosts = xlsread('Data/Capital_costs_Data_Power_sectors.xlsx');


        if gentype == 1
            for powerplant = 2:length(CapitalCosts_strings)%sets initial investment costs
                if strcmpi(CapitalCosts_strings{powerplant,2},'Coal')
                    CapitalCosts_location{powerplant-1,:} = CapitalCosts_strings{powerplant,1};%country where power plant is located
                    FuelSpecific_CapitalCosts(powerplant-1,:) = CapitalCosts(powerplant-1,1);%initial investment costs in $/kw
                end
            end

            MIN = round(nanmean(FuelSpecific_CapitalCosts)-nanmean(FuelSpecific_CapitalCosts)*.2);%sets range of capital costs
            MAX = round(nanmean(FuelSpecific_CapitalCosts)+nanmean(FuelSpecific_CapitalCosts)*.2);
            
            
            for powerplant = 1:length(Plants)
                if Plants(powerplant,2) <=15
                    Plants(powerplant,6) = randi([MIN MAX])*1000;%$/MW
                elseif Plants(powerplant,2) > 15
                    Plants(powerplant,6) = 0;
                end
            end

            WholeSaleCostofElectricity = nan(length(Opr_Strings),40);%sets wholesale price of electricity
            for powerplant = 1:length(Opr_Strings)
                for country = 1:length(Wholesale_Electricity_Costs_Country_strings)
                    if strcmpi(Opr_Strings{powerplant,3},Wholesale_Electricity_Costs_Country_strings{country,1})
                        WholeSaleCostofElectricity(powerplant,1:40) = Wholesale_Electricity_Costs(country,1);%Wholesale electricity $ cost per MWh
                    end
                end
            end
            
            for powerplant = 1:length(Opr_Strings)
                if isnan(WholeSaleCostofElectricity(powerplant,1))
                    WholeSaleCostofElectricity(powerplant,1:40) = Wholesale_Electricity_Costs(end,1);%Wholesale electricity $ cost per MWh
                end
            end
            
            save('Data/WholeSaleCostofElectricityCoal','WholeSaleCostofElectricity');
            
            FuelCosts = xlsread('Data/CoalCosts.xlsx');%$ Cost of per unit fuel 
            Fuel_strings = readcell('Data/CoalCosts.xlsx');
            Fuel_strings = Fuel_strings(:,1:2);
            
           for i = 1:length(FuelCosts)
                if isnan(FuelCosts(i,1)) && ~isnan(FuelCosts(i,2))
                        FuelCosts(i,1) = FuelCosts(i,2);
                elseif isnan(FuelCosts(i,1)) && ~isnan(FuelCosts(i,3))
                    FuelCosts(i,1) = FuelCosts(i,3);
                elseif isnan(FuelCosts(i,1)) && ~isnan(FuelCosts(i,4))
                    FuelCosts(i,1) = FuelCosts(i,4);
                end
            end
            
            
            for i = 1:length(FuelCosts)
                for j = 2:73
                    if FuelCosts(i,j) < 0
                        FuelCosts(i,j) = FuelCosts(i,j) * -1;
                    end
                    
                    if isnan(FuelCosts(i,j)) && ~isnan(FuelCosts(i,j-1))
                        FuelCosts(i,j) = FuelCosts(i,j-1);
                    end
                end
            end
            

            oprcounter = 1;

            for i = 2:length(Fuel_strings)-4
                FuelCost_strings{oprcounter,1} = upper(Fuel_strings{i,1});
                oprcounter = oprcounter + 1;
            end

            F_Costs = nan(length(Opr_Strings),40);
            for powerplant = 1:length(Opr_Strings)
                for country = 1:length(FuelCost_strings)
                    if strcmpi(Opr_Strings{powerplant,3},FuelCost_strings{country,1})
                       F_Costs(powerplant,1:40) = FuelCosts(country,22:61);%Costs of fuel per short ton 
                    end
                end
            end
            
            for powerplant = 1:length(Opr_Strings)
                if isnan(F_Costs(powerplant,1))
                    F_Costs(powerplant,1:40) = FuelCosts(2,22:61);%Wholesale electricity cost per MWh
                end
            end


            for powerplant = 1:length(Plants)
                Plants(powerplant,7) = 8.14;%conversion factor for short ton to MWh
            end

            
            for powerplant = 1:length(Plants)
                Plants(powerplant,8) = 40.79*1000;%Average O&M fixed costs per year $/MW
            end

            for powerplant = 1:length(Plants)
                 Plants(powerplant,11) = Plants(powerplant,1) * mean_coalCF * AnnualHours * Plants(powerplant,3); %tons CO2 
            end
             
            colorschemecategory = zeros(length(Plants),1);
            for region = 1:5
                if region == 1%OECD
                    CountryNames = {'Albania', 'Australia', 'Austria', 'Belgium', 'Bosnia-Herzegovina', 'Bulgaria', 'Canada',...
                        'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Guam', 'Hungary',...
                        'Iceland', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Montenegro', 'Netherlands', 'New Zealand',...
                        'Norway', 'Poland', 'Portugal', 'Puerto Rico', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', ...
                        'North Macedonia', 'Turkey', 'United Kingdom', 'USA','ENGLAND & WALES','Scotland','Ireland'};
                    CountryNames = upper(CountryNames)';
                    for powerplant = 1:length(Plants)
                        for Names = 1:length(CountryNames)
                            if strcmpi(Plants_string{powerplant,3},CountryNames{Names,1})
                                Plants(powerplant,12) = region;
                                colorschemecategory(powerplant) = 4;
                                if strcmpi(Plants_string{powerplant,3},'UNITED KINGDOM') || strcmpi(Plants_string{powerplant,3},'ENGLAND & WALES')...
                                        || strcmpi(Plants_string{powerplant,3},'SCOTLAND') || strcmpi(Plants_string{powerplant,3},'IRELAND')
                                    colorschemecategory(powerplant) = 4;
                                elseif strcmpi(Plants_string{powerplant,3},'USA') 
                                    colorschemecategory(powerplant) = 1;
                                elseif strcmpi(Plants_string{powerplant,3},'AUSTRALIA') || strcmpi(Plants_string{powerplant,3},'NEW ZEALAND')...
                                        || strcmpi(Plants_string{powerplant,3},'CANADA') 
                                    colorschemecategory(powerplant) = 8;
                                end
                            end
                        end
                    end
                elseif region == 2%REF
                    CountryNames = {'Armenia', 'Azerbaijan', 'Belarus', 'Georgia', 'Kazakhstan', 'Kyrgyzstan', 'Moldova', 'Russia', ...
                        'Tajikistan', 'Turkmenistan', 'Ukraine', 'Uzbekistan'};
                    CountryNames = upper(CountryNames)';
                    for powerplant = 1:length(Plants)
                        for Names = 1:length(CountryNames)
                            if strcmpi(Plants_string{powerplant,3},CountryNames{Names,1})
                                Plants(powerplant,12) = region;
                                colorschemecategory(powerplant) = 7;
                            end
                        end
                    end
                elseif region == 3%Asia
                    CountryNames = {'Afghanistan', 'Bangladesh', 'Bhutan', 'Brunei', 'Cambodia', 'China', 'North Korea', 'Fiji', 'French Polynesia','India' ...
                        'Indonesia', 'Laos', 'Malaysia', 'Maldives', 'Micronesia', 'Mongolia', 'Myanmar', 'Nepal',' New Caledonia', 'Pakistan', 'Papua New Guinea',...
                        'Philippines', 'South Korea', 'Samoa', 'Singapore','JAPAN', 'Solomon Islands', 'Sri Lanka', 'Taiwan', 'Thailand', 'Timor-Leste', 'Vanuatu', 'Vietnam'};
                    CountryNames = upper(CountryNames)';
                    for powerplant = 1:length(Plants)
                        for Names = 1:length(CountryNames)
                            if strcmpi(Plants_string{powerplant,3},CountryNames{Names,1})
                                Plants(powerplant,12) = region;
                                colorschemecategory(powerplant) = 6;
                                if strcmpi(Plants_string{powerplant,3},'CHINA')
                                    colorschemecategory(powerplant) = 3;
                                elseif strcmpi(Plants_string{powerplant,3},'INDIA')
                                    colorschemecategory(powerplant) = 9;    
                                end
                            end
                        end
                    end
                elseif region == 4%MAF
                    CountryNames = {'Algeria', 'Angola','Bahrain', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cameroon', 'Cape Verde', 'Central African Republic',...
                        'Chad', 'Comoros', 'Congo', 'Cote dIvoire', 'Congo', 'Djibouti', 'Egypt', 'Equatorial Guinea', 'Eritrea', 'Ethiopia', ...
                        'Gabon', 'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 'Iran', 'Iraq', 'Israel', 'Jordan', 'Kenya', 'Kuwait', 'Lebanon', 'Lesotho', 'Liberia', ...
                        'Libya', 'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius', 'Mayotte', 'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Palestine', ...
                        'Oman', 'Qatar', 'Rwanda', 'Reunion', 'Saudi Arabia', 'Senegal', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan', 'Swaziland',...
                        'Syria', 'Togo', 'Tunisia', 'Uganda', 'United Arab Emirates', 'Tanzania', 'Western Sahara', 'Yemen', 'Zambia', 'Zimbabwe'};
                    CountryNames = upper(CountryNames)';
                    for powerplant = 1:length(Plants)
                        for Names = 1:length(CountryNames)
                            if strcmpi(Plants_string{powerplant,3},CountryNames{Names,1})
                                Plants(powerplant,12) = region;
                                colorschemecategory(powerplant) = 5;
                            end
                        end
                    end  
                elseif region == 5%LAM
                    CountryNames = {'Argentina', 'Aruba', 'Bahamas', 'Barbados', 'Belize', 'Bolivia', 'Brazil', 'Chile', 'Colombia', 'Costa Rica', 'Cuba', 'Dominican Republic',...
                        'Ecuador', 'El Salvador', 'French Guiana', 'Grenada', 'Guadeloupe', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaica', 'Martinique', 'Mexico', 'Nicaragua',...
                        'Panama', 'Paraguay', 'Peru', 'Suriname', 'Trinidad and Tobago', 'United States Virgin Islands', 'Uruguay', 'Venezuela'};
                    CountryNames = upper(CountryNames)';
                    for powerplant = 1:length(Plants)
                        for Names = 1:length(CountryNames)
                            if strcmpi(Plants_string{powerplant,3},CountryNames{Names,1})
                                Plants(powerplant,12) = region;
                                colorschemecategory(powerplant) = 2;
                            end
                        end
                    end  
                end
            end
                    
                        
                           
            colorschemecategoryCoal = colorschemecategory;
            save('Data/Results/CoalColors','colorschemecategoryCoal');

            save('Data/Results/Coal_Plants','Plants');
            save('Data/Results/Coal_Plants_strings','Plants_string');
            save('Data/Results/CoalCostbyCountry','F_Costs');
                   
        end
end%gentype

