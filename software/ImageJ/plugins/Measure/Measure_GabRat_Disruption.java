import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;

import ij.measure.ResultsTable;

/*

-Convolve the original image parallel with its outline AND orthogonal to it.
-Disruption could be considered to be the ratio of parallel to orthogonal energy

Process:

-Extract image data
-Create mask of pixels inside ROI (black outside, white inside)
-Extract pixles that make up the edge of the target
-Convolve the edge of the MASK image (black & white object outline) to find the angle of the outline at this scale
-Convolve the original image around the edges at all angles
-Convert the gabor data to absolute values
-Find the dominant angle (max energy in mask gabor data)
-calculate the difference between the parallel and orthogonal image gabor data
i.e. difference = orthogonal/(orthogonal+parallel)
any values >0.5 would be disruptive, < 0.5 would create salient edges

This results in the "Edge Disruption Ratio", which says how much the patterns of the object and its background
disrupt or enhance its outline. In additon the "Edge Disruption Energy" is produced, which defines the contrast
of the edge of the target orthogonal to its outline. The two are likely to be correlated...



*/
public class Measure_GabRat_Disruption implements PlugIn {
public void run(String arg) {


	ImagePlus imp = IJ.getImage();

	// ---------------------- Calculate Gabor Filter Stuff-------------------------------

	int nAngles = 4;
	double sigma = 3.0;
	double gamma = 1.0;
	double Fx = 2.0;
	String imTitle = imp.getTitle();

	GenericDialog gd = new GenericDialog("RGB Linearisation");
		gd.addMessage("Gabor Filter Settings");
		gd.addNumericField("Number_of_angles", nAngles, 0);
		gd.addNumericField("Sigma", sigma, 2);
		gd.addNumericField("Gamma aspect ratio", gamma, 2);
		gd.addNumericField("Frequency", Fx, 2);
		gd.addMessage("Output Images");
		gd.addCheckbox("Gabor Kernel", false);
		gd.addCheckbox("Edge and Mask", false);
		gd.addCheckbox("GabRat", false);
		//gd.addCheckbox("GabRatE", false);
		gd.addStringField("Label", imTitle, 20);
		//gd.addNumericField("Row", 0, 0);

	gd.showDialog();
	if (gd.wasCanceled())
		return;

	
	nAngles = (int) Math.round(gd.getNextNumber());
	sigma = gd.getNextNumber();
	gamma = gd.getNextNumber();
	Fx = gd.getNextNumber();
	double psi = Math.PI / 4.0 * 2; // Phase


	boolean outputKernel = gd.getNextBoolean();
	boolean outputMask = gd.getNextBoolean();
	boolean outputGabRat= gd.getNextBoolean();
	//boolean outputGabRatE = gd.getNextBoolean();

	imTitle = gd.getNextString();
	//int row = (int) Math.round(gd.getNextNumber());

	if(nAngles/2 != Math.round(nAngles/2))
		nAngles = nAngles -1;

	double sigma_x = sigma;
	double sigma_y = sigma / gamma;
	double largerSigma = 0.0; 

	// Decide size of the filters based on the sigma
	if(sigma_x > sigma_y)
		largerSigma = sigma_x;
	else largerSigma = sigma_y;

	if(largerSigma < 1)
		largerSigma = 1;

	double sigma_x2 = sigma_x * sigma_x;
	double sigma_y2 = sigma_y * sigma_y;

	int filterSizeX = (int) Math.round(6 * largerSigma + 1);
	int filterSizeY = (int) Math.round(6 * largerSigma + 1);

	float[] kernelArray = new float[nAngles * filterSizeX * filterSizeY];


	int middleX = Math.round(filterSizeX / 2) + 1;
	int middleY = Math.round(filterSizeY / 2) + 1; 

	double rotationAngle = Math.PI/nAngles;
	double theta = 0.0;
	double xPrime = 0.0;
	double yPrime = 0.0;
	double a = 0.0;
	double c = 0.0;

	
	ImageStack kernelStack = new ImageStack(filterSizeX, filterSizeY);
	
	for(int i=0; i<nAngles; i++){
		theta = rotationAngle * i;
		float[] kernelOutputArray = new float[filterSizeX * filterSizeY];

		for(int y=0; y<filterSizeY; y++){
			for(int x=0; x<filterSizeX; x++){
				xPrime = (x-middleX+1) * Math.cos(theta) + (y-middleY+1) * Math.sin(theta);
				yPrime = (y-middleY+1) * Math.cos(theta) - (x-middleX+1) * Math.sin(theta);
				a = 1.0 / ( 2.0 * Math.PI * sigma_x * sigma_y ) * Math.exp(-0.5 * (xPrime*xPrime / sigma_x2 + yPrime*yPrime / sigma_y2) );
				c = Math.cos( 2.0 * Math.PI * (Fx * xPrime) / filterSizeX + psi);
             				kernelArray[(i*filterSizeX * filterSizeY)+(y*filterSizeX)+x] = (float) (a*c);
				kernelOutputArray[(y*filterSizeX)+x] = (float) (a*c);
			}//x
		}//y

		if(outputKernel == true)
			kernelStack.addSlice("angle " + i, kernelOutputArray);
		
	}// i (angles)


	// --------------------- Get ROI Mask and Outline---------------------------------


	Roi roi = imp.getRoi();
	if (roi!=null && !roi.isArea()) roi = null;
	ImageProcessor ip = imp.getProcessor();
	ImageProcessor mask = roi.getMask();

	//Rectangle r = roi.getBounds():new Rectangle(0,0,ip.getWidth(),ip.getHeight());
	Rectangle r = roi.getBounds();

	int w = ip.getWidth();
	int h = ip.getHeight();


	float[] edgeArray = new float[w*h];

/*
	double sum = 0;
	int count = 0;

	for (int y=0; y<r.height; y++)
	for (int x=0; x<r.width; x++)
		if (mask.getPixel(x,y)!=0) {
			count++;
			sum += ip.getPixelValue(x+r.x, y+r.y);
		}
	IJ.log("count: "+count);
	IJ.log("mean: "+IJ.d2s(sum/count,4));
*/


	// Find up-down outline (bottom edge)
	for (int y=0; y<r.height-1; y++)
	for (int x=0; x<r.width; x++)
	if(mask.getPixel(x,y) != 0 && mask.getPixel(x,y+1) == 0)
		edgeArray[((y+r.y)*w) + x+r.x] = 1;

	// Find down-up outline (top edge)
	for (int y=0; y<r.height-1; y++)
	for (int x=0; x<r.width; x++)
	if(mask.getPixel(x,y+1) != 0 && mask.getPixel(x,y) == 0)
		edgeArray[(((y+1)+r.y)*w) + x+r.x] = 1;

	// Find left-right outline (right edge)
	for (int y=0; y<r.height; y++)
	for (int x=0; x<r.width-1; x++)
	if(mask.getPixel(x,y) != 0 && mask.getPixel(x+1,y) == 0)
		edgeArray[((y+r.y)*w) + x+r.x] = 1;

	// Find right-left outline (left edge)
	for (int y=0; y<r.height; y++)
	for (int x=0; x<r.width-1; x++)
	if(mask.getPixel(x+1,y) != 0 && mask.getPixel(x,y) == 0)
		edgeArray[((y+r.y)*w) + x+r.x+1] = 1;

	// Fill in the mask edges that meet the boundaries
	for (int y=0; y<r.height; y++){
		if(mask.getPixel(0,y) != 0)
			edgeArray[((y+r.y)*w) + r.x] = 1;
		if(mask.getPixel(r.width-1,y) != 0)
			edgeArray[((y+r.y)*w) + r.width+r.x-1] = 1;	
	}

	for (int x=0; x<r.width; x++){
		if(mask.getPixel(x,0) != 0)
			edgeArray[(r.y*w) + x+r.x] = 1;
		if(mask.getPixel(x,r.height-1) != 0)
			edgeArray[((r.height+r.y-1)*w) + x+r.x] = 1;	
	}

	// Create arrays with x & y coordinates of the edge points
	int edgeCount = 0;
	for(int i=0; i<w*h; i++)
	if(edgeArray[i] == 1)
		edgeCount++;

	int[] xCoords = new int[edgeCount];
	int[] yCoords = new int[edgeCount];

	edgeCount = 0;
	for(int y=r.y; y<r.height+r.y; y++)
	for(int x=r.x; x<r.width+r.x; x++)
	if(edgeArray[(y*w)+x] == 1){
		xCoords[edgeCount] = x;
		yCoords[edgeCount] = y;
		edgeCount++;
	}


	// Create mask image with full size for Gabor convolution
	float[] maskArray = new float[w*h];

	for (int y=0; y<r.height; y++)
	for (int x=0; x<r.width; x++)
	if(mask.getPixel(x,y) != 0)
		maskArray[((y+r.y)*w) + x+r.x] = 1;


	// ----------------------------------------CONVOLVE-----------------------------------------


	double[] maskGaborData = new double[edgeCount * nAngles];
	double[] imageGaborData = new double[edgeCount * nAngles];
	int xFocus = 0;
	int yFocus = 0;

	for(int i=0; i<nAngles; i++){
		
		for(int j=0; j<edgeCount; j++){
			xFocus = xCoords[j]-middleX+1; // I tested this centre, and it's correct
			yFocus = yCoords[j]-middleY+1;
			for(int y=0; y<filterSizeY; y++)
				for(int x=0; x<filterSizeX; x++){
					//work out the angle of the object outline at each point on the edge
					maskGaborData[(i*edgeCount)+j] = maskGaborData[(i*edgeCount)+j] + (maskArray[((yFocus+y)*w)+(xFocus+x)] * kernelArray[(i*filterSizeX * filterSizeY)+(y*filterSizeX)+x]);
					// parallel to the outline and orthogonal to the outline
					imageGaborData[(i*edgeCount)+j] = imageGaborData[(i*edgeCount)+j] + (ip.getPixelValue(xFocus+x, yFocus+y) * kernelArray[(i*filterSizeX * filterSizeY)+(y*filterSizeX)+x]);
				}//x
		}//j

	}// i (angles)


	// --------------------CONVERT TO ABSOLUTE-------------------------

	for(int i=0; i<nAngles*edgeCount; i++){
		maskGaborData[i] = Math.abs(maskGaborData[i]);
		imageGaborData[i] = Math.abs(imageGaborData[i]);
	}


/*
	// Create images of output (mostly for debugging)
	ImageStack maskGaborStack = new ImageStack(w, h);
	for(int i=0; i<nAngles; i++){
		float[] tempArray = new float[w * h];
		for(int j=0; j<edgeCount; j++)
			tempArray[(yCoords[j]*w) +xCoords[j]] = (float) (maskGaborData[(i*edgeCount)+j]);
		maskGaborStack.addSlice("angle " + i, tempArray);
	}
	new ImagePlus("Mask Gabor", maskGaborStack).show();

	ImageStack imageGaborStack = new ImageStack(w, h);
	for(int i=0; i<nAngles; i++){
		float[] tempArray = new float[w * h];
		for(int j=0; j<edgeCount; j++)
			tempArray[(yCoords[j]*w) +xCoords[j]] = (float) (imageGaborData[(i*edgeCount)+j]);
		imageGaborStack.addSlice("angle " + i, tempArray);
	}
	new ImagePlus("Image Gabor", imageGaborStack).show();

*/


	// --------------FIND ANGLE OF THE TARGET'S EDGE-----------------------

	int[] edgeAngle = new int[edgeCount];
	double[] maskEnergy = new double[edgeCount];
	double energy = 0.0;

	for(int j=0; j<edgeCount; j++)
		for(int i=0; i<nAngles; i++){
			energy = maskGaborData[(i*edgeCount)+j];
			if(energy > maskEnergy[j]){
				edgeAngle[j] = i;
				maskEnergy[j] = energy;
			}
		}


	//-------------CALCULATE GabRat EDGE DISRUPTION RATIO----------------------
	//GabRat= orthogonal/(orthogonal+parallel)
	//any values >0.5 would be disruptive, < 0.5 would create salient edges

	double[] gabRat = new double[edgeCount];
	double[] gabRatE = new double[edgeCount]; // GabRatE is weighted by the overall power of the edge energy, so weak edges aren't counted
	double[] orthEnergy = new double[edgeCount];
	double[] paraEnergy = new double[edgeCount];
	int paraAngle = 0;
	int orthAngle = 0;

	for(int j=0; j<edgeCount; j++){
		paraAngle = edgeAngle[j];
		// Calculate opposite (orthogonal) angle to edge
		orthAngle = paraAngle - (nAngles/2);
		if(paraAngle < nAngles/2)
			orthAngle = paraAngle + (nAngles/2);
		paraEnergy[j] = imageGaborData[(paraAngle*xCoords.length)+j];
		orthEnergy[j] = imageGaborData[(orthAngle*xCoords.length)+j];
		gabRat[j] = orthEnergy[j] / (  orthEnergy[j] + paraEnergy[j]  );
		gabRatE[j] = (orthEnergy[j] / (  orthEnergy[j] + paraEnergy[j]  )) * orthEnergy[j];
	}

	double gabRatSum = 0.0;
	double gabRatESum = 0.0;

	for(int j=0; j<edgeCount; j++){
		gabRatSum += gabRat[j];
		gabRatESum += gabRatE[j];
	}


	//----------------------------OUTPUT IMAGES------------------------------------------

	// Create images of GabRat output (mostly for debugging)
	if(outputGabRat == true){
		ImageStack GabRatStack = new ImageStack(w, h);
		float[] tempArray = new float[w * h];
		for(int j=0; j<edgeCount; j++)
			tempArray[(yCoords[j]*w) +xCoords[j]] = (float) (gabRat[j]);
		GabRatStack.addSlice("GabRat", tempArray);
		new ImagePlus("GabRat", GabRatStack).show();
	}

	// Show GabRatE
	/*
	if(outputGabRatE == true){
		ImageStack GabRatEStack = new ImageStack(w, h);
		float[] tempArray2 = new float[w * h];
		for(int j=0; j<edgeCount; j++)
			tempArray2[(yCoords[j]*w) +xCoords[j]] = (float) (gabRatE[j]);
		GabRatEStack.addSlice("GabRatE", tempArray2);
		new ImagePlus("GabRatE", GabRatEStack).show();
	}
	*/

	// Show Kernel Image:
	if(outputKernel == true)
		new ImagePlus("Gabor Kernel", kernelStack).show();


	// Show Mask Image:
	if(outputMask == true){
		ImageStack outStack = new ImageStack(w, h);
		outStack.addSlice("mask outline", edgeArray);
		outStack.addSlice("mask", maskArray);
		new ImagePlus("Masks", outStack).show();
	}

	// ------------------ OUTPUT RESULTS--------------------------


	ResultsTable rt =  ResultsTable.getResultsTable();
	// if adding new row:
	rt.incrementCounter();
	rt.addValue("ID", imTitle);
	rt.addValue("Sigma", sigma);
	rt.addValue("GabRat", gabRatSum/edgeCount);
	//rt.addValue("GabRatE", gabRatESum/edgeCount);
	/*
	rt.setValue("Sigma", row, sigma);
	rt.setValue("GabRat", row, gabRatSum/edgeCount);
	rt.setValue("GabRatE", row, gabRatESum/edgeCount);
	*/

	rt.showRowNumbers(false);
	rt.show("Results");

}
}
