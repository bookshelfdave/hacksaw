/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.quadcs.hacksaw.tests;

import java.io.ByteArrayInputStream;
import javassist.ClassPool;
import javassist.CtClass;
import javassist.bytecode.Descriptor;


/**
 *
 * @author dparfitt
 */
public class DecTests {
    public static void main(String args[]) throws Exception {
        ClassPool cp = ClassPool.getDefault();
        
        CtClass klass = cp.getCtClass("java.lang.String");
        
        CtClass[] foo = {klass};
        System.out.println(Descriptor.ofMethod(CtClass.intType, foo).toString());
        
    }
}
