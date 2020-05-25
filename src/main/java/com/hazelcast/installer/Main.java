package com.hazelcast.installer;

import com.ibm.lex.lapapp.LAP;
import net.lingala.zip4j.ZipFile;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Main {

    private static final int STATUS_CODE_LICENSE_ACCEPTED = 9;

    public static void main(String[] args) throws Exception {
        extractEula();
        acceptEula();
        extractFiles();
    }

    private static void extractEula() throws IOException {
        String eulaLicensesFile = "eula-licenses.zip";
        copyFile(eulaLicensesFile);
        ZipFile zipFile = new ZipFile(eulaLicensesFile);
        zipFile.extractAll("eula-licenses");
        new File(eulaLicensesFile).delete();
    }

    private static void acceptEula() throws URISyntaxException {
        LAP lap = new LAP(new String[] {"-text_only", "-l", "eula-licenses", "-s", "license-output"});
        if (lap.getStatus() != STATUS_CODE_LICENSE_ACCEPTED) {
            System.out.println("You must accept the license to proceed with the Hazelcast Platform installation");
            System.exit(1);
        }
    }

    private static void extractFiles() throws IOException {
        for (String file : readFilesToCopy()) {
            copyFile(file);
        }
    }

    private static List<String> readFilesToCopy() throws FileNotFoundException {
        List<String> result = new ArrayList<String>();
        Scanner scanner = new Scanner(Main.class.getResourceAsStream("/files-to-copy.txt"));
        while (scanner.hasNextLine()) {
            result.add(scanner.nextLine());
        }
        return result;
    }

    private static void copyFile(String filename) throws IOException {
        System.out.println(String.format("Extracting file %s", filename));
        URL inputUrl = Main.class.getResource(String.format("/%s", filename));
        File destinationFile = new File(filename);
        FileUtils.copyURLToFile(inputUrl, destinationFile);
    }

}
