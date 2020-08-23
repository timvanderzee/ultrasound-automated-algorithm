# ultrasound_automated_algorithm

This respository includes code that can be used to estimate muscle fascicle lengths and pennation angles from muscle ultrasound images. The algorithm uses a combination of Frangi filtering, Hough transform and feature detection. 

**example.m**: main script that loads the image *example_ultrasound_image.mat* and the parameters *parms.mat*, and executes the MATLAB functions that are present in this repository

**Frangi filter folder**: contains Frangi filter functions created by Dirk-Jan Kroon (https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)

**dohough.m**: executes MATLABs hough transform function (https://www.mathworks.com/help/images/ref/hough.html) and uses a weighted average of the most frequently occuring angles in the image to estimate fascicle angle (i.e. with the horizontal)

**superapo_func.m**: uses feature detection to extract the location of the superficial aponeurosis, which is used to determine muscle thickness and superficial aponeurosis angle

**deepapo_func.m**: uses feature detection to extract the location of the deep aponeurosis, which is used together with the location fo the superficial aponeurosis to determine muscle thickness 

**cut_apo**: cuts the actual ultrasound image out of the original image (the latter includes a black frame). This would not be neccesary if the ultrasound image takes up the entire original image

Tested for MATLAB versions:
- 2016a
- 2019a

For questions, email to tim.vanderzee@ucalgary.ca
