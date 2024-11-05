%{
[explanation of this func]:
extracts the frame index for switching the LED on and off from the  array conitaining the RGB values of the LED and returns it as an array

[input arguments]
ref_array: [double vector], an array containing one of RGB values (R, G or B) fro each frame

[output arguments]
light_up_indices: [double array], List of indices at the time when the value rising sharply
turn_off_indices: [double array], List of indices at the time when the value falling sharply

[caution]
this is implemented based on binary classification, so it does not support
situations that include anything other than the LED being on or  off. (For example, when an object passes through in a waty  that overlaps with the LED)

[improvement point(japanese)]
エラー文が抽象的すぎるので、もうちょっと考える
%}

function [light_up_indices, turn_off_indices] = findLEDChanges(ref_array)
[cluster_idx, center_value_list] = kmeans(ref_array(:), 2);

% perform smoothing(handling for when some object unexpectedly overlaps with the LED)
window_size = 3;
for frame_idx = (window_size+1) : (length(cluster_idx) - window_size)
    ref_frame_cluster_idx = cluster_idx(frame_idx);
    if and(not(ref_frame_cluster_idx == cluster_idx(frame_idx - window_size)), not(ref_frame_cluster_idx == cluster_idx(frame_idx + window_size)))
        cluster_idx(frame_idx-window_size+1:frame_idx+window_size-1) = cluster_idx(frame_idx - window_size);
    end
end

% create an array by extracting only the index of the timing when the cluster number switches
[~, bright_cluster_num] = max(center_value_list);
bright_indices = find(cluster_idx == bright_cluster_num);
light_up_indices = eliminate_consective_num(bright_indices, 'front');
turn_off_indices = eliminate_consective_num(bright_indices, 'back');

% eliminate the information about the frist frame from 'light_up_indices'(or 'turn_off_indices') & match the number of length between 'light_up_indices' and 'turn_off_indices'
light_up_indices = light_up_indices(2:end);
trial_num = length(light_up_indices);
turn_off_indices = turn_off_indices(1:trial_num);
end

