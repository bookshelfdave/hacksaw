package com.quadcs.hacksaw.tests;

public class Foo {

    private String x = "Foo!";

    private int doSomething(int a, int b) {
        if(a > 1) {
            return a + b * -1;
        } else {
            return a + b;
        }
        
    }

    public String getX() {
        return x;
    }

    public String foo() {
        int s = doSomething(4,5);
        return "Foo:" + s + x;
    }

    public String bar() {
        int s = doSomething(1,2);
        return "Bar:" + s + x;
    }

}
