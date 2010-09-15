package be.mxs.common.util.system;

import java.net.InetSocketAddress;
import java.net.Socket;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 27-okt-2005
 * Time: 15:08:52
 * To change this template use Options | File Templates.
 */
public class Internet {
    public static boolean isReachable(String host,int port, int timeout){
        try{
            Socket remotesocket = new Socket();
            remotesocket.connect(new InetSocketAddress(host,port),timeout);
            if (remotesocket.isConnected()){
                remotesocket.close();
            }
        }
        catch (Exception e){
            return false;
        }
        return true;
    }
}
