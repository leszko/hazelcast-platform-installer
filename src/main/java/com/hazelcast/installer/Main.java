package com.hazelcast.installer;

import com.ibm.lex.lapapp.LAP;
import net.lingala.zip4j.ZipFile;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;

public class Main {

    private static final int STATUS_CODE_LICENSE_ACCEPTED = 9;

    public static void main(String[] args) throws Exception {
        extractEula();
        acceptEula();
        extractHazelcastPlatform();
    }


    private static void extractEula() throws IOException {
        extractFile("eula-licenses.zip", "eula-licenses");
    }

    private static void acceptEula() throws URISyntaxException {
        LAP lap = new LAP(new String[] {"-text_only", "-l", "eula-licenses", "-s", "license-output"});
        if (lap.getStatus() != STATUS_CODE_LICENSE_ACCEPTED) {
            System.out.println("You must accept the license to proceed with the Hazelcast Platform installation");
            System.exit(1);
        }
    }

    private static void extractHazelcastPlatform() throws IOException {
        System.out.println("Extracting Hazelcast Platform installation files, it may take a few minutes...");

        extractFile("hazelcast-platform.zip", ".");

        System.out.println();
        System.out.println("Please check INSTALL_GUIDE.md for the installation instructions");
    }

    private static void extractFile(String zipFilename, String destinationPath) throws IOException {
        copyFile(zipFilename, zipFilename);
        ZipFile zipFile = new ZipFile(zipFilename);
        zipFile.extractAll(destinationPath);
        new File(zipFilename).delete();
    }

    private static void copyFile(String source, String destination) throws IOException {
        URL inputUrl = Main.class.getResource(String.format("/%s", source));
        File destinationFile = new File(destination);
        FileUtils.copyURLToFile(inputUrl, destinationFile);
    }

}
