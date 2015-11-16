classdef expt_trial < handle
    %
    % 
    %
    
    properties
        
        % Experimentor Defined Variables
        save_filename       = '';
        expt_id             = 'sz_sequential_simultaneous_attn';
        subj_id             = 'Z99';
        trial_order_num     = NaN;
        trial_type          = 'sequential';
        catch_type          = 'no_catch';

        ITI                 = NaN;        
        char_stim           = {};
        font_rgb_color      = NaN

        
        response01_key      = 'noResponse';   
        response01_time     = NaN;              
        response01_acc      = NaN;

        response02_key      = 'noResponse';
        response02_time     = NaN;              
        response02_acc      = NaN;
        
        luminance_contrast  = NaN;

    end % properties
    
    
    
    properties (Hidden = true)
        save_filedir        = './data';

        % Removed letters: 'O','I'
        letter_array = upper(...
            { 'A','B','C','D','E','F','G','H','J','K'...
            , 'L','M','N','P','Q','R','S','T','U','V'...
            , 'W','X','Y','Z'});
        number_array = {'1','2','3','4','5','6','7','8','9'};
        
        ITI_range               = [.500 .750];
        
    end
    
    
    methods
        
        function obj   = expt_trial(varargin)
            
            switch nargin
                case 0
                    
                case 4
                    obj.trial_type             = varargin{1};
                    obj.catch_type             = varargin{2};
                    obj.expt_id                = varargin{3};
                    obj.subj_id                = varargin{4};
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.save_filename = fullfile(...
                obj.save_filedir, ...
                [obj.expt_id '-' obj.subj_id '.csv']);
            
            %% Randomly calculate inter-trial interval
            %  based min & max ITI-range
            obj.ITI  = min(obj.ITI_range)  ...
                + (rand * (max(obj.ITI_range)-min(obj.ITI_range)));
            
            %% Set up stimulus objects
            
            % Choose character stimuli
            obj.char_stim = [...
                randsample(obj.letter_array, 2), ...
                randsample(obj.number_array, 2)];

            if strcmpi(obj.trial_type, 'simultaneous')
                obj.char_stim = Shuffle(obj.char_stim);
            else
                obj.char_stim = [ ...
                    Shuffle({obj.char_stim{1} obj.char_stim{3}}) ...
                    Shuffle({obj.char_stim{2} obj.char_stim{4}}) ];
            end
            
            
        end % constructor method
        
        
        function run(obj, trialNum, winPtr, background, fixation, luminanceContrast)
            % -------------------------
            % Execute Single Trial
            % -------------------------
            %
            %             ITI_processing_time     = (GetSecs-ITI_start_time);
            %             leftover_ITI_dur        = ITI_dur -ITI_processing_time;
            %             WaitSecs(leftover_ITI_dur);
            %             fprintf('Nominal ITI Duration:\t%-8.4f\tms\n'       , ITI_dur               *1000);
            %             fprintf('Actual  ITI Duration:\t%-8.4f\tms\n'       , (GetSecs-ITI_start_time)*1000);

            fprintf('=================================================\n');
            fprintf('Current trial Num:\t\t%3d\n'    , trialNum);
            fprintf('Luminance contrast: \t\t%3.3f\n', luminanceContrast(1));
            fprintf('\n');
            
            
            obj.trial_order_num    = trialNum;
            obj.luminance_contrast = luminanceContrast(1);
            obj.font_rgb_color     = abs(background.color_rgb - luminanceContrast);

            keyboard               = seKeyboard();

                        
            %% Calculate character locations
            X = 1; Y = 2;
            [winSizeX, winSizeY] = Screen('WindowSize', winPtr);
            screenCenter_pt = [winSizeX winSizeY]/2;
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
            
            
            %% Present: Pre-trial frame
            background.draw(winPtr);
            Screen('Flip', winPtr);        
            WaitSecs(0.500);  
            
            background.draw(winPtr);
            fixation.draw(winPtr);
            Screen('Flip', winPtr);        
            WaitSecs(0.500);              
            %                     fprintf('Pre-trial fixation dur: %1.4f\t\t ms\n' , (GetSecs-start)/1000);
            
            
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
                    DrawFormattedText(winPtr, obj.char_stim{1} ...
                        , sx_center ...
                        , sy_topChar ...
                        , obj.font_rgb_color,5,0,0,2);
                    % BOTTOM character
                    DrawFormattedText(winPtr, obj.char_stim{2} ...
                        , sx_center ...
                        , sy_bottomChar ...
                        , obj.font_rgb_color,5,0,0,2);
                    
                    % RIGHT character
                    DrawFormattedText(winPtr, obj.char_stim{3} ...
                        , sx_rightChar, sy_center ...
                        , obj.font_rgb_color,5,0,0,2);
                    % LEFT character
                    DrawFormattedText(winPtr, obj.char_stim{4} ...
                        , sx_leftChar, sy_center ...
                        , obj.font_rgb_color,5,0,0,2);

                    
                    Screen('Flip', winPtr);                  
                    WaitSecs(.100);

                    
                case 'sequential'

                    % Draw 1st Character Stim Pair
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    % TOP character
                    DrawFormattedText(winPtr, obj.char_stim{1} ...
                        , sx_center ...
                        , sy_topChar ...
                        , obj.font_rgb_color,5,0,0,2);
                    % BOTTOM character
                    DrawFormattedText(winPtr, obj.char_stim{2} ...
                        , sx_center ...
                        , sy_bottomChar ...
                        , obj.font_rgb_color,5,0,0,2);
                    Screen('Flip', winPtr);
                    WaitSecs(0.050);
                    
                    % Draw Blank ISI
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    Screen('Flip', winPtr);
                    WaitSecs(0.800);
                    
                    % Draw 2nd Character Stim Pair
                    background.draw(winPtr);
                    fixation.draw(winPtr);
                    % RIGHT character
                    DrawFormattedText(winPtr, obj.char_stim{3} ...
                        , sx_rightChar, sy_center ...
                        , obj.font_rgb_color,5,0,0,2);
                    % LEFT character
                    DrawFormattedText(winPtr, obj.char_stim{4} ...
                        , sx_leftChar, sy_center ...
                        , obj.font_rgb_color,5,0,0,2);
%                     WaitSecs(0.050);
                    
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
            responseNum = 1;
            subjectResponse_01 = keyboard.waitForResponse();
            obj.saveResponse(subjectResponse_01, responseNum);              % save the response to the expt class structure
            
            WaitSecs(0.300);
            
            DrawFormattedText(winPtr, '??', 'center', 'center', seColor2RGB('white'), 5,0,0,2);
            Screen('Flip', winPtr);
            responseNum = 2;
            subjectResponse_02 = keyboard.waitForResponse();
            obj.saveResponse(subjectResponse_02, responseNum);              % save the response to the expt class structure
            
           
            
            % ------------------------------
            % Present: Post-response frame
            % ------------------------------
            %             ITI_start_time = GetSecs;
            background.draw(winPtr);
            Screen('Flip', winPtr);                                                 % flip/draw buffer to display monitor
            WaitSecs(obj.ITI);
            
            % -------------------------
            % Post-Trial Processing
            % -------------------------            
            % Save trial information to file
            
            % Save header information to file before first trial
            if(obj.trial_order_num == 1); obj.save_to_file(true); end;
            % Save trial information to file
            obj.save_to_file();
            
            
            %             curr_mean_accuracy  = nanmean([ obj.block.trials.accuracy  ]) * 100;        % calculate current mean accuracy
            %             curr_mean_RT        = nanmean([ obj.block.trials.RT ]) * 1000;              % calculate current mean response time
            %             ITI_dur             = obj.block.trials(currTrialNum).ITI;                   % figure out the ITI duration at the end of the trial
            %
            fprintf('Accuracy - 1st Response: \t%-3f %% - %s\n'	 ...
                , obj.response01_acc*100 ...
                , obj.response01_key);
            fprintf('Accuracy - 2nd Response: \t%-3f %% - %s\n'	...
                , obj.response02_acc*100 ...
                , obj.response02_key);

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

                
                trialNum = 1;
                luminanceContrast = 50;
                obj.run(trialNum, winPtr, background, fixation, luminanceContrast);
                
                
                ShowCursor;
                Screen('CloseAll');         % close psychtoolbox screen

            catch err
                ShowCursor;
                Screen('CloseAll');          % close psychtoolbox screen
                rethrow(err);
            end
            
        end % function
        
        
        function trialObj = saveResponse(trialObj, subjectResponse, responseNum)
            
            % Save response info into trial object
            responseNum = num2str(responseNum);
            eval(['trialObj.response0' responseNum '_key = upper(subjectResponse.keycode{1});']);
            eval(['trialObj.response0' responseNum '_time = subjectResponse.responseTime;']);
            
            % Calculate accuracy
            if( ismember( ...
                    subjectResponse.keycode, ...
                    lower(trialObj.char_stim)))
                eval(['trialObj.response0' responseNum '_acc = true;']);

            else
                eval(['trialObj.response0' responseNum '_acc = false;']);
            end
            
        end       % method
        
        
        
        
        
        
        
        
        
        
        
        function save_to_file(obj, printHeader, separator, decimal)
            % Writes cell array content into a *.csv file.
            %
            % CELL2CSV(obj.save_filename, cellArray, separator, excelYear, decimal)
            %
            % obj.save_filename     = Name of the file to save. [ i.e. 'text.csv' ]
            % cellArray    = Name of the Cell Array where the data is in
            % separator    = sign separating the values (default = ';')
            % decimal      = defines the decimal separator (default = '.')
            %
            %         by Sylvain Fiedler, KA, 2004
            % updated by Sylvain Fiedler, Metz, 06
            % fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
            % added the choice of decimal separator, 11/2010, S.Fiedler
            
            % Check for optional Variables
            if ~exist('separator', 'var')
                separator = ','; 
            end
            
            if ~exist('printHeader', 'var')
                printHeader = false; 
            end
            
            if ~exist('decimal', 'var')
                decimal = '.';
            end
            

            % Write file            
            outputFileID = fopen(obj.save_filename, 'a+'); % open/create file; append data
            
            
            % Print all variables in trial data object
            var_names    = transpose(fieldnames(obj));            
            for var_name = var_names
                
                if (printHeader)
                    % Print variable names
                    print_value = var_name{1};
                else
                    % Print variable values
                    print_value = eval(['obj.' var_name{1}]);
                    
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

                    % If cell array -> String
                    if iscell(print_value)
                        print_value = cell2mat(print_value);
                    end
                end
                
                
                % OUTPUT value
                fprintf(outputFileID, '%s', print_value);
                
                % OUTPUT separator
                %     if s ~= size(cellArray, 2)
                fprintf(outputFileID, separator);
                %     end
                
            end
            
            fprintf(outputFileID, '\n'); % print new line at end of every line
            
            % Closing file
            fclose(outputFileID);
        end
        
        
    end % methods
    
end % classdef
