function [intaverage] = axon_workflow(Input)
    % this is a temporary fundtion to speed re-analysis
    % it is supposed to get integral values at different lengths (excel
    % will then sum up these values) and these will be used for paper
    
    % truncate
    average = procstructure(Input, 'truncate');
    
    % average
    average = removenoise_struct(average, 'none');
	
	% calculate trapezoid integral over 100 um distances
    intaveragestruc = procstructure(average, 'trapz');
	
	% plot and output
    intaverage = plotstruct(intaveragestruc);
    
end