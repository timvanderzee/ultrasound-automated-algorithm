# Ultrasound-automated-algorithm

This respository includes code that can be used to estimate muscle fascicle lengths and pennation angles from muscle ultrasound images. The algorithm uses a combination of Frangi filtering, Hough transform and feature detection. 

This algorithm has been used for determination of fascicle lengths during isometric knee torque production, see: https://www.biorxiv.org/content/10.1101/2020.08.23.263574v1

In addition, it has been used to estimate muscle work and its associated energetic cost during cyclic torque production, see: https://www.biorxiv.org/content/10.1101/2020.08.25.266965v1

## Main function: auto_ultrasound.m
[alpha, betha, thickness] = auto_ultrasound(data,parms)

**Inputs**

* data: needs to be grayscale (therefore m-by-n numeric array). see: https://www.mathworks.com/help/matlab/ref/rgb2gray.html on how to convert rgb to grayscale
* parms: struct specifying the parameters used in the algorithm, with fields frangi, fas and apo

**Outputs**

* alpha: fascicle angle with the horizontal (degrees)
* betha: superficial aponeurosis angle with horizontal (degrees)
* thickness: perpendicular distance between superficial- and deep aponeurosis (pixels)

**Outputs may be used to determine pennation angle (phi) and fascicle length (faslen):**
* phi = alpha - betha;
* faslen = thickness ./ sind(phi);

## Example scripts: example.m and example_live.mlx

Both scripts run auto_ultrasound.m on example image(s)

**Example.m**: script that loads parameters stored in *parms.mat*, which are suited for example data *example_ultrasound_image.mat*

**Example_live.mlx**: live script that facilitates updating parameter values and investigate their effect

## Folders
**Frangi Filter**: contains Frangi filter functions created by Dirk-Jan Kroon (https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)

**Aponeurosis**

* *superapo_func.m*: uses feature detection to extract the location of the superficial aponeurosis, which is used to determine muscle thickness and superficial aponeurosis angle

* *deepapo_func.m*: uses feature detection to extract the location of the deep aponeurosis, which is used together with the location fo the superficial aponeurosis to determine muscle thickness 

* *cut_apo*: cuts the actual ultrasound image out of the original image (the latter includes a black frame). This would not be neccesary if the ultrasound image takes up the entire original image

**Hough**

* *dohough.m*: executes MATLABs hough transform function (https://www.mathworks.com/help/images/ref/hough.html) and uses a weighted average of the most frequently occuring angles in the image to estimate fascicle angle (i.e. with the horizontal)

* *ComputeAndDisplayHoughTransformExample.m*: adapted version of MATLABs example for using their hough transform function on a build-in image ('gantrycrane.png') (see: https://www.mathworks.com/help/images/ref/hough.html). Adapted to allow for visualizing lines and playing with the npeaks parameter that sets the amount of extracted lines. 

**Parameters**: contains default parameters *parms.mat* and a script to create these *default_parms.m*

**Data**: contains example data

*example_ultrasound_image.mat*
* Muscle: Vastus Lateralis
* Ultrasound device: General Electric Logiq E9
* Facility: University of Calgary, Canada
* Investigator: Tim van der Zee
* Format: .mat

*example_ultrasound_image2.png*
* Muscle: Vastus Lateralis
* Ultrasound device: Telemed LVD8-4L65S-3
* Facility: University of Verona, Italy
* Investigator: Paolo Tecchio
* Format: .png

*example_ultrasound_image3.png*
* Muscle: Gastrocnemius Medialis
* Ultrasound device: Telemed LVD8-4L65S-3
* Facility: University of Verona, Italy
* Investigator: Paolo Tecchio
* Format: .png

For questions, please email me: tim.vanderzee@ucalgary.ca
