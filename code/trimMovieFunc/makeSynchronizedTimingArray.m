function [synchronized_timing_data]= makeSynchronizedTimingArray(real_timing_data, video_timing_data)
validate_range = ceil(video_timing_data(2, end) / 10) * 10;
validate_trial_num = max(find(real_timing_data(2, :) < validate_range));
validate_real_timing_data = real_timing_data(:, 1:validate_trial_num);
synchronized_timing_data = [];
gap_score_list = zeros(1, validate_trial_num);
for trial_id = 1:validate_trial_num
    ref_real_timing = validate_real_timing_data(:, trial_id);
    gap_timings = video_timing_data - ref_real_timing;
    gap_durations = abs(gap_timings(2, :) - gap_timings(1, :));
    gap_scores = sum([abs(gap_timings); gap_durations]);
    [gap_score, correspond_id] = min(gap_scores);
    gap_score_list(trial_id) = gap_score;
    if trial_id == 1
        if gap_score < 200
            synchronized_timing_data = [synchronized_timing_data video_timing_data(:, correspond_id)];
        else
            break;
        end
    elseif gap_score - gap_score_list(trial_id-1) < 200
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