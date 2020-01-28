<%@page import="java.awt.Graphics"%>
<%@page import="com.modal.cetra.HeatmapGenerator"%>
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
  	
  	File stepFiles[] = dir.listFiles(new FilenameFilter() {
  		public boolean accept(File f, String file)
  		{
  			System.out.println("file " + file);
  			return file.endsWith("json") && file.startsWith("step");
  		}
  	});

  	for(File f : stepFiles)
  		f.delete();
  	
  	System.out.println("files " + imageFiles);
  	
  	BufferedImage image = ImageIO.read(new File(dir, imageFiles[0]));
  	
  	JSONObject start;
  	JSONObject end;
  	
  	PathsCalculator calculator = new PathsCalculator(image);
  	
  	HashMap<Integer, JSONObject> doorsMap = new HashMap();
  	HashMap<String, JSONObject> sensorsMap = new HashMap();
  	
  	for(int i = 0; i < sensorArray.length(); i++)
  	{
  		JSONObject item = sensorArray.getJSONObject(i);
  		if(item.getString("type").equals("door"))
  		{
  			doorsMap.put(item.getInt("floor"), item);  			
  		}
  		else
  		{
  			sensorsMap.put(item.getString("name"), item);
  		}
  	}
  	
  	System.out.println("sensor map: " + sensorsMap);
  	
  	for(int i = 0; i < sensorArray.length(); i++)
  	{
  		start = sensorArray.getJSONObject(i);
  		for(int j = i + 1; j < sensorArray.length(); j++)
  		{
  			if(start.getString("type").equals("sensor"))
  			{
	  			end = sensorArray.getJSONObject(j);    		
	  			
	  			if(end.getString("type").equals("sensor"))
	  			{
		  			if(start.getInt("floor") == end.getInt("floor"))
		  			{  				  			
		  				String name = start.getString("name") + end.getString("name");
		  				
			  			System.out.println("-----------++++++++-----------");
			  			System.out.println(name);
			  			File fileName = new File(dir, "step-" + name + ".json");
			  			if(!fileName.exists())
			  			{
				  			JSONArray path = calculator.generate(start.getDouble("x"), start.getDouble("y"), end.getDouble("x"), end.getDouble("y"));
				  			  			  						  			
				  			FileWriter fw = new FileWriter(fileName);  	
				  			fw.write(path.toString(4));
				  			fw.close();
			  			}
		  			}
		  			else
		  			{
		  				int floor1 = start.getInt("floor");
		  				int floor2 = end.getInt("floor");
		  				
		  				JSONObject door1 = doorsMap.get(floor1);
		  				JSONObject door2 = doorsMap.get(floor2);
		  				
		  				if(door1 != null && door2 != null)
		  				{		  					
			  				String name = start.getString("name") + door1.getString("name");
			  				
			  				System.out.println("-----------...........-----------");
				  			System.out.println(name);
				  			File fileName = new File(dir, "step-" + name + ".json");
				  			if(!fileName.exists())
				  			{
					  			JSONArray path = calculator.generate(start.getDouble("x"), start.getDouble("y"), door1.getDouble("x"), door1.getDouble("y"));
					  			  			  							  			
					  			FileWriter fw = new FileWriter(fileName);  	
					  			fw.write(path.toString(4));
					  			fw.close();
				  			}
				  			
				  			
							name = door2.getString("name") + end.getString("name");
			  				
			  				System.out.println("-----------____________-----------");
				  			System.out.println(name);
				  			fileName = new File(dir, "step-" + name + ".json");
				  			if(!fileName.exists())
				  			{
				  				JSONArray path = calculator.generate(door2.getDouble("x"), door2.getDouble("y"), end.getDouble("x"), end.getDouble("y"));
				  			  			  						  			
				  				FileWriter fw = new FileWriter(fileName);  	
					  			fw.write(path.toString(4));
					  			fw.close();
				  			}
		  				}
		  			}
	  			}
  			}
  		}
  		
  		
  	}
  	
  	try
  	{
  		BufferedImage heatmapImage = HeatmapGenerator.generate(image, sensorsMap, doorsMap, new File(dirPath, "dataset.txt"));  	
  	
  	
	  	File heatmapDir = new File(dirPath, "heatmaps");
	  	File heatmapFile = new File(heatmapDir, "heatmap_base.png");
	  	File grayFile = new File(heatmapDir, "gray_base.png");
	  	heatmapFile.mkdirs();
	  	
	  	System.out.println("writing heatmap");
	  	ImageIO.write(heatmapImage, "png", heatmapFile);
	  	System.out.println("writing heatmap ok");
	  	
  		ImageIO.write(calculator.imageGray, "png", grayFile);
  		
  		BufferedImage b = new BufferedImage(calculator.imageGray.getWidth(), calculator.imageGray.getHeight(), BufferedImage.TYPE_INT_ARGB);
	    Graphics g = b.getGraphics();
	    g.drawImage(calculator.imageGray, 0, 0, null);
	    g.drawImage(heatmapImage, 0, 0, null);
	    g.dispose();
	    
	    heatmapFile = new File(heatmapDir, "heatmap.png");
	    ImageIO.write(b, "png", heatmapFile);
  		
  	}
  	catch(IOException ex)
  	{
  		ex.printStackTrace();
  	}

%>