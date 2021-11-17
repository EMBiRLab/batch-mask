import ij.*;
import ij.plugin.filter.PlugInFilter;
import ij.process.*;



public class RGB_Exposure_Test implements PlugInFilter {

ImageStack stack;
	public int setup(String arg, ImagePlus imp) { 
	stack = imp.getStack(); 
	return DOES_RGB; 
	}

public void run(ImageProcessor ip) {


	int w = stack.getWidth();
	int h = stack.getHeight();

	int[] pixels =(int[]) ip.getPixels();

	int v = 0;
	int red = 0;
	int green = 0;
	int blue = 0;
	int odd = 1;
	int satThreshold = 254;


	for(int j=0; j<w*h; j++){
		odd *= -1;
		v = pixels[j];
		red = (v>>16)&0xff;
		green = (v>>8)&0xff;
		blue = v&0xff;
		
		if(odd == 1){
		if(red>satThreshold && green>satThreshold && blue>satThreshold)
			pixels[j] = 0x000000;
		else if(red>satThreshold && green>satThreshold)
			pixels[j] = 0xffff00;
		else if(red>satThreshold && blue>satThreshold)
			pixels[j] = 0xff00ff;
		else if(green>satThreshold && blue>satThreshold)
			pixels[j] = 0x00ffff;
		else if(red>satThreshold)
			pixels[j] = 0xff0000;
		else if(green>satThreshold)
			pixels[j] = 0x00ff00;
		else if(blue>satThreshold)
			pixels[j] = 0x0000ff;
		}else{		
		if(red>satThreshold && green>satThreshold && blue>satThreshold)
			pixels[j] = 0xffffff;
		else if(red>satThreshold || green>satThreshold || blue>satThreshold)
			pixels[j] = 0x000000;
		}
	}//j

}
}
