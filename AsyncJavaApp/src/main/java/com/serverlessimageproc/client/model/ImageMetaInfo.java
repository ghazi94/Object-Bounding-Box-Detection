package com.serverlessimageproc.client.model;
import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.File;

/**
 * Created by UserName on 5/2/17
 * Used to store Image Properties
 */
@JsonAutoDetect(fieldVisibility = JsonAutoDetect.Visibility.ANY)
@JsonIgnoreProperties(ignoreUnknown = true)
public class ImageMetaInfo {
    // Public URL specific porperties
    private String sourceUrl;

    // S3 specific properties
    private String s3key;
    private String sourceS3bucket;
    private String destinationS3bucket;

    // Image is an actual file
    private File imageFile;

    // Common Attribute
    private ResourceType resourceType;

    public ImageMetaInfo() {

    }

    public ImageMetaInfo(String bucketName, String key) {
        this.sourceS3bucket = bucketName;
        this.s3key = key;
    }

    public String getS3key() {
        return s3key;
    }

    public void setS3key(String s3key) {
        this.s3key = s3key;
    }

    public String getSourceS3bucket() {
        return sourceS3bucket;
    }

    public void setSourceS3bucket(String sourceS3bucket) {
        this.sourceS3bucket = sourceS3bucket;
    }

    public String getSourceUrl() {
        return sourceUrl;
    }

    public void setSourceUrl(String sourceUrl) {
        this.sourceUrl = sourceUrl;
    }

    public String getDestinationS3bucket() {
        return destinationS3bucket;
    }

    public void setDestinationS3bucket(String destinationS3bucket) {
        this.destinationS3bucket = destinationS3bucket;
    }

    public File getImageFile() {
        return imageFile;
    }

    public void setImageFile(File imageFile) {
        this.imageFile = imageFile;
    }

    public static enum ResourceType {
        S3_RESOURCE,
        PUBLIC_URL,
        FILE
    }
}
