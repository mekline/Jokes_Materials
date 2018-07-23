function ISCmega(subjID, theStim)

%%% This function is for running the experiment while scanning in fMRI %%% 
%%% subjID =  subject id
%%% theStim = a prefix from stimNames (see line 13)

%%% Author: Idan Blank (based on codes by Eyal Decther, Jason Fischer)
%%% Date: 03/22/2015

%%% IPS
%- church: 185 (370 sec)
%- cloud: 199 (398 sec)
%- shapes: 145 (401 sec)
%- ice: 173 (346 sec)
%- kal: 174 (348 sec)
%- elvis: 158 (316 sec)
%- dinner: 187 (374 sec)
%- lisbon: 163 (326 sec)
%- flute: 172 (343 sec)
%- day: 138 (276 sec)

%% Initialize Variables
stimDir = '/Users/Shared/ev/ISCmega/stimuli/';       % path to where the stimuli are saved
stimNames = {'church', 'cloud', 'shapes', 'ice', 'kal', 'elvis', 'dinner', 'lisbon', 'flute', 'day'};
stimFiles = {'Mr Bean.mp4', 'partly cloudy.mp4', 'shapes animation.mp4', 'Glaciers.mp4', 'visual patterns.mp4',...
             'Elvis.wav', 'angels_in_america.mp4', 'night_in_lisbon_v2.mp3', 'Paganini Caprice No.mp3', 'dayInTheLife_Jeanne.wav'}; % a file for each name in stimNames
isVideo = [1 1 1 1 1 0 0 0 0 0];
theInd = find(strcmp(stimNames, theStim),1);
theFile = stimFiles{theInd};

%% Check that the stimulus exists %%
if ~exist([stimDir, theFile],'file')
    disp(['Warning: ', stimDir, theFile, ' is missing.'])
    return
end

%% Durations %%
pretrialFixDur = 16;  % in seconds
posttrialFixDur = 32; % in seconds

%% Other variables %%
fixationSize = 2;   % in degrees
pixPerDeg = 60;     % pixels per degree
stimFontSize = .4;  % in degrees
screenNum = 0;
escapeKey = KbName('ESCAPE');

%% generate stimulus sets %%
stimulusSet = {};

pretrial_stim = struct();
pretrial_stim.type = 'pretrial';
stimulusSet{end+1} = pretrial_stim;

if ~isVideo(theInd)
    audio_stim = struct();
    audio_stim.file = [stimDir, theFile];
    audio_stim.type = 'audio';
    stimulusSet{end+1} = audio_stim;
else
    video_stim = struct();
    video_stim.file = [stimDir, theFile];
    video_stim.type = 'video';
    stimulusSet{end+1} = video_stim;
end

padding_stim = struct();
padding_stim.type = 'padding';
stimulusSet{end+1} = padding_stim;

posttrial_stim = struct();
posttrial_stim.type = 'posttrial';
stimulusSet{end+1} = posttrial_stim;

final_stim = struct();
final_stim.type = 'end run';
stimulusSet{end+1} = final_stim;

nStimuli = length(stimulusSet);

%% Create / open a file for saving the results %%
timing = zeros(nStimuli,1); % timing of different events in the experiment
dataDir = './data';
dataFile = [dataDir, subjID, '_data.txt'];
fid = fopen(dataFile, 'a');
fprintf(fid, '%s\n', [stimFiles{theInd}, ':']);

try 
    %% Initialize Window %%
    [windowPtr,rect]=Screen('OpenWindow',screenNum);
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'SuppressAllWarnings', 1);
    movie_rect = CenterRect([0 0 530 440],rect);
    priorityLevel = MaxPriority(windowPtr); 
    Priority(priorityLevel);
    Screen('TextFont',windowPtr, 'Helvetica');
    Screen('TextSize',windowPtr, stimFontSize*pixPerDeg);

    %% Load stimulus %%
    if ~isVideo(theInd)
        [y, freq] = audioread([stimDir, theFile]);
        wavedata = y';
        nrchannels = size(wavedata,1); % Number of rows == number of channels
        audioDur = length(y)/freq;
        InitializePsychSound; % Perform basic initialization of the sound driver:
        pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);     
                    % Open the default audio device [], with default mode [] (==Only playback),
                    % and a required latencyclass of zero 0 == no low-latency mode, as well as
                    % a frequency of freq and nrchannels sound channels.
                    % This returns a handle to the audio device:
        PsychPortAudio('FillBuffer', pahandle, wavedata);
                    % Fill the audio playback buffer with the audio data 'wavedata':
    else
        movie = Screen('OpenMovie', windowPtr, [stimDir, theFile]); % Open movie file
    end

    %% Wait for trigger %%
    triggerKey = [KbName('=+'), KbName('+'), KbName('=')];  % If this doesn't work, change to '=+'
    DrawFormattedText(windowPtr, 'Waiting for trigger.', 'center', 'center', 0);
    Screen('Flip', windowPtr);
    while 1
        [keyIsDown, seconds, keyCode] = KbCheck(-3);        % -3 = check input from ALL devices
        if keyCode(escapeKey)
            Screen('CloseAll');
            fprintf('Experiment quit by pressing ESCAPE\n');
            break;
        elseif ismember(find(keyCode,1), triggerKey)        % used to be: keyCode(KbName(triggerKey))
            break
        end
    end

    %% Experiment %%
    expStartTime = GetSecs();
    tic

    current = 0;        % current event in stimulusSet
    moveToNext = 1;     % move to next event?
    checkTiming = 0;    % check how much time has passed

    while current <= nStimuli
        if moveToNext
            current = current + 1;
            switch stimulusSet{current}.type
                case 'pretrial'                
                    DrawFormattedText(windowPtr, '+', 'center', 'center', 0);
                    Screen('Flip',windowPtr);
                    eventStart = GetSecs();
                    timing(current) = eventStart;
                    moveToNext = 0;
                    timeLimit = pretrialFixDur;
                    checkTiming = 1;
                case 'audio'
                    DrawFormattedText(windowPtr, '+', 'center', 'center', 0);
                    Screen('Flip',windowPtr);
                    eventStart = PsychPortAudio('Start', pahandle, 1, 0, 1);  
                    timing(current) = eventStart;
                    timeLimit = audioDur;
                    moveToNext = 0;
                    checkTiming = 1;     
                case 'video'
                    Screen('PlayMovie', movie, 1);                       % Start playback engine
                    isFirstFrame = 1;
                    while 1 %   Playback loop
                        tex = Screen('GetMovieImage', windowPtr, movie); % Wait for next movie frame, retrieve texture handle to it
                                                                         % Valid texture returned? Negative value = end of movie reached
                        if tex<=0   % We're done, break out of loop
                            moveToNext = 1;
                            break
                        end
                        Screen('DrawTexture', windowPtr, tex,[],movie_rect); % Draw the new texture immediately to screen
                        Screen('Flip', windowPtr);
                        Screen('Close', tex); % Release texture

                        if isFirstFrame
                            eventStart = GetSecs();
                            timing(current) = eventStart;
                            isFirstFrame = 0;
                        end
                    end
                    Screen('PlayMovie', movie, 0);  % Stop playback
                    Screen('CloseMovie', movie);    % Close movie
                    moveToNext = 1;
                    checkTiming = 0;
                case 'padding'
                    criticalEnd = GetSecs();
                    timing(current) = criticalEnd;
                    criticalStart = eventStart;

                    if ~isVideo(theInd)                
                        PsychPortAudio('Stop', pahandle);
                    end

                    eventStart = criticalEnd;
                    timeLimit = 2*ceil((criticalEnd-criticalStart)/2) - (criticalEnd - criticalStart);
                                    % so that the posttrial fixation starts with a TR, assuming TR = 2 secs                                
                    moveToNext = 0;
                    checkTiming = 1;
                case 'posttrial'
                    DrawFormattedText(windowPtr, '+', 'center', 'center', 0);
                    Screen('Flip',windowPtr);
                    eventStart = GetSecs();
                    timing(current) = eventStart;
                    moveToNext = 0;
                    timeLimit = posttrialFixDur;
                    checkTiming = 1;
                case 'end run'
                    timing(current) = GetSecs();
                    fprintf('Total Run Time in Seconds: %f\n', toc);
                    Screen('CloseAll');
                    checkTiming = 0;
                    current = current+1;
            end
        end
        if checkTiming 
            if (GetSecs() - eventStart) > timeLimit
                moveToNext = 1;
            else
                WaitSecs(0.001)
            end
        end
        % If the user is pressing a key, then display its code number and name.
        if keyIsDown
            % Note that we use find(keyCode) because keyCode is an array; see 'help KbCheck'
            key_name = KbName(keyCode);
            if keyCode(escapeKey)
                Screen('CloseAll');
                if ~isVideo(theInd)
                    PsychPortAudio('Close');
                else
                    Screen('PlayMovie', movie, 0);  % Stop playback
                    Screen('CloseMovie', movie);    % Close movie
                end
                fprintf('Experiment quit by pressing ESCAPE\n');
                break
            end
        end
    end

    %% Save timing %%
    newTiming = cell(length(timing),2);
    for i = 1:length(timing)
        fprintf(fid, '%s %f\n', stimulusSet{i}.type, timing(i)-expStartTime);
        newTiming{i,1} = stimulusSet{i}.type;
        newTiming{i,2} = timing(i)-expStartTime;
    end
    fprintf(fid,'\n');
    fclose(fid);
    timing = newTiming;
    eval(['save ', subjID, '_', stimNames{theInd}, ' timing']);

    Priority(0)
catch
    ShowCursor;
    Screen('CloseAll')
end

end %main function