<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%
if(this.getServletContext().getAttribute("username") == null)
{
	response.sendRedirect("login.html");
	return;
}
else
{
	response.sendRedirect("admin.jsp");
}
%>
