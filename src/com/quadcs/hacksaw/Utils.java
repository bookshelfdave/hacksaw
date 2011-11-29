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

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import javassist.ClassPool;
import javassist.CtClass;
import javassist.bytecode.Descriptor;

public class Utils {

    public static byte[] getFileBytes(File f) throws Exception {
        FileInputStream fis = new FileInputStream(f);
        // unsafe cast to int :-(
        byte[] bytes = new byte[(int) f.length()];

        int offset = 0;
        int bytesRead = 0;
        while (offset < bytes.length
                && (bytesRead = fis.read(bytes, offset, bytes.length - offset)) >= 0) {
            offset += bytesRead;
        }

        if (offset < bytes.length) {
            throw new Exception("Error reading file " + f.getName());
        }

        fis.close();
        return bytes;
    }

    public static String makeDesc(String returnType, String[] params) throws Exception {
        ClassPool cp = ClassPool.getDefault();
        
        List<CtClass> paramClasses = new ArrayList<CtClass>();
        for(String p: params) {
            CtClass klass;
            try{
               klass = cp.getCtClass(p);
            } catch (Exception e) {
                throw new Exception("Can't create descriptor: invalid paramter:" + p,e);
            }
            paramClasses.add(klass);
        }
        CtClass[] paramArray = new CtClass[paramClasses.size()];
        paramArray = paramClasses.toArray(paramArray);        
        CtClass returnClass;
        
        try{
           returnClass = cp.getCtClass(returnType);
        } catch (Exception e) {
            throw new Exception("Can't create descriptor: invalid return type:" + returnType,e);
        }

        

        return Descriptor.ofMethod(returnClass,paramArray);
    }
    
}
