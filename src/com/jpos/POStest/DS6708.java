package com.jpos.POStest;

import jpos.Scanner;
import jpos.JposException;
import jpos.events.DataListener;
import jpos.events.DataEvent;
import jpos.events.ErrorListener;
import jpos.events.ErrorEvent;
import be.mxs.common.util.db.MedwanQuery;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.apache.commons.httpclient.methods.PostMethod;


public class DS6708 implements DataListener, ErrorListener {
    Scanner scanner=new Scanner();
    byte[] scanData = new byte[]{};
    byte[] scanDataLabel=new byte[]{};
    StringBuffer sb = new StringBuffer();
    String ident="";
    String lastname="";
    String firstname="";
    int stage=0;

    public class Cleaner extends Thread {
        int timeout=0;

        public Cleaner(int timeout){
            this.timeout=timeout;
        }

        public void run(){
            try {
                sleep(timeout);
                stage=0;
                sb=new StringBuffer();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        
    }

    public class Opener extends Thread {
        public void run(){
            try {
                while(getScanner().getState()<2){
                    try {
                        try{
                            getScanner().close();
                        }
                        catch (Exception e){};
                        getScanner().open("SymbolScannerUSB");
                        getScanner().claim(1000);
                        getScanner().setDeviceEnabled(true);
                        getScanner().setDataEventEnabled(true);
                        getScanner().setDecodeData(true);
                    } catch (JposException e) {
                        e.printStackTrace();
                    }
                    try {
                        sleep(10000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
                    }
                }
                System.out.println("Scanner = "+getScanner().getDeviceServiceDescription());
            } catch (JposException e) {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
    }

    public DS6708(){
        scanner.addDataListener(this);
        scanner.addErrorListener(this);
        Opener opener = new Opener();
        opener.start();
    }

    public void errorOccurred(ErrorEvent ee)
    {
            System.out.println("Error Occurred");
    }

    public void dataOccurred(DataEvent de){
        Scanner scn = (Scanner) de.getSource();
        try {
            scn.setDataEventEnabled(true);
            scanData = scn.getScanData();
            scanDataLabel = scn.getScanDataLabel();
            for(int n=0;n<scanDataLabel.length;n++){
                byte[] b = new byte[1];
                b[0]=scanDataLabel[n];
                sb.append(new String(b));
                if(stage==0 && sb.length()==21){
                    ident=sb.substring(0,21);
                    stage=1;
                }
                else if(stage==1 && sb.length()==31){
                    sb = new StringBuffer();
                    stage=2;
                }
                else if(stage==2 && b[0]==0){
                    lastname = sb.substring(0,sb.length()-1);
                    stage=3;
                }
                else if (stage==3 && b[0]==0){
                    sb = new StringBuffer();
                }
                else if (stage==3 && b[0]!=0){
                    stage=4;
                }
                else if(stage==4 && b[0]==0){
                    firstname = sb.substring(0,sb.length()-1);
                    HttpClient httpClient = new HttpClient();
                    PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("barcodeUpdateURL","http://localhost/openclinic/util/setbarcode.jsp"));
                    method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,new DefaultHttpMethodRetryHandler(3, false));
                    NameValuePair[] data = {
                      new NameValuePair("ident", ident),
                        new NameValuePair("lastname",lastname),
                        new NameValuePair("firstname",firstname)
                    };
                    method.setRequestBody(data);
                    httpClient.executeMethod(method);
                    stage=5;
                    Cleaner cleaner = new Cleaner(200);
                    cleaner.start();
                }
            }
            Cleaner cleaner = new Cleaner(1000);
            cleaner.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Scanner getScanner() {
        return scanner;
    }

    public void setScanner(Scanner scanner) {
        this.scanner = scanner;
    }
}
