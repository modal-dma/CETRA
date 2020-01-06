<%@page import="org.json.JSONArray"%>
<%@ page import = "java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import = "org.apache.commons.fileupload.*" %>
<%@ page import = "org.apache.commons.fileupload.disk.*" %>
<%@ page import = "org.apache.commons.fileupload.servlet.*" %>
<%@ page import = "org.apache.commons.io.output.*" %>

<%
	String mapName = request.getParameter("data[name]");
	String sensors = request.getParameter("data[sensors]");

	System.out.println("mapName " + mapName);
	System.out.println("sensors " + sensors);
	
	JSONArray sensorsArray = new JSONArray(sensors);
	
	System.out.println("sensorsArray " + sensorsArray);	
	
	ServletContext context = pageContext.getServletContext();
   
  	String dirPath = context.getRealPath("") + "maps" + File.separator + mapName;
       
  	File file = new File(dirPath, "sensors.txt");
  	
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
%>