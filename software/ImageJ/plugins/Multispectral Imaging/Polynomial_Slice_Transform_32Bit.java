/*__________________________________________________________________

	Title: Polynomial Slice Transform (32-bit)
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Author: Jolyon Troscianko
	Date: 8/7/2014
............................................................................................................

This code applies a polynomial transform to the selected channel of
an image. Designed for use with linearisation & normalisation scripts
as a faster processing method than macro language calls.
____________________________________________________________________
*/



import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.filter.*;

public class Polynomial_Slice_Transform_32Bit implements PlugInFilter {



ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	//return DOES_32 + STACK_REQUIRED; 
	return DOES_32; 
	}
public void run(ImageProcessor ip) {

	double x2 = 0.0;
	double x1 = 1.0;
	double x0 = 0.0;
	int slice = 1;

			GenericDialog gd = new GenericDialog("RGB Linearisation");
			gd.addMessage("Quadratic adjustment of slice pixels:\n"
				+"New Colour = X2*(Old Colour^2) + Old Colour*X + C");
			gd.addMessage("");
			gd.addNumericField("X^2", x2, 2);
			gd.addNumericField("X", x1, 2);
			gd.addNumericField("constant", x0, 2);
			gd.addMessage("");
			gd.addNumericField("Slice", slice, 0);

			gd.showDialog();

	
	x2 = gd.getNextNumber();
	x1 = gd.getNextNumber();
	x0 = gd.getNextNumber();
	slice = (int) Math.round( gd.getNextNumber());

float[] rawPxs;

int dimension = stack.getWidth()*stack.getHeight();

float[] transPxs = new float[dimension];


rawPxs = (float[]) stack.getPixels(slice);


for (int i=0;i<dimension;i++) 
	transPxs[i] = (float) (rawPxs[i] * rawPxs[i] * x2 + rawPxs[i] * x1 + x0);


stack.setPixels(transPxs, slice);
}
}
