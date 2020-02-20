
<%@page import="java.awt.Color"%>
<%@page import="com.modal.cetra.Gradient"%>
<%@page import="com.modal.cetra.HeatmapGenerator.Point"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.List"%>
<%@page import="com.modal.cetra.HeatmapGenerator"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.JSONObject"%>
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
	
	String tempDir = System.getProperty("java.io.tmpdir");
	String dirPath = context.getRealPath("");
	
	dirPath = dirPath + "maps" + File.separator + mapName;
	
	System.out.println("dirPath " + dirPath);
	
	File dir = new File(dirPath);
	
	String imageFiles[] = dir.list(new FilenameFilter() {
		public boolean accept(File f, String file)
		{
			System.out.println("file " + file);
			return file.endsWith("jpg") || file.endsWith("png");
		}
	});
	
	System.out.println("files " + imageFiles);
	
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
	
	JSONArray imagesArray = new JSONArray();
	
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
%>

<!DOCTYPE html>
<html lang="en">

<head>

  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>CETRA Admin</title>

  <!-- Custom fonts for this template-->
  <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">

  <!-- Page level plugin CSS-->
  <link href="vendor/datatables/dataTables.bootstrap4.css" rel="stylesheet">

  <!-- Custom styles for this template-->
  <link href="css/sb-admin.css" rel="stylesheet">
  <link href="css/style.css" rel="stylesheet">
  
     <link href="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.contextMenu.css" rel="stylesheet" type="text/css" />
	<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/ui-darkness/jquery-ui.css" rel="stylesheet">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.contextMenu.js" type="text/javascript"></script>

	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
    <script src="https://swisnl.github.io/jQuery-contextMenu/dist/jquery.ui.position.min.js" type="text/javascript"></script>
  
  <script src="js/widgetLoader.js"></script>
  
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
<%
	SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy");
	
	try
	{
		List<List<Point>> visitorsPathArray;
		
		if(from != null)
			visitorsPathArray = HeatmapGenerator.generateVisitorPaths(sensorsMap, doorsMap, new File(dirPath, "dataset.txt"), sdf.parse(from), sdf.parse(to));
		else
			visitorsPathArray = HeatmapGenerator.generateVisitorPaths(sensorsMap, doorsMap, new File(dirPath, "dataset.txt"), null, null);
		
		JSONArray visitorsPaths = new JSONArray();
		
		for(List<Point> points : visitorsPathArray)
		{
			JSONArray visitorPath = new JSONArray();
			
			for(Point p : points)
			{
				JSONObject point = new JSONObject();
				point.put("x", p.x);
				point.put("y", p.y);
				
				visitorPath.put(point);
			}
			
			visitorsPaths.put(visitorPath);
		}		
		
		%>
var visitorsPaths = <%=visitorsPaths.toString()%>
		<%

	}
	catch(IOException ex)
	{
		ex.printStackTrace();
	}
	
//Color colors[] = Gradient.GRADIENT_GREEN_YELLOW_ORANGE_RED_50;
Color colors[] = Gradient.GRADIENT_RAINBOW_100;

JSONArray colorArray = new JSONArray();

for(Color color : colors)
{
	colorArray.put(String.format("rgba(%d, %d, %d, 1)", color.getRed(), color.getGreen(), color.getBlue()));
}

%>
var colorsGradient = <%=colorArray.toString()%>

</script>
</head>

<body id="page-top">

  <nav class="navbar navbar-expand navbar-dark bg-dark static-top">

    <a class="navbar-brand mr-1" href="index.html">CETRA</a>

    <button class="btn btn-link btn-sm text-white order-1 order-sm-0" id="sidebarToggle" href="#">
      <i class="fas fa-bars"></i>
    </button>

   <jsp:include page="navbaradmin.jsp"/>

  </nav>

  <div id="wrapper">

    <!-- Sidebar -->
    <jsp:include page="sidebaradmin.jsp"/>
    
    <div id="content-wrapper">

      <div class="container-fluid">

        <!-- Breadcrumbs-->
        <ol class="breadcrumb">
          <li class="breadcrumb-item">
            <a href="index.html">Dashboard</a>
          </li>
          <li class="breadcrumb-item active"><%=mapName %></li>
        </ol>

        <!-- Page Content -->
        <h1>Editing mappa</h1>
        <hr>
        <p><%=mapName %></p>
        
        <div id="map-container">
        
        <%
        for(String imageFile : imageFiles)
        {
        	imagesArray.put(imageFile);
        	
        	String url = context.getContextPath() + "/maps/" + mapName + "/" + imageFile;
        	
        	System.out.println("url " + url);
        	
        	%>
        	<img class="mapimage" name="<%=imageFile%>" src="<%=url %>">
        	<canvas id="coveringCanvas" class="coveringCanvas"></canvas>
        	<%
        }
        %>         
        
        </div> 
      </div>
      <!-- /.container-fluid -->

      <!-- Sticky Footer -->
      <footer class="sticky-footer">
        <div class="container my-auto">
          <div class="copyright text-center my-auto">
            <span>Copyright � Modal 2019-2020</span>
          </div>
        </div>
      </footer>

    </div>
    <!-- /.content-wrapper -->

  </div>
  <!-- /#wrapper -->

  <!-- Scroll to Top Button-->
  <a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
  </a>

  <!-- Logout Modal-->
  <div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalLabel">Ready to Leave?</h5>
          <button class="close" type="button" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">×</span>
          </button>
        </div>
        <div class="modal-body">Select "Logout" below if you are ready to end your current session.</div>
        <div class="modal-footer">
          <button class="btn btn-secondary" type="button" data-dismiss="modal">Cancel</button>
          <a class="btn btn-primary" href="login.html">Logout</a>
        </div>
      </div>
    </div>
  </div>
	
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

var canvas;
var canvasWidth;
var canvasHeight;
var ctx;
var canvasData;

$(document).ready(function () {

	<% if(sensorArray != null)
	{
	%>
		sensorsArray = <%=sensorArray.toString()%>;
	
		printSensors();
		<%
	}
	%>	
		
	runVisitors();	    	  
});


function printSensors()
{
	$('.sensor').remove();
	$('.door').remove();
	sensorsMap = {};
	
	for(var i = 0; i < sensorsArray.length; i++)
	{
		var sensor = sensorsArray[i];
		
		var imageFile = sensor.image;
		
		var mapImage = $( "img[name='" + imageFile + "']" );
		
		var w = mapImage.width();
		var h = mapImage.height();
		
		var x = Math.floor(sensor.x * w) + mapImage.offset().left;
		var y = Math.floor(sensor.y * h) + mapImage.offset().top;
				    
		console.log(x, y);
		
		var name = sensor.name;
		
		sensorsMap[name] = name;       
		
		var type = sensor.type;
		
		var div = $("<div />");
		
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

const MAX_RUNNING_VISITORS = 100;

var visitorsIndex = 0;
function runVisitors()
{
	var sensor = sensorsArray[0];
	var imageFile = sensor.image;
	var mapImage = $( "img[name='" + imageFile + "']" );
	var x = mapImage.offset().left;
	var y = mapImage.offset().top;
	var w = mapImage.width();
	var h = mapImage.height();
	
	$('.coveringCanvas').css({left:x, top:y, width:w, height:h});
	
	canvas = document.getElementById("coveringCanvas");
	
	// Get the device pixel ratio, falling back to 1.
	var dpr = window.devicePixelRatio || 1;
	
	// Get the size of the canvas in CSS pixels.
	var rect = canvas.getBoundingClientRect();
	// Give the canvas pixel dimensions of their CSS
	// size * the device pixel ratio.
	canvas.width = rect.width * dpr;
	canvas.height = rect.height * dpr;
	
	ctx = canvas.getContext('2d');
	// Scale all drawing operations by the dpr, so you
	// don't have to worry about the difference.
	ctx.scale(dpr, dpr);

	canvasWidth = canvas.width;
	canvasHeight = canvas.height;
/*
	ctx = canvas.getContext("2d");
	ctx.imageSmoothingEnabled = true;
	canvasData = ctx.getImageData(0, 0, canvasWidth, canvasHeight);
*/
	console.log("canvas width " + canvasWidth);
	console.log("canvas height " + canvasHeight);

	for(var i = 0; i < MAX_RUNNING_VISITORS && i < visitorsPaths.length; i++)
	{
		runNextVisitor();
		//setTimeout(runNextVisitor(), Math.random() * 2000 + 1)		
	}
}

function runNextVisitor()
{
	//console.log("visitorsIndex " + visitorsIndex);
	
	if(visitorsIndex < visitorsPaths.length)
	{
		var sensor = sensorsArray[0];
		var imageFile = sensor.image;
		
		var mapImage = $( "img[name='" + imageFile + "']" );
		var w = mapImage.width();
		var h = mapImage.height();
			
		var visitorPath = visitorsPaths[visitorsIndex];
		
		//var elem = document.createElement("img");   // Create a <img> element
		//elem.src = "images/3dball.png";
		//elem.className = "ball";
		//elem.style.background = colorsGradient[visitorsIndex];
		
		var elem = document.createElement("i");   // Create a <img> element
		//elem.className = "ball fas fa-walking";
		elem.className = "ball fas fa-user-circle";
		elem.style.color = colorsGradient[visitorsIndex % MAX_RUNNING_VISITORS];
		
		var point = visitorPath[0];
    	
    	var x = Math.floor(point.x * w) + mapImage.offset().left;
		var y = Math.floor(point.y * h) + mapImage.offset().top;
		
		x = x - 4;
		y = y - 4;
		
      	elem.style.top = y + 'px';
      	elem.style.left = x + 'px';
      	
		//var parent = document.body("map-container");
		
			document.body.appendChild(elem);      
				
		var n = parseInt(Math.random() * 100) + 30;
		//console.log("n " + n);
		
		var id = setInterval(frame, n);
		var id1 = 0;
		
		var visitorIndex = visitorsIndex;
		var index = 0;
		
		visitorsIndex++;
		
		function frame() 
		{		
			//console.log("frame " + visitorIndex);
			
		    if (index >= visitorPath.length) 
		    {
		    	//console.log("index >= visitorPath.length");
		    	
		    	clearInterval(id);
		    	elem.parentNode.removeChild(elem);
		    	runNextVisitor();
		    } 
		    else 
		    {
		    	//console.log("index < visitorPath.length");
		    	
		    	var point = visitorPath[index];
		    			    		    	
		    	var x = Math.floor(point.x * w) + mapImage.offset().left;
				var y = Math.floor(point.y * h) + mapImage.offset().top;
				
				x = x - 4;
				y = y - 4;
				
		      	elem.style.top = y + 'px';
		      	elem.style.left = x + 'px';
		      	
		      	index++;
		    }
		}
		
		$( elem ).mouseover(function() {
			  console.log("Handler for .mouseover() called" );
			  
			  clearInterval(id);
			  
			  $(elem).css('z-index', 3000);
			  
			  var i = 0;
			  id1 = setInterval(function() 
			  {
				  if(i < visitorPath.length)					  
				  {
				 	 var point = visitorPath[i];
				 	 
			    	 var x = Math.floor(point.x * w);// + mapImage.offset().left;
					 var y = Math.floor(point.y * h);// + mapImage.offset().top;
					 
					 console.log("(x, y) (" + x + ", " + y + ")" );
					 
					 ctx.strokeStyle = "rgba(150, 150, 150, 0.6)";
					 
					 ctx.lineWidth = 1;
					 
					 //ctx.strokeRect(x,y,1,1);
					 
					 ctx.beginPath();
					 ctx.arc(x, y, 1, 0, 2 * Math.PI, true);
					 ctx.stroke();
					 
					/* 
					 ctx.beginPath();
					 ctx.moveTo(x, y);
					 ctx.lineTo(x + 1, y + 1);
					 //ctx.arc(x, y, 0.1, 0, 2 * Math.PI, true);
					 ctx.stroke();
					 */
					 //ctx.fillRect(x,y,1,1);
					 
					 //drawPixel(x, y, 20, 20, 20, 1);
					 
					 i++;
					 
				  }
				  
				  //updateCanvas();
			  }, 3000 / visitorPath.length );
			  
			  	
			  
			})
			.mouseout(function() {
				console.log("Handler for .mouseout() called" );
				
				$(elem).css('z-index', 1);
				
				clearCanvas();
				if(id1 != 0)
					clearInterval(id1);
				
				id = setInterval(frame, n);
  			});
		
	
		
	}
	else
	{
		console.log("restart");
		visitorsIndex = 0;
		
		runNextVisitor();		
	}
}



// That's how you define the value of a pixel //
function drawPixel (x, y, r, g, b, a) {
    var index = (x + y * canvasWidth) * 4;

    canvasData.data[index + 0] = r;
    canvasData.data[index + 1] = g;
    canvasData.data[index + 2] = b;
    canvasData.data[index + 3] = a;
}

// That's how you update the canvas, so that your //
// modification are taken in consideration //
function updateCanvas() {
	
	console.log("updateCanvas");
    ctx.putImageData(canvasData, 0, 0);
}

function clearCanvas() {
    
	console.log("clearCanvas");
	ctx.clearRect(0, 0, canvasWidth, canvasHeight);
}
</script>
</body>

</html>
