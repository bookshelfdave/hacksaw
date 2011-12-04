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

import java.lang.instrument.Instrumentation;
import java.io.ByteArrayInputStream;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtField;
import javassist.CtMethod;
import javassist.NotFoundException;

public class HacksawMain implements ClassFileTransformer {

    public static final String version = "0.2 \"XYZ\"";
    public static Instrumentation sys;

    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("--------------------------------------------------------------");
        System.out.println("Hacksaw V" + version);
        System.out.println("* Copyright (C) 2011- Dave Parfitt. All Rights Reserved.");
        System.out.println("*	Version: MPL 1.1");
        System.out.println("* 	See License.html for details");
        System.out.println("*	Hacksaw uses the Javassist toolkit:");
        System.out.println("*Javassist, a Java-bytecode translator toolkit.");
        System.out.println("* Copyright (C) 1999- Shigeru Chiba. All Rights Reserved.");
        System.out.println("* 	Version: MPL 1.1");
        System.out.println("* 	See License.html for details");
        System.out.println("");
        System.out.println("--------------------------------------------------------------");
        sys = inst;
        sys.addTransformer(new HacksawMain());
    }
    private static Set<ClassModification> listeners = new HashSet<ClassModification>();
    public static boolean DEBUG = false;

    public static void registerMod(ClassModification cl) {
        if (DEBUG) {
            System.out.println("Registering Hacksaw Listener:" + cl.getClass().getName());
        }
        listeners.add(cl);
    }

    @Override
    public byte[] transform(ClassLoader loader, String className,
            Class<?> classBeingRedefined, ProtectionDomain protectionDomain,
            byte[] classfileBuffer) throws IllegalClassFormatException {

        String theClass = className.replace("/", ".");
        if (DEBUG) {
            System.out.println("Hacksaw:" + theClass);
        }

        for (ClassModification l : listeners) {
            ClassPool cp = ClassPool.getDefault();
            try {
                CtClass klass = cp.makeClass(new ByteArrayInputStream(classfileBuffer));
                if (l.getClassMatcher().matchClass(theClass, klass)) {

//                    ClassPool cp = ClassPool.getDefault();
//                    CtClass klass = cp.makeClass(new ByteArrayInputStream(classfileBuffer));

                    // TODO: Need a set of declared AND non-declared methods
                    CtMethod methods[] = klass.getDeclaredMethods();

                    // load all methods
                    Map<String, List<String>> methodDescriptors = new HashMap<String, List<String>>();
                    loadDescriptors(methods, methodDescriptors);


                    processClass(l, klass);
                    processFields(klass, l);
                    processMethods(l, methodDescriptors, klass);

                    byte[] b = klass.toBytecode();
                    klass.detach();
                    return b;

                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return classfileBuffer;
    }

    private void processFields(CtClass klass, ClassModification l) {
        // TODO: Need a set of declared AND non-declared fields
        for (CtField field : klass.getDeclaredFields()) {
            for (FieldModification fm : l.getFieldModifications()) {
                // TODO: Should I be using equalsIgnoreCase here?               
                if (fm.getFieldMatcher().matchField(field.getName(), field)) {
                    for (FieldAction action : fm.getFieldActions()) {
                        action.exec(field);
                    }
                }
            }
        }
    }

    private void loadDescriptors(CtMethod[] methods, Map<String, List<String>> methodDescriptors) {
        System.out.println("Loading descriptors");
        for (CtMethod method : methods) {
            if (!methodDescriptors.containsKey(method.getName())) {
                methodDescriptors.put(method.getName(), new ArrayList<String>());
                System.out.println("Adding " + method.getName());
            }
            methodDescriptors.get(method.getName()).add(method.getMethodInfo().getDescriptor());
            System.out.println("Adding " + method.getName() + " " + method.getMethodInfo().getDescriptor());
        }
    }

    private void processClass(ClassModification l, CtClass klass) {
        for (ClassAction ca : l.getClassActions()) {
            ca.exec(klass);
        }
    }

    private void processMethods(ClassModification l, Map<String, List<String>> methodDescriptors, CtClass klass) throws NotFoundException {
        for (MethodAction ma : l.getMethodActions()) {
            // make sure the method exists
            if (methodDescriptors.containsKey(ma.getMethodname())) {

                if (methodDescriptors.get(ma.getMethodname()).size() > 1) {

                    if (ma.getSig() != null && !ma.getSig().equals("")) {

                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());

                        ma.exec(m);
                    } else {

                        for (String desc : methodDescriptors.get(ma.getMethodname())) {
                            CtMethod m = klass.getMethod(ma.getMethodname(), desc);
                            ma.exec(m);
                        }
                    }
                } else {

                    if (ma.getSig() != null && !ma.getSig().equals("")) {

                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
                        ma.exec(m);
                    } else {

                        String desc = methodDescriptors.get(ma.getMethodname()).get(0);
                        CtMethod m = klass.getMethod(ma.getMethodname(), desc);
                        ma.exec(m);
                    }
                }
            } else {
                System.err.println("Hacksaw: Method not found:" + ma.getMethodname() + " -> " + ma.getSig());
                continue;
            }
        }
    }
}
