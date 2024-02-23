function finalMask = detectPlate(plateImage)
%DETECTPLATE Detects license plate(s) in an image and returns a binary mask of the location(s)
%
% plateImage - The input image for plate detection
% finalMask  - The resulting binary mask for the plate(s)
%
%%%%%% Write your code here:
% Convert image to HSV color space
    plateImage_hsv = rgb2hsv(plateImage);
    
    % Extract hue and saturation channels
    hue = plateImage_hsv(:,:,1);
    sat = plateImage_hsv(:,:,2);

    %figure(1); imshow(hue); impixelinfo;title('Hue');
    %figure(2); imshow(sat); impixelinfo;title('Saturation');

    % Create a mask based on hue and saturation values
    mask = (0.08 <= hue & hue <= 0.18 & sat >= 0.4 & sat <= 1);
    
    % dilate using SE1
    SE1 = strel('rectangle', [15 5]);
    mask_cleaned = imdilate(mask, SE1);
    %figure(30);
    %imshow(mask_cleaned);impixelinfo;

    % Fill holes in the mask 
    mask_filled = imfill(mask_cleaned, 'holes');
    %figure(3);
    %imshow(mask_filled);impixelinfo;
    %title("filled holes")
    
    % erode using SE2
    SE2 = strel('rectangle', [10 10]);
    mask_processed = imerode(mask_filled, SE2);
    %figure(4);
    %imshow(mask_processed);impixelinfo;title('after erosion');

    % Filter by major axis length
    bw_modified = bwpropfilt(mask_processed, 'MajorAxisLength', [30 500]);
    %figure(7);
    %imshow(bw_modified);impixelinfo;title('filter by MajorAxisLength');
    
    % Filter by eccentricity
    bw_modified_final_Eccentricity = bwpropfilt(bw_modified, 'Eccentricity', [0.87 0.99]);
    %figure(8);
    %imshow(bw_modified_final_Eccentricity);impixelinfo;title('filter by Eccentricity');
    
    % Filter by orientation
    bw_modified_final_orientation = bwpropfilt(bw_modified_final_Eccentricity, 'Orientation', [-45 45]);
    %figure(10);
    %imshow(bw_modified_final_orientation);impixelinfo;title('filter by Orientation');
    
    % Filter by area (keep only the largest area)
    stats = regionprops(bw_modified_final_orientation, 'Area');
    CC = bwconncomp(bw_modified_final_orientation);
    num = CC.NumObjects;
    max = 0;
    for i=1:num
        obj = stats(i);
        a = obj.Area;
        if(a>max)
         max = a;
        end
    end
    bw_final = bwpropfilt(bw_modified_final_orientation, 'Area',[max-1 max+1]);
    % Assign the final mask
    finalMask = bw_final;
end

