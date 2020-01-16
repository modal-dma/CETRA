package com.modal.cetra;

import java.util.HashMap;

public class Constants {

	public static HashMap<String, String> usersMap = new HashMap<>();
	
	static
	{
		usersMap.put("admin@cetra.it", "admin123");
		usersMap.put("ugo@cetra.it", "ugo123");
	}
	
	public static int STEP = 4;
	public static int COLOR_STEP = 4;
}
