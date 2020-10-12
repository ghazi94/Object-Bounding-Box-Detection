package com.serverlessimageproc.client.parser;

import com.serverlessimageproc.client.model.ImageMetaInfo;
import com.serverlessimageproc.client.utils.AmazonS3Utils;
import com.serverlessimageproc.client.utils.ZefoUtils;

import javax.ws.rs.core.Response;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Created by UserName on 03-02-2017
 */
public class ImageProcessorParser {
    // Pseudo Constants
    private String ASPECT_WIDTH = "4";
    private String ASPECT_HEIGHT = "3";
    private int WAIT_TIME = 20;
    private int PROCESSED_FILE_POLL_INTERVAL = 1;

    private AmazonS3Utils amazonS3Utils;

    // File IO Directories
    private String workDirectory;
    private String rawImages;
    private String mediumResizedImages;
    private String pollingFile;
    private String resultImagesDirectory;

    // Threadpool executor
    private ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors.newFixedThreadPool(4);

    public ImageProcessorParser(AmazonS3Utils amazonS3Utils) {
        this.amazonS3Utils = amazonS3Utils;
        this.workDirectory = "/media/disk2" + "/MATRUN";
        this.rawImages = workDirectory + "/IncomingImages" + "/Raw";
        this.mediumResizedImages = workDirectory + "/IncomingImages" + "/MediumResized";
        this.pollingFile = "/media/disk2" + "/MATRUN" + "/Poll.txt";
        this.resultImagesDirectory = "/media/disk2" + "/MATRUN" + "/Result";
    }

    // This API always returns an ok response, because of the asynchronous nature of the api
    // All the faulty processing logs will be written in future to a log file
    public Response processImageUrl(ImageMetaInfo imageInfo, Boolean inSync) {
        Boolean failed = true;
        if (inSync == null) {
            inSync = false;
        }
        // Image Processing is designed to be extremely safe
        try {
            ImageProcessor imageProcessorRunnable = new ImageProcessor(imageInfo);
            Future imageProcessingResult = executor.submit(imageProcessorRunnable);
            if (inSync && (Integer) imageProcessingResult.get() == 1) {
                failed = false;
            } else if (!inSync) {
                return Response.accepted().build();
            }
        } catch (Exception e) {
            // Do nothing
        }
        if (!failed) {
            return Response.ok().build();
        } else {
            return Response.serverError().build();
        }
    }

    public class ImageProcessor implements Callable {
        private ImageMetaInfo imageMetaInfo;

        public ImageProcessor(ImageMetaInfo imageMetaInfo) {
            this.imageMetaInfo = imageMetaInfo;
        }

        // Frequently used objects
        FileWriter fileWriter = null;
        BufferedWriter bufferedWriter = null;

        File originalFile = null;
        File mediumResizedFile = null;
        File resultImageFile = null;

        @Override
        public Object call() {
            int exitCode = -1;
            // Summary of exit codes
            // -1   No exceptions or errors but a processed image was not generated within 1 minute
            // -2   Poll.txt/Processed Image IO Exception occured
            // -3   The sleeping/resuming thread which polls Poll.txt was interrupted
            // -4   Original Image File could not be downloaded
            // 1    Successful!
            if (!ZefoUtils.emptyString(imageMetaInfo.getSourceS3bucket())
                    && !ZefoUtils.emptyString(imageMetaInfo.getS3key())
                    && !ZefoUtils.emptyString(imageMetaInfo.getDestinationS3bucket())) {
                try {
                    // Based on how S3 stores the keys of the files
                    String fileName = imageMetaInfo.getS3key().substring(
                            imageMetaInfo.getS3key().lastIndexOf("/") + 1);
                    // Log file being watched by MATLAB
                    File logFile = new File(workDirectory + "/Poll.txt");
                    // If file doesn't exist, then create it
                    if (!logFile.exists()) {
                        logFile.createNewFile();
                    }

                    // Download the file first
                    originalFile = amazonS3Utils.downloadTo(
                            imageMetaInfo.getSourceS3bucket(), imageMetaInfo.getS3key(),
                            rawImages + "/" + fileName);

                    // Use imageMagick to create a 50% resized image
                    String resizeCommand = "convert -resize 50% " + rawImages + "/"
                            + fileName + " " + mediumResizedImages +
                            "/" + fileName;
                    Runtime.getRuntime().exec(resizeCommand).waitFor();

                    mediumResizedFile = new File(mediumResizedImages + "/" + fileName);

                    // Now write this to log file. Matlab will take care of the rest
                    String logString = System.getProperty("line.separator") +
                            // Adding a new line is required for MATLAB to poll correctly
                            rawImages + "/" + fileName + "," +
                            mediumResizedImages + "/" + fileName + "," +
                            resultImagesDirectory + "/" + fileName + "," +
                            ASPECT_WIDTH + "," + ASPECT_HEIGHT + System.getProperty("line.separator");

                    // Append the image file details to the polling file of MATLAB
                    fileWriter = new FileWriter(logFile.getAbsoluteFile(), true);
                    bufferedWriter = new BufferedWriter(fileWriter);
                    bufferedWriter.write(logString);
                    bufferedWriter.close();
                    fileWriter.close();
                    bufferedWriter = null;
                    fileWriter = null;

                    // Now wait for maximum 30 seconds to check if a processed file has been created by MATLAB
                    int count = WAIT_TIME / PROCESSED_FILE_POLL_INTERVAL;
                    while (count > 0) {
                        resultImageFile = new File(resultImagesDirectory + "/" + fileName);
                        if (resultImageFile.exists() && !resultImageFile.isDirectory()) {
                            // Upload the file to S3
                            Boolean uploadCheck = amazonS3Utils.uploadFile(imageMetaInfo.getDestinationS3bucket(),
                                    imageMetaInfo.getS3key().replace("RAW", "EDITED"), resultImageFile);
                            if (uploadCheck != null && uploadCheck) {
                                exitCode = 1;
                            }
                            break;
                        }
                        Thread.sleep(PROCESSED_FILE_POLL_INTERVAL * 1000);
                        count--;
                    }
                } catch (IOException ioException) {
                    // Do nothing
                    exitCode = -2;
                    System.out.println("ImageProcessing: IO Exception Occured");
                } catch (InterruptedException iterruptException) {
                    // Do nothing
                    exitCode = -3;
                    System.out.println("ImageProcessing: Thread sleep was interrupted");
                } finally {
                    // Close all opened resources and delete downloaded files
                    if (originalFile == null) {
                        System.out.println("ImageProcessing: Error while downloading image");
                        exitCode = -4;
                    }
                    try {
                        if (bufferedWriter != null) {
                            bufferedWriter.close();
                        }
                        if (fileWriter != null) {
                            fileWriter.close();
                        }
                        if (originalFile.exists()) {
                            originalFile.delete();
                        }
                        if (mediumResizedFile.exists()) {
                            mediumResizedFile.delete();
                        }
                        if (resultImageFile.exists()) {
                            resultImageFile.delete();
                        }
                    } catch (Exception innerException) {
                        // Do nothing
                    }
                }
            }
            return exitCode;
        }
    }
}
