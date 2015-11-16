classdef expt_SequentialSimultaneousAttention
    % Author:   Jason Arita
    % Version:  1
    %
    
    properties
        expt_id                 = 'scz_seq_sim_divided_attn';
        subjectID;                      % from prompt

        blocks;                          % where all trial data is stored
        catch_blocks;
        date;                           % current date (see help DATESTR)
        start_time;                     % current time
        end_time;
        
        
        save_directory                  = 'data';
        
        
        %------------------------
        % Stimulus settings
        %------------------------
        bgColorWd                   = 'white';    % (str)
        numPracticeTrials           = 25;
        
        
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
        
        
        instructions_str = 'Report the 2 LETTERS that appeared.';
        
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
                        };
                    promptNumAnsLines = 1;
                    promptDefaultAns  =   ...
                        { 'A99'  ...
                        };
                    
                    
                    options.Resize              = 'on';
                    answer                      = inputdlg(prompt, promptTitle, promptNumAnsLines, promptDefaultAns, options);
                    if(isempty(answer))
                        return;
                    else
                        obj.subjectID           = answer{1};
                    end
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
           
            
            
            %------------------------
            % Set up trials
            %------------------------
            display('Generating Trial Permutations...');
       
            obj.blocks{1} = expt_block(obj.expt_id, obj.subjectID, 'simultaneous', 'no_catch');
            obj.blocks{2} = expt_block(obj.expt_id, obj.subjectID, 'sequential'  , 'no_catch');
            
            obj.catch_blocks{1} = expt_block(obj.expt_id, obj.subjectID, 'simultaneous', 'catch');
            obj.catch_blocks{2} = expt_block(obj.expt_id, obj.subjectID, 'sequential'  , 'catch');
            
            display('Done');
            
            % -----------------------
            % Randomize Block Order
            % -----------------------\
            display('Randomizing blocks...');
            obj.blocks          = Shuffle(obj.blocks);
            obj.catch_blocks    = Shuffle(obj.catch_blocks);
            display('done...');

            % If necessary, create Save Directory
            if(~exist(obj.save_directory, 'dir')); mkdir(obj.save_directory); end            % if save dir doesn't exist create one
            
            %             % Save header to output file
            %             if(obj.isPractice)
            %                 obj.save_filename   = [ './' obj.save_directory '/practice_' obj.name '_' obj.subjectID '.txt'];
            %             else
            %                 obj.save_filename   = [ './' obj.save_directory '/' obj.name '_' obj.subjectID '.txt'];
            %             end
            
        end % constructor method
        
        function obj    = run(obj)
            
            try
                
                clc; HideCursor;
                
                
                % --------------------
                % Execute Experiment
                % --------------------
                %                 startTime    = GetSecs;                                                         % start timing experiment session
                
                % --------------------------
                % Present instructions
                % --------------------------
                %                 background.draw(winPtr);
                %                 DrawFormattedText(winPtr, obj.instructions_str, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap,0,0,2);
                %                 Screen('Flip', winPtr);                                                         % flip/draw buffer to display monitor
                %                 KbWait;
                
                
                
                
                %                 ITI_start_time = GetSecs;
                %                 ITI_dur        = 0;
                %
                
                
                % Run Catch Blocks
                for iBlock = 1:length(obj.catch_blocks)
                    
                    obj.catch_blocks{iBlock}.run();
                    
                end
                
                % Run Catch Blocks
                for iBlock = 1:length(obj.catch_blocks)
                    
                    obj.blocks{iBlock}.run();
                    
                end
                
                
                % -------------------------
                % Finish Expt
                % -------------------------
                
                
                
                % -------------------------
                % Present: Expt End Screen
                % -------------------------
                % display experiment information at run end
                %                 obj.exptDuration = (GetSecs - startTime) / 60;  % (minutes)
                %                 fprintf('Session Duration: %1.4f\t min\n\n'     , obj.exptDuration);
                %
                %
                %                 if(obj.isPractice)
                %                     end_instructions = sprintf('Practice Finished.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress any button to continue'  ...
                %                         , curr_mean_accuracy    ...
                %                         , curr_mean_RT          ...
                %                         );
                %                 else
                %                     end_instructions = sprintf('Run finished.\n\nAccuracy:\t %-1.2f \t%%\nResponse Time:\t %-1.2f\tmsecs\n\nPress any button to continue'  ...
                %                         , curr_mean_accuracy    ...
                %                         , curr_mean_RT          ...
                %                         );
                %                     [ exptEndSndData exptEndSndFreq ] = wavread('expt.end.wav');
                %                     soundsc(exptEndSndData, exptEndSndFreq);        % Play sound at expt run end
                %                 end
                %
                %                 background.draw(winPtr);
                %                 DrawFormattedText(winPtr, end_instructions, 'center', 'center',seColor2RGB(obj.fontColorWd),obj.fontWrap);
                %                 Screen('Flip', winPtr);                                 % flip/draw buffer to display monitor
                %
                %
                
                
                
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
        
        %         function save_to_file(obj, trial_num, header, separator, excelYear, decimal)
        %             % Writes cell array content into a *.csv file.
        %             %
        %             % CELL2CSV(obj.save_filename, cellArray, separator, excelYear, decimal)
        %             %
        %             % obj.save_filename     = Name of the file to save. [ i.e. 'text.csv' ]
        %             % cellArray    = Name of the Cell Array where the data is in
        %             % separator    = sign separating the values (default = ';')
        %             % excelYear    = depending on the Excel version, the cells are put into
        %             %                quotes before they are written to the file. The separator
        %             %                is set to semicolon (;)
        %             % decimal      = defines the decimal separator (default = '.')
        %             %
        %             %         by Sylvain Fiedler, KA, 2004
        %             % updated by Sylvain Fiedler, Metz, 06
        %             % fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
        %             % added the choice of decimal separator, 11/2010, S.Fiedler
        %
        %             %% Checking for optional Variables
        %             if ~exist('separator', 'var')
        %                 separator = ',';
        %             end
        %
        %             if ~exist('excelYear', 'var')
        %                 excelYear = 1997;
        %             end
        %
        %             if ~exist('decimal', 'var')
        %                 decimal = '.';
        %             end
        %
        %             %% Setting separator for newer excelYears
        %             if excelYear > 2000
        %                 separator = ';';
        %             end
        %
        %             %% Write file
        %
        %             datei       = fopen(obj.save_filename, 'a+'); % open/create file; append data
        %             var_names   = transpose(fieldnames(obj.block.trials(trial_num)));
        %
        %             for var_name = var_names
        %
        %                 if header
        %                     print_value = var_name{1};
        %                 else
        %                     print_value = eval(['obj.block.trials(trial_num).' var_name{1}]);
        %                 end
        %
        %                 % If zero, then empty cell
        %                 if size(print_value, 1) == 0
        %                     print_value = '';
        %                 end
        %                 % If numeric -> String
        %                 if isnumeric(print_value)
        %                     print_value = num2str(print_value);
        %                     % Conversion of decimal separator (4 Europe & South America)
        %                     % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
        %                     if decimal ~= '.'
        %                         print_value = strrep(print_value, '.', decimal);
        %                     end
        %                 end
        %                 % If logical -> 'true' or 'false'
        %                 if islogical(print_value)
        %                     if print_value == 1
        %                         print_value = 'TRUE';
        %                     else
        %                         print_value = 'FALSE';
        %                     end
        %                 end
        %                 % If newer version of Excel -> Quotes 4 Strings
        %                 if excelYear > 2000
        %                     print_value = ['"' print_value '"']; %#ok<AGROW>
        %                 end
        %
        %                 % OUTPUT value
        %                 fprintf(datei, '%s', print_value);
        %
        %                 % OUTPUT separator
        %                 %     if s ~= size(cellArray, 2)
        %                 fprintf(datei, separator);
        %                 %     end
        %
        %             end
        %
        %             fprintf(datei, '\n'); % print new line at end of every line
        %
        %             % Closing file
        %             fclose(datei);
        %         end
        
    end % methods
    
    
end % classdef


% END
