classdef expt_block < handle
    %  obj = expt_block()
    %
    
    properties
        
        subject_ID              = 'Z99';
        experimentID            = 'sz_sequential_simultaneous_attn';
        run_order_num           = 99;
        trials                  = []; % expt_trial.empty();                     % array for SINGLETRIAL objs
        numTrials               = 0;
        
        % INPUT:
        ITI_range               = [1.000, 1.250];
        num_trial_copies        = 10;
        
        % Factors
        block_type              = 'simultaneous';
        catch_block             = '';
        
        % Non-factors
        searchAnnulusRadius     = 200;
        
        
        save_filename           = 'test_data.txt';
        save_filedir            = 'data';
        
    end % properties
    
    
    
    
    
    methods
        
        function obj = expt_block(varargin)
            % constructor method for TRIALBLOCK obj
            %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
            
            % INPUT HANDLING:
            switch nargin
                
                % FOR DEBUGGING PURPOSES ONLY
                case 0
                    % Default settings
                    %                     obj.subject_ID                  = 'Z99';
                    %                     obj.run_order_num               = '99';
                    %                     obj.trials                      = wedgewood_trial.empty;                        %
                    %                     obj.num_trial_copies            = 1;                                            %
                    %
                    %                     obj.ITI_range                    = {1000 1400};                                  %
                    %                     obj.searchAnnulusRadius           = 200;
                    %
                    
                case 1
                    obj.block_type = varargin{1};
                    %
                    %                 case 11
                    %
                    %                     obj.subject_ID                  = varargin{1};
                    %                     obj.run_order_num               = varargin{2};
                    %                     obj.num_trial_copies            = varargin{3};                  % 1
                    %                     obj.set_size_list               = varargin{4};                  % { 4 }
                    %
                    %                     obj.target_quadrant_list        = varargin{5};
                    %                     obj.target_quadrant_distribution= varargin{6};
                    %                     obj.target_presence_list        = varargin{7};                  % { present }
                    %                     obj.targetOrientation_list     = varargin{8};                  %
                    %                     obj.distractor_orientation_list = varargin{9};                  % { left, right }
                    %
                    %                     obj.ITI_range                   = varargin{10};                 % { 1000, 1400 }
                    %                     obj.searchAnnulusRadius           = varargin{11};                 % 200
                    %
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
            
            for num_trial_copiesIndex = 1:obj.num_trial_copies
                %                 unique_ID                   = 11;                   % reset the unique trial ID number (for ERPSS event codes)
                
                % -------------------- %
                % Generate Base Trials %
                % -------------------- %
                
                
                
                % create new single trial
                obj.trials(trialNum)     = expt_trial(obj.block_type, obj.experimentID);
                trialNum                 = trialNum+1;                          % increment trial num
                
                
                %                 unique_ID                = unique_ID+1;                         % increment unique trial ID
                %                 if(mod(trialNum, 10) == 0); fprintf('%d...', trialNum); end;    % display current status
                
                
            end                 % trial multiplier loop
            
            
            obj.numTrials   = length(obj.trials);
            fprintf('...done.\n')        % end status display
            
        end % function
        
        
        
        
        
        function value = randomize(obj)
            % returns randomized trials
            %
            % NOTE:
            % Does not mutate obj itself. Need to run command:
            %
            %       exptBlockName.trials = exptBlockName.randomize();
            %
            % to do actual randomization
            
            value = Shuffle(obj.trials);
            
        end % method
        
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
        
        function testRun(obj)
            
            try
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
                
                
                
                for iTrial = 1:length(obj.trials)
                    %% to determine current trial test value, ask quest what you should test
                    questOutput = QuestQuantile(qStruct);	% Recommended by Pelli (1987)
                    luminanceContrastTested = 10.^questOutput;
                    display(luminanceContrastTested);
                    
                    stimColor = abs(seColor2RGB(bgColorWd) - luminanceContrastTested);
                    display(stimColor);
                    
                    %% execute trial
                    obj.trials(iTrial).run(iTrial, winPtr, background, fixation, stimColor);
                    
                    %% update Quest
                    display(obj.trials(iTrial).accuracy);
                    qStruct = QuestUpdate(qStruct,log10(luminanceContrastTested), ...
                        obj.trials(iTrial).accuracy(1)); %report what we did
                    
                    qStruct = QuestUpdate(qStruct,log10(luminanceContrastTested), ...
                        obj.trials(iTrial).accuracy(2)); %report what we did
                    
                    % SAVE TO FILE

                    % Save trial information to file
%                     if(currTrialNum == 1); obj.trials(iTrial).save_to_file('header'); end;             % Save header information to file before first trial
%                     obj.trials(iTrial).save_to_file(currTrialNum);                                     % Save trial information to file


                    WaitSecs(2);
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
