package be.mxs.common.util.system;

import java.awt.AlphaComposite;
import java.awt.Composite;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.HeadlessException;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.Transparency;
import java.awt.image.BufferedImage;
import java.awt.image.FilteredImageSource;
import java.awt.image.ImageFilter;
import java.awt.image.PixelGrabber;
import java.awt.image.RGBImageFilter;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.datacenter.District;

public class Imaging {
	
	public static BufferedImage drawDistricts(String countryFile, int totalcolors, double min, double max, District[] districts){
		String cf = "";
		SAXReader reader = new SAXReader(false);
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + countryFile;
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
           	cf=root.attributeValue("directory")+"/"+root.attributeValue("countrymap");
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
		BufferedImage resultImage= toBufferedImage(Miscelaneous.getImage(cf));
		for (int n=0; n<districts.length;n++){
			if(districts[n]!=null){
				int color=getColor(totalcolors,min,max,districts[n].getScore());
				BufferedImage im1=toBufferedImage(replaceColor(Miscelaneous.getImage(districts[n].getMap()),0xffff0000,color));
		        resultImage = createComposite(resultImage, im1, 1f);
			}
		}
		return resultImage;
	}
	
	public static BufferedImage drawDistrictsById(String countryFile, int totalcolors, double min, double max, double[][] districts){
		String cf = "";
		SAXReader reader = new SAXReader(false);
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + countryFile;
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
           	cf=root.attributeValue("directory")+"/"+root.attributeValue("countrymap");
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
		BufferedImage resultImage= toBufferedImage(Miscelaneous.getImage(cf));
			for (int n=0; n<districts.length;n++){
				if(districts[n]!=null){
					District district = District.getDistrictWithId(countryFile, new Double (districts[n][0]).intValue()+"");
					if(district!=null){
						int color=getColor(totalcolors,min,max,districts[n][1]);
						BufferedImage im1=toBufferedImage(replaceColor(Miscelaneous.getImage(district.getMap()),0xffff0000,color));
				        resultImage = createComposite(resultImage, im1, 1f);
					}
				}
			}
		return resultImage;
	}
	
	public static BufferedImage drawDistrictsByZipCode(String countryFile, int totalcolors, double min, double max, String[][] districts){
		String cf = "";
		SAXReader reader = new SAXReader(false);
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + countryFile;
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
           	cf=root.attributeValue("directory")+"/"+root.attributeValue("countrymap");
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
		BufferedImage resultImage= toBufferedImage(Miscelaneous.getImage(cf));
			for (int n=0; n<districts.length;n++){
				if(districts[n]!=null){
					District district = District.getDistrictWithZipcode(countryFile, districts[n][0]);
					if(district!=null){
						BufferedImage im1=toBufferedImage(replaceColor(Miscelaneous.getImage(district.getMap()),0xffff0000,getColor(totalcolors,min,max,Double.parseDouble(districts[n][1]))));
				        resultImage = createComposite(resultImage, im1, 1f);
					}
				}
			}
		return resultImage;
	}
	
	public static int getColor(int totalcolors, double min, double max, double value){
		double step = (max-min)/totalcolors;
		int w_value=new Double((value-min)/step).intValue();
		int red,green,blue;
		if(w_value<=totalcolors/2){
			red=255;
			green=255 * (totalcolors/2-w_value) / (totalcolors/2);
			blue=255 * (totalcolors/2-w_value) / (totalcolors/2);
		}
		else {
			red=255 * (totalcolors - w_value) / (totalcolors/2);
			green=0;
			blue=0;
		}
		return new Double(0xff000000 + 256*256*red +256*green + blue).intValue();
	}
	
	public static Image replaceColor(Image image, int sourcergb, int destinationrgb){
		ImageFilter filter = new GetColorFilter(sourcergb,destinationrgb);
		FilteredImageSource filteredSrc = new FilteredImageSource(image.getSource(), filter);
		return Toolkit.getDefaultToolkit().createImage(filteredSrc);
	}

	public static Image keepColor(Image image, int sourcergb){
		ImageFilter filter = new KeepColorFilter(sourcergb);
		FilteredImageSource filteredSrc = new FilteredImageSource(image.getSource(), filter);
		return Toolkit.getDefaultToolkit().createImage(filteredSrc);
	}

	public static BufferedImage createComposite(BufferedImage im1, BufferedImage im2, float alpha)  {  
		 BufferedImage buffer = new BufferedImage(Math.max(im1.getWidth(), im2.getWidth()),  
		    Math.max(im1.getHeight(), im2.getHeight()),BufferedImage.TYPE_INT_ARGB);  
		 Graphics2D g2=buffer.createGraphics();  
		 g2.drawImage(im1, null, null);  
		 Composite newComposite =  AlphaComposite.getInstance(AlphaComposite.SRC_OVER, alpha);  
		 g2.setComposite(newComposite);  
		 g2.drawImage(im2, null, null);  
		 g2.dispose();  
		 return buffer;  
	}  
	
	public static BufferedImage toBufferedImage(Image image) {
        if (image instanceof BufferedImage) {return (BufferedImage)image;}
    
        // This code ensures that all the pixels in the image are loaded
        image = new ImageIcon(image).getImage();
    
        // Determine if the image has transparent pixels
        boolean hasAlpha = hasAlpha(image);
    
        // Create a buffered image with a format that's compatible with the screen
        BufferedImage bimage = null;
        GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
        try {
            // Determine the type of transparency of the new buffered image
            int transparency = Transparency.OPAQUE;
            if (hasAlpha == true) {transparency = Transparency.BITMASK;}
    
            // Create the buffered image
            GraphicsDevice gs = ge.getDefaultScreenDevice();
            GraphicsConfiguration gc = gs.getDefaultConfiguration();
            bimage = gc.createCompatibleImage(image.getWidth(null), image.getHeight(null), transparency);
        } 
        catch (HeadlessException e) {} //No screen
    
        if (bimage == null) {
            // Create a buffered image using the default color model
            int type = BufferedImage.TYPE_INT_RGB;
            if (hasAlpha == true) {type = BufferedImage.TYPE_INT_ARGB;}
            bimage = new BufferedImage(image.getWidth(null), image.getHeight(null), type);
        }
    
        // Copy image to buffered image
        Graphics g = bimage.createGraphics();
    
        // Paint the image onto the buffered image
        g.drawImage(image, 0, 0, null);
        g.dispose();
    
        return bimage;
    }

      public static boolean hasAlpha(Image image) {
             // If buffered image, the color model is readily available
             if (image instanceof BufferedImage) {return ((BufferedImage)image).getColorModel().hasAlpha();}
         
             // Use a pixel grabber to retrieve the image's color model;
             // grabbing a single pixel is usually sufficient
             PixelGrabber pg = new PixelGrabber(image, 0, 0, 1, 1, false);
             try {pg.grabPixels();} catch (InterruptedException e) {}
             // Get the image's color model
             return pg.getColorModel().hasAlpha();
         }

}
