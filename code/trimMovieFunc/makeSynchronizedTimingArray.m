%{
[explanation of this func]:

[input arguments]
real_timing_data:[double array], Event data for 'task start' and 'task end' recorded by AlphaOmega.
                                                  array size is [2, trial_num], with the row1 is the event data for 'task start' and the row2 is the event data for 'task end' 

video_timing_data:[double array], Event data that is a candidate for 'task_start' and 'task_end', as determined from the blue LED in the  video.
                                                    array size is [2, <number of times LED ligiht up>], with the row1 is the event data for 'task start' and the row2 is the event data for 'task end' 


[output arguments]
synchronized_timing_data: [double array], an array containing the LED switching timing data corresponding to the event data recorded from alphaOmega.
                                          This array is filtered version of 'video_timing_data'

[caution]
If the accuracy of the synchronization between the event data from the video and actual event data (from alphaOmega) is low,  an empty array is returned. 
This is to eliminate unreliable data.
%}

function [synchronized_timing_data]= makeSynchronizedTimingArray(real_timing_data, video_timing_data)

% Extract only 'real_timing_data' for the section corresponding to the video range
validate_range = ceil(video_timing_data(2, end) / 10) * 10;
validate_trial_num = max(find(real_timing_data(2, :) < validate_range));
validate_real_timing_data = real_timing_data(:, 1:validate_trial_num);

% examining the gaps between actual event data and eventdatafrom videos to match the  2
synchronized_timing_data = [];
gap_score_list = zeros(1, validate_trial_num);
for trial_id = 1:validate_trial_num
    ref_real_timing = validate_real_timing_data(:, trial_id);

    % check the gap and convert it to a gap_score (the lower the score, the smaller the gap)
    gap_timings = video_timing_data - ref_real_timing;
    gap_durations = abs(gap_timings(2, :) - gap_timings(1, :));
    gap_scores = sum([abs(gap_timings); gap_durations]);
    [gap_score, correspond_id] = min(gap_scores);
    gap_score_list(trial_id) = gap_score;

    % if the 'gap_score' is below the threshold, the data if adopted as 'synchronized_timing_data'.
    gap_score_threshold = 200; % this threshold was decided arbitrarily. there is room for improvement.
    if trial_id == 1
        if gap_score < gap_score_threshold
            synchronized_timing_data = [synchronized_timing_data video_timing_data(:, correspond_id)];
        else
            break;
        end
    elseif gap_score - gap_score_list(trial_id-1) < gap_score_threshold
        synchronized_timing_data = [synchronized_timing_data video_timing_data(:, correspond_id)];
    end
end

% if the synchronization rate is low, the data is not raliable, so discard the data
if isempty(synchronized_timing_data)
    return;
else 
    synchronized_trial_num = length(synchronized_timing_data(1, :));
    synchronized_rate = synchronized_trial_num / validate_trial_num;
    if synchronized_rate < 0.8
        synchronized_timing_data = [];
        return;
    end
end
end