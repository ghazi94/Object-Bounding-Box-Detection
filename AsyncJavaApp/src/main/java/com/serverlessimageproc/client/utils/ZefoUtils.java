package com.serverlessimageproc.client.utils;

/**
 * Utility methods
 * Created by UserName on 4/5/16.
 */
public class ServelessProcUtils {

    public static boolean emptyString(String s) {
        if (s != null && !s.trim().equals("")) {
            return false;
        }
        return true;
    }
}
