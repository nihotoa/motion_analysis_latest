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


[Saved data location]
    【data】:
        <RGB value of LED>:
            motion_analysis_latest/saveFold/<monkey name>/data/movieRGBData/<recording date>

        <task timing data>:
            motion_analysis_latest/saveFold/<monkey name>/data/movieTimingData/<recording date>
        

[procedure]
pre: nothing
post: comming soon...


[Improvement points(Japanaese)]
dirdir, uiselectはEMG_analysis_latestのttbで定義されているので、commonCodeと一緒に、このプロジェクトの兄弟ディレクトリの中に
格納するように変更する
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%% set param
task_movie_extension = 'mp4';  
monkeyname = 'Hu';
LED_color = 'red'; % 'red' / 'blue'

%% code section
realname = get_real_name(monkeyname);
base_dir = fileparts(pwd);
use_data_fold_dir = fullfile(base_dir, 'useDataFold');
save_data_fold_dir = fullfile(base_dir, 'saveFold', realname);
use_data_movie_dir = fullfile(use_data_fold_dir, realname, 'movie');
task_movie_dir = fullfile(use_data_movie_dir, 'taskMovie');

% タスク動画のオブジェクトを配列にまとめる
disp('Please select all date fold  you want to operate')
ref_dates = uiselect(dirdir(task_movie_dir), 1, 'Please select date folders which contains the VAF data you want to plot');

% LED_colorの色に沿って、timingのidを変える
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

    rgb_save_fold_path = fullfile(save_data_fold_dir, 'data', 'movieRGBData', ref_date);
    makefold(rgb_save_fold_path);
    timing_save_fold_path = fullfile(save_data_fold_dir, 'data', 'movieTimingData', ref_date);
    makefold(timing_save_fold_path)
    
    timing_file_name = [timing_label  '_on_off_timing.mat'];
    fprintf(['【start making "' timing_label '" timing data for: ' ref_date '】\n' ]);
    if exist(fullfile(timing_save_fold_path, timing_file_name))
        fprintf(['the file created by this procecss has already been created in:【' fullfile(timing_save_fold_path, timing_file_name) '】\n']);
        continue;
    end

    ref_task_movie_fold = fullfile(task_movie_dir, ref_date);
    task_movies = dirEx(fullfile(ref_task_movie_fold, ['*.'  task_movie_extension]));
    task_movies_name = {task_movies.name}; 
    camera_indicies = getCameraIndicies(task_movies_name);
    ref_timings_frame_idx_list = cell(1, camera_indicies(end));

    for camera_id = camera_indicies
        rgb_save_file_name = ['camera' num2str(camera_id) '_RGB.mat'];
        save_file_path = fullfile(rgb_save_fold_path, rgb_save_file_name);
        if exist(save_file_path)
            load(save_file_path, 'rgb_value_array');
        else
            ref_movie_path = fullfile(ref_task_movie_fold, ['camera' num2str(camera_id) '.' task_movie_extension]);
            rgb_value_array = getLEDRGB(ref_movie_path, LED_color);
            save(save_file_path, "rgb_value_array");
        end

        % rgb_valueの中からstartとendのタイミングを見つける
        focus_rgb_array =  rgb_value_array(focus_rgb_index, :);
        [start_timings, end_timings] = findBinaryChanges(focus_rgb_array);

        ref_timing_data_struct = struct();
        start_timing_indecies = ones(1, length(start_timings)) * start_timing_id;
        end_timing_indecies = ones(1, length(end_timings)) * end_timing_id;
        ref_timing_data_struct.start_timing = [start_timings; start_timing_indecies];
        ref_timing_data_struct.end_timing = [end_timings; end_timing_indecies]; 
        ref_timings_frame_idx_list{camera_id} =ref_timing_data_struct;
    end
    save(fullfile(timing_save_fold_path, timing_file_name), 'ref_timings_frame_idx_list')
end