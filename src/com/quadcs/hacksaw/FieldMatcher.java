/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.quadcs.hacksaw;

import javassist.CtField;

/**
 *
 * @author dparfitt
 */
public interface FieldMatcher {
    public boolean match(CtField field);
}
