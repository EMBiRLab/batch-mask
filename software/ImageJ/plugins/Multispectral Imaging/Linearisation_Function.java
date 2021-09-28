/*__________________________________________________________________

	Title: Linearisation Function
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Author: Jolyon Troscianko
	Date: 17/10/16
............................................................................................................

This code applies a linearisation transform to the selected channel of
an image. Designed for use with linearisation & normalisation scripts
as a faster processing method than macro language calls.

JT Linearisation equation: y =x*x*c +x*d + exp((x-a)/b)

____________________________________________________________________
*/



import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.filter.*;

public class Linearisation_Function implements PlugInFilter {



ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	//return DOES_32 + STACK_REQUIRED; 
	return DOES_32; 
	}
public void run(ImageProcessor ip) {

	double a = 0.0;
	double b = 0.0;
	double c = 0.0;
	double d = 0.0;

	String[] equNames = new String[13];

	equNames[0] = "Straight Line";
	equNames[1] = "JT Linearisation";
	equNames[2] = "sRGB";
	equNames[3] = "2nd Degree Polynomial";
	equNames[4] = "3rd Degree Polynomial";
	equNames[5] = "Rodbard";
	equNames[6] = "Power";
	equNames[7] = "Exponential";
	equNames[8] = "Exponential with Offset";
	equNames[9] = "Exponential Recovery";
	equNames[10] = "Gaussian";
	equNames[11] = "Gamma Variate";
	equNames[12] = "Chapman-Richards";

	int slice = 1;

	GenericDialog gd = new GenericDialog("Linearisation Function");
		gd.addChoice("Equation", equNames, "JT Linearisation");
		gd.addNumericField("a", a, 12);
		gd.addNumericField("b", b, 12);
		gd.addNumericField("c", c, 12);
		gd.addNumericField("d", d, 12);

		gd.addMessage("");
		gd.addNumericField("Slice", slice, 0);

		gd.showDialog();
			if (gd.wasCanceled())
				return;

	String eqn = gd.getNextChoice();
	a = gd.getNextNumber();
	b = gd.getNextNumber();
	c = gd.getNextNumber();
	d = gd.getNextNumber();
	slice = (int) Math.round( gd.getNextNumber());

float[] rawPxs;

int dimension = stack.getWidth()*stack.getHeight();

float[] transPxs = new float[dimension];


rawPxs = (float[]) stack.getPixels(slice);

// ------------Linearise pixels using selected equation------------------


if(eqn.equals("Straight Line"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) (a+b*rawPxs[i]);

if(eqn.equals("JT Linearisation"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) (rawPxs[i]*rawPxs[i]*c +rawPxs[i]*d + Math.exp((rawPxs[i]-a)/b));

if(eqn.equals("sRGB"))
	for (int i=0; i<dimension; i++) 
		if(rawPxs[i]<=10)
			transPxs[i] = (float) ((rawPxs[i]/255)/12.92);
			else transPxs[i] = (float) Math.pow(((rawPxs[i]/255)+0.055)/(1+0.055),2.4);

if(eqn.equals("2nd Degree Polynomial"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a+b*rawPxs[i]+c*rawPxs[i]*rawPxs[i] );

if(eqn.equals("3rd Degree Polynomial"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a+b*rawPxs[i]+c*rawPxs[i]*rawPxs[i]+d*rawPxs[i]*rawPxs[i]*rawPxs[i] );

if(eqn.equals("Rodbard"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( d+(a-d)/(1+Math.pow(rawPxs[i]/c,b)) );

if(eqn.equals("Power"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a*Math.pow(rawPxs[i],b) );

if(eqn.equals("Exponential"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a*Math.exp(b*rawPxs[i]) );

if(eqn.equals("Exponential with Offset"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a*Math.exp(-b*rawPxs[i]) + c );

if(eqn.equals("Exponential Recovery"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a*(1-Math.exp(-b*rawPxs[i])) + c );

if(eqn.equals("Gaussian"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a + (b-a)*Math.exp(-(rawPxs[i]-c)*(rawPxs[i]-c)/(2*d*d)) );

if(eqn.equals("Gamma Variate"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( b*Math.pow(rawPxs[i]-a,c)*Math.exp(-(rawPxs[i]-a)/d) );

if(eqn.equals("Chapman-Richards"))
	for (int i=0; i<dimension; i++) 
		transPxs[i] = (float) ( a*Math.pow(1-Math.exp(-b*rawPxs[i]),c) );

stack.setPixels(transPxs, slice);
}
}
