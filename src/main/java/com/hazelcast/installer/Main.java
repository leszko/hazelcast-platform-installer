package com.hazelcast.installer;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws Exception {
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
