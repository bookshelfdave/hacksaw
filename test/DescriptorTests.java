
import org.junit.Test;
import com.quadcs.hacksaw.Utils;

import static org.junit.Assert.*;

public class DescriptorTests {
    
    public DescriptorTests() {
    }

   
    @Test
    public void testSimple() throws Exception {
        String[] params = {"java.lang.String"};
        String desc = Utils.makeDesc("java.lang.String",params);
        assertEquals("(Ljava/lang/String;)Ljava/lang/String;", desc);
    }
    
    @Test
    public void testDescWithVoidParams() throws Exception {
        String[] params = {};
        String desc = Utils.makeDesc("java.lang.String",params);
        System.out.println(desc);
        assertEquals("()Ljava/lang/String;", desc);
    }
    
    @Test
    public void testDescWithVoidReturn() throws Exception {
        String[] params = {};
        String desc = Utils.makeDesc("void",params);
        System.out.println(desc);
        assertEquals("()V", desc);
    }
    
     @Test
    public void testDescWithArrayReturn() throws Exception {
        String[] params = {};
        String desc = Utils.makeDesc("java.lang.String[]",params);
        System.out.println(desc);
        assertEquals("()[Ljava/lang/String;", desc);
    }
     
    @Test
    public void testDescWithArrayParam() throws Exception {
        String[] params = {"int[]"};
        String desc = Utils.makeDesc("java.lang.String[]",params);
        System.out.println(desc);
        assertEquals("([I)[Ljava/lang/String;", desc);
    }
    
   
}
