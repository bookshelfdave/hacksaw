/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.quadcs.hacksaw;

import javassist.CtMethod;

/**
 *
 * @author dparfitt
 */
public interface MethodMatcher {
    public boolean match(CtMethod m);
}
