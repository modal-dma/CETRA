<%@page import="com.modal.cetra.Constants"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%

String username = request.getParameter("email");
String password = request.getParameter("password");

if(password != null && password.equals(Constants.usersMap.get(username)))
{
	request.getSession().setAttribute("username", username);
	response.sendRedirect("admin.html");
}
else
{
	response.sendRedirect("login.html");
}
%>
