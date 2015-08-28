classdef ExptBlock_StaircasedDividedAttention < handle
    %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
    %
    % gonna need:
    %     exptVars.cue2targDur;
    %     exptVars.possibleColors
    %     orientationList {'up', 'down'}
    %     exptVars.validPercent
    %     exptVars.num_trial_copies
    
    
    properties
        
        subject_ID              = 'Z99';
        run_order_num           = 99;
        trials                  = []; % ExptTrial_ExptStaircasedDividedAttention.empty();                     % array for SINGLETRIAL objs
        numTrials               = 0;
        
        % INPUT:
        ITI_range               = [1.000, 1.250];
        num_trial_copies        = 10;
        
        % Factors
        block_type              = 'sequential'; % 'simultaneous'
        
        
        % Non-factors
        searchAnnulusRadius     = 200;
        
        
    end % properties
    
    
    
    
    
    methods
        
        function obj = ExptBlock_StaircasedDividedAttention(varargin)
            % constructor method for TRIALBLOCK obj
            %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
            
            % INPUT HANDLING:
            switch nargin
                
                % FOR DEBUGGING PURPOSES ONLY
                case 0                                                              % Default settings
                    %                     obj.subject_ID                  = 'Z99';
                    %                     obj.run_order_num               = '99';
                    %                     obj.trials                      = wedgewood_trial.empty;                        %
                    %                     obj.num_trial_copies            = 1;                                            %
                    %
                    %                     obj.ITI_range                    = {1000 1400};                                  %
                    %                     obj.searchAnnulusRadius           = 200;
                    %
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
            obj.trials   = ExptTrial_StaircasedDividedAttention.empty();          % cell array for SINGLETRIAL objs
            trialNum     = 1;                    % reset trial count
            
            for num_trial_copiesIndex = 1:obj.num_trial_copies
%                 unique_ID                   = 11;                   % reset the unique trial ID number (for ERPSS event codes)
                
                % -------------------- %
                % Generate Base Trials %
                % -------------------- %
                
                
                
                % create new single trial
                obj.trials(trialNum)     = ExptTrial_StaircasedDividedAttention();
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
                
                bgColorWd = 'white';
                clc; HideCursor;
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
                
                    obj.trials(iTrial).run(winPtr, background, fixation, iTrial*0.2);
                
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
