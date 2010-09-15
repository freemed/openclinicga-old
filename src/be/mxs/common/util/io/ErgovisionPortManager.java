package be.mxs.common.util.io;

import be.mxs.common.util.system.Debug;

public class ErgovisionPortManager extends SerialPortManager{

    public static final int STATUS_INIT=1;
    public static final int STATUS_DISCONNECT_REQUEST=2;
    public static final int COMMAND_DISCONNECT=1;
    private int status=STATUS_INIT;
    private static ErgovisionPortManager portmanager=null;

    public ErgovisionPortManager(String port){
        super(port);
    }

    public static ErgovisionPortManager getInstance(String port){
        if (portmanager==null){
            portmanager=new ErgovisionPortManager(port);
        }
        return portmanager;
    }

    public static ErgovisionPortManager getNewInstance(String port){
        portmanager=new ErgovisionPortManager(port);
        return portmanager;
    }

    public void receiveByte(byte b){
        int rb = (b & 0xFF);
        switch (status){
            default:
                if (rb<0xFF){
                    sendByte(b);
                    Debug.println("ECHO ["+rb+"]");
                }
        }
    }

    public void execute(int command){
        switch (command){
            case COMMAND_DISCONNECT:
                Debug.println("Sending disconnect request");
                status=STATUS_DISCONNECT_REQUEST;
                byte[] b={0x38,0x36,0x01};
                sendBytes(b);
       }
    }
}
