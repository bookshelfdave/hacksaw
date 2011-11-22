package com.quadcs.hacksaw.actions;

import javassist.CannotCompileException;
import javassist.CtMethod;

import com.quadcs.hacksaw.MethodAction;

public class AddLineBeforeMethod extends MethodAction {
	private String line;
	public AddLineBeforeMethod(String methodname, String sig, String line) {
		super(methodname, sig);
		this.line = line;
	}

	@Override
	public void exec(CtMethod c) {
		try {
			c.insertBefore(line);
		} catch (CannotCompileException e) {
			e.printStackTrace();
		}
	}
	
}
