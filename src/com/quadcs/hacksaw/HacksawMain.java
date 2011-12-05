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
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtConstructor;
import javassist.CtField;
import javassist.CtMethod;
import javassist.NotFoundException;

public class HacksawMain implements ClassFileTransformer {

    public static final String version = "0.3 \"Post Zilla\"";
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
        debug("Registering Hacksaw Listener:" + cl.getClass().getName());
        listeners.add(cl);
    }

    @Override
    public byte[] transform(ClassLoader loader, String className,
            Class<?> classBeingRedefined, ProtectionDomain protectionDomain,
            byte[] classfileBuffer) throws IllegalClassFormatException {

        String theClass = className.replace("/", ".");

        debug("Hacksaw checking class:" + theClass);

        for (ClassModification l : listeners) {
            ClassPool cp = ClassPool.getDefault();
            try {
                CtClass klass = cp.makeClass(new ByteArrayInputStream(classfileBuffer));
                if (l.getClassMatcher().match(klass)) {
                    debug("\tLoading class info for " + theClass);
                 
                    for(Object o: l.getAllModifications()) {
                        System.out.println(o.getClass().getName());

                        if(o instanceof MethodModification) {
                            processMethodMod(l, klass, (MethodModification)o);
                        } else if (o instanceof FieldModification) {
                            processFieldMod(l, klass, (FieldModification)o);
                        } else if (o instanceof CtorModification) {
                            processCtorMod(l, klass, (CtorModification)o);
                        } else if (o instanceof ClassAction) {
                            ClassAction ca = (ClassAction)o;
                            ca.exec(klass);
                        }
                    }
                    
//                    processClass(l, klass);
//                    processCtors(l,klass);
//                    processMethods(l, klass);
//                    processFields(l,klass);
//                    // processAnnotations(l,klass);

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
//
//    private void processClass(ClassModification l, CtClass klass) {
//        for (ClassAction ca : l.getClassActions()) {
//            ca.exec(klass);
//        }
//    }

    
    
    private void processCtorMod(ClassModification l, CtClass klass, CtorModification mod) throws NotFoundException {
        Map<String, CtConstructor> allCtors = new HashMap<String, CtConstructor>();

        for (CtConstructor c : klass.getDeclaredConstructors()) {
            allCtors.put(c.getLongName(), c);
        }
        for (CtConstructor c : klass.getConstructors()) {
            allCtors.put(c.getLongName(), c);
        }
       
        for (CtConstructor ctor : allCtors.values()) {
            //for (CtorModification cm : l.getCtorModifications()) {
                debug("Matching method:" + ctor.getName() + ctor.getMethodInfo().getDescriptor());
                if (mod.getCtorMatcher().match(ctor)) {

                    for (CtorAction action : mod.getCtorActions()) {
                        action.exec(ctor);
                    }
                }
            //}
        }
    }

    
    
    
    private void processMethodMod(ClassModification l, CtClass klass, MethodModification mod) throws NotFoundException {
        Map<String, CtMethod> allMethods = new HashMap<String, CtMethod>();

        for (CtMethod m : klass.getDeclaredMethods()) {
            allMethods.put(m.getLongName(), m);
        }
        for (CtMethod m : klass.getMethods()) {
            allMethods.put(m.getLongName(), m);
        }
        for (CtMethod method : allMethods.values()) {
            //for (MethodModification mm : l.getMethodModifications()) {
                debug("Matching method:" + method.getName() + method.getMethodInfo().getDescriptor());
                if (mod.getMethodMatcher().match(method)) {
                    for (MethodAction action : mod.getMethodActions()) {
                        action.exec(method);
                    }
                }
            //}
        }
    }

    private void processFieldMod(ClassModification l, CtClass klass, FieldModification mod) throws NotFoundException {
        Map<String, CtField> allFields = new HashMap<String, CtField>();

        // TODO: look into declared vs regular
        // TODO: what about shadowed fields?
        for (CtField f : klass.getDeclaredFields()) {
            allFields.put(f.getName(), f);
        }

        for (CtField f : klass.getFields()) {
            allFields.put(f.getName(), f);
        }

        for (CtField field : allFields.values()) {
            //for (FieldModification fm : l.getFieldModifications()) {
              
                debug("Matching field:" + field.getName() + field.getFieldInfo().getDescriptor());
                if (mod.getFieldMatcher().match(field)) {
                    for (FieldAction action : mod.getFieldActions()) {
                        action.exec(field);
                    }
                }
            //}
        }
    }

    public static void debug(String message) {
        if (HacksawMain.DEBUG) {
            System.out.println(message);
        }
    }
}
