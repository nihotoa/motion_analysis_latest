%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
[your operation]
1. Please 
2. Change some parameters (please refer to 'set param' section)
3. Please run this code

[role of this code]
Extract and save the video of each trial from the recording video. 
The video extension of exracted video will be same as the recording video.
The following data can be obtained during the processing process:
    > RGB value of LED
    > task timing data (referencing RGB values of LEDs)
    > trial videos


[Saved data location]
    【data】:
        <RGB value of LED>:
            motion_analysis_latest/saveFold/<monkey name>/data/movieRGBData/<recording date>

        <task timing data>:
            motion_analysis_latest/saveFold/<monkey name>/data/movieTimingData/<recording date>

    【movie】
        <each trial movie>
            motion_analysis_latest/saveFold/<monkey name>/movie/trimmed/<focus_timing>_on_off/<recording date>/<camera name>
       
[procedure]
pre: nothing
post: comming soon...

[caution!!]
出力される動画は問答無用で.mp4(めんどくさいから)
タスク開始は青色LEDが消える瞬間、タスク終了は青色LEDが点灯する瞬間であることに注意

[Improvement points(Japanaese)]
>dirdir, uiselectはEMG_analysis_latestのttbで定義されているので、commonCodeと一緒に、このプロジェクトの兄弟ディレクトリの中に
格納するように変更する
>
処理上の問題はないが、is_timing_file_existsがfalseだった場合とtrueだった場合で、ワークスペース変数の構成が異なってしまうので、
falseだった時の処理の中身を関数にしたほうがいい
 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%% set param
task_movie_extension = 'mp4';  
monkeyname = 'Hu';
LED_color = 'blue'; % 'red' / 'blue'
record_Hz = 200; % recording framerate[Hz]

%% code section
realname = get_real_name(monkeyname);
base_dir = fileparts(pwd);
use_data_fold_dir = fullfile(base_dir, 'useDataFold');
save_fold_dir = fullfile(base_dir, 'saveFold', realname);
save_data_fold_dir = fullfile(save_fold_dir, 'data');
save_movie_fold_dir = fullfile(save_fold_dir, 'movie');
use_data_movie_dir = fullfile(use_data_fold_dir, realname, 'movie');
task_movie_dir = fullfile(use_data_movie_dir, 'taskMovie');

disp('Please select all date fold  you want to operate')
ref_dates = uiselect(dirdir(task_movie_dir), 1, 'Please select date folders which contains the VAF data you want to plot');

switch LED_color
    case 'blue'
        % 'task_start' & 'task_end' timing
        timing_label = 'task';
        start_timing_id = 1;
        end_timing_id = 6;
        focus_rgb_index = 3;
    case 'red'
        timing_label = 'food';
        start_timing_id = 3;
        end_timing_id = 4;
        focus_rgb_index = 1;
end

for date_index = 1:length(ref_dates)
    ref_date = ref_dates{date_index};

    rgb_save_fold_path = fullfile(save_data_fold_dir, 'movieRGBData', ref_date);
    makefold(rgb_save_fold_path);
    timing_save_fold_path = fullfile(save_data_fold_dir, 'movieTimingData', ref_date);
    makefold(timing_save_fold_path)
    
    timing_file_name = [timing_label  '_on_off_timing.mat'];
    fprintf(['【start making "' timing_label '" timing data for: ' ref_date '】\n' ]);
    
    ref_task_movie_fold = fullfile(task_movie_dir, ref_date);
    task_movies = dirEx(fullfile(ref_task_movie_fold, ['*.'  task_movie_extension]));
    task_movies_name = {task_movies.name}; 
    camera_indicies = getCameraIndicies(task_movies_name);

    is_timing_file_exists = false;
    if exist(fullfile(timing_save_fold_path, timing_file_name))
        fprintf(['the file created by this procecss has already been created in:【' fullfile(timing_save_fold_path, timing_file_name) '】\n']);
        is_timing_file_exists = true;
        load(fullfile(timing_save_fold_path, timing_file_name), 'ref_timings_frame_idx_list');
    end

    if is_timing_file_exists == false
        ref_timings_frame_idx_list = cell(1, camera_indicies(end));
        for camera_id = camera_indicies
            rgb_save_file_name = ['camera' num2str(camera_id) '_RGB.mat'];
            save_file_path = fullfile(rgb_save_fold_path, rgb_save_file_name);
            if exist(save_file_path)
                load(save_file_path, 'rgb_value_array');
            else
                ref_camera_movie_path = fullfile(ref_task_movie_fold, ['camera' num2str(camera_id) '.' task_movie_extension]);
                rgb_value_array = getLEDRGB(ref_camera_movie_path, LED_color);
                save(save_file_path, "rgb_value_array");
            end
    
            % find the start and end timing by using 'rgb_value_array'
            focus_rgb_array =  rgb_value_array(focus_rgb_index, :);
            switch LED_color
                case 'red'
                    [start_timings, end_timings] = findBinaryChanges(focus_rgb_array);
                case 'blue'
                    [end_timings, start_timings] = findBinaryChanges(focus_rgb_array);
                    validate_end_timing_indices = not(end_timings(1, :) == 1);
                    end_timings = end_timings(validate_end_timing_indices);
                    start_timings = start_timings(1:length(end_timings));
            end
    
            ref_timing_data_struct = struct();
            start_timing_indecies = ones(1, length(start_timings)) * start_timing_id;
            end_timing_indecies = ones(1, length(end_timings)) * end_timing_id;
            ref_timing_data_struct.start_timing = [start_timings; start_timing_indecies];
            ref_timing_data_struct.end_timing = [end_timings; end_timing_indecies]; 
            ref_timings_frame_idx_list{camera_id} =ref_timing_data_struct;
        end
        save(fullfile(timing_save_fold_path, timing_file_name), 'ref_timings_frame_idx_list')
    end

    %% extract and save video from each trial
    % load timing data from alphaOmega
    common_part_name = [monkeyname ref_date(3:end)];
    tp_path = fullfile(fileparts(base_dir), 'EMG_analysis_latest', 'data', realname, 'easyData', [common_part_name '_standard'], [common_part_name '_EasyData.mat']);
    load(tp_path, 'Tp', 'EMG_Hz');

    % format timing data for comparison with timing data from video;
    real_timing_data = [Tp(:, start_timing_id)'; Tp(:, end_timing_id)'];
    real_timing_data = round(real_timing_data * (record_Hz/EMG_Hz));

    % synchronize EMG and video for each camera
    for camera_id = camera_indicies
        % load timing data extracted from video
        ref_camera_task_timing_struct = ref_timings_frame_idx_list{camera_id};
        ref_camera_task_timing = [ref_camera_task_timing_struct.start_timing(1, :); ref_camera_task_timing_struct.end_timing(1, :)];

        synchronized_timings = makeSynchronizedTimingArray(real_timing_data, ref_camera_task_timing);

        if isempty(synchronized_timings)
            warning([ref_date '-camera' num2str(camera_id) ' was unable to synchronize with EMG, so it was not possible to extract the video'])
            continue;
        end

        % loading the video to be cut out & make folder to save trimmed videos
        ref_camera_movie_path = fullfile(ref_task_movie_fold, ['camera' num2str(camera_id) '.' task_movie_extension]);
        [~, trial_num] = size(synchronized_timings);
        full_movie_obj = VideoReader(ref_camera_movie_path);
        save_trial_movie_fold_path = fullfile(save_movie_fold_dir, 'trimmed', [timing_label '_on_off'], ref_date, ['camera' num2str(camera_id)]);
        makefold(save_trial_movie_fold_path);
        
        % extract only the trial part from the video and save them as a new video
        for trial_id = 1:trial_num
            save_movie_name = ['camera' num2str(camera_id) '_trial' sprintf('%03d', trial_id) '.mp4'];
            if exist(fullfile(save_trial_movie_fold_path, save_movie_name))
                continue;
            end
            trial_start_frame = synchronized_timings(1, trial_id);
            trial_end_frame = synchronized_timings(2, trial_id);
            ref_trial_images = generateTrialImages(full_movie_obj, trial_start_frame, trial_end_frame);
            if isempty(ref_trial_images)
                disp(['the following video could not be generated: 【camera' num2str(camera_id) '-trial' sprintf('%03d', trial_id) '】'])
                continue;
            end
            saveTrialMovie(ref_trial_images, save_trial_movie_fold_path, save_movie_name)
            clear ref_trial_images
        end
    end
end