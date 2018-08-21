function Output = truncatezeros(Source)
    % In our output we want to preserve everything, but for the columns
    Output = Source;
    % ask if you need to shift colums too
    startmax = strcmp(questdlg('Make maxima of each trace equal to start?'), 'Yes');
    % make a function to truncate ONE column
    function outcol = truncatecol(incol)
        outcol = incol;
        if startmax
            nrows = size(incol,1);
            [~, coordinates] = max(incol);
            % in case the maxima aren't at the start get new maximum <50um
            scale50um = Output(1).scale100um/2;
            if coordinates>scale50um
                coordinateswrong = coordinates;
                [~, coordinates] = max(incol(1:scale50um,1));
                coordinates = str2num(cell2mat(inputdlg(strcat('Caution!', Output(s).name, ', column', num2str(c) , ' max is at ', num2str(coordinateswrong), ', shift coordinates by:'), 'Shift coordinates dialogue', 1, {num2str(coordinates)})));
                % old code
                % display(strcat('Caution!', ' ', Output(s).name, 'column ', num2str(c) , ' max is at ', num2str(coordinateswrong), ', so shifted to ', num2str(coordinates)))
            end
            % you need the +1 here, e.g. consider if coordinates=1
            outcol(1:(nrows-coordinates+1)) = outcol(coordinates:nrows);
            % fill the bottom with zeros and later with NaNs
            outcol((nrows-coordinates+2):nrows)=zeros();
            
        end
        r = size(outcol,1);
        % for each cell starting from the bottom replace 0 with NaN
        while outcol(r) == 0
            outcol(r) = NaN;
            r=r-1;
        end
    end
    % check what type of variable it is
    % if matrix, just truncate each column
    if isa(Output, 'double');
        ncols = size(Output, 2);
        for c = 1:ncols
            Output(:,c) = truncatecol(Output(:,c));
        end
    elseif isa(Output, 'struct');
        fnames = fieldnames(Output);
        % if it's a structure, then you need to choose what to truncate
        workfields = listdlg('promptString', 'Which fields to truncate?', 'InitialValue', 2, 'OKString', 'Truncate!', 'SelectionMode', 'multiple', 'ListString', fnames);
        nfields = size(workfields, 2);
        % for each selected field
        for w = 1:nfields
            nmatrices = size(Output, 2);
            % for each array in the sources
            for s = 1:nmatrices
                ncols = size(Output(s).(fnames{workfields(w)}), 2);
                % for each column
                for c = 1:ncols
                    %shift column and truncate zeros
                    Output(s).(fnames{workfields(w)})(:,c) = truncatecol(Output(s).(fnames{workfields(w)})(:,c));
                end
            end
        end
    else
        disp('Variable input type not recognised')
    end
end