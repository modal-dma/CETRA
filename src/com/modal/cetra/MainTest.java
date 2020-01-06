package com.modal.cetra;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

public class MainTest {

	public static void main(String[] args) {
		
		try {
			BufferedImage image = ImageIO.read(new File("mann0.png"));			
			BufferedImage imageGray = Utils.convertImageToGrayscale(image);
			
//			Kernel kernel = new Kernel(3, 3, new float[] { -1, -1, -1, -1, 9, -1, -1,
//			        -1, -1 });
//		    BufferedImageOp op = new ConvolveOp(kernel);
//		    BufferedImage sharpenImage = op.filter(imageGray, null);
//			
		    BufferedImage binaryImage = new BufferedImage(
		    		imageGray.getWidth(),
		    		imageGray.getHeight(),
		            BufferedImage.TYPE_BYTE_BINARY);
		
		    Graphics2D graphic = binaryImage.createGraphics();
		    graphic.drawImage(imageGray, 0, 0, Color.WHITE, null);
		    graphic.dispose();
		    
		    ImageIO.write(imageGray, "png", new File("image_gray.png"));
		    ImageIO.write(binaryImage, "png", new File("image_binary.png"));
		    
		    GraphBitmap graphBitmap = new GraphBitmap();
		    
		    graphBitmap.setBitmap(imageGray);
		    
		    Node start = new Node(75, 47);
		    Node end = new Node(704, 558);
		    
		    graphBitmap = Dijkstra.calculateShortestPathFromSource(graphBitmap, start, end);
		    
		    System.out.println("---------------------------------------");
		    
		    //BufferedImage pathBitmap = new BufferedImage(imageGray.getWidth(), imageGray.getHeight(), BufferedImage.TYPE_3BYTE_BGR);		    
//		    Graphics2D g2d = (Graphics2D) pathBitmap.getGraphics();
//		    g2d.setBackground(new Color(0, 0, 0, 0));
		  
		    for(Node node : end.shortestPath)
		    {
		    	System.out.println(node);	
		    			    	    
		    	imageGray.setRGB(node.x, node.y, 0);
		    }
		    
//		    Node destination = Dijkstra.nodeMap.get(new Point(100, 141));		    		   
//		    System.out.println(destination.shortestPath);
		    
		    ImageIO.write(imageGray, "png", new File("image_path.png"));
		    ImageIO.write(Dijkstra.resultBitmap, "png", new File("image_result.png"));
		    
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		

	}

}
