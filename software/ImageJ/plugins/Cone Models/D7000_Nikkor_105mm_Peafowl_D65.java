// Code automatically generated by "Generate_Cone_Mapping_Model" script by Jolyon Troscianko

//Model fits:
//vsR2 0.998361887388435
//swR2 0.998011795821193
//mwR2 0.999428610977042
//lwR2 0.995995156312968
//dblR2 0.999452632472574
// Modelled based on Natural Spectra 300-700 database, containing 3139 spectra.
// Generated: 2015/3/6   15:10:30
import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;
public class D7000_Nikkor_105mm_Peafowl_D65 implements PlugInFilter {
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
float[] vs = new float[dimension];
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
vs[i] = (float) ( 193.509221169149 + vR[i] * 0.0299333626909147 + vG[i] * -0.178282119336698 + vB[i] * 0.911206467774511 + uB[i] * 0.741693500753728 + uR[i] * -0.532045022470865 + vR[i]*vG[i] * -8.82836982053305e-08 + vR[i]*vB[i] * 8.66112915543115e-07 + vR[i]*uB[i] * -5.70734194209008e-06 + vR[i]*uR[i] * 4.93455954710818e-06 + vG[i]*vB[i] * -1.09458202222242e-06 + vG[i]*uB[i] * -1.94361152854245e-05 + vG[i]*uR[i] * 1.985508429281e-05 + vB[i]*uB[i] * 4.47491614010038e-05 + vB[i]*uR[i] * -4.47339443489947e-05 + uB[i]*uR[i] * 1.11042085667962e-06);
sw[i] = (float) ( -313.274834893923 + vR[i] * -0.119163885483219 + vG[i] * 0.390621608360251 + vB[i] * 0.793072455770763 + uB[i] * -0.329010605326705 + uR[i] * 0.295270964477552 + vR[i]*vG[i] * -2.27465894920886e-07 + vR[i]*vB[i] * -8.65896275076843e-07 + vR[i]*uB[i] * 1.14695611314541e-05 + vR[i]*uR[i] * -1.17138085861394e-05 + vG[i]*vB[i] * 1.50035601683607e-06 + vG[i]*uB[i] * 1.76556969965884e-05 + vG[i]*uR[i] * -1.6125713109503e-05 + vB[i]*uB[i] * -4.49783372127627e-05 + vB[i]*uR[i] * 4.4269245344787e-05 + uB[i]*uR[i] * -1.48641113023288e-06);
mw[i] = (float) ( 349.733427644899 + vR[i] * -0.328164622064066 + vG[i] * 1.70841653284993 + vB[i] * -0.401145493387985 + uB[i] * -0.0115428703352005 + uR[i] * 0.0103447316413267 + vR[i]*vG[i] * 2.44032255833445e-08 + vR[i]*vB[i] * 1.43228116772477e-06 + vR[i]*uB[i] * 1.23404642013494e-06 + vR[i]*uR[i] * -1.57551782896136e-06 + vG[i]*vB[i] * -1.74936227985885e-06 + vG[i]*uB[i] * -2.83368528052554e-05 + vG[i]*uR[i] * 2.69367159829789e-05 + vB[i]*uB[i] * 3.51203238562011e-05 + vB[i]*uR[i] * -3.31328120373897e-05 + uB[i]*uR[i] * 3.66598011393826e-07);
lw[i] = (float) ( -624.642759650483 + vR[i] * 0.64974397418503 + vG[i] * 0.758424559408924 + vB[i] * -0.451313952345061 + uB[i] * 0.295135569093828 + uR[i] * -0.26815184657572 + vR[i]*vG[i] * -2.43209453354669e-06 + vR[i]*vB[i] * 6.3878391916489e-08 + vR[i]*uB[i] * -1.21018155377226e-05 + vR[i]*uR[i] * 1.5416274848735e-05 + vG[i]*vB[i] * 3.21608397855738e-06 + vG[i]*uB[i] * 4.01329203655034e-05 + vG[i]*uR[i] * -4.61832890284566e-05 + vB[i]*uB[i] * -2.47417627988922e-05 + vB[i]*uR[i] * 2.62346404708125e-05 + uB[i]*uR[i] * 9.35200630232586e-07);
dbl[i] = (float) ( -130.360990387897 + vR[i] * 0.0142722147804045 + vG[i] * 1.2615247586125 + vB[i] * -0.297551445253607 + uB[i] * 0.149116471113159 + uR[i] * -0.138584569530508 + vR[i]*vG[i] * -6.06065814859458e-07 + vR[i]*vB[i] * -7.3090870279587e-09 + vR[i]*uB[i] * -8.88695822190121e-06 + vR[i]*uR[i] * 1.00195287915202e-05 + vG[i]*vB[i] * 8.66612919028316e-07 + vG[i]*uB[i] * 1.65916730026606e-05 + vG[i]*uR[i] * -1.8916915451907e-05 + vB[i]*uB[i] * -5.52864887807747e-06 + vB[i]*uR[i] * 6.31261256905414e-06 + uB[i]*uR[i] * 4.21194549400099e-07);
}
ImageStack outStack = new ImageStack(w, h);
outStack.addSlice("vs", vs);
outStack.addSlice("sw", sw);
outStack.addSlice("mw", mw);
outStack.addSlice("lw", lw);
outStack.addSlice("dbl", dbl);
new ImagePlus("Output", outStack).show();
}
}
