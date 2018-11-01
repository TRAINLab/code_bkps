function parforLooper(subjects1,subjects2)

% parforLooper script for fMRI preprocessing pipeline @ MUSC TRAIN Lab
% healthneuro parallel computing 32-core cluster
% written by PAmcconnell 071918

% Requires specific dirStructure (see subDir variable definition below)
% subjects1 (v1 list) and subjects2 (v2 list) subID only as string (e.g., '1202')
% must have .m batch files already made for each subject in z_scripts
% dirStructure (see spm_jobman definition below)

% depends: artMotionDespike_loop.m, spm_jobman.m

%SPM.mat files must not exist in target folders (step 3/7) or else the first level modeling will break and the
%pool will need to be restarted

%% DEFINE SCRIPT PARAMETERS

% Check study/task variables, create if needed
study = inputdlg('Study Name?');
study = study{1};
task = inputdlg('Task Name?');
task = task{1};

% Define subject lists for each visit
subjects{1,1} = subjects1;
subjects{1,2} = subjects2;

% Define Visit and Root Directory Parameters
visit = {'v1','v2'};
%visit = {'v2'};
visits = spm_input('How many visits?');

rootDir = ['/TRAIN_Data/fmri/' study '/tasks/'];

% Preprocessing Steps (1:7)
step = {'unpack','module1','1LM_motion','artMotion','module2','smooth','1LM'};
steps = spm_input('Define step range (1:7)');

% Define Motion Correction Parameters
% if task(1) == 'r'
%     motion_threshold = '1';
%     despike = 'false';
% else
    motion_threshold = spm_input('motion threshold in mm');
    despike = 'true';
%end

%% Loop Preprocessing Steps

for iStep = steps
    for iVisit = 1:length(visit)
        parfor iSubj = 1:length(subjects{1,iVisit})
            subDir = [rootDir '/' task '/subjects/' subjects{1,iVisit}{iSubj} '/' visit{iVisit} '/'];
            if iStep == 4
                dataDir = [subDir '/spm_' task];
                spmFiles = [dataDir '/SPM.mat'];
                artMotionDespike_loop(motion_threshold,despike,dataDir,spmFiles)
                delete 'SPM.mat';
            else
                spm_jobman('run',[rootDir '/' task '/z_scripts/' step{iStep} '/' visit{iVisit} '/' subjects{1,iVisit}{iSubj} '.m']);
            end
        end
    end
end

