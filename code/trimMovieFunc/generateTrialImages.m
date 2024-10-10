%{
[explanation of this func]:
extract a specific range of video from original video.
Please note what is returned by this function is not a video, but an cell array of the multiple images that make up the specific range of video

[input arguments]
full_movie_obj: [VideoReader], VideoReader object for the video to be cut out
trial_start_frame: [double],  the first frame of the video to be cutout
trial_end_frame: [double],  the last frame of the video to be cutout

[output arguments]
trial_images: [cell array], an cell array of the multiple images that make up the specific range of video

[caution]
In some cases, is is not possible to read frames from the VideoReader
objet( = 'full_movie_obj'). if such a frame exists with in the trial range,
an empty array is returned.
%}

function [trial_images] = generateTrialImages(full_movie_obj, trial_start_frame, trial_end_frame)
trial_images = cell((trial_end_frame - trial_start_frame) + 1, 1);
image_store_id = 1;
for frame_idx = trial_start_frame:trial_end_frame
    try
        frame = read(full_movie_obj, frame_idx);
    catch
        % the frame could not be loaded, so the movie data for this trial will be dicrarded
        trial_images = {};
        return
    end
    trial_images{image_store_id} = frame;
    image_store_id = image_store_id + 1;
end
end