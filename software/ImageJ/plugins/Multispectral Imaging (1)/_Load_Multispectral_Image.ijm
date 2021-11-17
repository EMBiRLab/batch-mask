/*
_______________________________________________________________________

	Title: Load Multispectral Image
	Author: Jolyon Troscianko
	Date: 16/10/2014
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code loads multispectral images from their .mspec configuration files. Any ROIs
selected will also be loaded.

Instructions:
''''''''''''''''''''''''''''''''''''''''
Run the script and select a .mspec file (this needs to be in the same folder as the RAW
images it was created from).

_________________________________________________________________________
*/

configFilePath=File.openDialog("Select Config File"); // get file location
tempString = "select=["+ configFilePath+"]";

// LOAD PREVIOUSLY USED VALUES

settingsFilePath = getDirectory("plugins") + "Multispectral Imaging/importSettings.txt";
if(File.exists(settingsFilePath) == 1){
	settingsString=File.openAsString(settingsFilePath);	// open txt data file
	defaultSettings=split(settingsString, "\n");
	outputChoice = defaultSettings[13];
} else outputChoice = "Aligned Normalised 32-bit";

outputOptions = newArray( "Aligned Normalised 32-bit", "Aligned Linear 32-bit", "Visual 32-bit", "Pseudo UV 32-bit");

Dialog.create("Load Multispectral Image");
	Dialog.addChoice("Image output", outputOptions, outputChoice);
	Dialog.addMessage(" 'Aligned Normalised 32-bit', use if you're planning to measure pixel values manually");
	Dialog.addMessage("'Aligned Linear 32-bit' is not normalised, use it to investigate illuminance");
	Dialog.addMessage("'Visual 32-bit' is non-linear for viewing normal colour images (not for measuring)");
	Dialog.addMessage("Pseudo UV 32-bit' is non-linear for viewing 5-channel UV colour images (not for measuring)");
Dialog.show();

imageOutput =  Dialog.getChoice();

if(imageOutput != outputChoice){
// SAVE PREVIOUSLY USED SETTINGS
dataFile = File.open(settingsFilePath);

	print(dataFile, defaultSettings[0]);
	print(dataFile, defaultSettings[1]);
	print(dataFile, defaultSettings[2]);
	print(dataFile, defaultSettings[3]);
	print(dataFile, defaultSettings[4]);
	print(dataFile, defaultSettings[5]);
	print(dataFile, defaultSettings[6]);
	print(dataFile, defaultSettings[7]);
	print(dataFile, defaultSettings[8]);
	print(dataFile, defaultSettings[9]);
	print(dataFile, defaultSettings[10]);
	print(dataFile, defaultSettings[11]);
	print(dataFile, defaultSettings[12]);
	print(dataFile, imageOutput);
	print(dataFile, defaultSettings[14]);
	print(dataFile, defaultSettings[15]);

File.close(dataFile);
}

setBatchMode(true);
run("Create Stack from Config File", tempString);

//run("Create Stack from Config File");
if(imageOutput == "Aligned Linear 32-bit")
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line] align_only");
else
	run("Normalise & Align Multispectral Stack", "curve=[Straight Line]");

setMinAndMax(0, 65535);
setSlice(1);


run("Select None");
run("Save ROIs");
setOption("Changes", false);



if(imageOutput == "Visual 32-bit"){

	while(nSlices>3){
		setSlice(4);
		run("Delete Slice");
	}

	run("Square Root", "stack");
	setMinAndMax(0, 255);
	run("Make Composite", "display=Composite");
	setSlice(3);
	setMinAndMax(0, 255);
	setSlice(2);
	setMinAndMax(0, 255);
	setSlice(1);
	setMinAndMax(0, 255);
	setBatchMode(false);

	setColor(200, 0, 0);
	colourSwitch = colourSwitch * -1;
	setFont("SansSerif", getHeight()*0.04);


	setFont("SansSerif", getHeight()*0.02);
	setColor(200, 0, 0);
	Overlay.drawString("Do not measure this image. Use it for selecting regions.", getWidth()*0.05, getHeight()*0.05);
	Overlay.show;

}

if(imageOutput == "Pseudo UV 32-bit"){

	if(nSlices<5){
		exit("Pseudo-UV shows the visible Green and Blue\nand UV Red channels as a composite. This image\ndoes not have enough channels");
		setBatchMode(false);
		setSlice(1);
	}

	while(nSlices>5){
		setSlice(6);
		run("Delete Slice");
	}

	setSlice(4);
	run("Delete Slice"); // delete uvB

	setSlice(1);
	run("Delete Slice"); // delete visR


	run("Square Root", "stack");
	setMinAndMax(0, 255);
	run("Make Composite", "display=Composite");
	setSlice(3);
	setMinAndMax(0, 255);
	setSlice(2);
	setMinAndMax(0, 255);
	setSlice(1);
	setMinAndMax(0, 255);

	setFont("SansSerif", getHeight()*0.02);
	setColor(200, 0, 0);
	Overlay.drawString("Do not measure this image. Use it for selecting regions.", getWidth()*0.05, getHeight()*0.05);
	Overlay.show;


	transformInfo = "________________________________________\nThis is a false-colour image, shifting the\nchannels to show visible green, visible\nblue and uv red. Use this image to judge\nthe alignment and select ROIs, but don't\nmeasure it directly. Once you've selected\nROIs use the batch script"; 

	setBatchMode(false);
}


showStatus("Done");


setBatchMode(false);

// LOG THE LOCATION FOR ADDING ROIs

print("\\Clear");

	print("__________Config File Location:__________");
	print(configFilePath);

	print("________________________________________");
	print("Select regions of interest and press any");
	print("key to add them to the ROI manager.\n ");
	print("Draw a line along the scale bar and press");
	print("\"S\" if you're planning to measure pattern.\n ");
	print("To measure eggs and save their coordinates");
	print("press \"E\". Make sure a scale bar is selected\nbeforehand. Place a point on the tip and base\nof the egg, then three more down each side.\n ");
	print("Press \"0\" to save your selections linked");
	print("to the image. Leave this log window open");
	print("while adding selections without needing");
	print("to use the save dialog.");

	print("________________________________________");
