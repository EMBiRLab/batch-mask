# Table of Contents
[Introduction](#intro)

1 [Implementing Batch-Mask on a sample dataset to reproduce the results from our paper](#1)
* 1.1 [Downloading the code](#1.1)
* 1.2 [Batch Mask setup](#1.2)
* 1.3 [Implementation on a sample dataset](#1.3)

2 [Implementing Batch-Mask on a custom set of images using our pre-trained weights](#2)
* 2.1 [Downloading the code and adding a custom dataset](#2.1)
* 2.2 [Batch-Mask setup and editing the config file setup](#2.2)
* 2.3 [Implementation on custom dataset](#2.3)

3 [Training and implementing Batch-Mask on a custom set of images using custom weights](#3)
* 3.1 [Creating training masks using ImageJ](#3.1)
  * 3.1.1 [ImageJ setup](#3.1.1)
  * 3.1.2 [Labeling regions of interest (ROIs) in ImageJ](#3.1.2)
  * 3.1.3 [Editing ROI labels in ImageJ](#3.1.3)
* 3.2 [Downloading the code, creating a session folder, and adding custom training and inference datasets](#3.2)
* 3.3 [Checking your training dataset](#3.3)
* 3.4 [Training the neural network](#3.4)
  * 3.4.1 [Beginning the training process](#3.4.1)
  * 3.4.2 [Viewing loss values](#3.4.2)
  * 3.4.3 [Evaluation metrics](#3.4.3)
* 3.5 [Implementing Batch-Mask using custom generated weights](#3.5)

4 [Preparing Batch-Mask outputs for downstream analysis in micaToolbox](#4)
* 4.1 [Batch generating multispectral (.mspec) images for micaToolbox](#4.1)
* 4.2 [Editing multispectral image files](#4.2)

[Source Repositories and Software](#source)

<a name="intro"></a>
# Introduction
Hello, and thank you for using Batch-Mask! This workflow utilizes a customized region-based convolutional neural network (R-CNN) model to generate masks of snakes in photographs (see our accompanying paper [https://doi.org/10.1093/icb/icac036]) but can be applied to various organisms with limbless or nonstandard body forms. The neural network uses the training process to fine-tune mask weights from pre-trained weights provided with Mask R-CNN. We have included all necessary code in this repository for utilizing Batch-Mask on Google Colaboratory, as well as a version of the ImageJ software for Windows with the necessary plugins for dataset labeling and MicaToolbox Pattern analysis. 

This README file includes a tutorial and information for 1) implementing Batch-Mask on a sample dataset of snake images to reproduce the results of our paper, 2) implementing Batch-Mask on a custom set of images using our pre-trained weights, 3) training the neural network on a custom set of images and using the resulting weights to implement Batch-Mask on a custom set of images, and 4) preparing Batch-Mask outputs for downstream analyses in MicaToolbox.

<a name="1"></a>
# 1 Implementing Batch-Mask on a sample dataset to reproduce the results from our paper [https://doi.org/10.1093/icb/icac036]

<a name="1.1"></a>
## 1.1 Downloading the code
Download the zipped repository (batch-mask-v1.0.0.zip or newer version) from https://doi.org/10.7302/3xwv-7n71, extract/unzip if necessary, and upload the folder to your “My Drive” folder on Google Drive.

Navigate to the repository in Google Drive and find “batch_mask.ipynb” in “batch-mask-v1.0.0/code/scripts”. Right-click the ipynb file, then click “Open with” and select Google Colaboratory (hereafter referred to as “Google Colab”). If Google Colab is not available as an option, you may have to select “Connect more apps” and add the Google Colab app. The notebook should open in a new window.

<a name="1.2"></a>
## 1.2 Batch-Mask setup
In order to use the Batch-Mask script, you must first link your Google Drive folder to Google Colab. Press play on the first cell block. You will be asked to give Google Colab permission to access Google Drive. Follow the on-screen prompts to sign in to your Google account. 

Next, check the second cell block and ensure that the file path to your config file is correct. You can check file paths and modify files within the Google Colab notebook by clicking the folder icon on the left-hand side of the screen. In the side panel that pops up, navigate to the config file. If you are using the provided config.ini file, it should be located in “drive/MyDrive/batch-mask-v1.0.0/data/snake-session”. You can edit this file by double clicking it (opens in a new panel on the right-hand side of the screen) or copy its file path by right clicking it and selecting “Copy path”. This config file should be edited when using custom datasets or weights, but to reproduce the results of our paper, it does not need to be edited. Click the play button in this cell block to install the dependencies and run the setup script.

After this cell block has completed, scroll down to the cell block under the Code heading and click the play button to compile the code. Once this has finished running, the Batch-Mask script is ready to be implemented. 

<a name="1.3"></a>
## 1.3 Implementation on a sample dataset

Scroll down to the cell block under the Detect heading. Pressing play will generate masks for the unlabeled set of test images provided in the download; these are the same 50 images that were used in our paper. Batch-Mask can generate three output types, as follows:

* "json" will output the mask in the same format as the .json files used for training.
* "binary" will output the mask as a .csv file with each cell containing a zero or a one. This is the most universal style of output.
* "splash" will output a .jpg copy of the original image but with a blue overlay showing which portions of the image are not included in the mask. This is a non-functional output but can be used to determine the qualitative performance of the neural network.

Type the desired output type in the cell block before pressing play. To use multiple output types, you can separate them using the '&' character. For example, to create outputs for both "binary" and "splash", you would set the output type to be "binary&splash". Output folders are specified in the config file and are located in the snake-session folder.

If you need to resume detection because Google Colab timed out or you ran into resource limits, set resume equal to True in the cell block and run again; Batch-Mask will resume from the last output file in the output folder.

<a name="2"></a>
# 2 Implementing Batch-Mask on a custom set of images using our pre-trained weights

<a name="2.1"></a>
## 2.1 Downloading the code, creating a session folder, and adding a custom dataset
Download the code and upload to Google Drive in the same way as described in 1.1. 
In Google Drive, navigate to the datasets folder (“MyDrive/batch-mask-v1.0.0/data/datasets”) and create a new folder for your custom dataset. Upload all images that you wish to mask to this folder.

The Google Colab script contains a cell block under the heading Custom Dataset that will generate a new session folder for your custom dataset and Batch-Mask outputs, as well as the necessary config file. Set the log_dir in the cell block to be the directory where you want your session folder to be located, and set the dataset_dir to the custom dataset directory. Click the play button on the cell block to create the new session folder.

If desired, you can create custom folders for Batch-Mask to output files for your dataset. To create a custom output folder, navigate to the session folder (or the snake-session folder, if you did not create a new one [“MyDrive/batch-mask-v1.0.0/data/snake-session”]) and create (a) new subfolder(s) for your desired output type(s).

If desired, you can also create a metadata file, an optional .csv file that allows Batch-Mask to automatically name the mask ROIs that it generates. To do this, simply create a .csv file, and in the first column, enter a list of all the source images to be masked. Mask ROI names will be created using any text or values entered in columns after Column A (up to three columns). When done creating this .csv file, upload it to the datasets folder (“MyDrive>batch-mask-v1.0.0>data>datasets”).

Follow the rest of the instructions in 1.1 to open the Batch-Mask notebook in Google Colab.

<a name="2.2"></a>
## 2.2 Batch-Mask setup and editing the config file 
Link your Google Drive account to the Colab notebook and navigate to the config file as described in 1.2. 

Double click the config.ini file, and a new panel will pop up on the right-hand side, allowing you to edit it. Because you are using our pre-trained weights, you only need to edit Line 21. Enter the path to your custom dataset’s subfolder in this line (see 1.2 for how to copy paths in Google Colab). 

If you created (a) custom folder(s) for Batch-Mask outputs, you should enter the file path(s) to that/those folder(s) in Lines 24 to 26, depending on which output type(s) you desire. If you created a metadata file, you should enter the path to that .csv file in Line 28. 

Batch-Mask is also able to generate a scale bar for each image if certain conditions are met. In our snake image dataset, and in many datasets that include visible and/or UV color standards, all photos included a circular color standard of known radius. If your images contain a circular standard and your output type is “json”, you can enable this scale bar detection step by editing Lines 12 and 13 of the config file. Simply enter the radius of the standard (our gray UV standard had a radius of 16.6085mm) into Line 12 and set “CALCULATE_SCALE_BAR” equal to “True” in Line 13. You may need to add a “[SCALE BAR]” section to the bottom of the config file. Here, you specify the minimum radius (in pixels) that the algorithm uses to find the circular standard. For our snake dataset, 550 pixels worked for all but one image. To adjust the values for outlier images, enter the name of the image (minus the file extension) and the specified number of pixels (e.g., for our outlier, we entered “DSC_1705 : 600”).

You can now close the config file editing panel. 

Click the play button on the cell block to install dependencies and run the setup script, then click the play button on the cell block to compile the code (as in 1.2).

<a name="2.3"></a>
## 2.3 Implementation on a custom dataset
Scroll down to the cell block under the Detect heading, select an output type (see 1.3), and press play to generate masks for the images in your custom dataset. Files generated by Batch-Mask will be outputted to the folder(s) specified in the config file.

<a name="3"></a>
# 3 Training and implementing Batch-Mask on a custom set of images using custom weights

Note: Generating custom weights to use on a custom dataset involves training the neural network. The training process requires images that have been masked by hand. We provide instructions here for how to create these hand-drawn masks using ImageJ on a Windows operating system.

<a name="3.1"></a>
## 3.1 Creating training masks using ImageJ 

<a name="3.1.1"></a>
### 3.1.1 ImageJ setup
Download the code and upload to Google Drive in the same way as described in 1.1. In Google Drive, navigate to ImageJ (“batch-mask-v1.0.0/software/ImageJ”) and run “ImageJ.exe”.

<a name="3.1.2"></a>
### 3.1.2 Labeling regions of interest (ROIs) in ImageJ
Using “File->Open” in the ImageJ taskbar, open the image file to be labelled.

Select the polygon tool to outline the specimen or region of interest in the image. 

For a specimen that is coiled (e.g., a snake), first outline the outer edge of the specimen, then click “Edit->Selection->Make Inverse” to invert the selection. While holding the shift key, outline the parts within the original selection that are not part of the specimen. This will create a composite, donut-like shape. Finally, click “Edit->Selection->Make Inverse” to invert the selection again. Click on the ROI Manager (or “t” for a shortcut), select the ROI from the ROI Manager, and click rename to rename the ROI to “mask”.

For specimens that are not coiled, simply use the polygon tool to outline the specimen. Click on the ROI Manager (or “t” for a shortcut), select the ROI from the ROI Manager, and click rename to rename the ROI to “mask”.

To export the labels to a .json file, go to “Plugins->JSON ROI->Export” and a save dialogue box will appear. The default name for the .json file will be the same as the image file. Do not change this name, as the training script in Batch-Mask links the .json file to the .jpg file using filenames. Click “Save”.

Close the ROI Manager and the current open image before moving on to the next image. Feel free to click “Discard” on any save messages that pop up after closing windows.

<a name="3.1.3"></a>
### 3.1.3 Editing ROI labels in ImageJ
If exported labels need to be edited for any reason, open the image in ImageJ, press 't' to bring up the ROI manager, then go to “Plugins->JSON ROI->Import” and select the .json file to import. This will load the ROIs, which can then be edited. Use the instructions in 3.1.2 to export the edited labels to a .json file when done.

<a name="3.2"></a>
## 3.2 Downloading the code, creating a session folder, and adding custom training and inference datasets
Follow the instructions in 2.1 to download the code, create a session folder, and add your custom dataset (the dataset on which you wish to run Batch-Mask once it has been trained).

In addition, make a folder in the datasets folder (“MyDrive>batch-mask-v1.0.0>data>datasets”) to contain the training dataset, and title this folder “train_val_sets”. If your training dataset has subcategories, make separate subfolders for each (e.g., we divided our snake dataset into two subsets, dorsal and ventral). This is useful for comparing results from training on specific subsets of the data. Note that subset folders **cannot** be named “all”. In your subfolders, or in the “train_val_sets” folder if you did not create subfolders, upload the .json files you created in ImageJ, as well the image file associated with each.

Follow the rest of the instructions in 2.1 to open the Batch-Mask notebook in Google Colab. Link your Google Drive account to the Colab notebook as described in 1.2. 

<a name="3.3"></a>
## 3.3 Checking your training dataset
To make sure your training images and .json files are all present and loading properly, you can check your dataset by running the cell block under the heading Check Dataset. Set the “images_path” AND the “labels_path” to the path where your “train_val_sets” folder is located. You can modify the start and end values (the range of images to check) if you wish, but we suggest checking in batches of 50 due to limited RAM resources. Set the mode to either “json” or “binary” depending on the type of label.

<a name="3.4"></a>
## 3.4 Training the neural network

<a name="3.4.1"></a>
### 3.4.1 Beginning the training process
Open the config.ini file for editing as described in 2.2. 

Edit Line 18 to specify the path to the training set folder. You must also specify which weight files from which you would like to begin training. We used the “coco” weight files as our starting weights but may begin training from our weight file (“data/snake_epoch_16.h5”) if you wish.

You may also change the training parameters in the config file to yield better training results for a custom dataset. See our paper for information and recommendations for adjusting parameters.

When done editing the config file, close it. Run the cell block under the heading Train to begin training. For our paper, it took approximately 24 hours to finish the training process.

If the training process stops because Google Colab times out, you may resume the training process by setting the training weights to the last weight file save, which can be found in the weights folder on Google Drive. Running the cell block will then resume the training process with those weights. The number of epochs does **not** need to be changed. The code will automatically detect how many epochs are remaining.

<a name="3.4.2"></a>
### 3.4.2 Viewing loss values
Once the training process has finished, you can view the loss values using the second cell block under the Train heading. Specify the weights output folder and click the play button.

After viewing the loss values choose an epoch for inference/detection. Copy and paste the associated weight file path into the config.ini file on Line 22.

<a name="3.4.3"></a>
### 3.4.3 Evaluation metrics
To obtain the average IOU or IOL metrics for the validation partition for each subset of the training set, run the cell block under the heading Get Model Metric. Note that evaluation metrics are running using the test weights specified in the config file.

<a name="3.5"></a>
## 3.5 Implementing Batch-Mask using custom generated weights
Ensure that the path to the appropriate weight file and the path to your custom, unlabeled dataset have been entered in the config file. Follow the directions in 2.3 to implement Batch-Mask.

<a name="4"></a>
# 4 Preparing Batch-Mask outputs for downstream analysis in micaToolbox

Note: The following tutorial was written for a Windows operating system and includes instructions for how to generate and edit multispectral images using our sample dataset. 

<a name="4.1"></a>
## 4.1 Batch generating multispectral (.mspec) images for micaToolbox

After downloading, unzipping, and uploading the Batch-Mask repository to Google Drive (as in 1.1), navigate to “batch-mask-v1.0.0/data/imagej”. Note that the non-color-corrected images are located in the folder “data/imagej/non_color_corrected_images”, the .json masks created by hand in ImageJ are in the folder “data/imagej/training_masks”, and the .json masks generated from Batch-Mask are located in the folder “data/imagej/inference_masks”.

Create a new folder and copy or move the non-color-corrected images and .json files containing the labels for the masks (and scale bars, if generated) into it. 

In Google Drive, navigate to "batch-mask-v1.0.0/code/scripts" and open "_Generate_Multispectral_Image_Costum.ijm" in a text editor. On Line 55, set the path to the folder in which the .json files and source images are stored. On Line 56, set resume to "" if starting from the beginning. If resuming from an earlier session, set resume to the name of the image you wish to start from (e.g., "V8.jpg").

In Google Drive, navigate to " batch-mask-v1.0.0/code/scripts/JSON ROI/" and open "mica_import.py" in a text editor.

On Line 31, set the directory variable to the folder in which the json files and source images are stored.

Finally, navigate to “batch-mask-v1.0.0/software/ImageJ” and click “ImageJ.exe”.

In ImageJ, click “Plugins->Multispectral Imaging->Batch Generate Multispectral Images”.

Select the 5 percent color standard.

Select the 95 percent color standard.

Repeat the color standard selection for the entire folder.

Once the script is finished, the .mspec and ROI files will be saved in the same directory as the .json files and source images. These must stay in the same directory for other micaToolbox features to work.

You can follow this Youtube tutorial to replicate the pattern processing we performed for our paper: https://youtu.be/T62fr25b75M?t=3281

<a name="4.2"></a>
## 4.2 Editing multispectral image files

To open a multispectral image in imageJ, go to “Plugins->Multispectral Imaging->Load Multispectral Image” and select the desired .mspec file. Leave the image output as the default “Aligned Normalised 32-bit” and click “OK”.

To edit the mask, click on its ROI in the ROI Manager and adjust the mask’s nodes as necessary. Click ‘Update’ in the ROI Manager to apply the changes and type ‘0’ to save the .mspec file.

If you would like to add a scale bar to your .mspec image (if, for example, your images did not have a circular color standard for Batch-Mask to detect), you can do so in imageJ.

Click on the “Straight” selector.
Outline an object or portion of an object of known size in the image (e.g., a ruler).
Type “S” and enter the length of the scale bar in the window that appears. Make sure your units of measurement are correct. Click “OK”. Type “0” to save the .mspec. If you wish to edit the scale bar, simply delete the scale bar’s ROI from the ROI Manager and create a new one.

<a name="source"></a>
# Source Repositories and Software
* Original Mask RCNN Repository: https://github.com/matterport/Mask_RCNN
* Updated Mask RCNN for Tensorflow 2: https://github.com/akTwelve/Mask_RCNN
* micaToolbox version 1 website: http://www.jolyon.co.uk/myresearch/image-analysis/image-analysis-tools/
* ImageJ version 1 website: https://imagej.nih.gov/ij/download.html
