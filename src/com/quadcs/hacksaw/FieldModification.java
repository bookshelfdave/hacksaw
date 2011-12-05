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

public class FieldModification {
    private FieldMatcher fieldMatcher;
    private List<FieldAction> fieldActions = new ArrayList<FieldAction>();

    public FieldModification(FieldMatcher fm) {
        this.fieldMatcher = fm;
    }
    
    public FieldMatcher getFieldMatcher() {
        return fieldMatcher;
    }

    public List<FieldAction> getFieldActions() {
        return fieldActions;
    }
}
