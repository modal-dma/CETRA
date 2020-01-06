package com.modal.cetra;

import java.util.LinkedList;

public class Node {
	
	public int x;
	public int y;
	public int distance = Integer.MAX_VALUE;
	
	public LinkedList<Node> shortestPath = new LinkedList<>();
	
	public Node(int x, int y)
	{
		this.x = x; 
		this.y = y;
	}
	
	@Override
	public int hashCode()
	{
		return String.format("%d,%d", x, y).hashCode();
	}
	
	@Override 
	public String toString()
	{
		return String.format("(%d,%d):%d", x, y, distance);
	}
	
	@Override 
	public boolean equals(Object node)
	{
		if(node instanceof Node)
			return x == ((Node)node).x && y == ((Node)node).y;
		else
			return false;
	}
}
