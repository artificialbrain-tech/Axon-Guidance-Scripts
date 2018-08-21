function output = procstructure(Structure, Method)

    if nargin<2
        MethodNames = {'Truncate Zeros/shift curve',...
        'Smoothen the curve',...
        'Subtract the background and cut-off end',...
        'Calculate trapezoid integral',...
        'Plot a field',...
        'Plot a field and output a matrix',...
        'Find Maxima of twelve_bit field', ...
        'Find length of 75%, 50% and 25% of neurites'};
        MethodList = {'truncate', 'smooth', 'subtract', 'trapz', 'plot', 'plotmatrix', 'maxima', 'length'};
        Method = MethodList{listdlg('PromptString','Select method from the list:','SelectionMode','single','InitialValue',1,'Name','Processing Method','ListSize', [250 110],'ListString',MethodNames)};
    end
    
    switch Method
        case 'truncate'
            output = truncatezeros(Structure);
        case 'subtract'
            output = Structure;
            % there's no point subtracting background from binary
            fnames{1} = 'twelve_bit';
            % to subtract at 1400-1500um distance you need to know scale
            % old code asking for input
            % Scale = inputdlg('How many PIXELS are there in 1µm?', 'Scale', 1, {num2str(Structure(1).scale100um/100)});
            % Scale = str2double(Scale{:});
            Scale = Structure(1).scale100um/100;
            
            % Ask if you would like to cut-off the end as well
            cutoff = strcmp(questdlg('Cut-off after 1400um?'), 'Yes');

            % for each array in the sources
            nmatrices = size(output, 2);
            for s = 1:nmatrices
                % for each column
                ncols = size(output(s).(fnames{1}), 2);
                nrows = size(output(s).(fnames{1}), 1);
                for c = 1:ncols
                    if nrows>Scale*1500
                        %calculate median intensity at 1400-1500px
                        background = nanmedian(output(s).(fnames{1})(Scale*1400:Scale*1500,c));
                        display(strcat(output(s).name, ' background = ', num2str(background)))
                        %subtract background
                        output(s).(fnames{1})(:,c) = output(s).(fnames{1})(:,c)-background;
                        if cutoff
                            output(s).(fnames{1})(Scale*1400:nrows,c) = NaN;
                        end
                    elseif nrows>Scale*1400
                        display(strcat(output(s).name, ' too short! Median 1300 to end was subtracted'))
                        %calculate median intensity at 1400px to end
                        background = nanmedian(output(s).(fnames{1})(Scale*1300:nrows,c));
                        display(strcat(output(s).name, ' background = ', num2str(background)))
                        %subtract background
                        output(s).(fnames{1})(:,c) = output(s).(fnames{1})(:,c)-background;
                        if cutoff
                            output(s).(fnames{1})(Scale*1400:nrows,c) = NaN;
                        end
                    else
                        minbg = min(output(s).(fnames{1})(:,c));
                        background = str2num(cell2mat(inputdlg(strcat('Caution!', output(s).name, ' is too short. Min is at ', num2str(minbg), '; subtract'), 'Subtract background dialogue', 1, {num2str(minbg)})));
                        output(s).(fnames{1})(:,c) = output(s).(fnames{1})(:,c)-background;
                        if cutoff
                            output(s).(fnames{1})(Scale*1400:nrows,c) = NaN;
                        end
                        % display(strcat(output(s).name, ' too short! No background was subtracted'))
                    end
                end
            end
        case 'trapz'
            % you need to choose what to process
            fnames = fieldnames(Structure);
            workfields = listdlg('promptString', 'Which fields to process?', 'InitialValue', 2, 'OKString', 'Process!', 'SelectionMode', 'multiple', 'ListString', fnames);
            
            %define dimensions of output array
            nmatrices = size(Structure, 2);
            output(nmatrices).name = ' ';
            
            % define step size
            % temporarily put "/2" to get data for every 50 um
            stepsize = Structure(1).scale100um;
            % for each selected field
            nfields = size(workfields, 2);
            for w = 1:nfields
                % for each array in the sources
                for s = 1:nmatrices
                    output(s).name = Structure(s).name;
                    output(s).notes = Structure(s).notes;
                    % substitute all NaNs with zeros for trapz function
                    Structure(s).(fnames{workfields(w)})(isnan(Structure(s).(fnames{workfields(w)}))) = 0;
                    % for each column
                    ncols = size(Structure(s).(fnames{workfields(w)}), 2);
                    for c = 1:ncols
                        %how many values will be calculated
                        intsteps = floor(size(Structure(s).(fnames{workfields(w)})(:,c),1)/stepsize);
                        %calculate integral
                        for step = 1:intsteps
                            
                                %display (((step-1)*stepsize))
                                %display (step*stepsize)
                                output(s).(fnames{workfields(w)})(step,c) = trapz(Structure(s).(fnames{workfields(w)})(((step-1)*stepsize+1):(step*stepsize),c));
                        end
                    end
                end
            end

        case 'smooth'
            output = removenoise_struct(Structure);
        case 'plot'
            plotstruct(Structure);
        case 'plotmatrix'
            output = plotstruct(Structure);
        case 'maxima'
            output = arrayfun(@(x) (x.name), Structure, 'UniformOutput', false);
            [output(2, :), coordinates] =  arrayfun(@(x) max(x.twelve_bit), Structure, 'UniformOutput', false);
            if max(cell2mat(coordinates))>Structure(1).scale100um*10/100
                display('CAUTION! Coordinates of maxima of at least one sample are too far away')
            end
        case 'length'
            % you need to choose what to process
            fnames = fieldnames(Structure);
            workfields = listdlg('promptString', 'Which field to process?', 'InitialValue', 2, 'OKString', 'Process!', 'SelectionMode', 'single', 'ListString', fnames);
            
            %define dimensions of output array
            nmatrices = size(Structure, 2);
            output(nmatrices).name = ' ';
            
            % for each array in the sources
            for s = 1:nmatrices
                output(s).name = Structure(s).name;
                output(s).notes = Structure(s).notes;
                output(s).(fnames{workfields(1)}) = Structure(s).(fnames{workfields(1)});
                % for each column
                ncols = size(Structure(s).(fnames{workfields(1)}), 2);
                if ncols > 1
                    error('There is more than one column, please use this method with smoothened and averaged curves')
                end

                % the counter was deliberately reset BEFORE the loop, so that there's one counter for one table
                i=1;
                % I want to find L25, L50 and L75, hence three values
                L = [0; 0; 0];
                Y = [0; 0; 0];
                for f=[3 2 1]
                    % define what target we're trying to reach
                    % NB! Here we assume that struct(1)=max(struct(:))
                    Y(f)=Structure(s).(fnames{workfields(1)})(1)*f/4;
                    % scan array until you find target
                    % NB! loop will cause error if min value>1/4                  
                    while Structure(s).(fnames{workfields(1)})(i)>Y(f)
                        i=i+1;
                    end
                    % display x=i, y=struct(i);
                    % make a line interpolation and calculate precise position
                    L(f) = (i-1) - (Structure(s).(fnames{workfields(1)})(i-1)-Y(f))/(Structure(s).(fnames{workfields(1)})(i)-Structure(s).(fnames{workfields(1)})(i-1));
                    % plot the dashed lines on top.


                end
                output(s).lengthxy(:,1)=L;
                output(s).lengthxy(:,2)=Y;

            end
            
        otherwise
            display('Method not recognised')
    end
end