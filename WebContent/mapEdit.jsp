
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

String imageFiles[] = dir.list(new FilenameFilter() {
	public boolean accept(File f, String file)
	{
		System.out.println("file " + file);
		return file.endsWith("jpg") || file.endsWith("png");
	}
});

System.out.println("files " + imageFiles);

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
</head>

<body id="page-top">

  <nav class="navbar navbar-expand navbar-dark bg-dark static-top">

    <a class="navbar-brand mr-1" href="index.html">CETRA</a>

    <button class="btn btn-link btn-sm text-white order-1 order-sm-0" id="sidebarToggle" href="#">
      <i class="fas fa-bars"></i>
    </button>

    <!-- Navbar Search -->
    <form class="d-none d-md-inline-block form-inline ml-auto mr-0 mr-md-3 my-2 my-md-0">
      <div class="input-group">
        <input type="text" class="form-control" placeholder="Search for..." aria-label="Search" aria-describedby="basic-addon2">
        <div class="input-group-append">
          <button class="btn btn-primary" type="button">
            <i class="fas fa-search"></i>
          </button>
        </div>
      </div>
    </form>

    <!-- Navbar -->
    <ul class="navbar-nav ml-auto ml-md-0">
      <li class="nav-item dropdown no-arrow mx-1">
        <a class="nav-link dropdown-toggle" href="#" id="alertsDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <i class="fas fa-bell fa-fw"></i>
          <span class="badge badge-danger">9+</span>
        </a>
        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="alertsDropdown">
          <a class="dropdown-item" href="#">Action</a>
          <a class="dropdown-item" href="#">Another action</a>
          <div class="dropdown-divider"></div>
          <a class="dropdown-item" href="#">Something else here</a>
        </div>
      </li>
      <li class="nav-item dropdown no-arrow mx-1">
        <a class="nav-link dropdown-toggle" href="#" id="messagesDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <i class="fas fa-envelope fa-fw"></i>
          <span class="badge badge-danger">7</span>
        </a>
        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="messagesDropdown">
          <a class="dropdown-item" href="#">Action</a>
          <a class="dropdown-item" href="#">Another action</a>
          <div class="dropdown-divider"></div>
          <a class="dropdown-item" href="#">Something else here</a>
        </div>
      </li>
      <li class="nav-item dropdown no-arrow">
        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          <i class="fas fa-user-circle fa-fw"></i>
        </a>
        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="userDropdown">
          <a class="dropdown-item" href="#">Settings</a>
          <a class="dropdown-item" href="#">Activity Log</a>
          <div class="dropdown-divider"></div>
          <a class="dropdown-item" href="#" data-toggle="modal" data-target="#logoutModal">Logout</a>
        </div>
      </li>
    </ul>

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
          <li class="breadcrumb-item active">Mappa <%=mapName %></li>
        </ol>

        <!-- Page Content -->
        <h1>Amministrazione</h1>
        <hr>
        <p>Mappa <%=mapName %></p>
        
        <div>
        
        <%
        for(String imageFile : imageFiles)
        {
        	String url = context.getContextPath() + "/maps/" + mapName + "/" + imageFile;
        	
        	System.out.println("url " + url);
        	
        	%>
        	<img class="mapimage context-menu-one" name="<%=imageFile%>" src="<%=url %>">
        	<%
        }
        %>
        
        <input type="button" name="save" value="Salva" onClick="onSave()">
        <input type="button" name="save" value="Genera" onClick="onGenerate()">
        </div> 
      </div>
      <!-- /.container-fluid -->

      <!-- Sticky Footer -->
      <footer class="sticky-footer">
        <div class="container my-auto">
          <div class="copyright text-center my-auto">
            <span>Copyright © Modal 2019-2020</span>
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
            <span aria-hidden="true">Ã—</span>
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
  <script src="vendor/jquery/jquery.min.js"></script>
  <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

  <!-- Core plugin JavaScript-->
  <script src="vendor/jquery-easing/jquery.easing.min.js"></script>

  <!-- Custom scripts for all pages-->
  <script src="js/sb-admin.min.js"></script>

<script>

var sensorsMap = {};
var sensorsArray = [];

$(document).ready(function () {
	$('.mapimage').click(function (e) { //Default mouse Position 
		var elm = $(this);
	    var xPos = e.pageX - elm.offset().left;
	    var yPos = e.pageY - elm.offset().top;
		var imageFile = elm.attr("name");
		
	    console.log(xPos, yPos);
	    
	    xPos = xPos / elm.width();
	    yPos = yPos / elm.height();
	    
	    console.log(xPos, yPos);
	    
	    var name = prompt("Nome sensore", "");
	    if(sensorsMap[name] != null)
	    {
	    	alert("sensore " + name + " già presente");
	    	return;
	    }
	    	
	    var div = $("<div />")
        div.attr({"id": name, "class": 'sensor'});
        div.css({"top": e.pageY - 10, "left": e.pageX - 7, "position": "absolute"});
        div.html(name);
        $("#content-wrapper").append(div);
                 
        sensorsMap[name] = name;       
        sensorsArray.push({"x": xPos, "y": yPos, "name": name, "image": imageFile});
	});	
});

function onSave()
{
	var data = {"name": "<%=mapName%>", sensors: JSON.stringify(sensorsArray)};
	
	var posting = $.post( 
  	{
  			//"url": "http://phlay.us-east-2.elasticbeanstalk.com/ads/generateVideoAds",
  		"url": "storeSensors.jsp",
   		"data":	{ "data": data},
  		"timeout": 1200000
  	});
	
	posting.fail(function( error, textStatus, errorThrown ) {
    	alert( textStatus );
    });
	    
    /* Alerts the results */
    posting.done(function( data ) {
    	   	  
    });
}

function onGenerate()
{
	var data = {"name": "<%=mapName%>", sensors: JSON.stringify(sensorsArray)};
	
	var posting = $.post( 
  	{
  			//"url": "http://phlay.us-east-2.elasticbeanstalk.com/ads/generateVideoAds",
  		"url": "generatePaths.jsp",
   		"data":	{ "data": data},
  		"timeout": 1200000
  	});
	
	posting.fail(function( error, textStatus, errorThrown ) {
    	alert( textStatus );
    });
	    
    /* Alerts the results */
    posting.done(function( data ) {
    	   	  
    });
}

$(function() {
    $.contextMenu({
        selector: '.context-menu-one', 
        callback: function(key, options) {
            var m = "clicked: " + key;
            window.console && console.log(m) || alert(m); 
        },
        items: {
            "edit": {name: "Edit", icon: "edit"},
            "cut": {name: "Cut", icon: "cut"},
           copy: {name: "Copy", icon: "copy"},
            "paste": {name: "Paste", icon: "paste"},
            "delete": {name: "Delete", icon: "delete"},
            "sep1": "---------",
            "quit": {name: "Quit", icon: function(){
                return 'context-menu-icon context-menu-icon-quit';
            }}
        }
    });

    $('.context-menu-one').on('click', function(e){
        console.log('clicked', this);
    })    
});
</script>
</body>

</html>
