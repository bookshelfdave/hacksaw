package com.quadcs.hacksaw.tests;

import com.quadcs.hacksaw.ClassMatcher;
import com.quadcs.hacksaw.ClassModification;
import com.quadcs.hacksaw.Hacksaw;
import com.quadcs.hacksaw.actions.AddLineBeforeMethod;

public class Test {

    /**
     * @param args
     */
    public static void main(String[] args) {
        ClassMatcher cm = new ClassMatcher() {

            public boolean matchClass(String classname) {
                if (classname.equals("com.quadcs.hacksaw.tests.Foo")) {
                    return true;
                } else {
                    return false;
                }
            }
        };

        ClassModification mod = new ClassModification(cm);
        mod.getMethodActions().add(
                new AddLineBeforeMethod("getX", "()Ljava/lang/String;", "System.out.println(1000);"));
        Hacksaw.registerMod(mod);
        com.quadcs.hacksaw.tests.Foo f = new com.quadcs.hacksaw.tests.Foo();
        System.out.println(f.getX());
    }
}
// public void hackIt(CtClass klass) {
//	try {												
//		CtMethod[] ms = klass.getMethods();
//		CtMethod x = klass.getMethod("getX", "()Ljava/lang/String;");
//		x.insertBefore("System.out.println(100);");						
//		for(CtMethod m: ms) {						
//			if(m.getName().equals("getX")) {
//				m.insertBefore("System.out.println(1);");
//				System.out.println(m.getMethodInfo().getDescriptor());
//			}
//		}
//	} catch (Exception e) {
//		e.printStackTrace();
//	}
//}