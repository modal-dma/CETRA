
<%@page import="org.apache.commons.io.FileUtils"%>
<%@page import="org.json.JSONArray"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.io.FilenameFilter"%>
<%@page import="java.io.File"%>
<%@page import="com.modal.cetra.Constants"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%

ServletContext context = pageContext.getServletContext();
String mapName = request.getParameter("name");
String tempDir = System.getProperty("java.io.tmpdir");
String dirPath = context.getRealPath("");

dirPath = dirPath + "maps" + File.separator + mapName;

System.out.println("delete dirPath " + dirPath);

File dir = new File(dirPath);

FileUtils.deleteDirectory(dir);

System.out.println("deleted");
/*
File imageFiles[] = dir.listFiles();

System.out.println("files " + imageFiles);


for (File file : imageFiles)
{
	file.delete();
}

dir.delete();
*/
%>