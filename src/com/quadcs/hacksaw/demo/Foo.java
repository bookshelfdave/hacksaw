/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 * Copyright (C) 2011- Dave Parfitt. All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * ***** END LICENSE BLOCK ***** */

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
        return "Foo:" + myString.toUpperCase();
    }
    
}
