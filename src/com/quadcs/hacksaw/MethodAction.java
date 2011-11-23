package com.quadcs.hacksaw;

import javassist.CtMethod;

public class MethodAction {
	protected String methodname;
	protected String sig;
	
	public MethodAction(String methodname, String sig) {
		this.methodname = methodname;
		this.sig = sig;
	}
	
	public String getSig() {
		return sig;
	}

	public void setSig(String sig) {
		this.sig = sig;
	}

	
	public String getMethodname() {
		return methodname;
	}

	public void setMethodname(String methodname) {
		this.methodname = methodname;
	}

	public void exec(CtMethod c) {
            
        }
}