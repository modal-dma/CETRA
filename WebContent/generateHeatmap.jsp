<%@page import="java.text.SimpleDateFormat"%>
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
	String from = request.getParameter("from");
	String to = request.getParameter("to");

	System.out.println("mapName " + mapName);
		
	String heatmapName = String.format("heatmap_%s-%s.png", from, to).replace("/", "");
		
	ServletContext context = pageContext.getServletContext();
   
  	String dirPath = context.getRealPath("") + "maps" + File.separator + mapName;
    
  	File heatmapDir = new File(dirPath, "heatmaps");
  	File heatmapFile = new File(heatmapDir, heatmapName);
  	String heatmapName0 = String.format("heatmap_0_%s-%s.png", from, to).replace("/", "");
  	File heatmapFile0 = new File(heatmapDir, heatmapName0);
  	
  	
  	if(heatmapFile.exists())
  	{
  		%>{"heatmap":"<%=heatmapName%>"}<%
  		return;
  	}
  	
  	String sensors = dirPath + File.separator + "sensors.json";

  	System.out.println("sensorsFile " + sensors);

  	JSONArray sensorArray = null;

  	File sensorsFile = new File(sensors);
  	if(sensorsFile.exists())
  	{
  		FileReader fr = new FileReader(sensorsFile);
  		BufferedReader br = new BufferedReader(fr);
  		
  		String json = br.readLine();
  		
  		System.out.println("sensors " + json);
  		
  		br.close();
  		fr.close();
  		
  		sensorArray = new JSONArray(json);
  	}
  	    
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
  	
  	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy");
  	
  	try
  	{
  		BufferedImage heatmapImage = HeatmapGenerator.generate(image, sensorsMap, doorsMap, new File(dirPath, "dataset.txt"), sdf.parse(from), sdf.parse(to), null);  	
  	
	  	heatmapFile.mkdirs();
	  	
	  	System.out.println("writing heatmap0 " + heatmapFile0.getAbsolutePath());
	  	ImageIO.write(heatmapImage, "png", heatmapFile0);
	  	System.out.println("writing heatmap0 ok");
	  	
	  		
  		BufferedImage b = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_ARGB);
	    Graphics g = b.getGraphics();
	    g.drawImage(image, 0, 0, null);
	    g.drawImage(heatmapImage, 0, 0, null);
	    g.dispose();
	    
	    System.out.println("writing heatmap " + heatmapFile.getAbsolutePath());
	  	ImageIO.write(b, "png", heatmapFile);
	  	System.out.println("writing heatmap ok");
	  	
	    System.out.println("heatmapName " + heatmapName);
	    
	    %>{"heatmap":"<%=heatmapName%>"}<%
  	}
  	catch(IOException ex)
  	{
  		ex.printStackTrace();
  	}
%>