package com.serverlessimageproc.client.utils;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.*;

import java.io.*;
import java.util.Random;

/**
 * Amazon S3 Utils
 * Created by UserName on 14/10/16.
 */
public class AmazonS3Utils {
    private AmazonS3Client s3Client;

    public AmazonS3Utils(String accessKey, String secretKey) {
        s3Client = new AmazonS3Client(new BasicAWSCredentials(accessKey, secretKey));
    }

    public String download(String bucket, String key, String extension) {
        Random rand = new Random();
        Long n = Math.abs(rand.nextLong());
        String tempFile = "/tmp/" + n + "." + extension;
        downloadTo(bucket, key, tempFile);
        return tempFile;
    }

    public File downloadTo(String bucket, String key, String saveDestination) {
        File destinationFile = null;
        try {
            S3Object s3Object = s3Client.getObject(new GetObjectRequest(bucket, key));
            InputStream inputStream = s3Object.getObjectContent();
            destinationFile = new File(saveDestination);
            if (!destinationFile.exists()) {
                destinationFile.createNewFile();
            }
            OutputStream outputStream = new FileOutputStream(destinationFile);
            int read;
            byte[] bytes = new byte[1024];
            while ((read = inputStream.read(bytes)) != -1) {
                outputStream.write(bytes, 0, read);
            }
        } catch (AmazonServiceException ase) {
            System.out.println("Error while downloading images, error: {}" + ase.getMessage());

        } catch (Exception e) {
            System.out.println("Error in downloading image, error: {}" + e.getMessage());
        }
        return destinationFile;
    }

    public boolean uploadFile(String bucket, String key, File file) {
        try {
            s3Client.putObject(new PutObjectRequest(bucket, key, file));
            return true;
        } catch (AmazonServiceException ase) {
            System.out.println("Error while uploading file, error: {}" + ase.getMessage());
        } catch (Exception e) {
            System.out.println("Error in uploading file");
        }
        return false;
    }
}