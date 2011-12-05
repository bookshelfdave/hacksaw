package com.quadcs.hacksaw.tests;

import com.quadcs.hacksaw.demo.DemoAccount;
import org.junit.Test;
import static org.junit.Assert.*;

public class DemoTest {
    
    public DemoTest() {
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
