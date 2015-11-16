classdef expt_block < handle
    %  obj = expt_block()
    %
    
    properties
        
        subj_id                 = 'Z99';
        expt_id                 = 'scz_seq_sim_divided_attn';
        date                    = '';
        start_time              = '';
        run_order_num           = 99;
        trials                  = []; % expt_trial.empty();                     % array for SINGLETRIAL objs
        numTrials               = 0;
        
        % INPUT:
        ITI_range               = [1.000, 1.250];
        num_trial_copies        = 200;
        num_catch_trial_copies  = 50;   % ~3 mins per 50 trials
        
        % Factors
        block_type              = '';
        catch_type              = ''; % 'catch'
        
        % Non-factors
        catch_luminance_contrast = 100;
                
    end % properties
    
    
    
    
    
    methods
        
        function obj = expt_block(varargin)
            % constructor method for TRIALBLOCK obj
            %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
            
            % INPUT HANDLING:
            switch nargin
                
                case 0
                    
                    
                case 4
                    obj.expt_id    = varargin{1};
                    obj.subj_id    = varargin{2};
                    obj.block_type = varargin{3};
                    obj.catch_type = varargin{4};
                  
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            
            % --------------------------------------------------------- %
            % NOTE:                                                     %
            %   if trial multiplier is zero (default) then doesn't      %
            %   generate a trial array                                  %
            % --------------------------------------------------------- %
            obj.trials   = expt_trial.empty();          % cell array for SINGLETRIAL objs
            trialNum     = 1;                    % reset trial count
            
            
            if strcmpi(obj.catch_type, 'catch')
                num_trials_per_block = obj.num_catch_trial_copies;
            else
                num_trials_per_block = obj.num_trial_copies;
            end
            
            for num_trial_copiesIndex = 1:num_trials_per_block
                
                % -------------------- %
                % Generate Base Trials %
                % -------------------- %                
                
                % create new single trial
                obj.trials(trialNum)     = expt_trial(...
                    obj.block_type,   ...
                    obj.catch_type,   ...
                    obj.expt_id,      ...
                    obj.subj_id);
                trialNum                 = trialNum+1;                          % increment trial num
                
            end                 % trial multiplier loop
            
            obj.trials      = Shuffle(obj.trials);
            obj.numTrials   = length(obj.trials);
            fprintf('...done.\n')        % end status display
            
        end % function
        
        
        function displayTrials(obj, varargin)
            
            switch nargin
                case 1
                    saveFilename_wd = false;
                case 2
                    saveFilename_wd = varargin{1};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            for trialIndex = 1:length(obj.trials)
                
                if(saveFilename_wd)
                    obj.trials(trialIndex).displayTrial(saveFilename_wd);
                else
                    obj.trials(trialIndex).displayTrial();
                end
                
            end % trial loop
            
        end % function
        
        function run(obj)
            
            try
                obj.date        = datestr(now, 'mm/dd/yyyy');  % current date (see help DATESTR)
                obj.start_time  = datestr(now, 'HH:MM:SS AM'); % current time

                
                %% Setup QUEST
                tGuess      = log10(12);    % log of estimated threshold -  time for peripheral accuracy
                tGuessSd    = log10(3);     % standard deviation
                pThreshold  = 0.75;         % performance will converage at this
                beta        = 3.5;          % steepness of the Weibull function, typically 3
                delta       = 0.01;         % fraction of trials observer presses blindly
                gamma       = 0.5;          % fraction of trials generate response 1 when intensity = -inf
                %grain = 0.01;
                %range = 5; % tGuess+(-range/2:grain:range/2)
                
                qStruct = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma); %range and grain default
                
                
                %% Setup trial                
                clc; HideCursor;
                bgColorWd = 'black';
                [ winPtr, ~, screenCenter_pt ]      = seSetupScreen(seColor2RGB(bgColorWd));  % setup screen
                background                          = stimBackground(bgColorWd);                                % setup background stim
                fixation                            = stimFixationPt(screenCenter_pt);                              % setup fixation stim
                
                % Font
                fontName     = 'Monaco';  % font name for instructions
                fontSize     = 50;           % font size for all instructions
                %                 fontColorWd  = 'black';      % fonct color for all instructions
                %                 fontWrap     = 45;           % number of characters to wrap at
                Screen('TextFont', winPtr, fontName);                                       % setup text font
                Screen('TextSize', winPtr, fontSize);                                       % setup text size
                
                
                
                % Block start countdown
                waitTime        = 3;
                startTimestamp  = GetSecs;
                while GetSecs-startTimestamp < waitTime
                    countdown = waitTime-(round(GetSecs-startTimestamp));
                    
                    background.draw(winPtr);
                    break_text = sprintf('The experiment will start in...%d' , countdown);
                    DrawFormattedText(winPtr, break_text, 'center', 'center',seColor2RGB('white'),45,0,0,2);
                    Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                    
                end
                
                
                
                
                for iTrial = 1:length(obj.trials)
                    %% to determine current trial test value, ask quest what you should test
                    
                    if strcmpi(obj.catch_type, 'no_catch')
                        % Update luminance contrast value
                        questOutput = QuestQuantile(qStruct);	% Recommended by Pelli (1987)
                        luminanceContrastTested = 10.^questOutput;
                    else
                        % Do not update luminance contrast
                        luminanceContrastTested = obj.catch_luminance_contrast;
                    end
                    
                    stimColor = abs(seColor2RGB(bgColorWd) - luminanceContrastTested);
                    
                    %% execute trial
                    obj.trials(iTrial).run(iTrial, winPtr, background, fixation, stimColor);                    
                    
                    if strcmpi(obj.catch_type, 'no_catch')
                        %% update Quest based on each accuracy of each response
                        qStruct = QuestUpdate(qStruct,log10(luminanceContrastTested), ...
                            obj.trials(iTrial).response01_acc); 
                        qStruct = QuestUpdate(qStruct,log10(luminanceContrastTested), ...
                            obj.trials(iTrial).response02_acc); 
                    end
                                   

                end
                
                
                % Experiment start countdown
                waitTime        = 10;
                startTimestamp  = GetSecs;
                while GetSecs-startTimestamp < waitTime
                    countdown = waitTime-(round(GetSecs-startTimestamp));
                    
                    background.draw(winPtr);
                    break_text = sprintf('Take a break\n\nThe experiment will continue in...%d', countdown);
                    DrawFormattedText(winPtr, break_text, 'center', 'center',seColor2RGB('white'),45,0,0,2);
                    Screen('Flip', winPtr);            			% flip/draw buffer to display monitor
                    
                end
                
                
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                
            catch err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                rethrow(err);
            end
            
            
        end % function
        
    end % methods
    
    
end % class def
