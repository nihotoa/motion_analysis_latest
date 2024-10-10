%{
[explanation of this func]:
obtain the camera indicies from the file name of the task video(output by StreamPix) from each camera.

[input arguments]
task_movies_name: [cell array], an array whose elements are the name of
the task videos
(ex.)
task_movies_name = {'camera1.mp4', 'camera2.mp4', 'camera3.mp4', 'camera4.mp4'}

[output arguments]
camera_indicies: [double array], array of camera indicies extracted from 'task_movies_name'
(ex.)
camera_indicies = [1, 2, 3, 4];
%}

function [camera_indicies] = getCameraIndicies(task_movies_name)
temp = regexp(task_movies_name, 'camera(\d+)', 'tokens');
temp = [temp{:}];
camera_indicies = str2double([temp{:}]);
end