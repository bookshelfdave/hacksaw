package com.quadcs.hacksaw;

import javassist.CannotCompileException;
import javassist.expr.Cast;
import javassist.expr.ConstructorCall;
import javassist.expr.ExprEditor;
import javassist.expr.FieldAccess;
import javassist.expr.Handler;
import javassist.expr.Instanceof;
import javassist.expr.MethodCall;
import javassist.expr.NewArray;
import javassist.expr.NewExpr;


public abstract class FlatExprEditor extends ExprEditor {
    
    public void edit_newexpr(NewExpr e) throws CannotCompileException {    
    }
       
    public void edit_newarray(NewArray a) throws CannotCompileException {    
    }

    public void edit_methodcall(MethodCall m) throws CannotCompileException {        
       
    }

    public void edit_constructorcall(ConstructorCall c) throws CannotCompileException {        
    }

    public void edit_fieldaccess(FieldAccess f) throws CannotCompileException {        
    }

    public void edit_instanceof(Instanceof i) throws CannotCompileException {        
    }

    public void edit_cast(Cast c) throws CannotCompileException {        
    }
    
    public void edit_handler(Handler h) throws CannotCompileException {        
    }
       
    @Override
    public void edit(NewExpr e) throws CannotCompileException {
        edit_newexpr(e);        
    }

    @Override
    public void edit(NewArray a) throws CannotCompileException {
        edit_newarray(a);        
    }

    @Override
    public void edit(MethodCall m) throws CannotCompileException {
        edit_methodcall(m);  
    }

    @Override
    public void edit(ConstructorCall c) throws CannotCompileException {
        edit_constructorcall(c);
    }

    @Override
    public void edit(FieldAccess f) throws CannotCompileException {
        edit_fieldaccess(f);
    }

    @Override
    public void edit(Instanceof i) throws CannotCompileException {
        edit_instanceof(i);
    }

    @Override
    public void edit(Cast c) throws CannotCompileException {
        edit_cast(c);
    }

    @Override
    public void edit(Handler h) throws CannotCompileException {
        edit_handler(h);
    }
    
}
