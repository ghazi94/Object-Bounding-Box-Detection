package com.serverlessimageproc.client;

import com.amazon.sqs.javamessaging.SQSConnection;
import com.amazon.sqs.javamessaging.SQSConnectionFactory;
import com.amazon.sqs.javamessaging.SQSSession;

import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;

import com.serverlessimageproc.client.listener.YourImageProcessingListener;
import com.serverlessimageproc.client.parser.ImageProcessorParser;
import com.serverlessimageproc.client.utils.AmazonS3Utils;


import javax.jms.MessageConsumer;
import javax.jms.Session;

/**
 * Created by UserName on 10/2/17.
 */
public class LocalDryRun {
    public static String AWS_ACCESS_KEY = "YOUR_KEY_1";
    public static String AWS_ACCESS_SECRET_KEY = "YOUR_KEY_2";

    public static void main(String[] args) {
        try {
            SQSConnectionFactory connectionFactory = SQSConnectionFactory.builder()
                    .withRegion(Region.getRegion(Regions.AP_SOUTHEAST_1))
                    .build();
            SQSConnection connection = connectionFactory.createConnection(AWS_ACCESS_KEY,
                    AWS_ACCESS_SECRET_KEY);
            Session sqsSession = connection.createSession(false, SQSSession.CLIENT_ACKNOWLEDGE);
            MessageConsumer yourImageProcessingConsumer = sqsSession.createConsumer(sqsSession.createQueue(
                    YourImageProcessingListener.QUEUE_NAME));
            ImageProcessorParser imageProcessorParser = new ImageProcessorParser(new AmazonS3Utils(AWS_ACCESS_KEY,
                    AWS_ACCESS_SECRET_KEY));
            yourImageProcessingConsumer.setMessageListener(new YourImageProcessingListener(imageProcessorParser));
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}
