
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

File datasetFile = new File(dirPath, "dataset.txt");

FileReader fr = new FileReader(datasetFile);
BufferedReader br = new BufferedReader(fr);
String line = "";
	
HashMap<String, String> dateMap = new HashMap<>();
	
while((line = br.readLine()) != null)
{
	String fields[] = line.split(",");
	
	String datehour = fields[2];
	
	String date[] = datehour.split(" ");
		
	String day = date[0];
	String hour = date[1];
		
	//System.out.println("day " + day);
		
	if(!dateMap.containsKey(day))
	{
		dateMap.put(day, day);
	}
}


ArrayList<String> dates = new ArrayList(dateMap.values());

Collections.sort(dates, new Comparator<String>() {
	
	public int compare(String o1, String o2)
	{
		return o1.compareTo(o2);	
	}
});


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

        <!-- Page Content -->
        <h1><%=mapName %></h1>
        <hr>
        
        <span>Da: </span>
        <select id="from" name="from" style="width:100px;">
        	<option value="tutti" selected>Tutti</option>
        <%
        	for(String date : dates)
        	{
        		%>
        		<option value="<%=date%>"><%=date%></option>
        		<%
        	}
        %>
		</select> 
		<span>A: </span>
        <select id="to" name="to" style="width:100px;">
        <%
        	for(String date : dates)
        	{
        		%>
        		<option value="<%=date%>"><%=date%></option>
        		<%
        	}
        %>
		</select> 
		<span>Filtro 1 </span>
        <select id="filter1" name="filter1" style="width:100px;">
        <option value="none" selected>nessuno</option>
        <%
        	for(int i = 0; i < sensorArray.length(); i++)
        	{
        		JSONObject sensor = sensorArray.getJSONObject(i);
        		String name = sensor.getString("name");
        		String type = sensor.getString("type");
        		if(type.equals("sensor"))
        		{
	        		%>
	        		<option value="<%=name%>"><%=name%></option>
	        		<%
        		}
        	}
        %>
		</select> 
		
		<span>Filtro 2 </span>
        <select id="filter2" name="filter2" style="width:100px;">
        <option value="none" selected>nessuno</option>
        <%
        	for(int i = 0; i < sensorArray.length(); i++ )
        	{
        		JSONObject sensor = sensorArray.getJSONObject(i);
        		String name = sensor.getString("name");
        		String type = sensor.getString("type");
        		if(type.equals("sensor"))
        		{
	        		%>
	        		<option value="<%=name%>"><%=name%></option>
	        		<%
        		}
        	}
        %>
		<input type="button" name="run" value="Submit" onClick="onRun()">
        <div>
        
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

	var w = $(window).width();
	var h = $(window).height();
	
	var top = $(".mapimage").offset().top;
	
	h = h - top;
	
	$(".mapimage").height(h);
	
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
}

function onRun()
{
	var from = $('#from').find(":selected").text();
	var to = $('#to').find(":selected").text();
	var filter1 = $('#filter1').find(":selected").text();
	var filter2 = $('#filter2').find(":selected").text();
	
	var data;
	
	//if(from.equals("Tutti"))
	//{
	//	data = {"name": "<%=mapName%>"};
	//}
	//else
	//{
		data = {"name": "<%=mapName%>", "from": from, "to": to};
	//}
	if(filter1 != "nessuno")
		data["filter1"]= filter1;
	
	if(filter2 != "nessuno")
		data["filter2"]= filter2;
	
	var posting = $.post("generateHeatmap.jsp", data, function() {
		
	})
	.fail(function( error, textStatus, errorThrown ) {
    	alert( textStatus + " " + errorThrown);
    })
    .done(function( data ) {
   	
    	data = data.trim();
    	var json = JSON.parse(data);
    	
    	var heatmap = json.heatmap;
    	
    	var url = "maps/<%=mapName%>/heatmaps/" + heatmap;
    	
    	//Console.debug("url " + url);
    	
    	$(".mapimage").attr("src", url);
            
    });
}

</script>
</body>

</html>
