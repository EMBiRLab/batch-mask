
import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;

public class Human_Luminance_32bit implements PlugInFilter {

	ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
		stack = imp.getStack(); 
		return DOES_32 + STACK_REQUIRED; 
	}

public void run(ImageProcessor ip) {

	float[] lw;
	float[] mw;
	int w =  stack.getWidth();
	int h = stack.getHeight();
	int dimension =w*h;

	float[] lum = new float[dimension];

	lw = (float[]) stack.getPixels(1); // 1 
	mw = (float[]) stack.getPixels(2); // 2

	for (int i=0;i<dimension;i++) {
		lum[i] = (float)  ((lw[i])+(mw[i])) /2;
	}


	
	stack.addSlice("lum",lum); // adds luminance slice to end of stack


	//ImageStack outStack = new ImageStack(w, h); // output new image
	//outStack.addSlice("lum",lum);
	//new ImagePlus("Luminance", outStack).show();
	//imp.close();
	//new ImagePlus("Luminance", stack).show(); // output new stack
}


}
