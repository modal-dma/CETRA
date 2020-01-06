package com.modal.cetra;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

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
	 
}
