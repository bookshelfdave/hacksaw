package com.quadcs.hacksaw;

import java.util.ArrayList;
import java.util.List;

public class ClassModification {
	private ClassMatcher classMatcher;
	public ClassModification(ClassMatcher cm) {
		this.classMatcher = cm;
	}
	private List<ClassAction> classActions = new ArrayList<ClassAction>();
	private List<MethodAction> methodActions = new ArrayList<MethodAction>();
	public List<ClassAction> getClassActions() {
		return classActions;
	}
	public List<MethodAction> getMethodActions() {
		return methodActions;
	}
	public ClassMatcher getClassMatcher() {
		return classMatcher;
	}
	
}
