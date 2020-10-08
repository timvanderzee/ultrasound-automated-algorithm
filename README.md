# Ultrasound-automated-algorithm

This respository includes code that can be used to estimate muscle fascicle lengths and pennation angles from muscle ultrasound images. The algorithm uses a combination of Frangi filtering, Hough transform and feature detection. 

This algorithm has been used for determination of fascicle lengths during isometric knee torque production, see: https://www.biorxiv.org/content/10.1101/2020.08.23.263574v1

In addition, it has been used to estimate muscle work and its associated energetic cost during cyclic torque production, see: https://www.biorxiv.org/content/10.1101/2020.08.25.266965v1

## Main scripts: classic or live

**Recommended**: run the MATLAB live script called *example_live.mlx*. This live script allows you to update parameter values and investigate their effect on the outcome

**Alternative**: if you don't have the option to run MATLAB live scripts (e.g. old MATLAB version), you can run the 'classic' MATLAB script called *example.m*. This function calls the same functions as *example_live.mlx* (listed below), but does not provide the option to adjust parameters (instead, it uses the parameters stored in *parms.mat*)
## Images

**example_ultrasound_image.mat**: 
* Muscle: Vastus Lateralis
* Ultrasound device: General Electric Logiq E9
* Facility: University of Calgary, Canada
* Investigator: Tim van der Zee
* Format: .mat

**example_ultrasound_image2.png**: 
* Muscle: Vastus Lateralis
* Ultrasound device: Telemed LVD8-4L65S-3
* Facility: University of Verona, Italy
* Investigator: Paolo Tecchio
* Format: .png

**example_ultrasound_image3.png**: 
* Muscle: Gastrocnemius Medialis
* Ultrasound device: Telemed LVD8-4L65S-3
* Facility: University of Verona, Italy
* Investigator: Paolo Tecchio
* Format: .png

## Functions
**Frangi filter folder**: contains Frangi filter functions created by Dirk-Jan Kroon (https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)

**dohough.m**: executes MATLABs hough transform function (https://www.mathworks.com/help/images/ref/hough.html) and uses a weighted average of the most frequently occuring angles in the image to estimate fascicle angle (i.e. with the horizontal)

**superapo_func.m**: uses feature detection to extract the location of the superficial aponeurosis, which is used to determine muscle thickness and superficial aponeurosis angle

**deepapo_func.m**: uses feature detection to extract the location of the deep aponeurosis, which is used together with the location fo the superficial aponeurosis to determine muscle thickness 

**cut_apo**: cuts the actual ultrasound image out of the original image (the latter includes a black frame). This would not be neccesary if the ultrasound image takes up the entire original image

## Additional scripts
**ComputeAndDisplayHoughTransformExample**: adapted version of MATLABs example for using their hough transform function on a build-in image ('gantrycrane.png') (see: https://www.mathworks.com/help/images/ref/hough.html). Adapted to allow for visualizing lines and playing with the npeaks parameter that sets the amount of extracted lines. 

For questions, please email me: tim.vanderzee@ucalgary.ca
