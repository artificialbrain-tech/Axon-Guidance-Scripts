function Output_array = removenoise_struct(Source_array, Method, Window_Size)
% ask which smoothing method to use
if nargin<2
    MethodNames = {'Moving average',...
        'Local regression using weighted linear least squares and a 1st degree polynomial model', ...
        'A robust version of above that assigns lower weight to outliers in the regression', ...
        'Local regression using weighted linear least squares and a 2nd degree polynomial model',...
        'A robust version of above that assigns lower weight to outliers in the regression', ...
        'Savitzky-Golay filter', 'No Smoothing, average only'};
    MethodList = {'moving', 'lowess', 'rlowess', 'loess', 'rloess', 'sgolay', 'none'};
    Method = MethodList{listdlg('PromptString','Please select method for smoothing from the list:','SelectionMode','single','InitialValue',3,'Name','Smoothing Method','ListSize', [500 100],'ListString',MethodNames)};
end
% ask for a window size
if nargin<3
    if strcmp(Method, 'none')
        Window_Size = 1;
    else
        
        Window_Size = inputdlg('How many PIXELS would you like in the smoothing window?', 'Smoothing window size', 1, {num2str(Source_array(1).scale100um)});
        Window_Size = str2double(Window_Size{:});
        % old code:
        % Window_Size = 150;
        % display('Window size for smoothing = 150 by defualt!')
    end
end
[~, n] = size(Source_array);

% SAVE IMAGES?
saveim = strcmp(questdlg('Save all the plots to files?'), 'Yes');
if saveim
    if strcmp(inputname(1), 'Structure')
        dirname = inputdlg('Which folder would you like to save it to', 'Directory Name');
    else
        dirname = {inputname(1)};
    end
    savedir = strcat(dirname, '_', Method, '_', num2str(Window_Size));
    mkdir(savedir{1});
end

% DOWNSAMPLE?
dsmq = strcmp(questdlg('Downsample data for export?'), 'Yes');


% do the processing for each repeat
for i=1:n
    % 16-BIT DATA PROCESSING
    Source = Source_array(i);
    Output = struct;
    Output.name = Source.name;

    % plot raw data in a new window
    f=0;
    while ishandle(f)
        f = f+1;
    end
    figname = strcat(Source.name, ' 12 bit');
    figure(f); set(gcf, 'name', figname , 'OuterPosition', [0 768 1024 768]); hold on;
    plot(Source.twelve_bit);
    legend(num2str(Source.ROI_size'));
    % if the weights have been written in - take a
    % weighted average, otherwise take a mean
 
    if size (Source.twelve_bit, 2) == size (Source.ROI_size, 2)
        % Computes weighted average
        weights = Source.ROI_size;
        % NB! If some ROIs are shorter - then the reaminder is replaced
        % with zeros, which ARE INCLUDED in averaging using sum!!! :(
        % use truncatezeros.m to replace all the zeros at the bottom with NaNs
        % mSource = sum(bsxfun(@times,Source.twelve_bit,weights),2)/sum(weights,2);
        % use the loop below that takes into account if NaNs are there
        [rows, ~] = size(Source.twelve_bit);
        mSource = zeros(rows,1);
        for r = 1:rows
            mSource(r) = nansum(Source.twelve_bit(r,:).*weights)/nansum((~isnan(Source.twelve_bit(r,:))).*weights);
        end
    else
        mSource = nanmean(Source.twelve_bit, 2);
    end
    
    if strcmp(Method, 'none')
        dsmSource = mSource;
        x = 1:size(dsmSource,1);
    else
        % smoothing the mean
        smSource = smooth (mSource,Window_Size,Method);
        % downsample for susbequent analysis in Excel
        if dsmq
            dsmSource = downsample (smSource, Window_Size);
            x = 1:size(dsmSource,1);
            x = (x-1)*Window_Size;
        else
            dsmSource = smSource;
            x = 1:size(dsmSource,1);
        end
    end
    plot(x, dsmSource,'LineWidth',2,'Color','black');
    hold off;
    
    % save the output image
    if saveim
        saveas(gcf, [savedir{1}, '/', figname], 'png');
    end
    
    % save in a temporary output 1x1 structure
    Output.twelve_bit = dsmSource;
    
    % BINARY IMAGE DATA PROCESSING - essentially same script
    % but I couldn't be bothered to make a separate function
    figname = strcat(Source.name, ' Binary');
    
    %could potentially overvrite some existing figures, but chances are low
    if ishandle(f+1)
        clf(f+1);
    end
    figure(f+1); set(gcf, 'name', figname, 'OuterPosition', [1100 768 1024 768]); hold on;
    plot(Source.binary);
    legend(num2str(Source.binary_ROI_size'));
    if size (Source.binary, 2) == size (Source.binary_ROI_size, 2)
        weights = Source.binary_ROI_size;
        % mSource = sum(bsxfun(@times,Source.binary,weights),2)/sum(weights,2);
        [rows, ~] = size(Source.binary);
        mSource = zeros(rows,1);
        for r = 1:rows
            mSource(r) = nansum(Source.binary(r,:).*weights)/nansum((~isnan(Source.binary(r,:))).*weights);
        end
    else
        mSource = nanmean(Source.binary,2);
    end
    if strcmp(Method, 'none')
        dsmSource = mSource;
        x = 1:size(dsmSource,1);
    else
        smSource = smooth (mSource,Window_Size,Method);
        if dsmq
            dsmSource = downsample (smSource, Window_Size);
            x = 1:size(dsmSource,1);
            x = (x-1)*Window_Size;
        else
            dsmSource = smSource;
            x = 1:size(dsmSource,1);
        end
    end
    plot(x, dsmSource,'LineWidth',2,'Color','black');
    hold off;
    
    if saveim
        saveas(gcf, [savedir{1}, '/', figname], 'png');
    end
    
    Output.binary = dsmSource;
    Output.notes = Source.notes;
    Output.scale100um = Source.scale100um;
    Output_array(i) = Output;
end
end