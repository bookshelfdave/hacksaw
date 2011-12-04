/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.quadcs.hacksaw;

import javassist.CtClass;

/**
 *
 * @author dparfitt
 */
public interface ClassMatcher {
    public boolean match(CtClass c);
}
