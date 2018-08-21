function [plotarray] = plotstruct(Structure)
    % ask what field would you like to plot
    fnames = fieldnames(Structure);
    plotnum = listdlg('promptString', 'I would like to plot:', 'InitialValue', 2, 'OKString', 'Plot', 'SelectionMode', 'single', 'ListString',fnames);
    % how many plots are there
    [~, n] = size(Structure);
    % check if the lengths are there and ask if you want to plot them
    if isfield(Structure, 'lengthxy')
        plotlengths = strcmp(questdlg('Plot 75%, 50%, 25% lengths as well?'),'Yes');
    else
        plotlengths = false;
    end
    
    % define array that holds the sizes of all columns
    dims(n) = 0;
    
    % because the length of the arrays may be unequal, we need to fill in
    % all the unused parts with NaNs
    for i=1:n
        dims(i) = size(Structure(i).(fnames{plotnum}), 1);
        % if there is more than one column for whatever reason, only first one will be plotted
        if size(Structure(i).(fnames{plotnum}), 2)>1
            disp(strcat('There is more than one column, in ', Structure(i).name, ' only first column was be plotted'))
        end
    end
    
    % define array such that all the empty spaces will be filled with NaNs
    mdim = max(dims);
    plotarray = NaN (mdim, n);
    if plotlengths
        lengthx = NaN (12, n);
        lengthy = NaN (12, n);
    end
    % get all of the contents of the fields into one array
    for i=1:n
        plotarray(1:dims(i),i) = Structure(i).(fnames{plotnum})(:,1);
        
        % make new arrays with lengths to plot
        if plotlengths
            for f=[1 2 3]
                lengthx((4*f-3),i)=0;
                lengthx((4*f-2),i)=Structure(i).lengthxy(f,1);
                lengthx((4*f-1),i)=Structure(i).lengthxy(f,1);
                % lengthx((4*f),i)=NaN;
                lengthy((4*f-3),i)=Structure(i).lengthxy(f,2);
                lengthy((4*f-2),i)=Structure(i).lengthxy(f,2);
                lengthy((4*f-1),i)=0;
                % lengthy((4*f),i)=NaN;
            end
        end
    end
    
    % open a NEW figure window
    f=0;
    while ishandle(f)
        f = f+1;
    end
    
    % plot
    figure(f); set(f, 'name', fnames{plotnum}, 'OuterPosition', [1100 768 1024 768]);
    plot(plotarray);
    if plotlengths
        hold on
        plot(lengthx,lengthy, ':')
        hold off
    end
    legend(Structure(:).name);
end