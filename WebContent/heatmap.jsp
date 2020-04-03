
<%@page import="org.json.JSONObject"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.HashMap"%>
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
String from = request.getParameter("from");
String to = request.getParameter("to");
String filter1 = request.getParameter("filter1");
String filter2 = request.getParameter("filter2");

String tempDir = System.getProperty("java.io.tmpdir");
String dirPath = context.getRealPath("");

dirPath = dirPath + "maps" + File.separator + mapName;

System.out.println("dirPath " + dirPath);

File dir = new File(dirPath);

File heatmapFile = new File(dir, "heatmaps" + File.separator + "heatmap.png");

System.out.println("heatmapFile " + heatmapFile);

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

%>

<!DOCTYPE html>
<html lang="en">

<head>

  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>CETRA</title>

  <!-- Custom fonts for this template-->
  <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">

  <!-- Page level plugin CSS-->
  <link href="vendor/datatables/dataTables.bootstrap4.css" rel="stylesheet">

  <!-- Custom styles for this template-->
  <link href="css/sb-admin.css" rel="stylesheet">
  
     <link href="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.contextMenu.css" rel="stylesheet" type="text/css" />
	<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/ui-darkness/jquery-ui.css" rel="stylesheet">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.contextMenu.js" type="text/javascript"></script>

	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
    <script src="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.ui.position.min.js" type="text/javascript"></script>
  
  <script src="./js/jajaxloader.js"></script>
  
  <link rel="stylesheet" href="./skin/jajaxloader.css">
<link rel="stylesheet" href="./skin/lukehaas/vertical_bars.css">
<link rel="stylesheet" href="./skin/lukehaas/circle_on_path.css">
<link rel="stylesheet" href="./skin/lukehaas/tear_ball.css">
<link rel="stylesheet" href="./skin/vulchivijay/rosace.css">
<link rel="stylesheet" href="./skin/cssload/thecube.css">
<link rel="stylesheet" href="./skin/cssload/colordots.css">
<link rel="stylesheet" href="./skin/cssload/flipping_square.css">
<link rel="stylesheet" href="./skin/cssload/spinning_square.css">
<link rel="stylesheet" href="./skin/cssload/zenith.css">
<link rel="stylesheet" href="./skin/cssload/ventilator.css">
 
<link href="css/style.css" rel="stylesheet">
<script>

var imagesArray = [];

</script>
</head>

<body id="page-top">

  <div id="wrapper">
    
    <div id="content-wrapper">

      <div class="container-fluid">

             
        <%
        	
        	String url = context.getContextPath() + "/maps/" + mapName + "/heatmaps/" + heatmapFile.getName();
        	
        	System.out.println("url " + url);
        	
        	%>
        	<img class="mapimage" name="<%=heatmapFile.getName()%>" src="<%=url %>">
        	<%        
        %>              	         
        </div> 
        
        
      </div>
      <!-- /.container-fluid -->

    </div>
    <!-- /.content-wrapper -->

  </div>
  <!-- /#wrapper -->

  
  <!-- Bootstrap core JavaScript-->
  <!-- 
  <script src="vendor/jquery/jquery.min.js"></script>
   -->
  <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

  <!-- Core plugin JavaScript-->
  <script src="vendor/jquery-easing/jquery.easing.min.js"></script>

  <!-- Custom scripts for all pages-->
  <script src="js/sb-admin.min.js"></script>

<script>

var sensorsArray = [];
var sensorsMap = {};

$(document).ready(function () {

	<% if(sensorArray != null)
	{
	%>
		sensorsArray = <%=sensorArray.toString()%>;
	
		printSensors();
	<%
	}
	%>		
});


function printSensors()
{
	$('.sensor').remove();
	sensorsMap = {};
	
	for(var i = 0; i < sensorsArray.length; i++)
	{
		var sensor = sensorsArray[i];
		
		var imageFile = sensor.image;
		
		var mapImage = $(".mapimage")
		
		var w = mapImage.width();
		var h = mapImage.height();
		
		var x = sensor.x * w + mapImage.offset().left;
		var y = sensor.y * h + mapImage.offset().top;
				    
		console.log(x, y);
		
		var name = sensor.name;
		
		sensorsMap[name] = name;       
		
		var type = sensor.type;
		
		var div = $("<div />")
		if(type == "sensor")
        	div.attr({"id": name, "class": 'sensor context-menu-one', "index": i});
    	else
    		div.attr({"id": name, "class": 'door context-menu-one', "index": i});
	
        //div.attr({"id": name, "class": 'sensor context-menu-one', "index": i});
        div.css({"top": y - 10, "left": x - 7, "position": "absolute"});
        div.html(name);
        $("#content-wrapper").append(div);		
	}	
	
	var span = $("<span />")
	span.attr({"class": 'gradient'});
    
    x = w + mapImage.offset().left;
	y = h + mapImage.offset().top;
	
	span.css({"top": y + 10, "left": x + 10, "position": "absolute"});
    
    $("#content-wrapper").append(span);
}

</script>
</body>

</html>
