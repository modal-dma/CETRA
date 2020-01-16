package com.modal.cetra;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;
import java.io.File;

import javax.imageio.ImageIO;

import org.json.JSONArray;
import org.json.JSONObject;

public class PathsCalculator {

	BufferedImage image;
	public BufferedImage imageGray;
	
	
	public PathsCalculator(BufferedImage image)
	{		
		this.image = image;
		imageGray = Utils.convertImageToGrayscale(image);
	}
	
	public JSONArray generate(double x0, double y0, double x1, double y1)
	{
		GraphBitmap graphBitmap = new GraphBitmap();	    
	    graphBitmap.setBitmap(Utils.copyImage(imageGray));
	    
		Node start = new Node((int)(x0 * imageGray.getWidth()), (int)(y0 * imageGray.getHeight()));
		Node end = new Node((int)(x1 * imageGray.getWidth()), (int)(y1 * imageGray.getHeight()));
	    
	    graphBitmap = Dijkstra.calculateShortestPathFromSource(graphBitmap, start, end);
	    
	    JSONArray path = new JSONArray();
	    
	    for(Node node : end.shortestPath)
	    {
	    	System.out.println(node);	
	    			    	    
	    	//imageGray.setRGB(node.x, node.y, 0);
	    	
	    	JSONObject wp = new JSONObject();
	    	
	    	wp.put("x", (double)node.x / (double)imageGray.getWidth());
	    	wp.put("y", (double)node.y / (double)imageGray.getHeight());
	    	
	    	path.put(wp);		    	
	    }
	    
	    return path;	    
	}
}
