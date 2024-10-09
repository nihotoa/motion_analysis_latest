%{
[explanation of this func]:
returns the RGB values of specified pixel in the video for all frames.
you can obtain 'Specified pixel' by GUI operation.
This function is manly used when you want to know the RGB value of LED.

[input arguments]
movie_path: [char], full path of the video to be referenced
LED_color: [char], color of LED

[output arguments]
rgb_value_array: [double array], RGB values of the specified pixels in each
frame (= index). the size is [3, total number of frames]. number of row is 3 and means R, G, B
%}

function [rgb_value_array] = getLEDRGB(movie_path, LED_color)
try
    ref_video_obj = VideoReader(movie_path);
catch
    error(['次のmovieを読み込むことができませんでした。動画を確認してください: ' movie_path]);
end

rgb_value_array = nan(3, ref_video_obj.NumFrames);

% ref_video_objから画像オブジェクトを抽出(動画終わるまでiteration)
frame_idx = 0;
while frame_idx < ref_video_obj.NumFrames
    frame_idx = frame_idx + 1;
    try
        ref_frame_img = read(ref_video_obj, frame_idx);
    catch
        continue;
    end

    % LEDの位置を選んでもらって座標を取得する
    if frame_idx == 1
        while true
            disp(['Please click on the ' LED_color ' LED']);
            imshow(ref_frame_img);
            LED_figure = gcf;
            title(['Please click on the ' LED_color ' LED'], FontSize=15);
            [LED_x, LED_y] = ginput(1);
            
            hold on 
            fprintf("if it's ok, press 'Enter', if not, press 'd'\n")
            title('Enter = accept, D = select again', FontSize=15);
            plot(LED_x, LED_y, 'r+', MarkerSize=15, LineWidth=2);
            hold off;

            waitforbuttonpress;
            key_pressed = get(gcf, 'CurrentKey');
            if strcmp(key_pressed, 'return')
                close(LED_figure)
                break;
            else
                disp('Please select LED again');
            end
            close(LED_figure)
        end
    end

    % LEDの輝度値を算出する。
    rgb_value_array(1, frame_idx) = ref_frame_img(LED_y, LED_x, 1);
    rgb_value_array(2, frame_idx) = ref_frame_img(LED_y, LED_x, 2);
    rgb_value_array(3, frame_idx) = ref_frame_img(LED_y, LED_x, 3);

    % 明示的にclear(メモリを解放するため)
    clear ref_frame_img;
end
% NaN値を線形補完で埋める
for color_idx = 1:3
    ref_color_value_array= rgb_value_array(color_idx, :);
    have_value_indicies = find(~isnan(ref_color_value_array));
    have_value_array = ref_color_value_array(1, have_value_indicies);
    nan_indicies = find(isnan(ref_color_value_array));
    ref_color_value_array(isnan(ref_color_value_array)) = interp1(have_value_indicies, have_value_array, nan_indicies); 
    rgb_value_array(color_idx, :) = ref_color_value_array;
end
end

