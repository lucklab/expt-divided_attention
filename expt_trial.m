classdef expt_trial < handle
    %
    % 
    %
    
    properties
        
        % Experimentor Defined Variables
        subject_ID          = 'Z99';
        trial_order_num     = 99;
        trial_type          = 'sequential';
        %         run_order_num       = 1;
        %         setSize             = 8;
        %         targetPresence      = 'present';
        %         targetLocation      = 3;
        %         targetOrientation   = 'down';
        %         objectColor         = 'magenta';
        ITI;
        
        accuracy            = [];            % subject's single trial accuracy {1 == correct || 0 == incorrect}
        resp_keycode        = 'noResponse';   % response gamepad key number
        RT;                                   % subject's single trial response time
        
    end % properties
    
    
    
    properties (Hidden = true)
        event_code;
        letter_stim;                    % Search stimulus to draw
        number_stim;
        
        search_annulus_radius   = 200;
        ITI_range               = [.250 .500];
        
        responseKeyMap;
        
    end
    
    %     events
    %         calculateAccuracy
    %     end
    
    methods
        
        function obj   = expt_trial(varargin)
            
            switch nargin
                case 0
                    
                case 1
                    obj.trial_type                  = varargin{1};
                    
                case 9
                    
%                     obj.subject_ID                  = varargin{1};
%                     obj.run_order_num               = varargin{2};
%                     obj.event_code                  = varargin{3};
%                   
%                     obj.ITI_range                   = varargin{8};
%                     obj.search_annulus_radius       = varargin{9};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
%             obj.searchStimuli                 = stimLandoltCArray.empty;
            
            
            %% Randomly calculate inter-trial interval
            %  based min & max ITI-range
%             obj.ITI  = min(obj.ITI_range)  ...
%                 + (rand * (max(obj.ITI_range)-min(obj.ITI_range)));
%             
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
        
        
        function run(obj, winPtr, background, fixation, fontColor)
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
            keyboard = seKeyboard();

                
            %% Present: Pre-trial frame
            background.draw(winPtr);
            Screen('Flip', winPtr);        
            WaitSecs(0.500);  
            
            background.draw(winPtr);
            fixation.draw(winPtr);
            Screen('Flip', winPtr);        
            WaitSecs(0.500);              
            %                     fprintf('Pre-trial fixation dur: %1.4f\t\t ms\n' , (GetSecs-start)/1000);
            
            
            %% Choose character stimuli
            letter_array = upper(...
                { 'a','b','c','d','e','f','g','h','i','j','k'...
                , 'l','m','n','o','p','q','r','s','t','u','v'...
                , 'w','x','y','z'});
            number_array = {'1','2','3','4','5','6','7','8','9'};
            
            obj.letter_stim = randsample(letter_array, 2);
            obj.number_stim = randsample(number_array, 2);
            
            
            %% Calculate character locations
            X = 1; Y = 2;
            screenCenter_pt = fixation.location_pt;
            charRect         = Screen('TextBounds', winPtr, 'A');
            charCenterOffset = 200;
            charHeightOffset = RectHeight(charRect)/2;
            charWidthOffset  = RectWidth(charRect)/2;
            
            sy_center     = screenCenter_pt(Y) - charHeightOffset;
            sx_center     = screenCenter_pt(X) - charWidthOffset;
            sy_bottomChar = sy_center + charCenterOffset;
            sy_topChar    = sy_center - charCenterOffset;
            sx_rightChar  = sx_center + charCenterOffset;
            sx_leftChar   = sx_center - charCenterOffset;
            
            
            %% Present character stim

            %            ifi = Screen('GetFlipInterval', winPtr);
            %            trueStimOnsetTimestamp = Sc
            %
            
            background.draw(winPtr);
            fixation.draw(winPtr);

            switch obj.trial_type
                case 'simultaneous'

                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    
                    % TOP character
                    DrawFormattedText(winPtr, obj.number_stim{1} ...
                        , sx_center ...
                        , sy_topChar ...
                        , fontColor,5,0,0,2);
                    % BOTTOM character
                    DrawFormattedText(winPtr, obj.letter_stim{1} ...
                        , sx_center ...
                        , sy_bottomChar ...
                        , fontColor,5,0,0,2);
                    
                    % LEFT character
                    DrawFormattedText(winPtr, obj.number_stim{2} ...
                        , sx_leftChar, sy_center ...
                        , fontColor,5,0,0,2);
                    % RIGHT character
                    DrawFormattedText(winPtr, obj.letter_stim{2} ...
                        , sx_rightChar, sy_center ...
                        , fontColor,5,0,0,2);
                    
                    Screen('Flip', winPtr);                  
                    WaitSecs(.100);

                    
                case 'sequential'

                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    % TOP character
                    DrawFormattedText(winPtr, obj.number_stim{1} ...
                        , sx_center ...
                        , sy_topChar ...
                        , fontColor,5,0,0,2);
                    % BOTTOM character
                    DrawFormattedText(winPtr, obj.letter_stim{1} ...
                        , sx_center ...
                        , sy_bottomChar ...
                        , fontColor,5,0,0,2);
                    Screen('Flip', winPtr);
                    WaitSecs(0.050);
                    
                    % Draw Blank ISI
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    Screen('Flip', winPtr);
                    WaitSecs(0.800);
                    
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    % LEFT character
                    DrawFormattedText(winPtr, obj.number_stim{2} ...
                        , sx_leftChar, sy_center ...
                        , fontColor,5,0,0,2);
                    % RIGHT character
                    DrawFormattedText(winPtr, obj.letter_stim{2} ...
                        , sx_rightChar, sy_center ...
                        , fontColor,5,0,0,2);
                    Screen('Flip', winPtr);
                    WaitSecs(0.050);
                    
                otherwise
                    error('trial type');
                    % do nothing
            end % switch

            
            % ----------------------------------
            % Subj Response
            % ----------------------------------
            %                     start = GetSecs;
            DrawFormattedText(winPtr, '?', 'center', 'center', seColor2RGB('white'), 5,0,0,2);
            Screen('Flip', winPtr);
            subjectResponse_01 = keyboard.waitForResponse();
            obj.saveResponse(subjectResponse_01);              % save the response to the expt class structure
            % UPDATE QUEST
            
            WaitSecs(0.250);
            
            DrawFormattedText(winPtr, '??', 'center', 'center', seColor2RGB('white'), 5,0,0,2);
            Screen('Flip', winPtr);
            subjectResponse_02 = keyboard.waitForResponse();
            obj.saveResponse(subjectResponse_02);              % save the response to the expt class structure
            % UPDATE QUEST
            
            
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
            %             obj.saveResponse(subjectResponse);              % save the response to the expt class structure
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
                
                bgColorWd = 'black';
                clc; HideCursor;
                [ winPtr, ~, screenCenter_pt ]      = seSetupScreen(seColor2RGB(bgColorWd));  % setup screen
                background                          = stimBackground(bgColorWd);                                % setup background stim
                fixation                            = stimFixationPt(screenCenter_pt);                              % setup fixation stim

                % Font
                fontName     = 'Monaco';    % font name for instructions
                fontSize     = 50;          % font size for all instructions
                Screen('TextFont', winPtr, fontName);    % setup text font
                Screen('TextSize', winPtr, fontSize);    % setup text size

                
                obj.run(winPtr, background, fixation, seColor2RGB('white'));
                
                
                ShowCursor;
                Screen('CloseAll');         % close psychtoolbox screen

            catch err
                ShowCursor;
                Screen('CloseAll');          % close psychtoolbox screen
                rethrow(err);
            end
            
        end % function
        
        
        function trialObj = saveResponse(trialObj, subjectResponse)
            
            % Save response info into trial object
            trialObj.resp_keycode    = subjectResponse.keycode;               % response gamepad key number
            trialObj.RT              = subjectResponse.responseTime;                  % subject's single trial response time
            
            % Calculate accuracy
            if( ismember( ...
                    trialObj.resp_keycode, ...
                    lower(trialObj.letter_stim)))
                trialObj.accuracy = [trialObj.accuracy true];
            else
                trialObj.accuracy = [trialObj.accuracy false];
            end
            
        end       % method
        
        
    end % methods
    
end % classdef
