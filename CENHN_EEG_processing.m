close all hidden
close all force
CENHN_EEG_config
subjects=[];
%% processing loop - Change things only if you know what you are doing
if ~exist('ALLCOM','var')
    eeglab;close all;
end
setInFolder=dir(fullfile([CENHN_config.study_folder ...
    filesep CENHN_config.raw_EEG_data_folder],'*.set'));
if isempty(subjects)
    subjects=1:size(setInFolder,1);
end
for subject=subjects
    fprintf('Subject #%d\n',subject)
    STUDY=[];CURRENTSTUDY=0;ALLEEG=[];CURRENTSET=[];EEG=[];
    EEG_interp_avref=[];EEG_single_subject_final=[];
    input_filepath=[setInFolder(subject).folder];
    output_filepath=[CENHN_config.study_folder filesep...
        CENHN_config.single_subject_analysis_folder ...
        setInFolder(subject).name(1:end-4)];
    if forceRecompute
        try
            % load completely processed file
            EEG_single_subject_final=pop_loadset('filename',...
                [CENHN_config.filename_prefix num2str(subject)...
                '_' erase(CENHN_config.preprocessed_and_ICA_filename,...
                '.set') '_filtered.set'], 'filepath', output_filepath);
            EEG=pop_chanedit(EEG, 'load',...
                {CENHN_config.EOGchanLoc,'filetype','autodetect'});
        catch
            disp('...failed. Computing now.')
        end
        if ~forceRecompute && exist('EEG_single_subject_final','var') && ~isempty(EEG_single_subject_final)
            clear EEG_single_subject_final
            disp('Subject is completely preprocessed already.')
            continue
        end
    end
    try
        pop_editoptions( 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0);
    catch
        warning('Could NOT edit EEGLAB memory options!!');
    end
    EEG=pop_loadset('filename',setInFolder(subject).name,'filepath',input_filepath);
    EEG.subject=setInFolder(subject).name(1:end-7);
    EEG.condition=setInFolder(subject).name(8:end-4);
    % here if you are paranoid about channel locs
    %     EEG=pop_chanedit(EEG,'load',{'FONDECYT_ROSSI/ANT32.loc','filetype','autodetect'});
    CENHN_config.outname=setInFolder(subject).name(1:end-4);
    [ALLEEG, EEG_preprocessed, CURRENTSET] = bemobil_process_all_EEG_preprocessing(...
        subject, CENHN_config, ALLEEG, EEG, CURRENTSET, forceRecompute);
    addpath([eeglabPath,filesep,'plugins',filesep,'fieldtrip-motion2bids'])
    bemobil_process_all_AMICA(ALLEEG, EEG_preprocessed, CURRENTSET, ...
        subject, CENHN_config, forceRecompute, human_supervision);

end
subjects
subject
try
    bemobil_copy_plots_in_one(CENHN_config)
catch ME
end