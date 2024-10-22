%{
[explanation of this func]:
For an array that contains 2 states as values, returns an array of indices
for the timing of state switching

[input arguments]
ref_array: [double array], reference data array(1 dimensional)

[output arguments]
rising_indicies: [double array], List of indicies at the time when the value rising sharply
falling_indices: [double array], List of indicies at the time when the value falling sharply
%}

function [rising_indicies, falling_indices] = findBinaryChanges(ref_array)
[cluster_idx, center_value_list] = kmeans(ref_array(:), 2);

% perform smoothing(handling for when some object unexpectedly overlaps with the LED)
window_size = 3;
for frame_idx = (window_size+1) : (length(cluster_idx) - window_size)
    ref_frame_cluster_idx = cluster_idx(frame_idx);
    if and(not(ref_frame_cluster_idx == cluster_idx(frame_idx - window_size)), not(ref_frame_cluster_idx == cluster_idx(frame_idx + window_size)))
        cluster_idx(frame_idx-window_size+1:frame_idx+window_size-1) = cluster_idx(frame_idx - window_size);
    end
end

% 
[~, bright_cluster_num] = max(center_value_list);
bright_indicies = find(cluster_idx == bright_cluster_num);
rising_indicies = eliminate_consective_num(bright_indicies, 'front');
falling_indices = eliminate_consective_num(bright_indicies, 'back');
end