package com.modal.cetra;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.awt.image.FilteredImageSource;
import java.awt.image.ImageFilter;
import java.awt.image.ImageProducer;
import java.awt.image.RGBImageFilter;

public class Utils {

	 public static BufferedImage convertImageToGrayscale(BufferedImage image) {
	        BufferedImage tmp = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_BYTE_GRAY);
	        Graphics2D g2 = tmp.createGraphics();
	        g2.drawImage(image, 0, 0, null);
	        g2.dispose();
	        return tmp;
	    }
	 
	 public static BufferedImage copyImage(BufferedImage source){					
		    BufferedImage b = new BufferedImage(source.getWidth(), source.getHeight(), source.getType()==0?5:source.getType());
		    Graphics g = b.getGraphics();
		    g.drawImage(source, 0, 0, null);
		    g.dispose();
		    return b;
		}
	 
	 
	 /**
	  * Converts an HSL color value to RGB. Conversion formula
	  * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	  * Assumes h, s, and l are contained in the set [0, 1] and
	  * returns r, g, and b in the set [0, 255].
	  *
	  * @param   {number}  h       The hue
	  * @param   {number}  s       The saturation
	  * @param   {number}  l       The lightness
	  * @return  {Array}           The RGB representation
	  */
	 public static int hslToRgb(int h, int s, int l)
	 {
	     int r, g, b;

	     if(s == 0){
	         r = g = b = l; // achromatic
	     }else{
	         
	         int  q = l < 0.5 ? l * (1 + s) : l + s - l * s;
	         int p = 2 * l - q;
	         r = hue2rgb(p, q, (float)h + 1/3);
	         g = hue2rgb(p, q, (float)h);
	         b = hue2rgb(p, q, (float)h - 1/3);
	     }

	     return Math.round(r * 255) << 16 + Math.round(g * 255) << 8 + Math.round(b * 255);
	 }
	 
	 private static int hue2rgb(int p, int q, float t)
	 {
         if(t < 0) t += 1;
         if(t > 1) t -= 1;
         if(t < 1/6) return (int)(p + (q - p) * 6 * t);
         if(t < 1/2) return (int)q;
         if(t < 2/3) return (int)(p + (q - p) * (2/3 - t) * 6);
         return (int)p;
     }
	 
	 /**
	  * Converts an RGB color value to HSL. Conversion formula
	  * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	  * Assumes r, g, and b are contained in the set [0, 255] and
	  * returns h, s, and l in the set [0, 1].
	  *
	  * @param   {number}  r       The red color value
	  * @param   {number}  g       The green color value
	  * @param   {number}  b       The blue color value
	  * @return  {Array}           The HSL representation
	  */
	 public static int rgbToHsl(int rgb)
	 {
	     int r = (rgb & 0xFF0000) >> 16;
         int g = (rgb & 0x00FF00) >> 8;
         int b = (rgb & 0x0000FF);

         int max = Math.max(Math.max(r, g), b);
         int min = Math.min(Math.min(r, g), b);
         
         double h = 0, s = 0, l = (max + min) / 2;

	     if(max == min){
	         h = s = 0; // achromatic
	     }else{
	         int d = max - min;
	         s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
	         
	         if(max == r)
	        	 h = (g - b) / d + (g < b ? 6 : 0);
	         else if (max == g)
	        	 h = (b - r) / d + 2;
	         else if(max == b)
	        	 h = (r - g) / d + 4;
	         	         
	         h /= 6;
	     }

	     return ((int)h << 16) + ((int)s << 8) + (int)l;
	 }
	 
	 /**
	    * Make provided image transparent wherever color matches the provided color.
	    *
	    * @param im BufferedImage whose color will be made transparent.
	    * @param color Color in provided image which will be made transparent.
	    * @return Image with transparency applied.
	    */
	   public static BufferedImage makeColorTransparent(final BufferedImage im, final Color color)
	   {
	      final ImageFilter filter = new RGBImageFilter()		
	      {
	         // the color we are looking for (white)... Alpha bits are set to opaque
	         public int markerRGB = color.getRGB() | 0xFFFFFFFF;

	         public final int filterRGB(final int x, final int y, final int rgb)
	         {
	            if ((rgb | 0xFF000000) == markerRGB)
	            {
	               // Mark the alpha bits as zero - transparent
	               return 0x00FFFFFF & rgb;
	            }
	            else
	            {
	               // nothing to do
	               return rgb;
	            }
	         }
	      };

	      final ImageProducer ip = new FilteredImageSource(im.getSource(), filter);
	      return toBufferedImage(Toolkit.getDefaultToolkit().createImage(ip));
	   }
	   
	   /**
	    * Converts a given Image into a BufferedImage
	    *
	    * @param img The Image to be converted
	    * @return The converted BufferedImage
	    */
	   public static BufferedImage toBufferedImage(Image img)
	   {
	       if (img instanceof BufferedImage)
	       {
	           return (BufferedImage) img;
	       }

	       // Create a buffered image with transparency
	       BufferedImage bimage = new BufferedImage(img.getWidth(null), img.getHeight(null), BufferedImage.TYPE_INT_ARGB);

	       // Draw the image on to the buffered image
	       Graphics2D bGr = bimage.createGraphics();
	       bGr.drawImage(img, 0, 0, null);
	       bGr.dispose();

	       // Return the buffered image
	       return bimage;
	   }
}
