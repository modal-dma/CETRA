<%@page import="java.awt.RenderingHints"%>
<%@page import="java.awt.BasicStroke"%>
<%@page import="java.awt.Graphics2D"%>
<%@page import="com.modal.cetra.Gradient"%>
<%@page import="com.modal.cetra.Constants"%>
<%@page import="java.awt.Color"%>
<%@page import="com.modal.cetra.Utils"%>
<%@page import="org.json.JSONTokener"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="com.modal.cetra.PathsCalculator"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONArray"%>
<%@ page import = "java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import = "org.apache.commons.fileupload.*" %>
<%@ page import = "org.apache.commons.fileupload.disk.*" %>
<%@ page import = "org.apache.commons.fileupload.servlet.*" %>
<%@ page import = "org.apache.commons.io.output.*" %>

<%
	String mapName = request.getParameter("name");
	String sensors = request.getParameter("sensors");

	System.out.println("mapName " + mapName);
	System.out.println("sensors " + sensors);
	
	JSONArray sensorsArray = new JSONArray(sensors);
	System.out.println("sensorsArray " + sensorsArray);	
	
	ServletContext context = pageContext.getServletContext();
   
  	String dirPath = context.getRealPath("") + "maps" + File.separator + mapName;
       
  	File file = new File(dirPath, "sensors.json");
  	  	
    try 
    {        
   		FileWriter fw = new FileWriter(file);
   	  	
   	  	fw.write(sensors);
   	  	fw.close();      
    } 
    catch(Exception ex) 
    {
   		ex.printStackTrace();
   		response.sendError(500);
    }
    
  	JSONArray sensorArray = new JSONArray(sensors);  	
  	File dir = new File(dirPath);
  	
  	String imageFiles[] = dir.list(new FilenameFilter() {
  		public boolean accept(File f, String file)
  		{
  			System.out.println("file " + file);
  			return file.endsWith("jpg") || file.endsWith("png");
  		}
  	});

  	System.out.println("files " + imageFiles);
  	
  	BufferedImage image = ImageIO.read(new File(dir, imageFiles[0]));
  	
  	JSONObject start;
  	JSONObject end;
  	
  	PathsCalculator calculator = new PathsCalculator(image);
  	
  	for(int i = 0; i < sensorArray.length(); i++)
  	{
  		start = sensorArray.getJSONObject(i);
  		for(int j = i + 1; j < sensorArray.length(); j++)
  		{
  			end = sensorArray.getJSONObject(j);
  	
  			String name = start.getString("name") + end.getString("name");
  			
  			System.out.println("---------------------------------");
  			System.out.println(name);
  			JSONArray path = calculator.generate(start.getDouble("x"), start.getDouble("y"), end.getDouble("x"), end.getDouble("y"));
  			  			  			
  			File fileName = new File(dir, name + ".json");
  			FileWriter fw = new FileWriter(fileName);  	
  			fw.write(path.toString(4));
  			fw.close();
  		}
  		
  		
  	}
  	
  	BufferedImage heatmapImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_ARGB);
  	
  	heatmapImage = Utils.makeColorTransparent(heatmapImage, Color.black);
  	  	
  	FileReader fr = new FileReader(new File(dirPath, "dataset.txt"));
  	BufferedReader br = new BufferedReader(fr);
  	String line = "";
  	
  	HashMap<String, JSONObject> nodeMap = new HashMap<>();
  	
  	while((line = br.readLine()) != null)
  	{
  		String fields[] = line.split(",");
  		
  		String path = fields[0];
  		
  		for(int i = 0; i < path.length() - 1; i++)
  		{
  			boolean reverse = false;
  			
  			String step = path.substring(i, i + 2);
			  			
  			System.out.println("step " + step);
  			
  			File jsonFile = new File(dirPath, step + ".json");
  			if(!jsonFile.exists())
  			{
  				step = step.charAt(0) + "" + step.charAt(1);
  				jsonFile = new File(dirPath, step + ".json");
  				reverse = true;
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
  					
  					String nodeName = node.getDouble("x") + "," + node.getDouble("y");
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
  	
  	br.close();
  	fr.close();
  	
	int max = 0;
	int min = Integer.MAX_VALUE;
				
	for(JSONObject node : nodeMap.values())
	{
		int v = node.getInt("value");
		if(v > max)
			max = v;
		else if(v < min)
			min = v;  				
	}
				
	int range = max - min;
				
	System.out.println("max " + max);
	System.out.println("min " + min);
	System.out.println("range " + range);
		  				
	Color[] colors = Gradient.GRADIENT_BLUE_TO_RED;

	Graphics2D g2d = (Graphics2D)heatmapImage.getGraphics();
    
	for(JSONObject node : nodeMap.values())
	{  					
		int x = (int)(node.getDouble("x") * heatmapImage.getWidth());
		int y = (int)(node.getDouble("y") * heatmapImage.getHeight());
	  	
		int value = node.getInt("value");
				
		double norm = (double)(value - min) / (double)range; // 0 < norm < 1
        int colorIndex = (int) Math.floor(norm * (colors.length - 1));
  					
		Color color = colors[colorIndex];
		
		int rgb = color.getRGB() | 0xFF000000;
	
		
	    g2d.setColor(color);
	    g2d.setStroke(new BasicStroke(1));
	    g2d.setRenderingHint(
	            RenderingHints.KEY_ANTIALIASING,
	            RenderingHints.VALUE_ANTIALIAS_ON);
	    g2d.fillOval(x, y, 6, 6);
	    //g2d.drawLine(x, y, x+1, y+1);

	    
		//System.out.println("rgb " + rgb);
		
		/* heatmapImage.setRGB(x, y, rgb);
				
		heatmapImage.setRGB(x + 1, y, rgb);
		heatmapImage.setRGB(x - 1, y, rgb);
		heatmapImage.setRGB(x, y + 1, rgb);
		heatmapImage.setRGB(x, y - 1, rgb);
		heatmapImage.setRGB(x + 1, y + 1, rgb);
		heatmapImage.setRGB(x - 1, y - 1, rgb);
		heatmapImage.setRGB(x - 1, y + 1, rgb);
		heatmapImage.setRGB(x + 1, y - 1, rgb);  	
					
		heatmapImage.setRGB(x + 2, y, rgb);
		heatmapImage.setRGB(x - 2, y, rgb);
		heatmapImage.setRGB(x, y + 2, rgb);
		heatmapImage.setRGB(x, y - 2, rgb); */
	}
  					/* int rgb = heatmapImage.getRGB(x, y);
  					
  					int hsl = Utils.rgbToHsl(rgb);
  					
  					int h = (hsl & 0xFF0000) >> 16;
  					int s = (hsl & 0x00FF00) >> 8;
  			
  					h+=Constants.COLOR_STEP;
  					s+=Constants.COLOR_STEP;
  					
  					int l = 50;
  					
  					rgb = Utils.hslToRgb(h, s, l);
  					
  					rgb |= 0xFF000000;
  				
  					
  					/* int x0 = (int)(prevNode.getDouble("x") * heatmapImage.getWidth());
  					int y0 = (int)(prevNode.getDouble("y") * heatmapImage.getHeight());
  				
  					float m = x == x0 ? m = Float.MAX_VALUE : (y - y0) / (x - x0);

  					int X = x0 + 1;
  					  					
  					for(int k = 0; k < Constants.STEP & j + k < stepJsonArray.length(); k++)
  					{
  						float Y;
  						if(m == Float.MAX_VALUE)
  						{
  							JSONObject node1 = stepJsonArray.getJSONObject(j + k);
  							X = (int)(node1.getDouble("x") * heatmapImage.getWidth());
  		  					Y = (int)(node1.getDouble("y") * heatmapImage.getHeight());  		  					
  						}
  						else
  						{
  							Y = m * (X - x0) + y0;
  						}
  						
  						heatmapImage.setRGB(X, (int)Y, rgb);
  	  					
  	  					heatmapImage.setRGB(X + 1, (int)Y, rgb);
  	  					heatmapImage.setRGB(X - 1, (int)Y, rgb);
  	  					heatmapImage.setRGB(X, (int)Y + 1, rgb);
  	  					heatmapImage.setRGB(X, (int)Y - 1, rgb);
  	  					heatmapImage.setRGB(X + 1, (int)Y + 1, rgb);
  	  					heatmapImage.setRGB(X - 1, (int)Y - 1, rgb);
  	  					heatmapImage.setRGB(X - 1, (int)Y + 1, rgb);
  	  					heatmapImage.setRGB(X + 1, (int)Y - 1, rgb);
  	  					
  	  					X++;
  					}
  					
  					prevNode = node;
 */  					
  					/*
  					heatmapImage.setRGB(x, y, rgb);
  					
  					heatmapImage.setRGB(x + 1, y, rgb);
  					heatmapImage.setRGB(x - 1, y, rgb);
  					heatmapImage.setRGB(x, y + 1, rgb);
  					heatmapImage.setRGB(x, y - 1, rgb);
  					heatmapImage.setRGB(x + 1, y + 1, rgb);
  					heatmapImage.setRGB(x - 1, y - 1, rgb);
  					heatmapImage.setRGB(x - 1, y + 1, rgb);
  					heatmapImage.setRGB(x + 1, y - 1, rgb);  	
  					
  					heatmapImage.setRGB(x + 2, y, rgb);
  					heatmapImage.setRGB(x - 2, y, rgb);
  					heatmapImage.setRGB(x, y + 2, rgb);
  					heatmapImage.setRGB(x, y - 2, rgb); */
  					
  				//}  				  				
  	//		}  			  			  			  			
  	//	}  		  		
  	//}
  	
  	
  	
  	File heatmapDir = new File(dirPath, "heatmaps");
  	File heatmapFile = new File(heatmapDir, "heatmap_base.png");
  	File grayFile = new File(heatmapDir, "gray_base.png");
  	heatmapFile.mkdirs();
  	
  	System.out.println("writing heatmap");
  	ImageIO.write(heatmapImage, "png", heatmapFile);
  	System.out.println("writing heatmap ok");
  	
  	ImageIO.write(calculator.imageGray, "png", grayFile);

%>