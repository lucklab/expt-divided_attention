


%% setup quest
tGuess      = log10(0.100); % log of estimated threshold -  time for peripheral accuracy
tGuessSd    = log10(3);     % standard deviation
pThreshold  = 0.85;         % performance will converage at this
beta        = 3.5;          % steepness of the Weibull function, typically 3
delta       = 0.01;         % fraction of trials observer presses blindly
gamma       = 0.5;          % fraction of trials generate response 1 when intensity = -inf
%grain = 0.01;
%range = 5; % tGuess+(-range/2:grain:range/2)

qStruct = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma); %range and grain default



%% to determine current trial test value, ask quest what you should test
questOutput = QuestQuantile(qStruct);	% Recommended by Pelli (1987), and still our favorite.
ISItested = 10.^questOutput;
  

%% after trial, tell quest what you actually tested (in case you didnt like what it recommended) and how it went
qStruct = QuestUpdate(qStruct,log10(ISItested),trialAcc); %report what we did
               


%% to get a current quest estimate, this is one way
curQuestMean(trial,1) =   10.^QuestMean(qStruct);
