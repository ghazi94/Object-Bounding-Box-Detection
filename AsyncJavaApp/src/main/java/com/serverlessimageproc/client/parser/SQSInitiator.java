package com.serverlessimageproc.client.parser;

import com.amazon.sqs.javamessaging.SQSConnection;
import com.amazon.sqs.javamessaging.SQSConnectionFactory;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.serverlessimageproc.client.listener.PhotoshootImagesListener;
import com.serverlessimageproc.client.utils.AmazonS3Utils;

import javax.jms.MessageConsumer;
import javax.jms.Session;

/**
 * Created by UserName on 16-02-2017.
 */
public class SQSInitiator {
    public static String AWS_ACCESS_KEY = "YOUR_KEY_1";
    public static String AWS_ACCESS_SECRET_KEY = "YOUR_KEY_2";
    public static String QUEUE_NAME = "image-editing-automation";

    public SQSInitiator() {

    }

    public void start() {
        AWSCredentialsProvider awsCredentialsProvider = new AWSCredentialsProvider() {
            @Override
            public AWSCredentials getCredentials() {
                return new AWSCredentials() {
                    @Override
                    public String getAWSAccessKeyId() {
                        return AWS_ACCESS_KEY;
                    }

                    @Override
                    public String getAWSSecretKey() {
                        return AWS_ACCESS_SECRET_KEY;
                    }
                };
            }

            @Override
            public void refresh() {

            }
        };
        // Create the connection factory based on the config
        SQSConnectionFactory connectionFactory =
                SQSConnectionFactory.builder()
                        .withRegion(Region.getRegion(Regions.AP_SOUTHEAST_1))
                        .withAWSCredentialsProvider(awsCredentialsProvider)
                        .build();
        try {
            // Create the connection
            SQSConnection connection = connectionFactory.createConnection();
            Session session = connection.createSession(false, Session.CLIENT_ACKNOWLEDGE);
            MessageConsumer consumer = session.createConsumer( session.createQueue(QUEUE_NAME));

            PhotoshootImagesListener photoshootImagesListener =
                    new PhotoshootImagesListener(new ImageProcessorParser(
                            new AmazonS3Utils(awsCredentialsProvider)));

            consumer.setMessageListener(photoshootImagesListener);

            // No messages will be processed until this is called
            connection.start();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

}
