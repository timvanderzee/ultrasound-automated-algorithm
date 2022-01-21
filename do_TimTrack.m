function[geofeatures, apovecs, parms] = do_TimTrack(image_sequence, parms)

%% Check input type
% if string, assume that its the file name and load it
if ischar(image_sequence) || isstring(image_sequence)
    disp('Reading video file into VideoReader ...')
    v = VideoReader(image_sequence);
    disp('Reading complete')
    disp(' ')
    disp(['Your video contains ', num2str(v.Duration), ' seconds of data']) 
    disp('We recommend analyzing less than 10s of data, to avoid running out of RAM')
    nsec = input('How many seconds of data would you like to analyze? ');
    nframes = round(min([v.Duration, nsec]) * v.FrameRate);
    
    disp(['Reading ', num2str(nsec), 's of ultrasound data'])
    image_sequence = read(v, [1 nframes]);
    disp('Reading complete')
end

% convert to grayscale
q = size(image_sequence,4);
if q > 1, image_sequence = squeeze(image_sequence(:,:,1,:));
end

% if not a string, assume its a m-by-n-by-p matrix
[m,n,p] = size(image_sequence);

%% Region-of-interest (ROI)
% region of overall image corresponding to ultrasound image

% take assigned value if it exists, otherwise take full image
if ~isfield(parms,'ROI'), ROI = [1 n; 1 m];
else, ROI = parms.ROI;
end

% if you want to cut/crop first, adjust region-of-interest
if isfield(parms,'cut_image')
    if parms.cut_image
        ROI = cut_image(image_sequence(:,:,1));
        parms.ROI = ROI;
    end
end

% crop/cut image so that only ultrasound portion remains
image_sequence_cut = image_sequence(ROI(2,1):ROI(2,2), ROI(1,1):ROI(1,2),:);
    
%% Optional flipping and downsampling
% if you want to flip first
if isfield(parms,'flip_image')
    if parms.flip_image
        image_sequence_cut = flip(image_sequence_cut,2);
    end
end

% if you want to downsample
if isfield(parms,'downsample')
    if parms.downsample > 1
        i = 1:parms.downsample:p;
        image_sequence_cut = image_sequence_cut(:,:,i);
        p = size(image_sequence_cut,3);
    end
end

%% Timtrack Analysis
disp('Starting TimTrack analysis ...')

for i = 1:p 
%     disp(i)

    s = tic;
    [geofeatures(i), apovecs(i), parms] = auto_ultrasound(image_sequence_cut(:,:,i), parms);
    geofeatures(i).analysis_duration = toc(s);

    % write image to GIF file
    if isfield(parms, 'makeGIF')
        if parms.makeGIF
           if i == 1, GIF_filename = input('Please provide GIF filename: ','s'); gif([GIF_filename,'.gif']) 
           else, gif;
           end
        end
    end
end

% store image sequence
parms.image_sequence = image_sequence_cut;

%% Optional post-hoc correction
if isfield(parms, 'posthoc_correction')
    if parms.posthoc_correction
        % show extrapolated portion and brightness
        for i = 1:length(geofeatures)
            b(i) = geofeatures(i).brightness;
            extr_frac(i) = geofeatures(i).extrapolated_fraction;
        end

        max_brighness = double(max(parms.image_sequence(:)));
        brel = b/max_brighness;
        extr_frac(extr_frac<0) = 0;

        if ishandle(100), close(100); end
        
        figure(100);         c = get(gca,'colororder');
        subplot(121); plot([0 i], [.5 .5], 'k--'); hold on
        plot(extr_frac,'linewidth',1.5,'color',c(1,:));
        xlabel('Image #'); ylabel('Extrapolated fraction'); title('Extrapolated fraction')
        extr_frac(extr_frac < .5) = nan;
        hold on; plot(extr_frac,'linewidth',1.5,'color',c(2,:)); axis tight; grid on

        subplot(122); plot([0 i], .5*[mean(brel) mean(brel)], 'k--'); hold on
        plot(brel,'linewidth',1.5,'color',c(1,:)); 
        plot([0 i], [mean(brel) mean(brel)], '--', 'color',c(1,:))
        xlabel('Image #'); ylabel('Brightness'); title('Image brightness')
        brel(brel > (.5*mean(brel))) = nan;
        hold on; plot(brel,'linewidth',1.5,'color',c(2,:)); axis tight; grid on
    end
    
    %% Ask whether want to run step 5 and 6
    if parms.extrapolation, disp('Already in extrapolation mode'); parms.step5 = 'Y';
    else, parms.step5 = input('Would you like to re-run analysis in extrapolation mode? Y/N [Y]:','s');
    end
    
    parms.step6 = input('Would you like to interpolate estimates for images below a chosen brightness threshold? Y/N [Y]:','s');
    
    if strcmp(parms.step5,'Y'), parms.extrapolation = 1;
    end
    if strcmp(parms.step6,'Y'), bth = input('Which brightness threshold do you want to use? (0-1)');
    end
    
    %% Run step 5 or step 6 if asked for
    if strcmp(parms.step5,'Y') || strcmp(parms.step6,'Y')
        [geofeatures, apovecs] = post_hoc_correction(geofeatures, apovecs, parms, bth);
    end
end
end