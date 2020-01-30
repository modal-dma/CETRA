package com.modal.cetra;

import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.image.BufferedImage;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Map.Entry;

import java.util.Set;

public class Dijkstra {

	private static int STEP = 1;
	private static int THRESHOULD = 0x00F3e0e0;
	
	private static Set<Node> unsettledNodes = new HashSet<>();

	public static BufferedImage resultBitmap;
	public static BufferedImage graphBitmap;
	
	public static HashMap<Point, Node> nodeMap;
	
	private static Node end;
	
    public static GraphBitmap calculateShortestPathFromSource(GraphBitmap graph, Node start, Node end) {

    	graphBitmap = Utils.copyImage(graph.getBitmap());
    
//    	int v = graphBitmap.getRGB(350, 567);
//    	
//    	System.out.println("v :" + v);
//    	System.out.println("v :" + new BigInteger("" + v).toString(16));
//    	
//    	System.out.println("v :" + (0x00FFFFFF & v));
//    	System.out.println("v :" + new BigInteger("" + (0x00FFFFFF & v)).toString(16));
//    	
//    	System.out.println("v :" + BigInteger.valueOf(v).toString(16));
    	
    	
    	
    	Dijkstra.end = end;
    	
    	resultBitmap = new BufferedImage(graphBitmap.getWidth(), graphBitmap.getHeight(), BufferedImage.TYPE_3BYTE_BGR);    	
    	resultBitmap.setRGB(start.x, start.y, -1);
    	
    	nodeMap = new HashMap<>();
    	
    	start.distance = 0;
    	
        unsettledNodes.add(start);
        
        while (unsettledNodes.size() != 0) {
            Node currentNode = getLowestDistanceNode(unsettledNodes);
            
            unsettledNodes.remove(currentNode);
            for (Entry<Node, Integer> adjacencyPair : getAdjacentNodes(graphBitmap, currentNode).entrySet()) {
                Node adjacentNode = adjacencyPair.getKey();
                Integer edgeWeigh = adjacencyPair.getValue();

                if (graphBitmap.getRGB(adjacentNode.x, adjacentNode.y) != 0) {
                    calculateMinimumDistance(adjacentNode, edgeWeigh, currentNode);
                    unsettledNodes.add(adjacentNode);
                }
                            
                if(adjacentNode.equals(end))
                {
                	System.out.println("end: " + end);
                	end.shortestPath = adjacentNode.shortestPath;
                	end.distance = adjacentNode.distance;
                	//return graph;
                }
            }
            	
            graphBitmap.setRGB(currentNode.x, currentNode.y, 0);              
        }
        return graph;
    }

    private static void calculateMinimumDistance(Node evaluationNode, Integer edgeWeigh, Node sourceNode) 
    {
        Integer sourceDistance = sourceNode.distance;
        if (sourceDistance + edgeWeigh < evaluationNode.distance) 
        {
            evaluationNode.distance = sourceDistance + edgeWeigh;
            resultBitmap.setRGB(evaluationNode.x, evaluationNode.y, evaluationNode.distance);       
            graphBitmap.setRGB(evaluationNode.x, evaluationNode.y, 0);
            LinkedList<Node> shortestPath = new LinkedList<>(sourceNode.shortestPath);
            shortestPath.add(sourceNode);
            evaluationNode.shortestPath = shortestPath;       
        }
    }

    private static Node getLowestDistanceNode(Set<Node> unsettledNodes) {
        Node lowestDistanceNode = null;
        int lowestDistance = Integer.MAX_VALUE;
        for (Node node : unsettledNodes) {
            int nodeDistance = node.distance;
            if (nodeDistance < lowestDistance) {
                lowestDistance = nodeDistance;
                lowestDistanceNode = node;
            }
        }
        return lowestDistanceNode;
    }
    
    private static Map<Node, Integer> getAdjacentNodes(BufferedImage bitmap, Node currentNode)
    {
    	HashMap<Node, Integer> adjNode = new HashMap<>();
    	
		int x0 = currentNode.x - STEP;
		int x1 = currentNode.x + STEP;
		
		int y0 = currentNode.y - STEP;
		int y1 = currentNode.y + STEP;
		
		Node node;
		if(y0 >= 0 && ((0x00FFFFFF & bitmap.getRGB(currentNode.x, y0)) > THRESHOULD))
		{
			node = new Node(currentNode.x, y0);						
			adjNode.put(node, 1);
		}

		if(y1 < bitmap.getHeight() && ((0x00FFFFFF & bitmap.getRGB(currentNode.x, y1)) > THRESHOULD))
		{
			node = new Node(currentNode.x, y1);			
			adjNode.put(node, 1);
		}
		
		if(x0 >= 0 && ((0x00FFFFFF & bitmap.getRGB(x0, currentNode.y)) > THRESHOULD))
		{
			node = new Node(x0, currentNode.y);
			adjNode.put(node, 1);
		}
		
		if(x1 < bitmap.getWidth() && ((0x00FFFFFF & bitmap.getRGB(x1, currentNode.y)) > THRESHOULD))
		{
			node = new Node(x1, currentNode.y);		
			adjNode.put(node, 1);
		}
		
		if(x0 >= 0 && y0 > 0 && ((0x00FFFFFF & bitmap.getRGB(x0, y0)) > THRESHOULD))
		{
			node = new Node(x0, y0);
			adjNode.put(node, 1);
		}
		
		if(x1 < bitmap.getWidth() && y0 > 0 && ((0x00FFFFFF & bitmap.getRGB(x1, y0)) > THRESHOULD))
		{
			node = new Node(x1, y0);
			adjNode.put(node, 1);
		}
		
		if(y1 < bitmap.getHeight() && x0 > 0 && ((0x00FFFFFF & bitmap.getRGB(x0, y1)) > THRESHOULD))
		{
			node = new Node(x0, y1);
			adjNode.put(node, 1);
		}
		
		if(x1 < bitmap.getWidth() && y1 < bitmap.getHeight() && ((0x00FFFFFF & bitmap.getRGB(x1, y1)) > THRESHOULD))
		{
			node = new Node(x1, y1);
			adjNode.put(node, 1);
		}
		
		//System.out.println(adjNode.toString());
		
		return adjNode;
    }
    
//    private static Map<Node, Integer> getAdjacentNodes(BufferedImage bitmap, Node currentNode)
//    {
//    	HashMap<Node, Integer> adjNode = new HashMap<>();
//    	
//		int x0 = currentNode.x - STEP;
//		int x1 = currentNode.x + STEP;
//		
//		int y0 = currentNode.y - STEP;
//		int y1 = currentNode.y + STEP;
//		
//		Node node;
//		if(y0 >= 1 && 
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x, y0)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x - 1, y0)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x + 1, y0)) > THRESHOULD &&
//			    (0x00FFFFFF & bitmap.getRGB(currentNode.x, y0 + 1)) > THRESHOULD &&
//			    (0x00FFFFFF & bitmap.getRGB(currentNode.x, y0 - 1)) > THRESHOULD)
//		{
//			node = new Node(currentNode.x, y0);						
//			adjNode.put(node, 1);
//		}
//
//		if(y1 < bitmap.getHeight() - 1 && 
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x, y1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x - 1, y1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x + 1, y1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x, y1 + 1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(currentNode.x, y1 - 1)) > THRESHOULD)
//		{
//			node = new Node(currentNode.x, y1);			
//			adjNode.put(node, 1);
//		}
//		
//		if(x0 >= 1 && (0x00FFFFFF & bitmap.getRGB(x0, currentNode.y)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x0 - 1, currentNode.y)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x0 + 1, currentNode.y)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x0, currentNode.y - 1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x0, currentNode.y + 1)) > THRESHOULD)
//		{
//			node = new Node(x0, currentNode.y);
//			adjNode.put(node, 1);
//		}
//		
//		if(x1 < bitmap.getWidth() && 
//				(0x00FFFFFF & bitmap.getRGB(x1, currentNode.y)) > THRESHOULD && 
//				(0x00FFFFFF & bitmap.getRGB(x1 - 1, currentNode.y)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x1 + 1, currentNode.y)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x1, currentNode.y - 1)) > THRESHOULD &&
//				(0x00FFFFFF & bitmap.getRGB(x1, currentNode.y + 1)) > THRESHOULD)
//		{
//			node = new Node(x1, currentNode.y);		
//			adjNode.put(node, 1);
//		}
//		
////		System.out.println(currentNode);
////		System.out.println(adjNode.toString());
//		
//		return adjNode;
//    }
}
