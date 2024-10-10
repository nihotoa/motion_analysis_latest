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
cluster_idx = kmeans(ref_array(:), 2);
bright_indicies = find(cluster_idx==2);
rising_indicies = eliminate_consective_num(bright_indicies, 'front');
falling_indices = eliminate_consective_num(bright_indicies, 'back');
end