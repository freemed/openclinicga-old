package be.openclinic.common;

public class Util {
    public static String makeUID(int serverid,int objectid){
        return serverid+"."+objectid;
    }

    public static int getServerid(String uid){
        return Integer.parseInt(uid.split("\\.")[0]);
    }

    public static int getObjectid(String uid){
        return Integer.parseInt(uid.split("\\.")[1]);
    }
}
