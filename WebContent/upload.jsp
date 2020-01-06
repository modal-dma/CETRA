<%@ page import = "java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import = "org.apache.commons.fileupload.*" %>
<%@ page import = "org.apache.commons.fileupload.disk.*" %>
<%@ page import = "org.apache.commons.fileupload.servlet.*" %>
<%@ page import = "org.apache.commons.io.output.*" %>

<%
   File file ;
   int maxFileSize = 50000 * 1024;
   int maxMemSize = 5000 * 1024;
   ServletContext context = pageContext.getServletContext();
   
   String tempDir = System.getProperty("java.io.tmpdir");
   
   String dirPath = context.getRealPath("");
   
   dirPath = dirPath + "maps" + File.separator;
   
   // Verify the content type
   String contentType = request.getContentType();
   
   if ((contentType.indexOf("multipart/form-data") >= 0)) 
   {
      DiskFileItemFactory factory = new DiskFileItemFactory();
      // maximum size that will be stored in memory
      factory.setSizeThreshold(maxMemSize);
      
      // Location to save data that is larger than maxMemSize.
      factory.setRepository(new File(tempDir));

      // Create a new file upload handler
      ServletFileUpload upload = new ServletFileUpload(factory);
      
      // maximum file size to be uploaded.
      upload.setSizeMax( maxFileSize );
      
      try { 
         // Parse the request to get file items.
         List fileItems = upload.parseRequest(request);

         // Process the uploaded file items
         Iterator i = fileItems.iterator();

         out.println("<html>");
         out.println("<head>");
         out.println("<title>JSP File upload</title>");  
         out.println("</head>");
         out.println("<body>");
         
         String name = null;
         Vector<FileItem> files = new Vector<>();
         
         while ( i.hasNext () ) {
            FileItem fi = (FileItem)i.next();
            if (fi.isFormField()) 
            {
                // Process regular form field (input type="text|radio|checkbox|etc", select, etc).
                name = fi.getFieldName();
                
                if(name.equals("name"))
                {
                	name = fi.getString();
                	dirPath += fi.getString();
                	
                	File f = new File(dirPath);
                	if(!f.exists())
                		f.mkdirs();
                }
            }
            else //if ( !fi.isFormField () ) 
            {
            	files.add(fi);           	               
            }
         }
         
         for(FileItem fi : files)
         {         
      		// Get the uploaded file parameters
	         String fieldName = fi.getFieldName();
	         String fileName = fi.getName();
	         boolean isInMemory = fi.isInMemory();
	         long sizeInBytes = fi.getSize();
	      
	         // Write the file
	         if( fileName.lastIndexOf("\\") >= 0 ) {
	            file = new File( dirPath + File.separator + 
	            fileName.substring( fileName.lastIndexOf("\\"))) ;
	         } else {
	            file = new File( dirPath + File.separator + 
	            fileName.substring(fileName.lastIndexOf("\\")+1)) ;
	         }
	         fi.write( file ) ;	         
         }
         
         response.sendRedirect("map.jsp?name=" + name);
         
      } catch(Exception ex) {
    	  ex.printStackTrace();
      }
   } else {
      out.println("<html>");
      out.println("<head>");
      out.println("<title>Servlet upload</title>");  
      out.println("</head>");
      out.println("<body>");
      out.println("<p>No file uploaded</p>"); 
      out.println("</body>");
      out.println("</html>");
   }
%>