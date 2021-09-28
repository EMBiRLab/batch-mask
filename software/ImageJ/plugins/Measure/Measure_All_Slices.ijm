// Measure all channels


plugins = getDirectory("plugins");

installString = "install=[" + plugins + "Measure/Measure_All_Slices.txt]";

run("Install...", installString);// Measure all channels

macro "Measure all channels [m]" {

setBatchMode(true);

row = nResults;

if(bitDepth!=24){ // image stack

if(getMetadata("Label") == ""){
	for(i=1; i<nSlices+1; i++){
		setSlice(i);
		getStatistics(area, mean);
		setResult(i, row, mean);
	}
} else {

	for(i=1; i<nSlices+1; i++){
		setSlice(i);
		getStatistics(area, mean);
		setResult(getMetadata("Label"), row, mean);
	}
}

	setSlice(1);

}// stack

if(bitDepth==24){ // RGB image

setRGBWeights(1,0,0); //red
	getStatistics(area, mean);
	setResult("Red", row, mean);

setRGBWeights(0,1,0); //green
	getStatistics(area, mean);
	setResult("Green", row, mean);

setRGBWeights(0,0,1); //blue
	getStatistics(area, mean);
	setResult("Blue", row, mean);


}// RGB image


setBatchMode(false);
updateResults();

} // macro ends
