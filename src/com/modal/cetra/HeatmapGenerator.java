package com.modal.cetra;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

public class HeatmapGenerator {

	public static BufferedImage generate(BufferedImage image, HashMap<String, JSONObject> sensorsMap, HashMap<Integer, JSONObject> doorsMap, File datasetFile) throws IOException
	{
		BufferedImage heatmapImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_ARGB);
	  	
	  	heatmapImage = Utils.makeColorTransparent(heatmapImage, Color.black);
	  	  	
	  	FileReader fr = new FileReader(datasetFile);
	  	BufferedReader br = new BufferedReader(fr);
	  	String line = "";
	  	
	  	HashMap<String, JSONObject> nodeMap = new HashMap<>();
	  	
	  	while((line = br.readLine()) != null)
	  	{
	  		String fields[] = line.split(",");
	  		
	  		String path = fields[0];
	  		
	  		for(int i = 0; i < path.length() - 1; i++)
	  		{	  				  			
	  			String start = path.substring(i, i + 1);
	  			String end = path.substring(i + 1, i + 2);
	  			
	  			JSONObject startNode = sensorsMap.get(start);
	  			JSONObject endNode = sensorsMap.get(end);
	  			
	  			if(startNode != null && endNode != null)
	  			{
		  			if(startNode.getInt("floor") == endNode.getInt("floor"))
		  			{	  			
			  			String step = path.substring(i, i + 2);
						  			
			  			System.out.println("step " + step);
			  			
			  			addNode(step, datasetFile, nodeMap, heatmapImage); 
		  			}
		  			else
		  			{
		  				JSONObject door1 = doorsMap.get(startNode.getInt("floor"));	  				
		  				JSONObject door2 = doorsMap.get(endNode.getInt("floor"));
		  				
		  				String step1 = start + door1.getString("name");
		  				String step2 = door2.getString("name") + end;
			  			
			  			System.out.println("step " + step1);
			  			System.out.println("step " + step2);
			  			
			  			addNode(step1, datasetFile, nodeMap, heatmapImage);
			  			addNode(step2, datasetFile, nodeMap, heatmapImage);
		  			}
	  			}
	  		}
	  	}
	  	
	  	br.close();
	  	fr.close();
	  	
		int max = 0;
		int min = Integer.MAX_VALUE;
					
		for(JSONObject node : nodeMap.values())
		{
			int v = (int)averageValue(node, nodeMap, heatmapImage);//node.getInt("value");
			if(v > max)
				max = v;
			else if(v < min)
				min = v;  				
		}
					
		int range = max - min;
					
		System.out.println("max " + max);
		System.out.println("min " + min);
		System.out.println("range " + range);
			  				
//		Color[] colors = Gradient.createGradient(new Color(0x100000), new Color(0xFF0000), 256); //Gradient.GRADIENT_GREEN_YELLOW_ORANGE_RED;
		Color[] colors = Gradient.GRADIENT_RAINBOW;//GREEN_YELLOW_ORANGE_RED;
		
		Graphics2D g2d = (Graphics2D)heatmapImage.getGraphics();
	    
		List<JSONObject> listValues = new ArrayList<>(nodeMap.values());
		
		final BufferedImage b = heatmapImage;
		Collections.sort(listValues, new Comparator<JSONObject>() {

			@Override
			public int compare(JSONObject o1, JSONObject o2) {
				
				int value1 = (int)averageValue(o1, nodeMap, b);
				int value2 = (int)averageValue(o2, nodeMap, b);
				return value1 - value2;
			}
		});
		
		for(JSONObject node : listValues)
		{  					
			int x = (int)Math.floor(node.getDouble("x") * heatmapImage.getWidth());
			int y = (int)Math.floor(node.getDouble("y") * heatmapImage.getHeight());
		  	
			//int value = node.getInt("value");
				
			int value = (int)averageValue(node, nodeMap, heatmapImage);
			
			double norm = (double)(value - min) / (double)range; // 0 < norm < 1
	        int colorIndex = (int) Math.floor(norm * (colors.length - 1));
	  					
			//System.out.println("norm " + norm + ", color " + colorIndex);
			
			Color color = colors[colorIndex];
			
			//int rgb = color.getRGB() | 0xFF000000;
		
			Color colorSemitransparent = new Color(color.getRed(), color.getGreen(), color.getBlue(), 0x20);
			
			g2d.setColor(colorSemitransparent);
		    g2d.setStroke(new BasicStroke(1));
//		    g2d.setRenderingHint(
//		            RenderingHints.KEY_ANTIALIASING,
//		            RenderingHints.VALUE_ANTIALIAS_ON);
		    g2d.fillRect(x-2, y-2, 8, 8);
		    
		    Color color1 = new Color(color.getRed(), color.getGreen(), color.getBlue(), 0x40);
		    g2d.setColor(color1);
		    g2d.setStroke(new BasicStroke(2));
//		    g2d.setRenderingHint(
//		            RenderingHints.KEY_ANTIALIASING,
//		            RenderingHints.VALUE_ANTIALIAS_ON);
		    g2d.fillRect(x, y, 3, 3);
		}
		
		
		return heatmapImage;
	}
	
	private static double averageValue(JSONObject node, HashMap<String, JSONObject> nodeMap, BufferedImage image)
	{
//		System.out.println("averageValue " + nodeMap);
		
		int x = (int)Math.floor(node.getDouble("x") * image.getWidth());
		int y = (int)Math.floor(node.getDouble("y") * image.getHeight());
		
		int radius = 10;
		
		int count = 0;
		int sum = 0;
		for(int i = 0; i <= radius * 2; i++)
		{
			int x1 = x - radius + i;
			
			for(int j = 0; j <= radius * 2; j++)
			{
				int y1 = y - radius + j;
				
				String nodeName = x1 + "," + y1;
				
				//System.out.println("nodeName " + nodeName);
				
				JSONObject currentNode = nodeMap.get(nodeName);
				
				if(currentNode != null)
				{
					int value = currentNode.getInt("value");
					
					sum += value;
					count++;
				}
			}
		}
		
		//double average = sum / count;
		
		return sum;
	}
	
	private static void addNode(String step, File datasetFile, HashMap<String, JSONObject> nodeMap, BufferedImage image) throws IOException
	{
		File jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
		if(!jsonFile.exists())
		{
			step = step.charAt(1) + "" + step.charAt(0);
			jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
		}
			
		if(jsonFile.exists())
		{
			System.out.println("file exists " + step);
			
			FileReader fr1 = new FileReader(jsonFile);
			JSONTokener tokenizer = new JSONTokener(fr1);
			
			JSONArray stepJsonArray = new JSONArray(tokenizer);
			
			for(int j = 0; j < stepJsonArray.length(); j++)
			{
				JSONObject node = stepJsonArray.getJSONObject(j);
				
				String nodeName = (int)Math.floor(node.getDouble("x") * image.getWidth()) + "," + (int)Math.floor(node.getDouble("y") * image.getHeight());
				
				if(nodeMap.containsKey(nodeName))
				{
					JSONObject node1 = nodeMap.get(nodeName);
					int value = node1.getInt("value");
					value++;
					node1.put("value", value);
				}
				else
				{
					node.put("value", 1);
					nodeMap.put(nodeName, node);
				}
			}
			
			fr1.close();
		}
	}
}
