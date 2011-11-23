package com.quadcs.hacksaw;

import java.lang.instrument.Instrumentation;

public class Main {	
	public static final String version = "0.2 \"XYZ\"";
	public static Instrumentation sys;

        public static void premain(String agentArgs, Instrumentation inst) {
		System.out.println("--------------------------------------------------------------");
		System.out.println("Hacksaw V" + version);
		System.out.println("* Copyright (C) 2011- Dave Parfitt. All Rights Reserved.");
		System.out.println("*	Version: MPL 1.1");
		System.out.println("* 	See License.html for details");
		System.out.println("*	Hacksaw uses the Javassist toolkit:");
		System.out.println("*Javassist, a Java-bytecode translator toolkit.");
		System.out.println("* Copyright (C) 1999- Shigeru Chiba. All Rights Reserved.");
		System.out.println("* 	Version: MPL 1.1");
		System.out.println("* 	See License.html for details");			
		System.out.println("");	
		System.out.println("--------------------------------------------------------------");			
		sys = inst;
		sys.addTransformer(new Hacksaw());		
	}

    
        
}
