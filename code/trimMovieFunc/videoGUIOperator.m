function [currentFrame] = videoGUIOperator(ref_trial_movie_path)
    % 動画オブジェクトの作成
    disp("Move to the frame you want to cut out and press 'Enter'")
    disp('←: previous frame , →: next frame')
    videoObj = VideoReader(ref_trial_movie_path);
    numFrames = videoObj.NumFrames;
    
    % 初期フレームの画像データを取得
    currentFrame = 1;
    frame = read(videoObj, currentFrame);
    
    % Figureの設定
    figure_size = [100, 100, size(frame, 2), size(frame, 1)];
    hFig = figure('Name', 'AVI Frame-by-Frame Viewer', 'KeyPressFcn', @keyPressCallback, 'Position', figure_size);
    hIm = imshow(frame, 'Border', 'tight');
    
    % フレーム番号表示用のテキスト
    hText = text(10, 10, sprintf('Frame: %d / %d', currentFrame, numFrames), ...
                 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold', ...
                 'BackgroundColor', 'black', 'Margin', 5);
             
    % スライダー（シークバー）の作成
    hSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', numFrames, 'Value', currentFrame, ...
                        'Units', 'normalized', 'Position', [0.1, 0.05, 0.8, 0.05], ...
                        'Callback', @sliderCallback);
    addlistener(hSlider, 'ContinuousValueChange', @sliderCallback);
    
    % Figureサイズの調整
    set(hFig, 'Units', 'pixels', 'Position', figure_size);
    
    % キーボード操作用コールバック関数
    function keyPressCallback(~, event)
        switch event.Key
            case 'rightarrow'
                currentFrame = min(currentFrame + 1, numFrames);
            case 'leftarrow'
                currentFrame = max(currentFrame - 1, 1);
            case 'return'
                close(hFig);
                return;
        end
        updateFrame();
    end

    % スライダー操作用コールバック関数
    function sliderCallback(~, ~)
        currentFrame = round(get(hSlider, 'Value'));
        updateFrame();
    end

    % フレーム更新のための関数
    function updateFrame()
        frame = read(videoObj, currentFrame);
        set(hIm, 'CData', frame);
        set(hText, 'String', sprintf('Frame: %d / %d', currentFrame, numFrames));
        set(hSlider, 'Value', currentFrame);
        drawnow;
    end
    
    % Figureが閉じられるまで待機
    waitfor(hFig);
end
