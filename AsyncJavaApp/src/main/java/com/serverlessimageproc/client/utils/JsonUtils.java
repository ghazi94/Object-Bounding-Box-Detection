package com.serverlessimageproc.client.utils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.*;
import com.serverlessimageproc.client.model.ImageMetaInfo;

import java.io.IOException;

/**
 * JSON Utils
 * <p>
 * Created by UserName on 2/11/15.
 */
public class JsonUtils {

    private static Gson gson = new Gson();
    private static ObjectMapper objectMapper = new ObjectMapper();

    public static ImageMetaInfo getImageMetaInfoFromS3Notification(String message) {
        JsonElement jsonElement = new JsonParser().parse(message);
        String records = jsonElement.getAsJsonObject().get("Message").getAsString();
        jsonElement = new JsonParser().parse(records);
        JsonArray attributes = jsonElement.getAsJsonObject().get("Records").getAsJsonArray();
        JsonObject record = attributes.get(0).getAsJsonObject();
        JsonObject s3 = record.get("s3").getAsJsonObject();
        String bucket = s3.get("bucket").getAsJsonObject().get("name").getAsString();
        String key = s3.get("object").getAsJsonObject().get("key").getAsString();
        return new ImageMetaInfo(bucket, key);
    }

    public static String convertObjectToJson(Object object) {
        return gson.toJson(object);
    }

    public static Object clone(Object object, Class T) {
        String objectString = convertObjectToJson(object);
        try {
            return objectMapper.readValue(objectString, T);
        } catch (IOException e) {
            return null;
        }
    }
}
