// Code automatically generated by "Generate_Cone_Mapping_Model" script by Jolyon Troscianko

//Model fits:
//uvR2 0.998798258142599
//swR2 0.999847748793233
//mwR2 0.999717121267557
//lwR2 0.997743051409364
//dblR2 0.999608512513927
// Modelled based on Natural Spectra 300-700 database, containing 3139 spectra.
// Generated: 2015/3/6   15:9:9
import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;
public class D7000_Nikkor_105mm_Bluetit_D65 implements PlugInFilter {
ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	return DOES_32 + STACK_REQUIRED; 
	}
public void run(ImageProcessor ip) {
float[] vR;
float[] vG;
float[] vB;
float[] uB;
float[] uR;
int w = stack.getWidth();
int h = stack.getHeight();
int dimension = w*h;
float[] uv = new float[dimension];
float[] sw = new float[dimension];
float[] mw = new float[dimension];
float[] lw = new float[dimension];
float[] dbl = new float[dimension];
vR = (float[]) stack.getPixels(1);
vG = (float[]) stack.getPixels(2);
vB = (float[]) stack.getPixels(3);
uB = (float[]) stack.getPixels(4);
uR = (float[]) stack.getPixels(5);
for (int i=0;i<dimension;i++) {
uv[i] = (float) ( 58.3122519148696 + vR[i] * 0.0229758301149583 + vG[i] * -0.0561573560527075 + vB[i] * 0.0987038018350282 + uB[i] * 0.339749608978195 + uR[i] * 0.574908523514609 + vR[i]*vG[i] * -1.3365440587945e-07 + vR[i]*vB[i] * 6.10564033475276e-08 + vR[i]*uB[i] * 6.87673705331685e-06 + vR[i]*uR[i] * -8.95636028775291e-06 + vG[i]*vB[i] * -2.6387397691757e-07 + vG[i]*uB[i] * -2.59634840291405e-05 + vG[i]*uR[i] * 2.94483694861703e-05 + vB[i]*uB[i] * 3.17162607699098e-05 + vB[i]*uR[i] * -3.22443925309551e-05 + uB[i]*uR[i] * -2.58191037755816e-07);
sw[i] = (float) ( 58.0529944927115 + vR[i] * 0.00455552584017319 + vG[i] * -0.152442462319692 + vB[i] * 1.10191750080059 + uB[i] * 0.205293929907043 + uR[i] * -0.169893116234075 + vR[i]*vG[i] * -4.70140664589542e-08 + vR[i]*vB[i] * 1.95863806063864e-07 + vR[i]*uB[i] * -3.76296157392711e-06 + vR[i]*uR[i] * 3.87027698151598e-06 + vG[i]*vB[i] * -1.87590784961778e-07 + vG[i]*uB[i] * -2.63687181226937e-06 + vG[i]*uR[i] * 1.82321058649682e-06 + vB[i]*uB[i] * 1.14397871240409e-05 + vB[i]*uR[i] * -1.08109435050491e-05 + uB[i]*uR[i] * 3.00079055714599e-07);
mw[i] = (float) ( 217.813055234822 + vR[i] * -0.27531296402472 + vG[i] * 1.62775461752385 + vB[i] * -0.370989473050361 + uB[i] * 0.0284133723729995 + uR[i] * -0.0254101696269005 + vR[i]*vG[i] * -2.80929516376682e-08 + vR[i]*vB[i] * 9.62748969629815e-07 + vR[i]*uB[i] * -5.00057331434519e-07 + vR[i]*uR[i] * 3.67336996269732e-07 + vG[i]*vB[i] * -1.13206050518157e-06 + vG[i]*uB[i] * -1.77399497486114e-05 + vG[i]*uR[i] * 1.67080882915985e-05 + vB[i]*uB[i] * 2.44673128601252e-05 + vB[i]*uR[i] * -2.32615842034958e-05 + uB[i]*uR[i] * 3.91512018616032e-07);
lw[i] = (float) ( -516.046860173928 + vR[i] * 0.789826730266788 + vG[i] * 0.525950552740961 + vB[i] * -0.345160894819355 + uB[i] * 0.176776496643152 + uR[i] * -0.156783307087058 + vR[i]*vG[i] * -2.45368357423971e-06 + vR[i]*vB[i] * 9.67095660165951e-07 + vR[i]*uB[i] * -7.17528895847751e-06 + vR[i]*uR[i] * 9.42555264399489e-06 + vG[i]*vB[i] * 2.13327012097877e-06 + vG[i]*uB[i] * 2.9178187519148e-05 + vG[i]*uR[i] * -3.32761766960086e-05 + vB[i]*uB[i] * -1.92311529740166e-05 + vB[i]*uR[i] * 2.01529336914854e-05 + uB[i]*uR[i] * 6.46748873664181e-07);
dbl[i] = (float) ( -137.743871422107 + vR[i] * 0.107086871063743 + vG[i] * 1.03596873731926 + vB[i] * -0.158069317171665 + uB[i] * 0.100848005026124 + uR[i] * -0.0936732409742084 + vR[i]*vG[i] * -7.36948357765166e-07 + vR[i]*vB[i] * 2.64245841339836e-07 + vR[i]*uB[i] * -6.72373563611432e-06 + vR[i]*uR[i] * 7.64031419723328e-06 + vG[i]*vB[i] * 7.12620934704052e-07 + vG[i]*uB[i] * 1.48487713068462e-05 + vG[i]*uR[i] * -1.66991294308939e-05 + vB[i]*uB[i] * -6.82140520973141e-06 + vB[i]*uR[i] * 7.4311016458095e-06 + uB[i]*uR[i] * 2.85379114240465e-07);
}
ImageStack outStack = new ImageStack(w, h);
outStack.addSlice("uv", uv);
outStack.addSlice("sw", sw);
outStack.addSlice("mw", mw);
outStack.addSlice("lw", lw);
outStack.addSlice("dbl", dbl);
new ImagePlus("Output", outStack).show();
}
}
