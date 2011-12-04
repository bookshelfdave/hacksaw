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

    private ClassMatcher classMatcher;
    // would these lists make more sense as maps...
    // or do they allow the user to add more than 1 mod for eatch type of action?
    private List<ClassAction> classActions = new ArrayList<ClassAction>();
    private List<MethodAction> methodActions = new ArrayList<MethodAction>();
    private List<FieldModification> fieldModifications = new ArrayList<FieldModification>();

    public ClassModification(ClassMatcher cm) {
        this.classMatcher = cm;
    }

    public List<ClassAction> getClassActions() {
        return classActions;
    }

    public List<MethodAction> getMethodActions() {
        return methodActions;
    }

    public ClassMatcher getClassMatcher() {
        return classMatcher;
    }

    public List<FieldModification> getFieldModifications() {
        return fieldModifications;
    }
}
