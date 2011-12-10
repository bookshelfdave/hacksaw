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


package com.quadcs.hacksaw.demo;

import org.junit.Test;
import static org.junit.Assert.*;

public final class DemoAccount {
    private String accountNumber;
    private String pattern = "\\d\\d\\d\\d";
    float balance = 0.0f;
    
    public DemoAccount(String acct) {
        this.accountNumber = acct;
    }
    
    public boolean isValidAccount() {        
        if(accountNumber == null || accountNumber.isEmpty()) {
            return false;
        } else {           
            return accountNumber.matches(pattern);
        }
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    @Test
    public void testAccounts() throws Exception {
        assertTrue(new DemoAccount("1234").isValidAccount());
        assertFalse(new DemoAccount("123").isValidAccount());
        assertFalse(new DemoAccount("12345").isValidAccount());
        assertFalse(new DemoAccount("").isValidAccount());
        assertFalse(new DemoAccount(null).isValidAccount());
    }
        
    public float getBalance() {
        return balance;
    }
    
    public void deposit(float v) throws Exception {
        if(v <= 0) {
            throw new Exception("Can't deposit <0 $!");
        }
        balance += v;
    }

    public void withdraw(float v) throws Exception {
        if(v <= 0) {
            throw new Exception("Can't withdraw <0 $!");
        }
        balance += v;
    }

}
