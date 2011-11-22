package com.quadcs.hacksaw.tests;

public class Foo {
	private String x = "Foo!";
	
	private void doSomething() {
		System.out.println("This is a test!");
	}
	public String getX() {
		return x;
	}
	
	public String foo() {
		doSomething();
		return "Hi!";
	}
	
}
