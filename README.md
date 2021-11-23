# Table of Contents
1 Batch Mask
* 1.1 Cloning the Master Repository
* 1.2 Batch Mask Setup
* 1.3 Copying File Paths in Google Colab
* 1.4 Creating A Log Folder
* 1.5 Upload Datasets
* 1.6 Check Dataset
* 1.7 Training the Neural Network
  * 1.7.1 Training Process
  * 1.7.2 Viewing Loss Values
  * 1.7.3 Evaluation Metrics
* 1.8 Inference
* 1.9 Creating A Metadata File
2 ImageJ
* 2.1 Setup
* 2.2 Labeling Datasets
* 2.3 Editing Labels
* 2.4 Batch Generating Multispectral Images for MicaToolBox

# Introduction
The datasets and weight files that were used for the Batch-Mask paper can be downloaded from here: https://doi.org/10.7302/3xwv-7n71
This tutorial will reference this folder as the Snake data folder.
The Batch-Mask paper results were obtained from a sample of a larger photo dataset that can be found here: https://doi.org/10.7302/qta3-xs67

# 1 Batch Mask
## 1.1 Cloning the Master Repository
Download the repository, extract it, and upload it to the “My Drive” folder on Google Drive.
You can download the repository by clicking on "Code", then "Download ZIP":

![DownloadCode](https://user-images.githubusercontent.com/44889226/138960683-d2807e50-aa58-473e-9da0-fbf5c1b9ee13.png)

Navigate to the repository in Google Drive and find batch_mask.ipynb in batch-mask-main > code > scripts. Right-click the file, then click “Open with” and select Google Colaboratory (hereafter referred to as “Google Colab”. If Google Colab is not available as an option, you may have to select “Connect more apps” and add the Google Colab app.
 
## 1.2 Batch Mask Setup
In order to use the Batch-Mask script, you must first run the setup code by pressing the play button on this cell block:

![Setup](https://user-images.githubusercontent.com/44889226/138912649-9f23deb7-c9d7-446e-b24a-9e4955f0c5da.png)

You will be asked for an authentication code. Click on the link in the terminal, follow the prompts, and then copy and paste your authentication code into the box in the terminal to mount your Google Drive to the Google Colab script.
 
Click this cell block to compile the code:

![Compile](https://user-images.githubusercontent.com/44889226/138913444-42f51609-d989-4c4e-964c-26809dca9cb9.png)

The Google Colab script is now setup and ready to use!
 
## 1.3 Copying File Paths in Google Colab
You can copy a file or folder path in Google Colab by right clicking on the file/folder in the files view and selecting "copy path".

![copy_path](https://user-images.githubusercontent.com/44889226/138969645-22731987-f005-436a-bffa-02dde2ad9e7a.png)

## 1.4 Creating A Log Folder
The Google Colab script contains a code cell that will automatically generate a config file. Set the log_dir to be the directory that you want your log folder to be located, and set the dataset_dir to the dataset directory.

![gen_log](https://user-images.githubusercontent.com/44889226/138967351-bda00021-0c47-4f61-afc2-2a7f8a220eb3.png)

## 1.5 Upload Datasets
Create a "dataset" folder in Google Drive to contain training and inference datasets.
Specify the dataset path in the config file contained in the log folder:

![dataset_dir](https://user-images.githubusercontent.com/44889226/138972995-0498a16f-c4e0-46b7-b883-8895da3ca341.png)

If you plan to train the neural network, make a folder in the dataset folder to contain the training dataset. From there, create subfolders for each subset of the dataset. We divided the snake dataset into two subsets, dorsal and ventral. This is useful for comparing results from training on specific subsets. If you only need one subset for your dataset, then make a single folder. Note, the subset folders **cannot** be named "all".
 
Specify the training set folder in the config file contained in the log folder:

![training_dir](https://user-images.githubusercontent.com/44889226/138973171-e7d205cf-1c07-473c-a39a-96678ec6b459.png)

The training dataset for Snake masking can be found in the Snake data folder.
The first subset is the dorsal set, which is the upper side of a snake. This can be found under mask-rcnn/dorsal_set.
The second subset is the ventral set, which is the under side (stomach) of a snake. This can be found under mask-rcnn/ventral_set.

Download the ventral_set and dorsal_set folders and upload them to the training folder.
Alternatively, you may follow the tutorial for creating and labeling your own dataset in ImageJ.
 
If you want to use the neural network to detect the mask on a folder of images, simply upload the folder to the dataset folder and specify the folder in the config file contained in the log folder:

![specify_test_set](https://user-images.githubusercontent.com/44889226/138973368-ab73eb5f-d9fa-4bbf-a3ad-c702aa6878d2.png)

If you wish to run the neural network on the test set that we used, the download is located here:
 
https://www.dropbox.com/sh/w2zhi3ti96w3r4l/AABsFmnjX38VDQqZ1C54nhVca?dl=0
 
## 1.6 Check Dataset
You may check the dataset by running the check dataset cell block. Before running the cell block, set image_path to the path of the folder containing the dataset images, set label_path to the path of the folder containing the labels, set the start and end value to be the range of images to check (we suggest checking in batches of 50 because of limited ram resources), and set the mode to either "json" or "binary" depending on the type of label.

![check dataset](https://user-images.githubusercontent.com/44889226/138973479-477136fe-0524-4482-b645-c01e7ef0b2e8.png)

## 1.7 Training the Neural Network
 
### 1.7.1 Training Process
After a log file has been created and the dataset are uploaded to Google Drive, you can begin the training process.
First, you must specify the weight files to begin the training from. We used the "coco" weight files, but alternatively you may begin training it from our weight file (https://www.dropbox.com/s/tt1u307y0p3nyhf/snake_epoch_16.h5?dl=0). However, you must upload the weight file to Google Drive and specify the path to the weight file in the config file:

![specify_weights](https://user-images.githubusercontent.com/44889226/138974367-0fc17a0a-f137-4fa2-8c6f-f8e61c240b82.png)

You may also change the training parameters in the config file to yield better training results.
 
Specify the config file path in the training cell block and run the cell block to begin training. It took us ~24 hours to finish the training process.

![Paste_config_file_path](https://user-images.githubusercontent.com/44889226/138974760-4f01a4f7-e64c-46f6-8da7-e86dc7837aa1.png)

If the training process stops because Google Colab times out, you may resume the training process by setting the training weights to the last weight file save, which can be found in the weights folder contained in your logs folder. Running the cell block will then resume the training process with those weights. The number of epochs does **not** have to be changed. The code will automatically detect how many epochs are remaining.
 
### 1.7.2 Viewing Loss Values
Once the training process is finished, you may view the loss values by specifying the weights output folder (which should be located under the weights folder in the log directory) and running this cell block:

![image](https://user-images.githubusercontent.com/44889226/138975279-85428283-8268-489e-83d5-3b770a3619f7.png)

After viewing the loss values, choose an epoch for inference and copy and paste the associated weight file path into the config file for inference and evaluation metrics:

![specify_test_weights](https://user-images.githubusercontent.com/44889226/138975784-36ea2927-4811-4e6a-a665-e51039b1f716.png)

### 1.7.3 Evaluation Metrics
 
You can obtain the average IOU or IOL metrics for the validation partition for each subset of the training set.
Copy and paste the config file path into this cell block and run it:

![metric path](https://user-images.githubusercontent.com/44889226/138975816-26ca2827-c474-486f-abab-ef71a69dffa6.png)

The evaluation metrics are run using the test weights specified in the config file.
 
## 1.8 Inference
To generate masks for an unlabeled set of images, specify the config file path, choose the output type, and run the inference cell block:

![image](https://user-images.githubusercontent.com/44889226/138976272-3de1b8ae-a1c8-4e45-96ce-618e85d17b9d.png)

The output types are as follows: "json", "binary", and "splash".
* "json" will output the mask in the same format as the json files used for training.
* "binary" will output the mask as a csv file with each cell containing a zero or a one. This is the most universal style of output.
* "splash" will output a copy of the original image but with a blue background. This is a non-functional output but can be used to determine the qualitative performance of the neural network.
 
The inference is run on the test set folder specified in the config file using the test weight file specified in the config file. If you did not train the neural network and you wish to use our weights you can download and upload them to Google Drive.
You can find our weights here: https://www.dropbox.com/s/tt1u307y0p3nyhf/snake_epoch_16.h5?dl=0
 
The output folders are already specified in the config file and are located in the logs folder.
 
If you need to resume the inference because Google Colab timed out, you may set resume to true and it will pick up based on the last output file in the output folder.
 
## 1.9 Creating A Metadata File

![image](https://user-images.githubusercontent.com/44889226/139880037-a2f35d5e-71af-4ab9-9e79-15e8f360e4c2.png)

The metadata file is an optional ".csv" file that will name the mask rois based off the data to the right of column A. Column A corresponds to the name of the source image, and the roi will be named using the scheme "ColumnB_ColumnC_ColumnD_...". For example, the mask roi for the first image would be named "RAB_249_d_uv".

# 2 ImageJ
 
## 2.1 Setup
Download the master repo and extract but don’t upload it to Google Drive.
You can download the repo by clicking on "code", then "download zip":

![DownloadCode](https://user-images.githubusercontent.com/44889226/138960683-d2807e50-aa58-473e-9da0-fbf5c1b9ee13.png)

Navigate to batch-mask/software/ImageJ and run ImageJ.exe
 
## 2.2 Labeling Datasets
 
Open up the image to label inside ImageJ by either dragging it or going to File/Open
 
Press 't' to bring up the roi manager.

![139877877-60fb4075-8d9c-472e-9f84-9bd9d32d04ce](https://user-images.githubusercontent.com/44889226/142041235-e7e10a6d-6d60-4fca-b44a-a0e4719ee644.png)

Select the polygon tool to outline the mask of the specimen in the image.
 
For a specimen that is coiled (ex, a snake), first outline the entire specimen, then go to Edit->Selection->Make Inverse to invert the selection

![Second](https://user-images.githubusercontent.com/44889226/139877914-aed015f3-aea0-4e54-9d95-d515eb1300e5.PNG)

While pressing shift, select the parts within the original selection that are not part of the specimen. This will create a composite (donut-like) shape.

![Third](https://user-images.githubusercontent.com/44889226/139877954-0418f957-1a48-4981-9897-da83da022239.PNG)

Finally, go to Edit->Selection->Make Inverse to invert the selection again. Click add on the roi manager (or 't' for a shortcut), select the roi from the roi manager, and click rename to rename the roi to 'mask'.
 
If the specimen is not coiled, then simply use the polygon tool to outline the specimen. Click add on the roi manager (or 't' for a shortcut), select the roi from the roi manager, and click rename to rename the roi to 'mask'.

![139879168-a24fdd3a-68b1-4098-8c4e-3c67079e47f1](https://user-images.githubusercontent.com/44889226/142041318-6b221c61-c3fd-4c98-ab67-5d3232920cd5.png)

To export the labels to a json file, go to Plugins->JSON ROI->export and a save dialogue will pop up. The default name for the json file will be the same as the image file. There is no need to change the name since the training script links the json file to the jpeg file by filenames. Just click save.

![Fifth (1)](https://user-images.githubusercontent.com/44889226/139879284-c5771605-d571-4f5a-a103-a4f695b51548.PNG)

Close roi manager and the current open image before moving on to the next image. Click discard to any save messages that pop up after closing any windows.
 
## 2.3 Editing Labels
 
If exported labels need to be edited for any reason, open the image, press 't' to bring up the roi manager, then go to Plugins->JSON ROI->import and select the json file to import. The rois will then be loaded and the file can be edited. Then, use the same method as in the 'Labeling' section to export the json file.
 
## 2.4 Batch Generating Multispectral Images for MicaToolBox

**Note, this portion of the tutorial can only be run on a Windows operating system**

Place the json files containing the labels for the masks and scale bars in a folder with the source images (see example below).

If you want to use the images from our dataset, you must use these the non-color corrected images located under "imagej/non_color_corrected_images" in the Snake data folder.

The human labeld json files are located under "imagej/training_masks" in the Snake data folder.

The json files generated from Batch-Mask are located under "imagej/inference_masks" in the Snake data folder.

![image](https://user-images.githubusercontent.com/44889226/142065871-a1121d8d-5b0c-4fe1-8cf0-7f3f9d509156.png)

Navigate to "batch-mask-main/software/ImageJ/plugins/Multispectral Imaging/" and open "\_Batch_Generate_Multispectral_Images.ijm" in a text editor.
On line 55, set the directory variable to the directory that the json files and source images are stored.
On line 56, set resume to "" is starting from the beginning, otherwise set it to the name of the image to start from (ex. "V8.jpg").

![gen_custom](https://user-images.githubusercontent.com/44889226/142077579-2b0883a1-04c7-4798-802d-8ba76bb32671.png)

Navigate to "batch-mask-main/software/ImageJ/plugins/JSON ROI/" and open "mica_import.py" in a text editor.

On line 31, set the directory variable to the directory that the json files and source images are stored.

![import_mica](https://user-images.githubusercontent.com/44889226/142066631-195becca-3ec0-46df-8a25-b6311e552de6.png)

Navigate to "batch-mask-main/software/ImageJ/" and run "ImageJ.exe"

Navigate to "Plugins-> Multispectral Imaging -> Batch Generate Multispectral Images" and left click to run the batch  multispectral images generator.

![run_script](https://user-images.githubusercontent.com/44889226/142079536-58e8662b-2af6-4d01-a7cc-1ac90e57f2fc.png)

Select the 5 percent color standard:

![5_percent](https://user-images.githubusercontent.com/44889226/142067813-16bdb2c7-e381-48b6-a554-bba03bbb93f1.png)

Select the 95 percent color standard:

![95_percent](https://user-images.githubusercontent.com/44889226/142066651-9e6fc702-0425-4f7b-b091-89afe4915261.PNG)

Repeat the color selection for the entire folder.

Once the script is finished, the MSPEC and ROI files will be saved in the same directory as the json files and source images. These must stay in the same directory for other MicatoolBox features to work.

![image](https://user-images.githubusercontent.com/44889226/142065784-fc1aab3c-e211-469c-b76b-5247374a5138.png)

You can follow this youtube tutorial to replicate the Pattern Processing we performed for the Batch-Mask paper: https://youtu.be/T62fr25b75M?t=3281

## 2.5 Editing MSPEC File
### 2.5.1 Changing the mask
To be added
### 2.5.2 Adding a scale bar
To be added

Original Mask RCNN Repository: https://github.com/matterport/Mask_RCNN \n
Updated Mask RCNN for Tensorflow 2: https://github.com/akTwelve/Mask_RCNN \n
MicatoolBox version 1 website: http://www.jolyon.co.uk/myresearch/image-analysis/image-analysis-tools/ \n
ImageJ version 1 website: https://imagej.nih.gov/ij/download.html \n

