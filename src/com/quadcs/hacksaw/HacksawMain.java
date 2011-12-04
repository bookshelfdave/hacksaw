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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javassist.ClassPool;
import javassist.CtClass;
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
                    // load all methods
//                    DescriptorSet methodDescriptors = new DescriptorSet();
//                    DescriptorSet fieldDescriptors = new DescriptorSet();
//                    DescriptorSet ctorDescriptors = new DescriptorSet();
//
//                    
//                    loadMethodDescriptors(klass.getDeclaredMethods(), methodDescriptors);
//                    loadMethodDescriptors(klass.getMethods(), methodDescriptors);

                    //loadFields(klass.getDeclaredFields(),fieldDescriptors);
                    //loadFields(klass.getFields(),fieldDescriptors);
                    
                    processClass(l, klass);
                    processMethods(l, klass);
                    //processFields(klass, l);
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

   

//    // TODO: do I need return types?
//    private void loadMethodDescriptors(CtMethod[] methods, DescriptorSet methodDescriptors) {
//        debug("\tLoading method descriptors");
//        for (CtMethod method : methods) {
//            if (!methodDescriptors.containsKey(method.getName())) {
//                methodDescriptors.put(method.getName(), new HashSet<String>());
//                debug("\tAdding " + method.getName());
//            }
//            
//            Set<String> descriptorSet = methodDescriptors.get(method.getName());
//            
//            String desc = method.getMethodInfo().getDescriptor();
//            if(!descriptorSet.contains(desc)) {
//                debug("\tAdding " + method.getName() + "->" + desc);
//                descriptorSet.add(desc);
//            }
//            
//        }
//    }
   
//    private void loadFields(CtField[] fields, DescriptorSet fieldDescriptors) {
//        debug("\tLoading field descriptors");
//        for (CtField field : fields) {
//            if (!fieldDescriptors.containsKey(field.getName())) {
//                fieldDescriptors.put(field.getName(), new HashSet<String>());
//                debug("\tAdding " + field.getName());
//            }
//            Set<String> descriptorSet = fieldDescriptors.get(field.getName());
//            String desc = field.getFieldInfo().getDescriptor();
//            if(!descriptorSet.contains(desc)) {
//                debug("\tAdding " + field.getName() + "->" + desc);
//                descriptorSet.add(desc);
//            }
//        }
//    }
    
    private void processClass(ClassModification l, CtClass klass) {
        for (ClassAction ca : l.getClassActions()) {
            ca.exec(klass);
        }
    }

    private void processMethods(ClassModification l,  CtClass klass) throws NotFoundException {
        List<CtMethod> allMethods = new ArrayList<CtMethod>();
        
        // TODO: I'm sure there is an easier way to do this
        for(CtMethod m: klass.getDeclaredMethods()) {
            allMethods.add(m);
        }
        for(CtMethod m: klass.getMethods()) {
            allMethods.add(m);
        }
        
        for(CtMethod method: allMethods) {
           for(MethodModification mm: l.getMethodModifications()) {
               debug("Matching method:" + method.getName() + method.getMethodInfo().getDescriptor());
               if(mm.getMethodMatcher().match(method)) {
                 
                   for(MethodAction action: mm.getMethodActions()) {
                       action.exec(method);
                   }
               }
           } 
        }       
    }
    
//    // holy crap I need to unit test this!
//    private void processMethods(ClassModification l, Map<String, Set<String>> methodDescriptors, CtClass klass) throws NotFoundException {
//        for (MethodAction ma : l) {
//            // make sure the method exists
//            if (methodDescriptors.containsKey(ma.getMethodname())) {
//                if (methodDescriptors.get(ma.getMethodname()).size() > 1) {
//                // there is more than one descriptor for this method
//                    if (ma.getSig() != null && !ma.getSig().equals("")) {
//                        // but an exact descriptor has been declared
//                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
//                        ma.exec(m);
//                    } else {
//                        // descriptor not declared by user, use them all
//                        for (String desc : methodDescriptors.get(ma.getMethodname())) {
//                            CtMethod m = klass.getMethod(ma.getMethodname(), desc);
//                            ma.exec(m);
//                        }
//                    }
//                } else {
//                    if (ma.getSig() != null && !ma.getSig().equals("")) {
//                        // use an exact descriptor
//                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
//                        ma.exec(m);
//                    } else {
//                        // use the first available desciptor
//                        // this is crappy code and needs to be refactored
//                        String desc = methodDescriptors.get(ma.getMethodname()).iterator().next();
//                        CtMethod m = klass.getMethod(ma.getMethodname(), desc);
//                        ma.exec(m);
//                    }
//                }
//            } else {
//                System.err.println("Hacksaw: Method not found:" + ma.getMethodname() + " -> " + ma.getSig());
//                continue;
//            }
//        }
//    }
    
    
    /*
     private void processFields(ClassModification l, Map<String, Set<String>> fieldDescriptors) throws NotFoundException {
         for (FieldModification fa : l.getFieldModifications()) {
            // make sure the method exists
            if (fieldDescriptors.containsKey(ma.getMethodname())) {
                if (fieldDescriptors.get(ma.getMethodname()).size() > 1) {
                // there is more than one descriptor for this method
                    if (ma.getSig() != null && !ma.getSig().equals("")) {
                        // but an exact descriptor has been declared
                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
                        ma.exec(m);
                    } else {
                        // descriptor not declared by user, use them all
                        for (String desc : methodDescriptors.get(ma.getMethodname())) {
                            CtMethod m = klass.getMethod(ma.getMethodname(), desc);
                            ma.exec(m);
                        }
                    }
                } else {
                    if (ma.getSig() != null && !ma.getSig().equals("")) {
                        // use an exact descriptor
                        CtMethod m = klass.getMethod(ma.getMethodname(), ma.getSig());
                        ma.exec(m);
                    } else {
                        // use the first available desciptor
                        // this is crappy code and needs to be refactored
                        String desc = methodDescriptors.get(ma.getMethodname()).iterator().next();
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
     * 
     */
    
    public static void debug(String message) {
        if(HacksawMain.DEBUG) {
            System.out.println(message);
        }
    }
}
