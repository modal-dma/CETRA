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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

public class HeatmapGenerator {

	private static final int LIMIT = 2000;
	
	private static final SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy HH:mm");

	public static BufferedImage generate(BufferedImage image, HashMap<String, JSONObject> sensorsMap, HashMap<Integer, JSONObject> doorsMap, File datasetFile, Date from, Date to, List<String> filters) throws IOException
	{
		BufferedImage heatmapImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_ARGB);
	  	
	  	heatmapImage = Utils.makeColorTransparent(heatmapImage, Color.black);
	  	  	
	  	FileReader fr = new FileReader(datasetFile);
	  	BufferedReader br = new BufferedReader(fr);
	  	String line = "";
	  	
	  	HashMap<String, JSONObject> nodeMap = new HashMap<>();
	  	
	  	int pathCount = 0;
	  	while((line = br.readLine()) != null)
	  	{
	  		String fields[] = line.split(",");
	  		
	  		String path = fields[0];
	  		String datestr = fields[2];
	  		
	  		boolean addPath = true;
	  		
	  		if(filters != null)
	  		{
	  			for(String sensor : filters)
	  			{
	  				if(!path.contains(sensor))
	  				{
	  					addPath = false;
	  					break;
	  				}	  				
	  			}
	  		}
	  		
	  		if(addPath)
	  		{
		  		if(from != null)
		  		{
		  			Date date;
					try {
						date = sdf.parse(datestr);
						System.out.println("date: " + datestr);
						System.out.println("date: " + date.toString());
						System.out.println("from: " + from.toString());
						
						if(date.before(from))
						{
			  				addPath = false;
			  				System.out.println("before: removed from path");
						}
						else
						{
							if(to != null)
							{
								if(date.after(to))
								{
									addPath = false;
									System.out.println("after: removed from path");
								}
							}							
						}					
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}	  			
		  		}
	  		}
	  		
	  		if(addPath)
	  		{
	  			pathCount++;
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
	  	}
	  	
	  	br.close();
	  	fr.close();
	  	
	  	System.out.println("path count: " + pathCount);
	  	System.out.println("nodeMap size: " + nodeMap.size());
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
		Color[] colors = Gradient.GRADIENT_RAINBOW_100;//GREEN_YELLOW_ORANGE_RED;
		//Color[] colors = Gradient.GRADIENT_BLUE_TO_RED_100;//GREEN_YELLOW_ORANGE_RED;
		
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
		    g2d.fillRect(x-2, y-2, 10, 10);
		    
		    Color color1 = new Color(color.getRed(), color.getGreen(), color.getBlue(), 0x30);
		    g2d.setColor(color1);
		    g2d.setStroke(new BasicStroke(2));
//		    g2d.setRenderingHint(
//		            RenderingHints.KEY_ANTIALIASING,
//		            RenderingHints.VALUE_ANTIALIAS_ON);
		    g2d.fillRect(x, y, 5, 5);
		}
		
		
		return heatmapImage;
	}
	
	public static JSONArray generateVisitorPathsJSON(HashMap<String, JSONObject> sensorsMap, HashMap<Integer, JSONObject> doorsMap, File datasetFile, Date from, Date to, List<String> filters) throws IOException
	{	  	  	
	  	FileReader fr = new FileReader(datasetFile);
	  	BufferedReader br = new BufferedReader(fr);
	  	String line = "";
	  	
	  	JSONArray visitorsPaths = new JSONArray();
	  	
	  	int pathCount = 0;
	  	while(pathCount < LIMIT && (line = br.readLine()) != null)
	  	{
	  		String fields[] = line.split(",");
	  		
	  		String path = fields[0];
	  		boolean addPath = true;
	  		
	  		if(filters != null)
	  		{
	  			for(String sensor : filters)
	  			{
	  				if(!path.contains(sensor))
	  				{
	  					addPath = false;
//	  					System.out.println("filtered0 " + path);
	  					break;
	  				}	  				
	  			}
	  		}
	  		
	  		String datestr = fields[2];
	  		
	  		if(addPath)
	  		{	  		
		  		if(from != null)
		  		{
		  			Date date;
					try 
					{
						date = sdf.parse(datestr);
						System.out.println("date: " + datestr);
						System.out.println("date: " + date.toString());
						System.out.println("from: " + from.toString());
						
						if(date.before(from))
						{
			  				addPath = false;
			  				System.out.println("before: removed from path");
						}
						else
						{
							if(to != null)
							{
								if(date.after(to))
								{
									addPath = false;
									System.out.println("after: removed from path");
								}
							}							
						}					
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}	  			
		  		}
	  		}
	  		
	  		if(addPath)
	  		{
//	  			JSONObject visitorPath = new JSONObject();
	  			//visitorPath.put("path", path);
	  			
	  			JSONArray pointsArray = new JSONArray();
	  			//visitorPath.put("points", pointsArray);
	  			
	  			pathCount++;
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
							  			
				  			//System.out.println("step " + step);
				  			
				  			addNodeToPathJSON(step, datasetFile, pointsArray); 
			  			}
			  			else
			  			{
			  				JSONObject door1 = doorsMap.get(startNode.getInt("floor"));	  				
			  				JSONObject door2 = doorsMap.get(endNode.getInt("floor"));
			  				
			  				String step1 = start + door1.getString("name");
			  				String step2 = door2.getString("name") + end;
				  			
				  			//System.out.println("step " + step1);
				  			//System.out.println("step " + step2);
				  			
				  			addNodeToPathJSON(step1, datasetFile, pointsArray); 
				  			addNodeToPathJSON(step2, datasetFile, pointsArray); 
			  			}
		  			}	
		  			
		  			
		  		}
		  		
		  		System.out.println("added " + path);
		  		
		  		visitorsPaths.put(pointsArray);
	  		}
	  		else
	  		{
//	  			System.out.println("filtered " + path);
	  		}
	  		
	  	}
	  	
	  	br.close();
	  	fr.close();
	  	
	  	System.out.println("path count: " + pathCount);
	  	System.out.println("nodeMap size: " + visitorsPaths.length());
	  			
		return visitorsPaths;
	}
	
	public static List<VisitorPath> generateVisitorPaths(HashMap<String, JSONObject> sensorsMap, HashMap<Integer, JSONObject> doorsMap, File datasetFile, Date from, Date to, List<String> filters) throws IOException
	{	  	  	
	  	FileReader fr = new FileReader(datasetFile);
	  	BufferedReader br = new BufferedReader(fr);
	  	String line = "";
	  	
	  	ArrayList<VisitorPath> visitorPathArray = new ArrayList<>();
	  	
	  	int pathCount = 0;
	  	while((line = br.readLine()) != null)
	  	{
	  		String fields[] = line.split(",");
	  		
	  		String path = fields[0];
	  		boolean addPath = true;
	  		
	  		if(filters != null)
	  		{
	  			for(String sensor : filters)
	  			{
	  				if(!path.contains(sensor))
	  				{
	  					addPath = false;
//	  					System.out.println("filtered0 " + path);
	  					break;
	  				}	  				
	  			}
	  		}
	  		
	  		String datestr = fields[2];
	  		
	  		if(addPath)
	  		{	  		
		  		if(from != null)
		  		{
		  			Date date;
					try 
					{
						date = sdf.parse(datestr);
						System.out.println("date: " + datestr);
						System.out.println("date: " + date.toString());
						System.out.println("from: " + from.toString());
						
						if(date.before(from))
						{
			  				addPath = false;
			  				System.out.println("before: removed from path");
						}
						else
						{
							if(to != null)
							{
								if(date.after(to))
								{
									addPath = false;
									System.out.println("after: removed from path");
								}
							}							
						}					
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}	  			
		  		}
	  		}
	  		
	  		if(addPath)
	  		{
	  			VisitorPath visitorPath = new VisitorPath();
	  			
		  		visitorPath.pathArray = new ArrayList<>();
		  		visitorPath.path = path;
		  		
	  			pathCount++;
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
				  			
				  			addNodeToPath(step, datasetFile, visitorPath.pathArray); 
			  			}
			  			else
			  			{
			  				JSONObject door1 = doorsMap.get(startNode.getInt("floor"));	  				
			  				JSONObject door2 = doorsMap.get(endNode.getInt("floor"));
			  				
			  				String step1 = start + door1.getString("name");
			  				String step2 = door2.getString("name") + end;
				  			
				  			System.out.println("step " + step1);
				  			System.out.println("step " + step2);
				  			
				  			addNodeToPath(step1, datasetFile, visitorPath.pathArray); 
				  			addNodeToPath(step2, datasetFile, visitorPath.pathArray); 
			  			}
		  			}		  		
		  		}
		  		
		  		System.out.println("added " + path);
		  		visitorPathArray.add(visitorPath);
	  		}
	  		else
	  		{
//	  			System.out.println("filtered " + path);
	  		}
	  		
	  	}
	  	
	  	br.close();
	  	fr.close();
	  	
	  	System.out.println("path count: " + pathCount);
	  	System.out.println("nodeMap size: " + visitorPathArray.size());
	  			
		return visitorPathArray;
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
			//System.out.println("file exists " + step);
			
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
	
	private static void addNodeToPath(String step, File datasetFile, ArrayList<Point> pathArray) throws IOException
	{
		boolean reverseNeeded = false;
		File jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
		if(!jsonFile.exists())
		{
			step = step.charAt(1) + "" + step.charAt(0);
			jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
			reverseNeeded = true;
		}
			
		if(jsonFile.exists())
		{
//			System.out.println("file exists " + step);
//			System.out.println("reversed " + reverseNeeded);
			
			FileReader fr1 = new FileReader(jsonFile);
			JSONTokener tokenizer = new JSONTokener(fr1);
			
			JSONArray stepJsonArray = new JSONArray(tokenizer);
			
			if(reverseNeeded)
			{
				for(int j = stepJsonArray.length() - 1; j >= 0; j--)
				{
					JSONObject node = stepJsonArray.getJSONObject(j);
					
					Point p = new Point(node.getDouble("x"), node.getDouble("y"));
					
					pathArray.add(p);
				}
			}
			else
			{
				for(int j = 0; j < stepJsonArray.length(); j++)
				{
					JSONObject node = stepJsonArray.getJSONObject(j);
					
					Point p = new Point(node.getDouble("x"), node.getDouble("y"));
					
					pathArray.add(p);
				}
			}
			
			fr1.close();
		}
	}
	
	private static void addNodeToPathJSON(String step, File datasetFile, JSONArray pathArray) throws IOException
	{
		boolean reverseNeeded = false;
		File jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
		if(!jsonFile.exists())
		{
			step = step.charAt(1) + "" + step.charAt(0);
			jsonFile = new File(datasetFile.getParentFile(), "step-" + step + ".json");
			reverseNeeded = true;
		}
			
		if(jsonFile.exists())
		{
//			System.out.println("file exists " + step);
//			System.out.println("reversed " + reverseNeeded);
			
			FileReader fr1 = new FileReader(jsonFile);
			JSONTokener tokenizer = new JSONTokener(fr1);
			
			JSONArray stepJsonArray = new JSONArray(tokenizer);
			
			if(reverseNeeded)
			{
				for(int j = stepJsonArray.length() - 1; j >= 0; j--)
				{
					JSONObject node = stepJsonArray.getJSONObject(j);
										
					pathArray.put(node);
				}
			}
			else
			{
				for(int j = 0; j < stepJsonArray.length(); j++)
				{
					JSONObject node = stepJsonArray.getJSONObject(j);
					
					pathArray.put(node);										
				}
			}
			
			fr1.close();
		}
	}
	
	public static class Point
	{
		public double x;
		public double y;
		
		public Point(double x, double y)
		{
			this.x = x;
			this.y = y;
		}
	}
	
	public static class VisitorPath
	{
		public ArrayList<Point> pathArray;
		public String path;
	}
}
