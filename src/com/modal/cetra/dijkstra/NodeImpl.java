package com.modal.cetra.dijkstra;

import java.util.HashMap;
import java.util.Map;

public class NodeImpl extends Node {

    private Map<Node, Integer> adjacentNodes = new HashMap<>();

    public NodeImpl(String name) {
        super(name);
    }
    
    public void addDestination(NodeImpl destination, int distance) {
        adjacentNodes.put(destination, distance);
    }

    @Override
    public Map<Node, Integer> getAdjacentNodes() {
        return adjacentNodes;
    }

    public void setAdjacentNodes(Map<Node, Integer> adjacentNodes) {
        this.adjacentNodes = adjacentNodes;
    }
}
