/*
________________________________________________________________________________

	Title: Generate cone mapping models
	Author: Jolyon Troscianko
	Date: 22/08/2012
	Update: 29/08/2013 bug in 16-bit (short) image processor fixed,
	switching to float processing for all calculations.
	Update: 14/10/14 modified to work with entirely 32-bit floating point processing
	Update: 10/11/2016 modified to accept different photography and modelled illuminant spectra
		plus some speed improvements
	Update: 14/11/16 updated to work with the JAMA library, so R is no longer required
....................................................................................................................................................................................

	Description:

		This script creates a new mapping script that models cone catchs for a given species and
		illuminant from the known sensitivity spectra of the camera's sensors.

		It can theoretically deal with any number of multispectral images and cone types with
		known sensitivity spectra, across any wavelength range, with any spacing (e.g. 1nm, 10nm
		from 400-700nm or 300-800nm).

		First the code imports the selected camera, illuminant spectrum and cone sensitivities. The
		camera and cone sensitivity functions must be normalised so that every receptor or sensor
		has a sum under the curve equal to one. The illuminant and training spectra must be
		normalised so that 1 is the maximum and 0 the minimum.

		The training set of spectra is then used to simulate the response of each cone type and camera
		sensor to each spectrum. These are then exported to a file, and an R script is generated that
		will model the conversion. In R a full interaction GLM is called for each cone
		(e.g. UV cone ~ Red*Green*Blue*UV).
		
		Once R has generated the models it exports them as a text file that this code then picks up.
		Then a new plugin script is generated based on the models provided by R and saved in the
		plugins\Cone Models folder. This script is then compiled and the resulting plugin should be
		able to convert images very quickly, adding the cone catch images as slices to the original
		image.

	Requirements:

		-.csv files containing spectra/sensitivities in the relevant folders
		-Sensitivity (cone and camera) functions normalised so the sum =1
		-Illuminant and training spectra scaled so max=1, min=0
		-The range and spacing of spectra must be identical for all sensitivity functions and spectra
		(e.g. 300-700nm range with 1nm increments). The code checks to make sure this holds.
		-Cones cannot be called 'double', 'short' or 'byte' as this will interfere with the scripting (e.g. use 'dbl' instead).
		-The order of camera sensor sensitivity functions must match the input photos, (e.g. Red, Green
		Blue if the image is a standard RGB photo).
		-Creates script files that can convert either 16 bit/channel or 8 bit/channel (RGB 24 bit) tiff images.
		-Use "Batch Cone Mapping" to implement the generated scripts once the mapping is done.

________________________________________________________________________________
*/




// LIST CAMERAS

	cameraPath = getDirectory("plugins")+"Cone Mapping/Cameras";

	cameraList=getFileList(cameraPath);

	cameraNames = newArray(0);

	for(i=0; i<cameraList.length; i++){
		if(endsWith(cameraList[i], ".csv")==1)
			cameraNames = Array.concat(cameraNames,replace(cameraList[i],".csv",""));
		if(endsWith(cameraList[i], ".CSV")==1)
			cameraNames = Array.concat(cameraNames,replace(cameraList[i],".CSV",""));
	}

// LIST ILLUMINANTS

	illumPath = getDirectory("plugins")+"Cone Mapping/Illuminants";

	illumList=getFileList(illumPath);

	illumNames = newArray(0);

	for(i=0; i<illumList.length; i++){
		if(endsWith(illumList[i], ".csv")==1)
			illumNames = Array.concat(illumNames,replace(illumList[i],".csv",""));
		if(endsWith(illumList[i], ".CSV")==1)
			illumNames = Array.concat(illumNames,replace(illumList[i],".CSV",""));
	}

// LIST RECEPTORS

	receptorPath = getDirectory("plugins")+"Cone Mapping/Receptors";

	receptorList=getFileList(receptorPath);

	receptorNames = newArray(0);

	for(i=0; i<receptorList.length; i++){
		if(endsWith(receptorList[i], ".csv")==1)
			receptorNames = Array.concat(receptorNames,replace(receptorList[i],".csv",""));
		if(endsWith(receptorList[i], ".CSV")==1)
			receptorNames = Array.concat(receptorNames,replace(receptorList[i],".CSV",""));
	}

// LIST TRAINING SPECTRA

	spectraPath = getDirectory("plugins")+"Cone Mapping/Spectra";

	spectraList=getFileList(spectraPath);

	spectraNames = newArray(0);

	for(i=0; i<spectraList.length; i++){
		if(endsWith(spectraList[i], ".csv")==1)
			spectraNames = Array.concat(spectraNames,replace(spectraList[i],".csv",""));
		if(endsWith(spectraList[i], ".CSV")==1)
			spectraNames = Array.concat(spectraNames,replace(spectraList[i],".CSV",""));
	}

// USER SETTINGS

	simplificationDirection = newArray("backward/forward","forward/backward","backward","forward");
	simplificationCriterion = newArray("BIC", "AIC");

	Dialog.create("Settings");
		Dialog.addMessage("Select Configuration:");
		Dialog.addChoice("Camera", cameraNames);
		Dialog.addChoice("Photography Illuminant", illumNames);
		Dialog.addChoice("Receptors", receptorNames);
		Dialog.addChoice("Model Illuminant", illumNames);
		Dialog.addChoice("Training spectra", spectraNames);
		Dialog.addMessage("Set the maximum number of interaction terms:\ne.g. 3 = Red*Green*Blue");
		Dialog.addNumber("Interaction Levels", 2);
		Dialog.addNumber("Polynomial level", 1);
	Dialog.show();


	cameraChoice = Dialog.getChoice();
	pillumChoice = Dialog.getChoice();
	receptorChoice = Dialog.getChoice();
	millumChoice = Dialog.getChoice();
	spectraChoice = Dialog.getChoice();
	nInteractions = Dialog.getNumber();
	polyLevel = Dialog.getNumber();

	osName = getInfo("os.name");


// Make model name from choices

	scriptName = cameraChoice + "_" + pillumChoice  + "_to_" + receptorChoice + "_" + millumChoice + "\t";
	scriptName = replace(scriptName, " ", "_");
	scriptName = replace(scriptName, "300-700" , "");
	scriptName = replace(scriptName, "400-700" , "");
	scriptName = replace(scriptName, "__" , "_");
	scriptName = replace(scriptName, "_\t" , ""); // remove tailing underscore

	bitDepthLevels = 65535;
	bitDepthCasting = "0xffff";


// IMPORT CAMERA SENSITIVITIES

open(cameraPath + "/" + cameraChoice + ".csv");

columns = split(String.getResultsHeadings, "\t"); //array of column names (must not have any repeats)

cameraSensitivity = newArray(nResults*(columns.length-2));

for(i=0; i<nResults; i++)
	for(j=0; j<columns.length-2; j++)
		cameraSensitivity[(i*(columns.length-2))+j] = getResult(columns[j+2],i);

//Array.print(cameraSensitivity);

if(startsWith(getVersion(), "1.4") == 1 || startsWith(getVersion(), "1.3") == 1 || startsWith(getVersion(), "1.2") == 1 || startsWith(getVersion(), "1.1") == 1)
	version = 1.4;
else version = 1.5;

	sensorNames = newArray(nResults);
	for(i=0; i<nResults; i++)
		if(version < 1.5)
			sensorNames[i] = getResultLabel(i);
		else
			sensorNames[i] = getResultString(columns[1], i);


// IMPORT ILLUMINANT SPECTRA


open(illumPath + "/" + pillumChoice + ".csv");
nColumns = columns.length-2;

columnCheck = split(String.getResultsHeadings, "\t"); //array of column names (must not have any repeats)

	if(columnCheck.length != columns.length)
		exit("Illuminant and camera must use matching wavelength units");

	if(columnCheck[2] != columns[2])
		exit("Illuminant and camera must use matching wavelength units");

	pilluminantSpectrum = newArray(nColumns);

	for(i=0; i<nColumns; i++)
		pilluminantSpectrum[i] = getResult(columns[i+2],0);


open(illumPath + "/" + millumChoice + ".csv");

columnCheck = split(String.getResultsHeadings, "\t"); //array of column names (must not have any repeats)

	if(columnCheck.length != columns.length)
		exit("Illuminant and camera must use matching wavelength units");

	if(columnCheck[2] != columns[2])
		exit("Illuminant and camera must use matching wavelength units");

	milluminantSpectrum = newArray(nColumns);

	for(i=0; i<nColumns; i++)
		milluminantSpectrum[i] = getResult(columns[i+2],0);



// IMPORT RECEPTOR SENSITIVITIES

open(receptorPath + "/" + receptorChoice + ".csv");

columnCheck = split(String.getResultsHeadings, "\t"); //array of column names (must not have any repeats)

	if(columnCheck.length != columns.length)
		exit("Receptor sensitivities and camera must use matching wavelength units");

	if(columnCheck[2] != columns[2])
		exit("Receptor sensitivities and camera must use matching wavelength units");

	if(columnCheck[10] != columns[10])
		exit("Receptor sensitivities and camera must use matching wavelength units");

receptorSensitivity = newArray(nResults*nColumns);

for(i=0; i<nResults; i++)
	for(j=0; j<nColumns; j++)
		receptorSensitivity[(i*nColumns)+j] = getResult(columns[j+2],i);

	coneNames = newArray(nResults);
	for(i=0; i<nResults; i++)
		if(version < 1.5)
			coneNames[i] = getResultLabel(i);
		else
			coneNames[i] = getResultString(columnCheck[1], i);

for(i=0; i<coneNames.length; i++)
	for(j=0; j<sensorNames.length; j++)
		if(coneNames[i] == sensorNames[j])
			exit("Error: one of the receptor names is the same as a camera channel name\nrename them to ensure there are no duplicates");


/*
// PLOT SPECTRA

illumWavelength = newArray(nColumns);
	for(i=0; i<nColumns; i++)
		illumWavelength[i] = parseInt(columns[i+2]);


receptorWavelength = newArray();
	for(i=0; i<coneNames.length; i++)
		receptorWavelength = Array.concat(receptorWavelength,illumWavelength);

sensorWavelength = newArray();
	for(i=0; i<sensorNames.length; i++)
		sensorWavelength = Array.concat(sensorWavelength,illumWavelength);


Plot.create("Camera Spectral Sensitivity", "Wavelength (nm)", "Normalised Sensitivity", illumWavelength, illuminantSpectrum);
	Plot.setFrameSize(600, 400);
	Plot.setColor("black");
		Plot.add("line", receptorWavelength, receptorSensitivity);
	Plot.setColor("red");
		Plot.add("line", sensorWavelength, cameraSensitivity);
	Plot.setColor("lightGray");
Plot.show();
*/

// IMPORT TRAINING SPECTRA

open(spectraPath + "/" + spectraChoice + ".csv");

columnCheck = split(String.getResultsHeadings, "\t"); //array of column names (must not have any repeats)

	if(columnCheck.length != columns.length)
		exit("Training spectra and camera must use matching wavelength units");

	if(columnCheck[2] != columns[2])
		exit("Training spectra and camera must use matching wavelength units");

	if(columnCheck[10] != columns[10])
		exit("Training spectra and camera must use matching wavelength units");

trainingSpectra = newArray(nResults*nColumns);

for(i=0; i<nResults; i++)
	for(j=0; j<nColumns; j++)
		trainingSpectra[(i*nColumns)+j] = getResult(columns[j+2],i);


// CALCULATE CAMERA & CONE RESPONSES

pvonKreis = newArray(sensorNames.length);
for(i=0; i<sensorNames.length; i++){
	pvonKreis[i] = 0; // set initial to zero
	for(j=0; j<nColumns; j++)
		pvonKreis[i] = pvonKreis[i] + (pilluminantSpectrum[j]*cameraSensitivity[j+(i*nColumns)]);
}//i

mvonKreis = newArray(coneNames.length);
for(i=0; i<coneNames.length; i++){
	mvonKreis[i] = 0; // set initial to zero
	for(j=0; j<nColumns; j++)
		mvonKreis[i] = mvonKreis[i] + (milluminantSpectrum[j]*receptorSensitivity[j+(i*nColumns)]);
}//i

nRows = nResults;
selectWindow("Results");
run("Close");
setResult("y", 0, 0.0);


sensorEstimates = newArray(sensorNames.length * nRows);

showStatus("Calculating camera responses to training set");
for(k=0; k<sensorNames.length; k++){
	for(i=0; i<nRows; i++){
		tempVal = 0;
		for(j=0; j<nColumns; j++)
			tempVal = tempVal + trainingSpectra[(i*nColumns)+j]*pilluminantSpectrum[j]*cameraSensitivity[j+(k*nColumns)]*bitDepthLevels;
		tempVal = tempVal/pvonKreis[k];
		setResult(sensorNames[k],i, tempVal);
		sensorEstimates[(k*nRows)+i] = tempVal;
		showProgress((k/sensorNames.length) + ((i/nRows)/sensorNames.length) );
	}
}




//----------------CALCULATE POLYNOMIAL MODEL TERMS----------------


mSensorNames = Array.copy(sensorNames);
for(i=0; i<sensorNames.length; i++){
	tempName = sensorNames[i];
	for(j=1; j<polyLevel; j++){
		prevName = tempName;
		tempName = tempName+"*" +sensorNames[i];
		for(k=0; k<nRows; k++)
			setResult(tempName, k, getResult(prevName,k)*getResult(sensorNames[i],k));
		mSensorNames = Array.concat(mSensorNames, tempName);
	}
}

//----------------CALCULATE INTERACTION MODEL TERMS----------------

if(nInteractions > 1)
for(i=0; i<mSensorNames.length; i++)
for(k=i+1; k<mSensorNames.length; k++)
for(j=0; j<nRows; j++)
	setResult(mSensorNames[i] + "*" + mSensorNames[k], j, getResult(mSensorNames[i],j)*getResult(mSensorNames[k],j) );

if(nInteractions > 2)
for(i=0; i<mSensorNames.length; i++)
for(k=i+1; k<mSensorNames.length; k++)
for(l=k+1; l<mSensorNames.length; l++)
for(j=0; j<nRows; j++)
	setResult(mSensorNames[i] + "*" + mSensorNames[k] + "*" + mSensorNames[l], j, getResult(mSensorNames[i],j)*getResult(mSensorNames[k],j)*getResult(mSensorNames[l],j) );

if(nInteractions > 3)
	waitForUser("Currently the script only supports three-way interactions");



coneEstimates = newArray(coneNames.length * nRows);
modelR2s = newArray(coneNames.length);
models = newArray(coneNames.length);

showStatus("Calculating receptor responses to training set");
for(k=0; k<coneNames.length; k++){
	for(i=0; i<nRows; i++){
		tempVal = 0;
		for(j=0; j<nColumns; j++)
			tempVal = tempVal + trainingSpectra[(i*nColumns)+j]*milluminantSpectrum[j]*receptorSensitivity[j+(k*nColumns)]*bitDepthLevels;
		tempVal = tempVal/mvonKreis[k];
		setResult("y",i, tempVal);
		coneEstimates[(k*nRows)+i] = tempVal;
		showProgress((k/sensorNames.length) + ((i/nRows)/coneNames.length) );
	}

	print("\\Clear"); // clear log window
	run("multiple regression");

	logString = getInfo("log");
	logString = split(logString, "\n");

	modelR2s[k] = coneNames[k] + " " + replace(logString[1], "R2: ", "");

	for(i=0; i<sensorNames.length; i++)
		logString[2] = replace(logString[2], sensorNames[i], sensorNames[i] + "[i]");

	models[k] = logString[2];

}
showProgress(1);

showStatus("Done Modelling");

print("\\Clear"); // clear log window



//------------------------ CREATE JAVA PLUGIN----------------------

pluginPath = getDirectory("plugins")+"Cone Models/" + scriptName + ".java";
if(File.exists(pluginPath)==1)
	File.delete(pluginPath);

scriptFile = File.open(pluginPath);


print(scriptFile, "// Code automatically generated by 'Generate Cone Mapping Model' script by Jolyon Troscianko");
print(scriptFile, "\n//Model fits:");

for(i=0; i<modelR2s.length; i++)
	print(scriptFile, "//" + modelR2s[i]);
print(scriptFile, "\n");
print(scriptFile, "\n");

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

print(scriptFile, "// Generated: " + year + "/" + month + "/" + dayOfMonth + "   " + hour + ":" + minute + ":" + second );
print(scriptFile, "\n");
print(scriptFile, "\n");
print(scriptFile, "import ij.*;");
print(scriptFile, "import ij.plugin.filter.PlugInFilter;");
print(scriptFile, "import ij.process.*;");
print(scriptFile, "\n");
print(scriptFile, "public class "+ scriptName + " implements PlugInFilter {");
print(scriptFile, "\n");
print(scriptFile, "ImageStack stack;");
print(scriptFile, "\tpublic int setup\(String arg, ImagePlus imp\) { \n\tstack = imp.getStack\(\); \n\treturn DOES_32 + STACK_REQUIRED; \n\t}");
print(scriptFile, "public void run\(ImageProcessor ip\) {");
print(scriptFile, "\n");
print(scriptFile, "IJ.showStatus\(\"Cone Mapping\"\);");

for(i=0; i<sensorNames.length; i++)
	print(scriptFile, "float[] " + sensorNames[i] + ";");

print(scriptFile, "int w = stack.getWidth\(\);" );
print(scriptFile, "int h = stack.getHeight\(\);" );
print(scriptFile, "int dimension = w*h;" );
print(scriptFile, "\n");

for(i=0; i<coneNames.length; i++)
	print(scriptFile, "float[] " + coneNames[i] + " = new float[dimension];");

print(scriptFile, "\n");

for(i=0; i<sensorNames.length; i++)
	print(scriptFile, sensorNames[i] + " = \(" + "float[]\) stack.getPixels\("+ (i+1) + "\);");

print(scriptFile, "\n");
print(scriptFile, "for \(int i=0;i<dimension;i++\) {");

for(i=0; i<coneNames.length; i++)
	print(scriptFile, coneNames[i]  + "[i] = \(float\) \(" + models[i] + "\);" );

print(scriptFile, "IJ.showProgress\(\(float\) i/dimension\);");
print(scriptFile, "}");
print(scriptFile, "\n");
print(scriptFile, "ImageStack outStack = new ImageStack\(w, h\);");

for(i=0; i<coneNames.length; i++)
	print(scriptFile, "outStack.addSlice\(\"" + coneNames[i] + "\", " + coneNames[i] + "\);");


print(scriptFile, "new ImagePlus\(\"Output\", outStack\).show\(\);" );
print(scriptFile, "\n");
print(scriptFile, "}");
print(scriptFile, "}");

File.close(scriptFile);


// -------------------------COMPILE PLUGIN SCRIPT-----------------------------------


pluginPath = replace(pluginPath, "\\", "/");

compileString = "compile=["+pluginPath+"]";

run("Compile and Run...", compileString); // compile java script to make .class file

wait(500);

windowList = getList("window.titles");
for(i=0; i<windowList.length; i++)
	if(startsWith(windowList[i], "Exception") == 1){
		selectWindow("Exception"); // exception window comes up & this closes it
		run("Close");
	}
		

print("\\Clear");

print("Cone mapping model completed");

print("____________________________________");
print("Model name:");
print(scriptName);
print("........................................................................");
print("Model R^2 values:");

for(i=0; i<modelR2s.length; i++)
	print(modelR2s[i]);
print("____________________________________");

run("Refresh Menus"); // refresh menus so the new script is visible
updateResults;
selectWindow("Results");
run("Close");




