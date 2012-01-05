package be.mxs.common.util.system;

import java.awt.image.RGBImageFilter;

// This filter replaces a color in an image
class KeepColorFilter extends RGBImageFilter {
	int sourcergb=0;
	
    public KeepColorFilter(int sourcergb) {
        // When this is set to true, the filter will work with images
        // whose pixels are indices into a color table (IndexColorModel).
        // In such a case, the color values in the color table are filtered.
        canFilterIndexColorModel = true;
        this.sourcergb=sourcergb;
    }

    // This method is called for every pixel in the image
    public int filterRGB(int x, int y, int rgb) {
    	if(rgb == this.sourcergb){	
    		return rgb; 
    	}
    	else {
    		return 0x00000000;
    	}
    }
}

