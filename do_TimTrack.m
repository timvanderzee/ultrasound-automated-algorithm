function[geofeatures, apovecs, parms] = do_TimTrack(image_sequence, parms)

for i = 1:size(image_sequence,3)
    figure(1)
    [geofeatures(i), apovecs(i), parms] = auto_ultrasound(image_sequence(:,:,i), parms);
    drawnow
end
end