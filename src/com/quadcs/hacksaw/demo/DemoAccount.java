package com.quadcs.hacksaw.demo;

import org.junit.Test;
import static org.junit.Assert.*;

public final class DemoAccount {
    private String accountNumber;
    private String pattern = "\\d\\d\\d\\d";
    
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
    
}
