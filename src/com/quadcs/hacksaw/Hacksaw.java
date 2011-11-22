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
package com.quadcs.hacksaw;

import java.io.ByteArrayInputStream;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;
import java.util.HashSet;
import java.util.Set;

import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtMethod;

public class Hacksaw implements ClassFileTransformer {

    private static Set<ClassModification> listeners = new HashSet<ClassModification>();
    public static boolean DEBUG = false;

    public static void registerMod(ClassModification cl) {
        if (DEBUG) {
            System.out.println("Registering Hacksaw Listener:" + cl.getClass().getName());
        }
        listeners.add(cl);
    }

    public byte[] transform(ClassLoader loader, String className,
            Class<?> classBeingRedefined, ProtectionDomain protectionDomain,
            byte[] classfileBuffer) throws IllegalClassFormatException {
        if (DEBUG) {
            System.out.println("Hacksaw:" + className);
        }
        String theClass = className.replace("/", ".");
        for (ClassModification l : listeners) {
            if (l.getClassMatcher().matchClass(theClass)) {
                try {
                    ClassPool cp = ClassPool.getDefault();
                    CtClass klass = cp.makeClass(new ByteArrayInputStream(classfileBuffer));
                    for (ClassAction ca : l.getClassActions()) {
                        ca.exec(klass);
                    }
                    for (MethodAction ma : l.getMethodActions()) {
                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
                        ma.exec(m);
                    }

                    byte[] b = klass.toBytecode();
                    klass.detach();
                    return b;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return classfileBuffer;
    }
}
