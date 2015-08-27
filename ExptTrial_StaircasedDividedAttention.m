classdef ExptTrial_StaircasedDividedAttention < handle
    %
    % Experimentor Defined Variables:
    %
    
    properties
        
        % Experimentor Defined Variables
        subject_ID          = 'Z99';
        trial_order_num     = 99;
        trial_type          = 'simultaneous';
        %         run_order_num       = 1;
        %         setSize             = 8;
        %         targetPresence      = 'present';
        %         targetLocation      = 3;
        %         targetOrientation   = 'down';
        %         objectColor         = 'magenta';
        ITI;
        
        accuracy            = NaN;            % subject's single trial accuracy {1 == correct || 0 == incorrect}
        resp_keycode        = 'noResponse';   % response gamepad key number
        RT;                                   % subject's single trial response time
        
    end % properties
    
    
    
    properties (Hidden = true)
        event_code;
        searchStimuli;                    % Search stimulus to draw
        
        search_annulus_radius   = 200;
        ITI_range               = [.250 .500];
        
        responseKeyMap;
        
    end
    
    %     events
    %         calculateAccuracy
    %     end
    
    methods
        
        function obj   = visualSearch_statLearning_trial(varargin)
            
            switch nargin
                case 0
                    
                    
                case 9
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.event_code                  = varargin{3};
                    obj.setSize                     = varargin{4};
                    obj.targetPresence              = varargin{5};
                    obj.targetLocation              = varargin{6};
                    obj.targetOrientation           = varargin{7};
                    obj.ITI_range                   = varargin{8};
                    obj.search_annulus_radius       = varargin{9};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.searchStimuli                 = stimLandoltCArray.empty;
            
            
            %% Randomly calculate inter-trial interval
            %  based min & max ITI-range
            obj.ITI  = min(obj.ITI_range)  ...
                + (rand * (max(obj.ITI_range)-min(obj.ITI_range)));
            
            %% Set up stimulus objects
            
            %             obj.searchStimuli = stimLandoltCArray(obj.setSize, obj.search_annulus_radius, obj.targetLocation, obj.targetOrientation, obj.objectColor); % , -7*pi/obj.setSize);
            
            %% Set up response key mapping
            
            %             obj.responseKeyMap      = cell(10,1);
            %             obj.responseKeyMap{6}   = 'up';
            %             obj.responseKeyMap{8}   = 'down';
            %
            %             obj.responseKeyMap = containers.Map(    ...
            %                 { 5     , 6    , 7     , 8      } , ...  %% Keys - for both left and right handed responses
            %                 { 'up'  , 'up' , 'down', 'down' } );     %% Values
            %
            
            
            
        end % constructor method
        
        
        function run(obj, winPtr, background, fixation)
            % -------------------------
            % Execute Single Trial
            % -------------------------
            %             obj.block.trials(currTrialNum).trial_order_num  = currTrialNum;  % save trial order number to data object
            %             stim_search                                     = obj.block.trials(currTrialNum).searchStimuli;
            %                     if(daqCard.isPresent); daqCard.resetPorts(); end
            %
            %             ITI_processing_time     = (GetSecs-ITI_start_time);
            %             leftover_ITI_dur        = ITI_dur -ITI_processing_time;
            %             WaitSecs(leftover_ITI_dur);
            %             fprintf('Nominal ITI Duration:\t%-8.4f\tms\n'       , ITI_dur               *1000);
            %             fprintf('Actual  ITI Duration:\t%-8.4f\tms\n'       , (GetSecs-ITI_start_time)*1000);
            %             fprintf('=================================================\n');
            %             fprintf('Current trial Num:\t%3d / %3d\t trials\n'  , currTrialNum, numTrials);
            %             fprintf('\n');
            
            
            % -------------------------
            % Present: Pre-trial frame
            % -------------------------
            background.draw(winPtr);
            fixation.draw(winPtr);
            Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
            WaitSecs(1);                                       % wait:
            %                     fprintf('Pre-trial fixation dur: %1.4f\t\t ms\n' , (GetSecs-start)/1000);
            
            
            letter_array = {'a','b','c'};
            number_array = {'1','2','3'};
            
            letter_stim = randsample(letter_array, 2);
            number_stim = randsample(number_array, 2);
            
            switch obj.trial_type
                case 'simultaneous'
                    % ----------------------------------
                    % Present: Search frame
                    % ----------------------------------
                    %                     start = GetSecs;
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    DrawFormattedText(winPtr, letter_stim{1}, 'center', 'center',seColor2RGB('black'),5,0,0,2);
                    DrawFormattedText(winPtr, letter_stim{2}, 'center', 'center',seColor2RGB('black'),5,0,0,2);
                    DrawFormattedText(winPtr, number_stim{1}, 'center', 'center',seColor2RGB('black'),5,0,0,2);
                    DrawFormattedText(winPtr, number_stim{2}, 'center', 'center',seColor2RGB('black'),5,0,0,2);
                    Screen('Flip', winPtr);

                    WaitSecs(3)

                    
                case 'sequential'
                    
                otherwise
                    error('trial type');
                    % do nothing
            end % switch
            % ----------------------------------
            % Present: Search frame
            % ----------------------------------
            %                     start = GetSecs;
            %             background.draw(winPtr);
            %             fixation.draw(winPtr);
            %             stim_search.draw(winPtr, screenCenter_pt);
            %             Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
            %                     daqCard.sendEventCode(target_eventCode);                                % send event code
            %                     targDisplaySOA = GetSecs-start;
            
            
            % ----------------------------------
            % Subj Response
            % ----------------------------------
            %                     start = GetSecs;
            %             subjectResponse = gamepadObject.waitForResponse(obj.responseDur);
            %             if(~isnan(subjectResponse.responseTime))
            %                 WaitSecs(obj.post_response_duration+(obj.responseDur-subjectResponse.responseTime));
            %             end
            %                     targetDisplayDur = GetSecs-start;
            
            % ------------------------------
            % Present: Post-response frame
            % ------------------------------
            %             ITI_start_time = GetSecs;
            background.draw(winPtr);
            Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
            WaitSecs(1);
            
            % -------------------------
            % Post-Trial Processing
            % -------------------------
            %             obj.block.trials(currTrialNum).saveResponse(subjectResponse);              % save the response to the expt class structure
            %             obj.save_to_file(currTrialNum, false);
            %             curr_mean_accuracy  = nanmean([ obj.block.trials.accuracy  ]) * 100;        % calculate current mean accuracy
            %             curr_mean_RT        = nanmean([ obj.block.trials.RT ]) * 1000;              % calculate current mean response time
            %             ITI_dur             = obj.block.trials(currTrialNum).ITI;                   % figure out the ITI duration at the end of the trial
            %
            %             fprintf('Trial Accuracy:     \t%-8.4f\t%%\n'	, obj.block.trials(currTrialNum).accuracy   * 100 );
            %             fprintf('Trial Response Time:\t%-8.4f\tms\n'	, obj.block.trials(currTrialNum).RT         * 1000);
            %             fprintf('\n');
            %             fprintf('Mean Accuracy:      \t%-8.4f\t%%\n'	, curr_mean_accuracy                        );
            %             fprintf('Mean Response Time: \t%-8.4f\tms\n'	, curr_mean_RT                              );
            %             fprintf('\n');
            %                     fprintf('Target Display SOA:\t %1.4f\t ms\n'          , targDisplaySOA                            * 1000);
            %                     fprintf('Target Display Duration: %1.4f\t ms\n\n'     , targetDisplayDur                          * 1000);
            fprintf('-------------------------------------------------\n');
            
        end % function
        
        
        function testRun(obj)
            
            try
                
                bgColorWd = 'white';
                clc; HideCursor;
                [ winPtr, ~, screenCenter_pt ]      = seSetupScreen(seColor2RGB(bgColorWd));  % setup screen
                background                          = stimBackground(bgColorWd);                                % setup background stim
                fixation                            = stimFixationPt(screenCenter_pt);                              % setup fixation stim

                % Font
                fontName     = 'Helvetica';  % font name for instructions
                fontSize     = 50;           % font size for all instructions
                fontColorWd  = 'black';      % fonct color for all instructions
                fontWrap     = 45;           % number of characters to wrap at
                Screen('TextFont', winPtr, fontName);                                       % setup text font
                Screen('TextSize', winPtr, fontSize);                                       % setup text size

                
                obj.run(winPtr, background, fixation);
                
                
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen

            catch
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                                
            end
            
        end % function
        
        function trialObj = saveResponse(trialObj, subjectResponse)
            
            % Save response info into trial object
            trialObj.resp_keycode    = subjectResponse.keycode;               % response gamepad key number
            trialObj.RT              = subjectResponse.responseTime;                  % subject's single trial response time
            
            % Calculate accuracy
            if( ~isnan(trialObj.resp_keycode) && ...
                    strcmpi(trialObj.responseKeyMap(trialObj.resp_keycode), trialObj.targetOrientation))
                trialObj.accuracy = true;
            else
                trialObj.accuracy = false;
            end
            
        end       % method
        
        
    end % methods
    
end % classdef
