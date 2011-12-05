/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.quadcs.hacksaw.tests;

/**
 *
 * @author dparfitt
 */
public class BarExt extends Bar{
    public int foo = 100;
    public static void main(String args[]) {
        System.out.println(new BarExt().foo
                );
    }
}
