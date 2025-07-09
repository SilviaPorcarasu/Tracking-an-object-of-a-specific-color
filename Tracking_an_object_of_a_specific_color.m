function color_tracking_gui()
    % Create the main window
    fig = uifigure('Name', 'Color Tracking GUI', 'Position', [100 100 800 600]);

   % Create the axes for displaying the video feed
    ax = uiaxes(fig, 'Position', [50 150 700 400]);

    % Create buttons for starting and stopping the tracking
    start_button = uibutton(fig, 'push', 'Position', [350 50 100 40], 'Text', 'Start', 'ButtonPushedFcn', @(src,evt)startTracking(ax));
    stop_button = uibutton(fig, 'push', 'Position', [470 50 100 40], 'Text', 'Stop', 'ButtonPushedFcn', @(src,evt)stopTracking());

    %Create a dropdown menu for selecting the color
    color_dropdown = uidropdown(fig, 'Position', [590 50 100 30], 'Items', {'Red', 'Blue', 'Green'}, 'Value', 'Red');

    % Set up a global variable for the video input object
    global vid;
    vid = videoinput('winvideo', 1, 'MJPG_1280x720');

     tracked_bb = [];
    
    function startTracking(ax)
        global hImg;

        % Start the video stream
        preview(vid);

        % Set up the preview window
        hImg = image(zeros(480, 640, 3), 'Parent', ax);
        preview(vid, hImg);

        % Loop through frames
        while true
            % Acquire a frame
            snap = getsnapshot(vid);

            % Extract the selected color channel
            selected_color = color_dropdown.Value;
            switch selected_color
                case 'Red'
                    snap_color = snap(:,:,1);
                case 'Blue'
                    snap_color = snap(:,:,3);
                case 'Green'
                    snap_color = snap(:,:,2);
            end

            % Subtract the color channel from the grayscale image
            snap_diff = imsubtract(snap_color, rgb2gray(snap));

            % Filter out noise
            snap_diff = medfilt2(snap_diff, [3 3]);

            % Convert the difference image to binary
            snap_binary = im2bw(snap_diff, 0.18);

            % Remove small objects
            snap_binary = bwareaopen(snap_binary, 300);

            % Label connected components
            snap_labels = bwlabel(snap_binary, 8);

            % Get region properties
            stats = regionprops(snap_labels, 'BoundingBox', 'Centroid');

            % Display the new image
            set(hImg, 'CData', snap);

            % Plot rectangles around centroids
            hold(ax, 'on');
             if ~isempty(stats)
                 % Get the centroid of the largest object
                max_area = -Inf;
                max_index = -1;
                for i = 1:numel(stats)
                    bb = stats(i).BoundingBox;
                    current_area = bb(3) * bb(4);
                    if current_area > max_area
                        max_area = current_area;
                        max_index = i;
                    end
                end
                
                if max_index ~= -1
                    bb = stats(max_index).BoundingBox;
                    
                    % Check if there is a previously tracked object
                    if ~isempty(tracked_bb)
                        % Calculate the displacement between the current and previous bounding box centers
                        prev_center = [tracked_bb(1) + tracked_bb(3)/2, tracked_bb(2) + tracked_bb(4)/2];
                        curr_center = [bb(1) + bb(3)/2, bb(2) + bb(4)/2];
                        displacement = norm(curr_center - prev_center);

                        % Only update the tracked bounding box if the displacement is within a threshold
                        if displacement < 50
                            % Update the tracked bounding box
                            tracked_bb = bb;

                            % Delete previous rectangle
                            delete(findobj(ax, 'Type', 'rectangle'));

                            % Plot the new rectangle
                            rectangle(ax, 'Position', tracked_bb, 'EdgeColor', 'r', 'LineWidth', 2);
                        else
                            % If the displacement is too large, clear the tracked bounding box
                            tracked_bb = [];
                        end
                    else
                        % If no previously tracked object, set the current bounding box as the tracked bounding box
                        tracked_bb = bb;

                        % Plot the rectangle
                        rectangle(ax, 'Position', tracked_bb, 'EdgeColor', 'r', 'LineWidth', 2);
                    end
                else
                    % If no object is detected, clear the tracked bounding box
                    tracked_bb = [];
                end
            else
                % If no object is detected, clear the tracked bounding box
                tracked_bb = [];
            end
            
            hold(ax, 'off');

            % Pause to allow for processing and updating the display
            pause(0.01);
        end
    end

    function stopTracking()
        % Stop the video stream
        stoppreview(vid);

        % Clear the axes
        cla(ax);
    end
end