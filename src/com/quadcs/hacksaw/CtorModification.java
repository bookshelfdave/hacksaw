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
 */
package com.quadcs.hacksaw;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author dparfitt
 */
public class CtorModification {
    private CtorMatcher ctorMatcher;
    private List<CtorAction> ctorActions = new ArrayList<CtorAction>();

    public CtorModification(CtorMatcher fm) {
        this.ctorMatcher = fm;
    }
    
    public CtorMatcher getCtorMatcher() {
        return ctorMatcher;
    }

    public List<CtorAction> getCtorActions() {
        return ctorActions;
    }
}
