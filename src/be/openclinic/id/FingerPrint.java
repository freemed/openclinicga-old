package be.openclinic.id;

import be.mxs.common.util.db.MedwanQuery;
import com.griaule.grfingerjava.*;

import java.awt.*;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.SortedMap;
import java.util.TreeMap;



public class FingerPrint implements IStatusEventListener, IImageEventListener,
        IFingerEventListener {

    private MatchingContext matchContext;
    private boolean captureInitialized=false;
    private FingerprintImage fingerprint;
    private Image biometricimage=null;
    private boolean autoExtract=true;
    private Template template;
    private boolean autoIdentify;
    private String finger="R1";
    private int personid=0;
    private String mode="identify"; //values: identify,verify,enroll
    private SortedMap matches;
    private boolean active=false;

    private static FingerPrint fingerPrint;

    public static void close(){
        if (fingerPrint!=null){
            fingerPrint.stop();
            fingerPrint=null;
        }
    }

    public static FingerPrint getFingerPrint(){
        if (fingerPrint==null){
            fingerPrint=new FingerPrint();
        }
        else {
            fingerPrint.stop();
        }
        return fingerPrint;
    }

    public boolean identifyFingerPrint(int timeout){
        mode="identify";
        matches=new TreeMap();
        active=true;
        start();
        for(int n=0;n<timeout;n+=500){
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if(matches.size()>0){
                active=false;
                return true;
            }
        }
        active=false;
        stop();
        return false;
    }

    public Template getTemplate() {
        return template;
    }

    public void setTemplate(Template template) {
        this.template = template;
    }

    public void setTemplateFromString(String s){
        template.setData(s.getBytes());
    }

    private String templateToString(){
        return new String(template.getData());
    }

    public SortedMap getMatches() {
        return matches;
    }

    public void setMatches(SortedMap matches) {
        this.matches = matches;
    }

    public byte[] getFingerPrint(int timeout){
        template=null;
        active=true;
        start();
        for(int n=0;n<timeout;n+=500){
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if(template!=null){
                active=false;
                return template.getData();
            }
        }
        active=false;
        stop();
        return null;
    }

    public String bestmatch(){
        if(matches.size()>0){
            return matches.get(matches.lastKey()).toString();
        }
        else {
            return null;
        }
    }

    public String bestscore(){
        if(matches.size()>0){
            return matches.lastKey().toString();
        }
        else {
            return "0";
        }
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }

    public String getFinger() {
        return finger;
    }

    public void setFinger(String finger) {
        this.finger = finger;
    }

    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public FingerPrint(){
        File binDirectory = new File(MedwanQuery.getInstance().getConfigString("fingerprintBinDirectory"));
        GrFingerJava.setNativeLibrariesDirectory(binDirectory);
        try {
            GrFingerJava.setLicenseDirectory(binDirectory);
        } catch (GrFingerJavaException e) {
            e.printStackTrace();
        }
    }

    public void start(){
        try {
            GrFingerJava.initializeCapture(this);
            captureInitialized=true;
            if(matchContext==null){
                matchContext=new MatchingContext();
                matchContext.setIdentificationThreshold(MedwanQuery.getInstance().getConfigInt("fingerprintIdentificationTreshold",45));
                matchContext.setVerificationThreshold(MedwanQuery.getInstance().getConfigInt("fingerprintVerificationTreshold",45));
            }
        } catch (GrFingerJavaException e) {
            e.printStackTrace();
        }
    }

    public void onSensorPlug(String idSensor) {
        try {
            GrFingerJava.startCapture(idSensor, this, this);
        } catch (GrFingerJavaException e) {
            e.printStackTrace();
        }
    }

    public void onSensorUnplug(String idSensor) {
        try {
            GrFingerJava.stopCapture(idSensor);
        } catch (GrFingerJavaException e) {
            e.printStackTrace();
        }
    }

    public void onImageAcquired(String idSensor, FingerprintImage fingerprint) {
        if(active){
            processImage(fingerprint);
        }
    }

    private void processImage(FingerprintImage fingerprint) {
        this.fingerprint = fingerprint;
        if (autoExtract) {
            extract();
        }
    }

    public static boolean exists(int personid){
        boolean exists=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps=oc_conn.prepareStatement("select * from OC_FINGERPRINTS where personid=?");
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                exists=true;
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return exists;
    }

    public FingerprintImage getFingerPrintImage(){
        return fingerprint;
    }

    public void onFingerDown(String idSensor) {
    }

    public void onFingerUp(String idSensor) {
    }

    public boolean enroll() {
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ByteArrayInputStream input = new ByteArrayInputStream(template.getData());
            PreparedStatement ps=oc_conn.prepareStatement("delete from OC_FINGERPRINTS where personid=? and finger=?");
            ps.setInt(1,personid);
            ps.setString(2,finger);
            ps.executeUpdate();
            ps.close();
            ps=oc_conn.prepareStatement("insert into OC_FINGERPRINTS(personid,finger,template) values(?,?,?)");
            ps.setInt(1,personid);
            ps.setString(2,finger);
            ps.setBinaryStream(3, input, template.getData().length);
            ps.executeUpdate();
            ps.close();
            oc_conn.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return false;
    }

    public boolean verify() {
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            Template referenceTemplate = new Template();
            PreparedStatement ps=oc_conn.prepareStatement("select * from OC_FINGERPRINTS where personid=?");
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                referenceTemplate.setData(rs.getBytes("template"));
                rs.close();
                ps.close();
                oc_conn.close();
                return matchContext.verify(template,referenceTemplate);
            }
            else {
                rs.close();
                ps.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return false;
    }

    public boolean identify() {
        matches=new TreeMap();
        Template referenceTemplate = new Template();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if(matchContext==null){
                matchContext=new MatchingContext();
                matchContext.setIdentificationThreshold(MedwanQuery.getInstance().getConfigInt("fingerprintIdentificationTreshold",45));
                matchContext.setVerificationThreshold(MedwanQuery.getInstance().getConfigInt("fingerprintVerificationTreshold",45));
            }
            matchContext.prepareForIdentification(template);
            PreparedStatement ps=oc_conn.prepareStatement("select * from OC_FINGERPRINTS");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                referenceTemplate.setData(rs.getBytes("template"));
                if (matchContext.identify(referenceTemplate)){
                    matches.put(new Integer(matchContext.getScore()),new Integer(rs.getInt("personid")));
                }
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return matches.size()>0;
    }

    public void extract() {
        try {
            template = matchContext.extract(fingerprint);
            biometricimage=GrFingerJava.getBiometricImage(template, fingerprint);
        } catch (GrFingerJavaException e) {
            e.printStackTrace();
        }

    }

    public Image getBiometricimage() {
        return biometricimage;
    }

    public void setBiometricimage(Image biometricimage) {
        this.biometricimage = biometricimage;
    }

    public void setAutoIdentify(boolean state) {
        autoIdentify = state;
    }

    public void setAutoExtract(boolean state) {
        autoExtract = state;
    }

    public void stop() {
        try {
            if (captureInitialized) {
                GrFingerJava.finalizeCapture();
                captureInitialized = false;
            }
            if (matchContext != null) {
                matchContext.destroy();
                matchContext = null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }



}
