package com.quadcs.hacksaw.demo;

public class Foo {

    private String myString = "Foo!";

    private int doSomething(int a, int b) {
        if(a > 1) {
            return a + b * -1;
        } else {
            return a + b;
        }
    }

    public String getX() {
        return myString;
    }

    public String foo() {
        int s = doSomething(4,5);
        return "Foo:" + s + myString;
    }

    
}
