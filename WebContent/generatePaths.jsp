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
  					
  					int x = (int)(node.getDouble("x") * heatmapImage.getWidth());
  					int y = (int)(node.getDouble("y") * heatmapImage.getHeight());
  					
  					int rgb = heatmapImage.getRGB(x, y);
  					
  					int hsl = Utils.rgbToHsl(rgb);
  					
  					int h = (hsl & 0xFF0000) >> 16;
  					int s = (hsl & 0x00FF00) >> 8;
  			
  					h++;
  					s++;
  					int l = 50;
  					
  					rgb = Utils.hslToRgb(h, s, l);
  					
  					rgb |= 0xFF000000;
  					
  					heatmapImage.setRGB(x, y, rgb);  					  					
  				}  				  				
  			}  			  			  			  			
  		}  		  		
  	}
  	
  	br.close();
  	fr.close();
  	
  	File heatmapDir = new File(dirPath, "heatmaps");
  	File heatmapFile = new File(heatmapDir, "heatmap_base.png");
  	File grayFile = new File(heatmapDir, "gray_base.png");
  	heatmapFile.mkdirs();
  	
  	System.out.println("writing heatmap");
  	ImageIO.write(heatmapImage, "png", heatmapFile);
  	System.out.println("writing heatmap ok");
  	
  	ImageIO.write(calculator.imageGray, "png", grayFile);

%>