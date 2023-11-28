function [Operating_data, Opr_Strings, Countries] = retrieve_plant_data(filename)
    % function reads Excel file that contains data on individual power plants 
    % and retrieves the operational conditions, age, location, and operations
    % owner of the plant
    
    Plant = readcell(filename);
    Plants = xlsread(filename);
    PlantYear = Plants(:,9); 
    PlantYear(PlantYear == 0) = nan;

    CO2  = Plants(:,18);
    CO2(CO2 == 0) = .828;

    
    Operating_data = nan(length(Plants),5);

    Plant( cellfun( @(Plant) isa(Plant,'missing'), Plant ) ) = {[]};

    for i = 2:length(Plant)
        if ~isempty(Plant{i,5})
            Plant{i,3} = Plant{i,5};
        elseif isempty(Plant{i,5})
            Plant{i,3} = Plant{i,3};
        end
    end

    oprcounter = 1;
    for n = 1:size(Plants,1)
        Operating_data(oprcounter,1) = (Plants(n,7)); %nameplate
        Operating_data(oprcounter,2) = (Plants(n,10)); %age in 2020
        Operating_data(oprcounter,3) = CO2(n); %CO2 intensity
        Operating_data(oprcounter,4) = (Plants(n,9)); %online year
        Operating_data(oprcounter,5) = (Plants(n,4)); %Comp ID
    
        Opr_Strings{oprcounter,1} = Plant{n+1,2};%Plant
        Opr_Strings{oprcounter,2} = Plant{n+1,3};%Company
        Opr_Strings{oprcounter,3} = Plant{n+1,11};%Country
        Opr_Strings{oprcounter,4} = Plant{n+1,13};%State
    
        Countries{oprcounter,1} = Plant{n+1,11};
    
        oprcounter = oprcounter + 1;
    
    
    end
end
