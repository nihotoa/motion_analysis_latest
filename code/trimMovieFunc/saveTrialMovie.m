%{
[explanation of this func]:
create a video file from multiple images that make up a video.

[input arguments]
> trial_images: [cell array], cell array containing multiple images that make up a video. This parameter can be obtained by executing 'generateTrialImages.m'
> save_fold_path: [char], full path of the directory where the video is stored
> save_movie_name: [char], the name of the video file to be output. please include extension(.mp4).
(ex.) 'sample.mp4'

[output arguments]
nothing
%}

function [] = saveTrialMovie(trial_images, save_fold_path, save_movie_name)
save_trial_movie_obj = VideoWriter(fullfile(save_fold_path, save_movie_name), 'MPEG-4');
open(save_trial_movie_obj)
for frame_idx = 1:length(trial_images)
    writeVideo(save_trial_movie_obj, trial_images{frame_idx})
end
close(save_trial_movie_obj)
end