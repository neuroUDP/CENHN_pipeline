%% CENHN Protocol for EEG data processing
% Always make sure the data are were recorded in synch
% 
% 1. Transform EEG data from propietary file to MATLAB/EEGLAB (.set|.fdt)
% and make sure you have the correct channel locations. Import them into
% the data if not. Make sure all event markers are present in the data
% otherwise import them if not. DO NOT APPLY or EXPORT ANY FILTERS!
% Filtering is very dangerous read and understand:
% Widmann, A., Schröger, E., & Maess, B. (2015). Digital filter design 
% for electrophysiological data – a practical approach. 
% Journal of Neuroscience Methods, 250, 34–46.
% 
% 2. Make sure you always work on double precision at this stage! 
% It was shown here:
% Bigdely-Shamlo, N., Mullen, T., Kothe, C., Su, K.-M., & Robbins, K. A. (2015).
% The PREP pipeline: standardized preprocessing for large-scale EEG analysis. 
% Frontiers in Neuroinformatics, 9, 16.
% 
% 3. Remove all non-experiment portions of the data and merge/concatenate 
% all data for a subject (blocks, conditions, etc.). Remove all non-data
% electrodes and sensors. DO NOT FILTER!
% 
% 4. As you probably acquired your data at 1024 Hz or 512 Hz, 
% resample the data to 500 Hz or keep 512 Hz keeping double precision. 
% DO NOT APPLY ANY FILTERS!
% 
% 5. Implement Zapline to remove line noise. DO NOT NOTCH! DO NOT FILTER!
% Zapline can be implemented with the standard parameters. If necessary and
% if you know what you are doing, modify those parameters after appropriate 
% testing. Make sure you read and understand:
% de Cheveigné, A. (2020). ZapLine: A simple and effective method to 
% remove power line artifacts. NeuroImage, 207, 116356.
% 
% 6. If you do not have the appropriate channel locations, this is your
% last chance to add them into the dataset. It is important to have EOG
% channels properly marked and separated at this point.
% 
% 7. Use the EEGLAB clean raw data plugin ONLY to detect bad channels. 
% DO NOT FILTER! DO NOT INTERPOLATE! DO NOT RE-REFERENCE!
% First re-reference to the average, excluding the EOG channels, 
% to approximate the final data while including the impact of bad channels. 
% This average reference is used only for detecting bad channels, not for 
% later analysis. We utilize the previously added reference channel or, 
% as a fallback, the Full Rank Average Reference EEGLAB plugin to preserve 
% the full rank and information of the data.
% Then, run the clean_artifacts function of the clean raw data EEGLAB
% plugin at least 10 times in order to generate RANSAC. Remember to delete 
% any micro cache or memory storing the results to force deterministic results.
% We want it to not be deterministic.
% To apply the iterations, the data is divided into five-second 
% windows, and robust interpolations for each channel are computed using 
% RANSAC sampling of the surrounding channels.
% Recommended correlation values: 0.75-0.85
% Maximum proportion of time windows a given channel may be flagged as bad 
% before it is detected as bad in the final output per iteration: 0.2-0.5
% Ignore flatlines.
% Only remove the top 1/5 of channels.
% Bigdely-Shamlo, N., Mullen, T., Kothe, C., Su, K.-M., & Robbins, K. A. (2015).
% The PREP pipeline: standardized preprocessing for large-scale EEG analysis. 
% Frontiers in Neuroinformatics, 9, 16.
% 
% 8. The detected bad channels are interpolated in the original dataset 
% (not re-referenced or filtered), using spherical spline interpolation.
% Rememeber that the rank of the data matrix is reduced by the number of 
% interpolated channels. Add this to the metadata as it will be used later.
% 
% 9. Re-reference the data to the average of all scalp channels, keep 
% excluding EOG channels.
% Delorme, A., Palmer, J., Onton, J., Oostenveld, R., & Makeig, S. (2012). 
% Independent EEG sources are dipolar. PloS One, 7(2), e30135.
% 
% 10. Create a dummy dataset and highpass it at 1.25 Hz (zero-phase Hamming 
% window FIR). Apply AMICA to the dummy dataset according to the 
% appropriate data matrix rank. Optionally use DIPFIT toolbox of EEGLAB.
% Palmer, J. A., Kreutz-delgado, K., & Makeig, S. (2011). AMICA : 
% An Adaptive Mixture of Independent Component Analyzers with 
% Shared Components. 1–15.
% Widmann, A., Schröger, E., & Maess, B. (2015). Digital filter design 
% for electrophysiological data – a practical approach. 
% Journal of Neuroscience Methods, 250, 34–46.
% 
% 11. Copy ALL AMICA outputs back to the original unfiltered dataset and
% apply a zero-phase Hamming window FIR 0.2 Hz high-pass filter
% Widmann, A., Schröger, E., & Maess, B. (2015). Digital filter design 
% for electrophysiological data – a practical approach. 
% Journal of Neuroscience Methods, 250, 34–46.
% 
% 12. Use ICLabel to automatically classify AMICA results. Check the 
% classification results. Remove the artifactual components from the data 
% and reconstruct the data without the artifactual components.
% Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019). ICLabel: An automated
% electroencephalographic independent component classifier, dataset, and website.
% NeuroImage, 198(May), 181–197.
% Mennes, M., Wouters, H., Vanrumste, B., Lagae, L., & Stiers, P. (2010). 
% Validation of ICA as a tool to remove eye movement artifacts from EEG/ERP. 
% Psychophysiology, 47(6), 1142-1150.