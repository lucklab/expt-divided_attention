classdef expt_SequentialSimultaneousAttention
    % Author:   Jason Arita
    % Version:  1
    %
    
    properties
        name                            = 'SZ-Sequential/Simultaneous Attention';
        block;                          % where all trial data is stored
        date;                           % current date (see help DATESTR)
        start_time;                     % current time
        end_time;
        
        isPractice;                     % from prompt
        subjectID;                      % from prompt
        run_num;                        % from prompt
        save_filename;                  % from prompt
        condInfo;                       % from prompt
        
        save_directory                  = 'data.raw';
        
        
        %------------------------
        % Stimulus settings
        %------------------------
        set_size_list               = { 8 };      % num of colored objects
        bgColorWd                   = 'white';    % (str)
        search_annulus_radius       = 200;        % (px) dist. from center for landalt-c's
        trialMultiplier             = 10;         % num times to repeat each trial permutation (~5 mins per set of unique trials)
        numPracticeTrials           = 25;
        target_quadrant_list        = ...
            { 'top_left'  ...
            , 'top_right' ...
            , 'btm_left'  ...
            , 'btm_right' };
        target_quadrant_distribution = ...
            { 7 ...
            , 1 ...
            , 1 ...
            , 1 };
        target_presence_list        = { 'present'   };
        target_orientation_list     = { 'up'   , 'down'    };
        distractor_orientation_list = { 'left' , 'right'   };
        
        
        %------------------------
        % Time Settings
        %------------------------
        % ~ 12 seconds max per trial
        ITI_range               = [ 1.000 1.400 ];  % (sec) min dur for inter trial interval (ITI)
        pre_trial_duration      = 0.250;            % (sec) dur to present fixation before search frame
        responseDur             = 1.500;            % (sec) dur to wait for resp
        post_response_duration  = 0.250;            % (sec) dur to wait after subj resp
        
        
        %------------------------
        % Font Settings
        %------------------------
        fontName     = 'Helvetica';  % font name for instructions
        fontSize     = 24;           % font size for all instructions
        fontColorWd  = 'black';      % fonct color for all instructions
        fontWrap     = 45;           % number of characters to wrap at
        
        
        % Timing %
        exptDuration;
        
        % Response %
        subjectHandedness;
        accResp;
        accRespNames;
        
        
        cue_instructions = 'Search for the target Landolt-C facing either gap up or gap down.\nReport whether the target was facing gap up or gap down via a button press on the gamepad.';
        
    end % properties
    
    
    properties (Constant = true)
        DEBUG = false ;
    end % constant properties
    
    
    
    methods
        
        function obj    = expt_SequentialSimultaneousAttention(varargin)
            
            
            % INPUT HANDLING:
            switch nargin
                
                case 0                                                              % Default settings
                    % -------------------------- %
                    % Prompt Experiment Run Info %
                    % -------------------------- %
                    
                    promptTitle = 'Experimental Setup Information';
                    prompt      =       ...
                        { 'Enter subject number: '      ...
                        , 'Enter Run Number: '          ...
                        , 'Practice?'                   ...
                        , 'Handedness (L-Left R-Right)' ...
                        };
                    promptNumAnsLines = 1;
                    promptDefaultAns  =   ...
                        { 'A99'  ...
                        , '99'   ...
                        , 'no'   ...
                        , 'R'    ...
                        };
                    
                    
                    options.Resize              = 'on';
                    answer                      = inputdlg(prompt, promptTitle, promptNumAnsLines, promptDefaultAns, options);
                    if(isempty(answer))
                        return;
                    else
                        obj.subjectID           = answer{1};
                        obj.run_num             = answer{2};
                        obj.isPractice          = answer{3};
                        obj.subjectHandedness   = answer{4};
                    end
                case 3
                    obj.subjectID               = varargin{1};
                    obj.run_num                 = varargin{2};
                    obj.isPractice              = varargin{3};
                    obj.subjectHandedness       = varargin{4};
                    
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            % Practice Setup
            switch lower(obj.isPractice)
                case 'yes'
                    obj.isPractice          = true;
                otherwise
                    obj.isPractice          = false;
            end
            
            
            if(obj.DEBUG)
                obj.trialMultiplier             = 1;                   % num times to repeat each trial permutation
            end
            
            %------------------------
            % Set up trials
            %------------------------
            display('Generating Trial Permutations...');
            obj.block = expt_block(); %   ...
%                 ( obj.subjectID                     ...
%                 , obj.run_num                       ...
%                 , obj.trialMultiplier               ...
%                 , obj.set_size_list                 ...
%                 , obj.target_quadrant_list          ...
%                 , obj.target_quadrant_distribution  ...
%                 , obj.target_orientation_list       ...
%                 , obj.distractor_orientation_list   ...
%                 , obj.ITI_range                     ...
%                 , obj.search_annulus_radius         ...
%                 );
%                 , obj.target_presence_list          ...
            display('Done');
            
            % -----------------------
            % Randomize Trials
            % -----------------------
            if(~obj.DEBUG); obj.block.trials = obj.block.randomize(); end                   % Don't randomize if not debugging
            
            
            % Setup Save Directory
            if(~exist(obj.save_directory, 'dir')); mkdir(obj.save_directory); end            % if save dir doesn't exist create one
            
            % Save header to output file
            if(obj.isPractice)
                obj.save_filename   = [ './' obj.save_directory '/practice_' obj.name '_' obj.subjectID '.txt'];
            else
                obj.save_filename   = [ './' obj.save_directory '/' obj.name '_' obj.subjectID '.txt'];
            end
            
        end % constructor method
        
        function obj    = run(obj)
            
            try
                obj.date        = datestr(now, 'mm/dd/yyyy');  % current date (see help DATESTR)
                obj.start_time  = datestr(now, 'HH:MM:SS AM'); % current time
                
                clc; HideCursor;
                %                 progEnv.gamepadIndex                = Gamepad('GetGamepadIndicesFromNames', 'Logitech(R) Precision(TM) Gamepad');
                [ winPtr, ~, screenCenter_pt ]      = seSetupScreen(seColor2RGB(obj.bgColorWd));  % setup screen
                
                % Response button(s) definitions
                if(upper(obj.subjectHandedness) == 'R')
                    responseButtons = [6 8];    % Right trigger button 6: Target present, Button 8: Target absent
                else
                    responseButtons = [5 7];    % Left  trigger button 5: Target present, Button 7: Target absent
                end
                gamepadObject   = seGamepad(responseButtons);   % Create a SEGAMEPAD object to collect responses
                
                background                          = stimBackground(obj.bgColorWd);                                % setup background stim
                fixation                            = stimFixationPt(screenCenter_pt);                              % setup fixation stim
                Screen('TextFont', winPtr, obj.fontName);                                       % setup text font
                Screen('TextSize', winPtr, obj.fontSize);                                       % setup text size
                
                if(obj.isPractice)
                    numTrials       = obj.numPracticeTrials;                                                       % use subset of all generated trials for practice
                else
                    numTrials       = length(obj.block.trials);                                 % use all generated trials
                end
                
                breakTrialNum   = ceil(numTrials / 3);                                          % Take a break every 1/3 of each session
                
                % --------------------
                % Execute Experiment
                % --------------------
                
                startTime    = GetSecs;                                                         % start timing experiment session
                
                % --------------------------
                % Present instructions
                % --------------------------
                background.draw(winPtr);
                DrawFormattedText(winPtr, obj.cue_instructions, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap,0,0,2);
                Screen('Flip', winPtr);                                                         % flip/draw buffer to display monitor
                KbWait;
                
                
                % Experiment start countdown
                waitTime        = 3;
                startTimestamp  = GetSecs;
                while GetSecs-startTimestamp < waitTime
                    countdown = waitTime-(round(GetSecs-startTimestamp));
                    
                    background.draw(winPtr);
                    break_text = sprintf('The experiment will start in...%d' , countdown);
                    DrawFormattedText(winPtr, break_text, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap,0,0,2);
                    Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                    
                end
                
                ITI_start_time = GetSecs;
                ITI_dur        = 0;
                
                for currTrialNum = 1:numTrials % Trial Start
                    
                    
                    %                     % -------------------------
                    %                     % Execute Single Trial
                    %                     % -------------------------
                    %                     obj.block.trials(currTrialNum).trial_order_num  = currTrialNum;  % save trial order number to data object
                    %                     stim_search                                     = obj.block.trials(currTrialNum).searchStimuli;
                    %                     %                     if(daqCard.isPresent); daqCard.resetPorts(); end
                    %
                    %                     ITI_processing_time     = (GetSecs-ITI_start_time);
                    %                     leftover_ITI_dur        = ITI_dur -ITI_processing_time;
                    %                     WaitSecs(leftover_ITI_dur);
                    %                     fprintf('Nominal ITI Duration:\t%-8.4f\tms\n'       , ITI_dur               *1000);
                    %                     fprintf('Actual  ITI Duration:\t%-8.4f\tms\n'       , (GetSecs-ITI_start_time)*1000);
                    %                     fprintf('=================================================\n');
                    %                     fprintf('Current trial Num:\t%3d / %3d\t trials\n'  , currTrialNum, numTrials);
                    %                     fprintf('\n');
                    %
                    %
                    %                     % -------------------------
                    %                     % Present: Pre-trial frame
                    %                     % -------------------------
                    %                     background.draw(winPtr);
                    %                     fixation.draw(winPtr);
                    %                     Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    %                     WaitSecs(obj.pre_trial_duration);                                       % wait:
                    %                     %                     fprintf('Pre-trial fixation dur: %1.4f\t\t ms\n' , (GetSecs-start)/1000);
                    %
                    %
                    %                     % ----------------------------------
                    %                     % Present: Search frame
                    %                     % ----------------------------------
                    %                     %                     start = GetSecs;
                    %                     background.draw(winPtr);
                    %                     fixation.draw(winPtr);
                    %                     stim_search.draw(winPtr, screenCenter_pt);
                    %                     Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    %                     %                     daqCard.sendEventCode(target_eventCode);                                % send event code
                    %                     %                     targDisplaySOA = GetSecs-start;
                    %
                    %
                    %                     % ----------------------------------
                    %                     % Subj Response
                    %                     % ----------------------------------
                    %                     %                     start = GetSecs;
                    %                     subjectResponse = gamepadObject.waitForResponse(obj.responseDur);
                    %                     if(~isnan(subjectResponse.responseTime))
                    %                         WaitSecs(obj.post_response_duration+(obj.responseDur-subjectResponse.responseTime));
                    %                     end
                    %                     %                     targetDisplayDur = GetSecs-start;
                    %
                    %                     % ------------------------------
                    %                     % Present: Post-response frame
                    %                     % ------------------------------
                    %                     ITI_start_time = GetSecs;
                    %                     background.draw(winPtr);
                    %                     Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
                    %
                    %
                    %                     % -------------------------
                    %                     % Post-Trial Processing
                    %                     % -------------------------
                    %                     obj.block.trials(currTrialNum).saveResponse(subjectResponse);              % save the response to the expt class structure
                    %                     obj.save_to_file(currTrialNum, false);
                    %                     curr_mean_accuracy  = nanmean([ obj.block.trials.accuracy  ]) * 100;        % calculate current mean accuracy
                    %                     curr_mean_RT        = nanmean([ obj.block.trials.RT ]) * 1000;              % calculate current mean response time
                    %                     ITI_dur             = obj.block.trials(currTrialNum).ITI;                   % figure out the ITI duration at the end of the trial
                    %
                    %                     fprintf('Trial Accuracy:     \t%-8.4f\t%%\n'	, obj.block.trials(currTrialNum).accuracy   * 100 );
                    %                     fprintf('Trial Response Time:\t%-8.4f\tms\n'	, obj.block.trials(currTrialNum).RT         * 1000);
                    %                     fprintf('\n');
                    %                     fprintf('Mean Accuracy:      \t%-8.4f\t%%\n'	, curr_mean_accuracy                        );
                    %                     fprintf('Mean Response Time: \t%-8.4f\tms\n'	, curr_mean_RT                              );
                    %                     fprintf('\n');
                    %                     %                     fprintf('Target Display SOA:\t %1.4f\t ms\n'          , targDisplaySOA                            * 1000);
                    %                     %                     fprintf('Target Display Duration: %1.4f\t ms\n\n'     , targetDisplayDur                          * 1000);
                    %                     fprintf('-------------------------------------------------\n');
                    
                    
                    % -------------------------
                    % subject break
                    % -------------------------
                    if((mod(currTrialNum, breakTrialNum) == 0)  ... %
                            && not(currTrialNum == numTrials)   ... % No break on last trial
                            && ~obj.isPractice)                     % No breaks during practice
                        
                        %                         background.draw(winPtr);
                        %
                        %                         break_text = sprintf('Take a break\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress button 10 button to continue', curr_mean_accuracy , curr_mean_RT);
                        %                         DrawFormattedText(winPtr, break_text, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap,0,0,2);
                        %                         Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                        %
                        
                        
                        
                        % Experiment start countdown
                        waitTime        = 10;
                        startTimestamp  = GetSecs;
                        while GetSecs-startTimestamp < waitTime
                            countdown = waitTime-(round(GetSecs-startTimestamp));
                            
                            background.draw(winPtr);
                            break_text = sprintf('Take a break\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\n\n\n\n\nThe experiment will continue in...%d', curr_mean_accuracy , curr_mean_RT, countdown);
                            DrawFormattedText(winPtr, break_text, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap,0,0,2);
                            Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                            
                        end
                    end
                    
                end % Trial End
                
                
                % -------------------------
                % Finish Expt
                % -------------------------
                
                
                
                % -------------------------
                % Present: Expt End Screen
                % -------------------------
                % display experiment information at run end
                obj.exptDuration = (GetSecs - startTime) / 60;  % (minutes)
                fprintf('Session Duration: %1.4f\t min\n\n'     , obj.exptDuration);
     
                
                if(obj.isPractice)
                    end_instructions = sprintf('Practice Finished.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress any button to continue'  ...
                        , curr_mean_accuracy    ...
                        , curr_mean_RT          ...
                        );
                else
                    end_instructions = sprintf('Run finished.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress any button to continue'  ...
                        , curr_mean_accuracy    ...
                        , curr_mean_RT          ...
                        );
                    [ exptEndSndData exptEndSndFreq ] = wavread('expt.end.wav');
                    soundsc(exptEndSndData, exptEndSndFreq);        % Play sound at expt run end
                end
                
                background.draw(winPtr);
                DrawFormattedText(winPtr, end_instructions, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap);
                Screen('Flip', winPtr);                                 % flip/draw buffer to display monitor
                
                
                
           
                
                KbWait;
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                
            catch matlabError
                Priority(0);
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlabError));
            end
            
            
            
        end % run method
        
        function save_to_file(obj, trial_num, header, separator, excelYear, decimal)
            % Writes cell array content into a *.csv file.
            %
            % CELL2CSV(obj.save_filename, cellArray, separator, excelYear, decimal)
            %
            % obj.save_filename     = Name of the file to save. [ i.e. 'text.csv' ]
            % cellArray    = Name of the Cell Array where the data is in
            % separator    = sign separating the values (default = ';')
            % excelYear    = depending on the Excel version, the cells are put into
            %                quotes before they are written to the file. The separator
            %                is set to semicolon (;)
            % decimal      = defines the decimal separator (default = '.')
            %
            %         by Sylvain Fiedler, KA, 2004
            % updated by Sylvain Fiedler, Metz, 06
            % fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
            % added the choice of decimal separator, 11/2010, S.Fiedler
            
            %% Checking for optional Variables
            if ~exist('separator', 'var')
                separator = ',';
            end
            
            if ~exist('excelYear', 'var')
                excelYear = 1997;
            end
            
            if ~exist('decimal', 'var')
                decimal = '.';
            end
            
            %% Setting separator for newer excelYears
            if excelYear > 2000
                separator = ';';
            end
            
            %% Write file
            
            datei       = fopen(obj.save_filename, 'a+'); % open/create file; append data
            var_names   = transpose(fieldnames(obj.block.trials(trial_num)));
            
            for var_name = var_names
                
                if header
                    print_value = var_name{1};
                else
                    print_value = eval(['obj.block.trials(trial_num).' var_name{1}]);
                end
                
                % If zero, then empty cell
                if size(print_value, 1) == 0
                    print_value = '';
                end
                % If numeric -> String
                if isnumeric(print_value)
                    print_value = num2str(print_value);
                    % Conversion of decimal separator (4 Europe & South America)
                    % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
                    if decimal ~= '.'
                        print_value = strrep(print_value, '.', decimal);
                    end
                end
                % If logical -> 'true' or 'false'
                if islogical(print_value)
                    if print_value == 1
                        print_value = 'TRUE';
                    else
                        print_value = 'FALSE';
                    end
                end
                % If newer version of Excel -> Quotes 4 Strings
                if excelYear > 2000
                    print_value = ['"' print_value '"']; %#ok<AGROW>
                end
                
                % OUTPUT value
                fprintf(datei, '%s', print_value);
                
                % OUTPUT separator
                %     if s ~= size(cellArray, 2)
                fprintf(datei, separator);
                %     end
                
            end
            
            fprintf(datei, '\n'); % print new line at end of every line
            
            % Closing file
            fclose(datei);
        end
        
    end % methods
    
    
end % classdef


% END
