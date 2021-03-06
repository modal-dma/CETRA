<%@page import="java.io.File"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%

ServletContext context = pageContext.getServletContext();
String tempDir = System.getProperty("java.io.tmpdir");
String dirPath = context.getRealPath("");

dirPath = dirPath + "maps";

System.out.println("dirPath " + dirPath);

File dir = new File(dirPath);

String mapDirs[] = dir.list();

System.out.println("files " + mapDirs);



%>
 <!-- Sidebar -->
    <ul class="sidebar navbar-nav">
      <li class="nav-item">
        <a class="nav-link" href="admin.jsp">
          <i class="fas fa-fw fa-tachometer-alt"></i>
          <span>Dashboard</span>
        </a>
      </li>
      
      <%
        	for(String map : mapDirs)
        	{
        		%>
        		<li class="nav-item dropdown">
        			<a class="nav-link dropdown-toggle" href="#" id="pagesDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          			<i class="fas fa-fw fa-folder"></i>
          			<span><%=map%></span>
        			</a>
       				<div class="dropdown-menu" aria-labelledby="pagesDropdown">    
       					<a class="dropdown-item" href="map.jsp?name=<%=map%>">Edit</a>    				
       					<a class="dropdown-item" href="mapview.jsp?name=<%=map%>">Heatmap</a>
       					<a class="dropdown-item" href="animapview.jsp?name=<%=map%>">Percorsi</a>
       					<a class="dropdown-item" onclick="deleteMap('<%=map%>')">Elimina</a>
       				</div>
        		</li>
        		<%
        	}
        %>
       
  
      <!-- 
      <li class="nav-item">
        <a class="nav-link" href="charts.html">
          <i class="fas fa-fw fa-chart-area"></i>
          <span>Charts</span></a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="tables.html">
          <i class="fas fa-fw fa-table"></i>
          <span>Tables</span></a>
      </li>
       -->
    </ul>
    <script>
    function deleteMap(map)
    {
    	var r = confirm("Sei sicuro di voler cancellare la mappa " + map + "?");
    	if (r == true) {
    		var posting = $.get("deleteMap.jsp?name=" + encodeURI(map), null, function() {
    			
    		})
    		.fail(function( error, textStatus, errorThrown ) {
    	    	alert( textStatus + " " + errorThrown);
    	    })
    	    .done(function( data ) {
    	    	location.reload();
    	    });
    	}
    }
    </script>