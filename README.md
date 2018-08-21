# Axon Guidance Scripts

## Introduction
This project accompanies the paper entitled "Proteolytically released Lasso/teneurin-2 induces axonal attraction by interacting with latrophilin-1 on axonal growth cones" (to appear in eLife).

Collection of MATLAB scripts for automation of processing of the data from ICC analysis of axons/dendrites in microfluidic devices. 

Tested on versions 2013 to 2015 (on Mac OS Yosemite), but designed to be platform and version independent.

Authors

      Nickolai Vysokov, King's College London

License

This project is licensed under the GNU GPL License - see the LICENSE.md file for details.

## Usage
Refer to the paper (link to follow) for the method of microfluidic axon isolation, formation of axonal attractant/repellant gradient, immunocytochemistry and image acquisition for getting the raw images. Use ImageJ/FIJI to rotate the stitched images, to subtract background and to select rectangular ROIs for getting a profile of mean fluorescence against distance from the separation wall. These can then be pasted into MATLAB (see "Structured data" section below) and processed using the functions in this repository.

### Structured data
The structured data for each experiment consists of 7 fields:
Field 1 ('name', string): name of the condition within the experiment
Field 2 ('twelve_bit', numerical array): raw data pasted from ImageJ, one column for each ROI
Field 3 ('ROI_size', integer array): size of the respective ROIs in the corresponding column in field 2. Used for weighted averaging.
Field 4 ('binary', numerical array): deprecated, used on binarised images in earlier analysis
Field 5 ('binary\_ROI\_size', integer array): deprecated, used on binarised images in earlier analysis
Field 6 ('notes', string): any special remarks for the experiment
Field 7 ('scale100um', integer): how many pixels are there in 100 um (used for caculating distance)

### Axon workflow
This would take in the structured data and call all the necessary functions to produce an output that could be pasted into Excel directly.

### Process structure
The "procstructure.m" function is the main function that takes in structured data and either processes it within the function or calls other functions. The internal processes include background subtraction (not necessary, as this was done in Excel), and calculation of trapezoid integrals. Other functions deprecated and irrelevant for the paper include finding the maxima for each field in the structure and reading off the curve at which distance away from the channel the fluorescence drops to 75%, 50% and 25% of maximum.

### Truncate
Matlab only works with arrays of a fixed length, so it fills in empty cells with zeros and these need to be truncated so as not to mess up the averages.

### Remove noise
Calculates a weighted average of all the ROIs. It can downsample or smooth data if required (neither was used in the Axon Workflow). Then it would plot the original data and the output data for verification and save the plots.

### Plot structure
Because MATLAB cannot just simply choose an array in the structure to plot, this has to be a separate function with a dialogue. On the positive side, the plots are labelled with respective condition names. This would also output the matrix where the corder of the columns corresponds to the order of the condition names. The output matrix can then be pasted into Excel.





