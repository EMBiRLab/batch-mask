# Batch Mask
## Cloning Repo
Clone the repo and upload it to google drive. Alternatively, you may download the google drive app and clone the repo directly into the drive.
Navigate to the repo in google drive and open batch_mask.ipynb in google colab by right clicking on the file, then clicking open with and selecting google colab. If google colab isn't available, you may have to select "connect more apps" and add the google colab app.

## Setup
To run use the batch-mask script, you must first run the setup code by pressing the play button on this cell block:

![Setup](https://user-images.githubusercontent.com/44889226/138912649-9f23deb7-c9d7-446e-b24a-9e4955f0c5da.png)

Click on the link in the terminal and follow the steps to mount your google drive to the colab script.

Then, click on this cell block to compile the code:

![Compile](https://user-images.githubusercontent.com/44889226/138913444-42f51609-d989-4c4e-964c-26809dca9cb9.png)

The colab script is now setup and ready to use!

## Upload and Check Dataset
The labeled dataset for Snake maskig can be downloaded from this link: https://www.dropbox.com/sh/2a0gb2jsb0gmaiu/AABJtSIZCUf9suE3x8l8XaY5a?dl=0.
Alternatively, you may follow the tutorial for creating and labeling you own dataset in ImageJ.
Create a folder in google drive to contain the dataset. We name the folder "train_val_sets". From here, you can create multiple folders as subsets of a dataset. We divided the snake dataset into two subsets, dorsal and ventral. This is useful for comparing results from training on specific subsets. If you only need one subset for you dataset, then make a single folder. Note, the subset folders cannot be named "all".

![image](https://user-images.githubusercontent.com/44889226/138954861-6756506c-6259-4aab-add6-e27adc9a8041.png)

## Creating A Log Folder

## Training

## Viewing Loss Values

## Evaluation Metrics

## Inference

# ImageJ
