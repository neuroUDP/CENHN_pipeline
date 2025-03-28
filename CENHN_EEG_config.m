clear CENHN_config
clear all;close all;clc;
% if you always want to re-compute everything = 1
forceRecompute=0;
% if you want to manually supervise the bot output = 1
human_supervision=0;
% make sure this is the one you want
chanLocsName='ANT32_BIP.ced';
% set up your paths
root='';
pluginRoot='';
dataRoot=root;
eeglabPath=[pluginRoot filesep 'eeglab_updated'];
eeglabPath=[pluginRoot filesep 'eeglab'];
addpath(genpath([eeglabPath filesep 'plugins' filesep 'fieldtrip-motion2bids']));
addpath(genpath([eeglabPath filesep 'plugins' filesep 'xdfimport1.18']));
addpath(eeglabPath);
%% defaults DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING
% Make sure you want the value in line 63
% Make sure you add channels to remove IF ANY in line 43
% Make sure you add EOG channels IF ANY in line 44
% Make sure you add REF channels IF ANY in line 45
chanlocsFolder=[root,filesep,chanLocsName];
CENHN_config.study_folder=dataRoot;
CENHN_config.EOGchanLoc=chanlocsFolder;
CENHN_config.filename_prefix=[];
CENHN_config.source_data_folder=['2_raw-EEGLAB' filesep];
CENHN_config.raw_EEG_data_folder=['2_raw-EEGLAB' filesep];
CENHN_config.EEG_preprocessing_data_folder=['3_EEG-preprocessing' filesep];
CENHN_config.spatial_filters_folder=['4_spatial-filters' filesep];
CENHN_config.spatial_filters_folder_AMICA=['4-1_AMICA' filesep];
CENHN_config.single_subject_analysis_folder=['5_single-subject-EEG-analysis' filesep];
CENHN_config.motion_analysis_folder=['6_single-subject-motion-analysis' filesep];
CENHN_config.final_analysis_folder=['7_CRD-analysis' filesep];
CENHN_config.merged_filename='merged_EEG.set';
CENHN_config.basic_prepared_filename='basic_prepared.set';
CENHN_config.preprocessed_filename='preprocessed.set';
CENHN_config.filtered_filename='filtered.set';
CENHN_config.amica_filename_output='AMICA.set';
CENHN_config.dipfitted_filename='dipfitted.set';
CENHN_config.preprocessed_and_ICA_filename='preprocessed_and_ICA.set';
CENHN_config.single_subject_cleaned_ICA_filename='cleaned_with_ICA.set';
CENHN_config.channels_to_remove=[];
CENHN_config.eog_channels={};
CENHN_config.ref_channel=[];
CENHN_config.rename_channels={};
CENHN_config.resample_freq=500;
CENHN_config.chancorr_crit=0.8;
CENHN_config.chan_max_broken_time=0.3;
CENHN_config.chan_detect_num_iter=20;
CENHN_config.chan_detected_fraction_threshold=0.5;
CENHN_config.flatline_crit='on';
CENHN_config.line_noise_crit='on';
CENHN_config.num_chan_rej_max_target=1/5;
CENHN_config.channel_locations_filepath=root;
CENHN_config.channel_locations_filename=chanLocsName;
CENHN_config.zaplineConfig.noisefreqs=[];
CENHN_config.filter_lowCutoffFreqAMICA=1.75; % 1.75 is 1.5Hz cutoff!
CENHN_config.filter_AMICA_highPassOrder=1650; % was used by Klug & Gramann (2020)
CENHN_config.filter_highCutoffFreqAMICA=[]; % not used
CENHN_config.filter_AMICA_lowPassOrder=[];
CENHN_config.num_models=1; % default 1
CENHN_config.AMICA_autoreject=1; % uses automatic rejection method of AMICA. no time-cleaning (manual or automatic) is needed then!
CENHN_config.AMICA_n_rej=10; % default 10
CENHN_config.AMICA_reject_sigma_threshold=3; % default 3
CENHN_config.AMICA_max_iter=2000; % default 2000
CENHN_config.max_threads=6; % default 4. Use wisely depending on your machine
CENHN_config.warping_channel_names=[];
CENHN_config.residualVariance_threshold=100;
CENHN_config.do_remove_outside_head='off';
CENHN_config.number_of_dipoles=1;
CENHN_config.iclabel_classifier='lite';
CENHN_config.iclabel_classes=1;
CENHN_config.iclabel_threshold=-1;
CENHN_config.final_filter_lower_edge=0.2; % this should not lead to any issues downstream but remove all very slow drifts
CENHN_config.final_filter_higher_edge=[];
CENHN_config.lowpass_motion=8;
CENHN_config.lowpass_motion_after_derivative=24;
try
    pop_editoptions('option_saveversion6', 0, 'option_single', 0, ...
        'option_memmapdata', 0, 'option_savetwofiles', 1, 'option_storedisk', 0);
catch
    warning('Could NOT edit EEGLAB memory options!!');
end