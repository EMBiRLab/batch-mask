/*__________________________________________________________________

	Title: XYZ to CIE LAB Colour Space (32-bit)
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Author: Jolyon Troscianko
	Date: 14/4/2014
............................................................................................................

This code converts XYZ to CIE LAB colour space, based on the procedure
used here: http://www.easyrgb.com/index.php?X=MATH&H=07#text7

The code requries a 32-bit XYZ stack (previously made with cone-mapping)

XYZ image must be in a percentage range (0-100) to get the correct result


____________________________________________________________________
*/


import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;

public class XYZ_to_CIELAB_32Bit implements PlugInFilter {

ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	return DOES_32 + STACK_REQUIRED; 
	}
public void run(ImageProcessor ip) {

float[] X;
float[] Y;
float[] Z;
int w = stack.getWidth();
int h = stack.getHeight();
int dimension = w*h;

// values for a 2 degree (1931) observer under D65 according to the website (but we've already done a von-Kreis, so seems unnecessary)
//double refX = 95.047;
//double refY = 100.000;
//double refZ = 108.883;

double refX = 65535.0;
double refY = 65535.0;
double refZ = 65535.0;

double oneThird = 1.0/3.0;

float[] L = new float[dimension];
float[] A = new float[dimension];
float[] B = new float[dimension];

X = (float[]) stack.getPixels(1);
Y = (float[]) stack.getPixels(2);
Z = (float[]) stack.getPixels(3);



for (int i=0;i<dimension;i++) {

double tempX = X[i]/refX;
double tempY = Y[i]/refY;
double tempZ = Z[i]/refZ;

if(tempX > 0.008856)
	tempX = Math.pow(tempX, oneThird);
else tempX = ( 7.787 * tempX) + ( 16.0 / 116.0 );

if(tempY > 0.008856)
	tempY = Math.pow(tempY, oneThird);
else tempY = ( 7.787 * tempY) + ( 16.0 / 116.0 );

if(tempZ > 0.008856)
	tempZ = Math.pow(tempZ, oneThird);
else tempZ = ( 7.787 * tempZ) + ( 16.0 / 116.0 );

L[i] = (float) ((116.0*tempY) - 16.0);
A[i] = (float) (500.0 * (tempX - tempY));
B[i] = (float) (200.0 * (tempY - tempZ));

}



ImageStack outStack = new ImageStack(w, h);
outStack.addSlice("CIE L", L);
outStack.addSlice("CIE A", A);
outStack.addSlice("CIE B", B);
new ImagePlus("CIE LAB", outStack).show();

}
}
