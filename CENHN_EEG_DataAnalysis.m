% This is the official CENHN pipeline for data processing 
% To begin: 
% 1. make a copy of CENHN_EEG_config.m, CENHN_EEG_DataAnalysis.m and
% CENHN_EEG_processing.m and put those copies in your main project folder.
% The name of these copies should start woth your project name. DO NOT
% OVERWRITE THE CENHN_EEG TEMPLATES.
% 2. in the main project folder, create a folder called "1_rawEEG" and put
% your raw data there. This can be a copy as well as your raw data should
% be located in googledrive/DATA/PROJECTNAME for safety reasons. You could
% also read the raw directly from GoogleDrive using the WebData variable.
% Use as you think is better/easier/faster. Both approaches have prons and
% cons.
% 3. Fill up the first 17 lines of YOURPROJECT_config accordingly. Only modify the rest
% of YOURPROJECT_config if you know what you are doing.
% 4. Modify lines 29-33 in YOURPROJECT_DataAnalysis accordingly to turn on 
% and off the things you want to work on. For the reLoad, doASR, and
% doEPOCH options you need to make sure the paths are all correct.
% 5. In YOURPROJECT_EEG_processing there should be nothing to change.
% 6. Run YOURPROJECT_DataAnalysis from the command line
%  make sure to have EEGLAB in your computer with AMICA, ANT, 
% FIELDTRIP-motion2bids, and XDF plugins
clear CENHN_config
clear all
close all hidden
close all force
clc
CENHN_EEG_config
%% Modify as needed
FJPlap=0; %this is for FJP laptop change accordingly or delete
reLoad=0;
doProcess=0;
doASR=0;
doEpoch=0;
%add other processes as needed/necessary/pertinent
%% start EEGLAB
eeglab;close all;
% % if you need to force MATLAB to open all MEX files
% % in the terminal, type
% sudo xattr -r -d com.apple.quarantine '/Users/fjparada/Documents/MATLAB/eeglab2022.1 2'
% change for your EEGLAB version
%% Converto to .SET
if reLoad
    %% User-Defined:
    root='';
    webData='';
    dataRoot=[root filesep ''];
    chanName='ANT32.loc'; %make sure this is what you want
    rawFileExtension='cnt'; %change accordingly
    %% change things only if you know what you are doing. At your own risk
    if FJPlap==1
        EEGLABRoot=[root filesep 'eeglab_updated'];
    else
        EEGLABRoot=[root filesep 'eeglab'];
    end
    rawDataFolder=webData;
    targetFolder=[dataRoot,filesep,'2_raw-EEGLAB'];
    if ~exist("targetFolder")
        mkdir(targetFolder);
    end
    SCRIPTSroot=dataRoot;
    addpath(EEGLABRoot);
    eeglab;close all;
    fprintf('adding MATLAB paths and creating configuration structure...');
    tmp=dir(fullfile(rawDataFolder));
    participants=[];
    inx=1;
    for pId=1:size(tmp,1)
        if tmp(pId).name(1)=='.'
            continue
        else
            participants(inx).name=tmp(pId).name;
            participants(inx).folder=tmp(pId).folder;
            participants(inx).date=tmp(pId).date;
            inx=inx+1;
        end
    end
    folderName=participants(1).folder;
    files2load=dir(fullfile(folderName,filesep,'*.',rawFileExtension));
    for fIx=1:size(files2load,1)
        [EEGOUT, command]=pop_loadeep_v4([files2load(fIx).folder,filesep,files2load(fIx).name]);
        EEGOUT.setname=files2load(fIx).name;
        EEGOUT.filepath=files2load(fIx).folder;
        % hardcoded for ANT 32+ECG change accordingly
        EEGOUT.ECG=EEGOUT.data(33,:);
        EEGOUT=pop_select(EEGOUT,'channel',{'Fp1','Fpz','Fp2','F7','F3',...
            'Fz','F4','F8','FC5','FC1','FC2','FC6','M1','T7','C3','Cz',...
            'C4','T8','M2','CP5','CP1','CP2','CP6','P7','P3','Pz','P4',...
            'P8','POz','O1','Oz','O2'});
        EEGOUT=pop_chanedit(EEGOUT,'load',{[dataRoot,filesep,chanName],'filetype','autodetect'});
        START=[];
        %         we usually program with 98 and 99 to mark the beginning and
        %         ending of the recording. Change accordingly
        for ix=1:2
            tgEv={'0, 98' '0, 99'};
            for i=1:size(EEGOUT.event,2)
                try
                    thisEv=EEGOUT.event(i).type(1:5);
                    thisOne=strcmp(tgEv{ix},thisEv);
                    if thisOne==1
                        START(ix)=i;
                    end
                catch ME
                    thisEv=EEGOUT.event(i).type(1:size(EEGOUT.event(i).type,2))
                    if thisEv=='0000'
                        fprintf('Participant %s, data file %d may be corrupted. Skipping...\n',...
                            files2load(fIx).name,fIx)
                        START=[];
                        break
                    end
                end
            end
            try
                if isempty(START)
                    tgEv={'3001, 98' '3001, 99'};
                    for i=1:size(EEGOUT.event,2)
                        thisEv=EEGOUT.event(i).type(1:8);
                        thisOne=strcmp(tgEv{ix},thisEv);
                        if thisOne==1
                            START(ix)=i;
                            break
                        end
                    end
                elseif size(START,2)==1
                    tgEv={'3001, 98' '3001, 99'};
                    for i=1:size(EEGOUT.event,2)
                        thisEv=EEGOUT.event(i).type(1:8);
                        thisOne=strcmp(tgEv{ix},thisEv);
                        if thisOne==1
                            START(ix)=i;
                        end
                    end
                end
            catch ME
                if thisEv=='0000'
                    fprintf('Participant %s, data file %d may be corrupted. Skipping...\n',...
                        files2load(fIx).name,fIx)
                    START=[];
                    break
                end
            end
        end
        if isempty(START)
            fprintf('Participant %s, data file %d may be corrupted. Skipping...\n',...
                files2load(fIx).name,fIx)
            continue
        elseif size(START,2)==1
            EEGOUT=pop_select(EEGOUT,'point',...
                [EEGOUT.event(START(1)).latency:EEGOUT.event(START(1)).latency+constantTask]);
            % ADD CHANNEL FIX HERE IF NECESSARY!!
            EEGOUT=pop_saveset(EEGOUT,'filename',files2load(fIx).name,'filepath',targetFolder);
        else
            EEGOUT=pop_select(EEGOUT,'point',...
                [EEGOUT.event(START(1)).latency:EEGOUT.event(START(2)).latency]);
            % ADD CHANNEL FIX HERE IF NECESSARY!!
            EEGOUT=pop_saveset(EEGOUT,'filename',files2load(fIx).name,'filepath',targetFolder);
        end
    end
end
%% Run cleaning procedures
if doProcess
    CENHN_EEG_processing;
end
% still can't decide if ASR should be before or after AMICA. It's an
% empirical question
doASR=0;
doEpoch=0;
%% Run ASR
if doASR
    root='';
    dataRoot=[root filesep ''];
    dataFolder=[dataRoot,filesep,'5_single-subject-EEG-analysis'];
    participants=[];
    tmp=dir(fullfile(dataFolder));
    inx=1;
    for pId=1:size(tmp,1)
        if tmp(pId).name(1)=='.'
            continue
        else
            participants(inx).name=tmp(pId).name;
            participants(inx).folder=tmp(pId).folder;
            participants(inx).date=tmp(pId).date;
            inx=inx+1;
        end
    end
    for pIx=1:size(participants,2)
        if participants(pIx).name(1)~='D'
            continue
        end
        folderName=[participants(pIx).folder,filesep,participants(pIx).name];
        files2load=dir(fullfile(folderName,filesep,'*_cleaned_with_ICA.set'));
        for fIx=1:size(files2load,1)
            EEGOUT=pop_loadset([files2load(fIx).folder,filesep,files2load(fIx).name]);
            EEGOUT=pop_clean_rawdata(EEGOUT,'FlatlineCriterion','off','ChannelCriterion','off',...
                'LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,...
                'WindowCriterion',0.25,'BurstRejection','off','Distance','Euclidian',...
                'WindowCriterionTolerances',[-Inf 7]);
            if ~exist([dataRoot,filesep,'6_ICA+ASR']);mkdir([dataRoot,filesep,'6_ICA+ASR']);end
            EEGOUT=pop_saveset(EEGOUT,'filename',[files2load(1).name(1:end-20),'ICA_ASR'],'filepath',[dataRoot,filesep,'6_ICA+ASR']);
        end
    end
end
%% Epoch
if doEpoch
    % USER DEFINED:
    epochLength=[-1 1]; 
    condNames={'Cond1','Cond2'};    
    theseCodes={'3001 , 16' '3001 , 01'};
    if FJPlap
        root='/Users/fjparada/Library/CloudStorage/GoogleDrive-francisco.parada@mail.udp.cl/Other computers/My Mac Pro/EEG_UDD';
    else
        root='';
    end    
    dataRoot=[root filesep ''];
    saveFolder=[dataRoot,filesep,''];
    dataFolder=[dataRoot,filesep,'5_single-subject-EEG-analysis'];    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if ~exist(saveFolder);mkdir(saveFolder);end
    fileExt='_cleaned_with_ICA.set';
    participants=[];
    tmp=dir(fullfile(dataFolder));
    inx=1;
    for pId=1:size(tmp,1)
        if tmp(pId).name(1)=='.'
            continue
        else
            participants(inx).name=tmp(pId).name;
            participants(inx).folder=tmp(pId).folder;
            participants(inx).date=tmp(pId).date;
            inx=inx+1;
        end
    end
    for pIx=1:size(participants,2)
        if participants(pIx).name(1)~='D'
            continue
        else
            thisFile=[dataFolder,filesep,participants(pIx).name,filesep,participants(pIx).name,fileExt];
            for cIdx=1:size(condNames,1)
                try
                    saveName=[participants(pIx).name(1:12),'_',condNames{cIdx},'.set'];
                catch ME
                    saveName=[participants(pIx).name(1:end),'_',condNames{cIdx},'.set'];
                end
                if ~exist([dataFolder,filesep,participants(pIx).name,filesep,participants(pIx).name,fileExt])
                    tmp=dir(fullfile([dataFolder,filesep,participants(pIx).name],'*.set'));
                    tmpName=tmp(1).name;
                    thisFile=[dataFolder,filesep,participants(pIx).name,filesep,tmpName];
                    EEG=pop_loadset(thisFile);
                    try
                        EEG=pop_epoch(EEG,theseCodes{cIdx},...
                            epochLength,'newname',saveName,'epochinfo','yes');
                    catch ME
                        EEG=pop_epoch(EEG,theseCodes2{cIdx},...
                            epochLength,'newname',saveName,'epochinfo','yes');
                    end
                else
                    thisFile=[dataFolder,filesep,participants(pIx).name,filesep,participants(pIx).name,fileExt];
                    EEG=pop_loadset(thisFile);
                    try
                        EEG=pop_epoch(EEG,theseCodes{cIdx},...
                            epochLength,'newname',saveName,'epochinfo','yes');
                    catch ME
                        EEG=pop_epoch(EEG,theseCodes2{cIdx},...
                            epochLength,'newname',saveName,'epochinfo','yes');
                    end
                    if ndims(EEG.data)==2
                        continue
                    else
                        try
                            EEG=pop_rmbase(EEG,[-150 0],[]);
                            EEG=pop_eegfiltnew(EEG,'locutoff',1,'hicutoff',35,'plotfreqz',0);
                            EEG=pop_saveset(EEG,'filename',saveName,'filepath',saveFolder);
                        catch ME
                        end
                    end
                end
            end
        end
    end
end