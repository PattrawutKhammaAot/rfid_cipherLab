
import java.io.*;
        import java.util.jar.*;
        import java.util.Enumeration;

public class Explorer {
    public static void main(String[] args) {
        try {
            JarFile jarFile = new JarFile("D:/work-mobile/flutteAppJar/flutter_app_jar/android/app/libs/RfidAPI_V1_0_24_api_level31.jar");

            Enumeration<JarEntry> entries = jarFile.entries();

            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                if (entry.getName().endsWith(".class")) {
                    System.out.println(entry.getName());
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}