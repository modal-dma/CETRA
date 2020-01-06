package com.modal.cetra;

import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;

public class PathsCalculator {

	public PathsCalculator(BufferedImage image)
	{
		BufferedImage imageGray = Utils.convertImageToGrayscale(image);
		
		Kernel kernel = new Kernel(3, 3, new float[] { -1, -1, -1, -1, 9, -1, -1,
		        -1, -1 });
	    BufferedImageOp op = new ConvolveOp(kernel);
	    BufferedImage sharpenImage = op.filter(imageGray, null);
		
	//    BufferedImage binaryImage = new BufferedImage(
	//    		sharpenImage.getWidth(),
	//    		sharpenImage.getHeight(),
	//            BufferedImage.TYPE_BYTE_BINARY);
	//
	//    Graphics2D graphic = binaryImage.createGraphics();
	//    graphic.drawImage(sharpenImage, 0, 0, Color.WHITE, null);
	//    graphic.dispose();
	    
	    //    ImageIO.write(image, "png", new File("image_" + imageCounter + ".png"));
	}
}
