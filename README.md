# Batch Mask
## Cloning Repo
Download the master repo, extract it, and upload it to google drive.
You can download the repo by clicking on "code", then "download zip":
![DownloadCode](https://user-images.githubusercontent.com/44889226/138960683-d2807e50-aa58-473e-9da0-fbf5c1b9ee13.png)

Navigate to the repo in google drive and open batch_mask.ipynb in google colab by right clicking on the file, then clicking open with and selecting google colab. If google colab isn't available, you may have to select "connect more apps" and add the google colab app.

## Setup
To run use the batch-mask script, you must first run the setup code by pressing the play button on this cell block:

![Setup](https://user-images.githubusercontent.com/44889226/138912649-9f23deb7-c9d7-446e-b24a-9e4955f0c5da.png)

Click on the link in the terminal and follow the steps to mount your google drive to the colab script.

Then, click on this cell block to compile the code:

![Compile](https://user-images.githubusercontent.com/44889226/138913444-42f51609-d989-4c4e-964c-26809dca9cb9.png)

The colab script is now setup and ready to use!


## Copying File Paths in Colab
You can copy a file or folder path in colab by right clicking on the file/folder in the files view and selecting "copy path".
![copy_path](https://user-images.githubusercontent.com/44889226/138969645-22731987-f005-436a-bffa-02dde2ad9e7a.png)

## Creating A Log Folder
The colab script contains a code cell that will automatically. Set the log_dir to be the directory that you want your log folder to be located, and set the dataset_dir to the dataset directory.

![gen_log](https://user-images.githubusercontent.com/44889226/138967351-bda00021-0c47-4f61-afc2-2a7f8a220eb3.png)

## Upload Datasets
Create a "dataset" folder in google drive to contain all of the datasets.
Specify the dataset path in the config file contained in the log folder:
![dataset_dir](https://user-images.githubusercontent.com/44889226/138972995-0498a16f-c4e0-46b7-b883-8895da3ca341.png)

If you plan on training the neural network, make a folder in the dataset folder to contain the training dataset. From there, create subfolders for each subset of the dataset. We divided the snake dataset into two subsets, dorsal and ventral. This is useful for comparing results from training on specific subsets. If you only need one subset for your dataset, then make a single folder. Note, the subset folders **cannot** be named "all".

Specify the training set folder in the config file contained in the log folder:

![training_dir](https://user-images.githubusercontent.com/44889226/138973171-e7d205cf-1c07-473c-a39a-96678ec6b459.png)

The training dataset for Snake masking can be downloaded from this link: https://www.dropbox.com/sh/bsmaopj8rr9z014/AABowTCMNJGJ6BV6keQToQhaa?dl=0.
Download the ventral_set and dorsal_set folders and upload them to the training folder.
Alternatively, you may follow the tutorial for creating and labeling you own dataset in ImageJ.

If you want use the neural network to detect the mask on a folder of images, simply upload the folder to the dataset folder and specify the folder in the config file contained in the log folder:

![specify_test_set](https://user-images.githubusercontent.com/44889226/138973368-ab73eb5f-d9fa-4bbf-a3ad-c702aa6878d2.png)

If you wish to run the neural network on the test set we used, the download is located here: 

## Check Dataset
You may check the dataset by running the check dataset cell block. Before, running the cell block, set image_path to the path of the folder containing the dataset images, set label_path to the path of the folder containing the labels, set the start and end value to be the range of images to check (we suggest checking in batches of 50 because of limited ram resources), and set the mode to either "json" or "binary" depending on the type of label.
![check dataset](https://user-images.githubusercontent.com/44889226/138973479-477136fe-0524-4482-b645-c01e7ef0b2e8.png)

## Training the Neural Network

### Training Process
After a log file has been created and the dataset are uploaded to google drive, you can begin the training process.
First, you must specify the weight files to begin the training from. We used the "coco" weight files, but alternatively you may begin training it from our weight file (https://www.dropbox.com/s/tt1u307y0p3nyhf/snake_epoch_16.h5?dl=0). However, you must upload the weight file to google drive and specify the path to the weight file in the config file:![specify_weights](https://user-images.githubusercontent.com/44889226/138974367-0fc17a0a-f137-4fa2-8c6f-f8e61c240b82.png)

You may also change the training parameters in the config file to yield better training results.

Specify the config file path in the training cell block and run the cell block to begin training. It took us ~x hours to finish the training proccess.
![Paste_config_file_path](https://user-images.githubusercontent.com/44889226/138974760-4f01a4f7-e64c-46f6-8da7-e86dc7837aa1.png)

If the training process stop because colab times out, you may resume the training process by setting the training weights to the last weight file save, which can be found in the weights folder contained in your logs folder. Running the cell block will then resume the training process with those weights. The number of epochs does **not** have to be changed. The code will automatically detect how many epoch are remaining.

### Viewing Loss Values
Once the training process is finished, you may view the loss values by specifying the weights ouput folder (which should be located under the weights folder in the log directory) and running this cell block:
![image](https://user-images.githubusercontent.com/44889226/138975279-85428283-8268-489e-83d5-3b770a3619f7.png)

After viewing the loss values, choose an epoch for inference and copy and paste the associated weight file path into the config file for inference and evaluation metrics:

![specify_test_weights](https://user-images.githubusercontent.com/44889226/138975784-36ea2927-4811-4e6a-a665-e51039b1f716.png)

### Evaluation Metrics

You can obtain the average IOU or IOL metrics for the validation partition for each subset of the training set.
Copy and paste the config file path into this cell block and run it:

![metric path](https://user-images.githubusercontent.com/44889226/138975816-26ca2827-c474-486f-abab-ef71a69dffa6.png)

The evalution metrics are run using the test weights specified in the config file.

## Inference
To generate masks for an unlabeled set of images, specify the config file path, choose the output type, and run the inference cell block:
![image](https://user-images.githubusercontent.com/44889226/138976272-3de1b8ae-a1c8-4e45-96ce-618e85d17b9d.png)

The output types are as follows: "json", "binary", and "splash".
* "json" will output the mask in the same format as the json files used for training.
* "binary" will output the mask as a csv file with each cell containing a zero or a one. This is the most universall style of output.
* "splash" will output a copy of the original image but with a blue background. This is a non-functional output but can be used to determine the qualitative performance of the neural network.

The inference is run on the test set folder specified in the config file using the test weight file specified in the config file. If you did not train the neural network and you wish to use our weights you can download and upload them to google drive.
You can find our weights here: https://www.dropbox.com/s/tt1u307y0p3nyhf/snake_epoch_16.h5?dl=0

The output folders are already specified in the config file and are located in the logs folder.

If you need to resume the inference because colab timed out, you may set resume to true and it will pickup based on the last output file in the output folder.

## Creating A Metadata File

# ImageJ

## Setup
Download the master repo and extract it.
You can download the repo by clicking on "code", then "download zip":
![DownloadCode](https://user-images.githubusercontent.com/44889226/138960683-d2807e50-aa58-473e-9da0-fbf5c1b9ee13.png)
Navigate to batch-mask -> software -> ImageJ and run ImageJ.exe

## Labeling Datasets

Open up the image to label inside ImageJ by either dragging it or going to File/Open

Press 't' to bring up the roi manager.

![First](https://user-images.githubusercontent.com/44889226/139877877-60fb4075-8d9c-472e-9f84-9bd9d32d04ce.PNG)

Select the polygon tool to outline the mask of the specimen in the image.

For a specimen that is coiled (ex, a snake), first outline the entire specimen, then go to Edit/Selection/Make Inverse to invert the selection

![Second](https://user-images.githubusercontent.com/44889226/139877914-aed015f3-aea0-4e54-9d95-d515eb1300e5.PNG)

Then while pressing shift select the parts within the original selection that are not part of the specimen. This will create a composite (donut-like) shape.

![Third](https://user-images.githubusercontent.com/44889226/139877954-0418f957-1a48-4981-9897-da83da022239.PNG)

Finally, go to Edit/Selection/Make Inverse to invert the selection again. Click add on the roi manager (or 't' for a shortcut), select the roi from the roi manager, and click rename to rename the roi to 'mask'.

If the specimen is not coiled, then simply use the polygon tool to outline the specimen. Click add on the roi manager (or 't' for a shortcut), select the roi from the roi manager, and click rename to rename the roi to 'mask'.

![Fourth](https://user-images.githubusercontent.com/44889226/139879168-a24fdd3a-68b1-4098-8c4e-3c67079e47f1.PNG)

To export the labels to a json file, go to Plugins/JSON ROI/export and a save dialogue will pop up. The default name for the json file will be the same as the image file. There is no need to change the name since the training script links the json file to the jpeg file by filenames. Just click save.

![Fifth (1)](https://user-images.githubusercontent.com/44889226/139879284-c5771605-d571-4f5a-a103-a4f695b51548.PNG)

Close roi manager and the current open image before moving on to the next image. Click discard to any save messages that pop up after closing any windows.

## Editing Labels

If exported labels need to be edited for any reason, open the image, press 't' to bring up the roi manager, then go to Plugins/JSON ROI/import and select the json file to import. The rois will then be loaded and the file can be edited. Then, use the same method as in the 'Labeling' section to export the json file.

## Batch Generating MSPEC files for MicaToolBox

