package be.mxs.common.util.io;

import be.mxs.common.util.system.Debug;

import javax.comm.*;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.TooManyListenersException;

public class SerialPortManager implements Runnable, SerialPortEventListener{

    static CommPortIdentifier portId;
    static Enumeration portList;

    InputStream inputStream;
    OutputStream outputStream;
    SerialPort serialPort;
    Thread readThread;
    boolean bEcho = true;

    public boolean isEcho() {
        return bEcho;
    }

    public void setEcho(boolean bEcho) {
        this.bEcho = bEcho;
    }

    public SerialPortManager(){

    }

    public SerialPortManager(String comPort){
        portList = CommPortIdentifier.getPortIdentifiers();

        while (portList.hasMoreElements()) {
            portId = (CommPortIdentifier) portList.nextElement();
            if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
                Debug.println("Checking: "+portId.getName());
                if (portId.getName().equalsIgnoreCase(comPort)) {
                    Debug.println("Using: "+portId.getName());
                    try {
                        serialPort = (SerialPort) portId.open("OpenworkSerial", 2000);
                        Debug.println("Port open");
                    } catch (PortInUseException e) {
                        e.printStackTrace();
                    }
                    try {
                        outputStream = serialPort.getOutputStream();
                        inputStream = serialPort.getInputStream();
                        Debug.println("I/O streams set");
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    try {
                        serialPort.addEventListener(this);
                        Debug.println("Event listener set");
                    } catch (TooManyListenersException e) {
                        e.printStackTrace();
                    }
                    serialPort.notifyOnDataAvailable(true);
                    try {
                        serialPort.setSerialPortParams(9600,
                            SerialPort.DATABITS_8,
                            SerialPort.STOPBITS_1,
                            SerialPort.PARITY_NONE);
                        Debug.println("Parameters set");
                    } catch (UnsupportedCommOperationException e) {
                        e.printStackTrace();
                    }
                    Debug.println("Starting thread");
                    readThread = new Thread(this);
                    readThread.start();
                    break;
                }
            }
        }

    }

    public void run() {
        try {
            Debug.println("Running SerialPortManager thread");
            Thread.sleep(20000);
        } catch (InterruptedException e) {
            //
        }
    }

    public void receiveByte(byte b){
        if (bEcho){
            sendByte(b);
        }
    }

    public void sendByte(byte b){
        try {
            outputStream.write(b);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void sendBytes(byte[] b){
        try {
            outputStream.write(b);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void serialEvent(SerialPortEvent event) {
        switch(event.getEventType()) {
        case SerialPortEvent.BI:
        case SerialPortEvent.OE:
        case SerialPortEvent.FE:
        case SerialPortEvent.PE:
        case SerialPortEvent.CD:
        case SerialPortEvent.CTS:
        case SerialPortEvent.DSR:
        case SerialPortEvent.RI:
        case SerialPortEvent.OUTPUT_BUFFER_EMPTY:
            break;
        case SerialPortEvent.DATA_AVAILABLE:
            byte[] readBuffer = new byte[1];

            try {
                while (inputStream.available()>0) {
                    if (inputStream.read(readBuffer)>0){
                        receiveByte(readBuffer[0]);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            break;
        }
    }
}
