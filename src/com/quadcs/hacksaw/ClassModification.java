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

import java.util.ArrayList;
import java.util.List;

public class ClassModification {

    private int stepId = 0;
    
    private ClassMatcher classMatcher;
    
    
    private List<Object> allActions = new ArrayList<Object>();
    private List<ClassAction> classActions = new ArrayList<ClassAction>();
//    private List<MethodModification> methodModifications = new ArrayList<MethodModification>();
//    private List<FieldModification> fieldModifications = new ArrayList<FieldModification>();
//    private List<CtorModification> ctorModifications = new ArrayList<CtorModification>();
//    
    public ClassMatcher getClassMatcher() {
        return classMatcher;
    }
     
    public ClassModification(ClassMatcher cm) {
        this.classMatcher = cm;
    }

    public List<ClassAction> getClassActions() {
        return classActions;
    }
    
    public List<Object> getAllModifications() {
        return allActions;
    }
    
    public void addClassAction(ClassAction ca) {
        allActions.add(ca);
    }
    
    public void addMethodModification(MethodModification mm) {
        allActions.add(mm);
    }
    
    public void addFieldModification(FieldModification fm) {
        allActions.add(fm);
    }
    
    public void addCtorModification(CtorModification cm) {
        allActions.add(cm);
    }
    
//    
//    public List<MethodModification> getMethodModifications() {
//        return methodModifications;
//    }
//
//    public List<FieldModification> getFieldModifications() {
//        return fieldModifications;
//    }
//
//    public List<CtorModification> getCtorModifications() {
//        return ctorModifications;
//    }
//    
    
}
