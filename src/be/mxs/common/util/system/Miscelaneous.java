package be.mxs.common.util.system;

import be.mxs.common.model.vo.healthrecord.HealthRecordVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.date.MedwanCalendar;
import be.dpms.medwan.common.model.vo.occupationalmedicine.VerifiedExaminationVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileRiskCodeVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;

import java.util.*;
import java.io.IOException;
import java.io.File;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.net.URL;
import java.awt.*;

public class Miscelaneous {
	
	//--- PARSE DATE ------------------------------------------------------------------------------
    public static java.util.Date parseDate(String date){
        return ScreenHelper.parseDate(date);
    }
    
    //--- START APPLICATION -----------------------------------------------------------------------
    public static void startApplication(String app,String dir){
        try {
            Runtime.getRuntime().exec(app,null,new File(dir));
        } 
        catch (IOException e) {
            e.printStackTrace();
        }
    }

    //--- GET IMAGE (1) ---------------------------------------------------------------------------
    public static com.itextpdf.text.Image getImage(String name, String project){
    	com.itextpdf.text.Image image = null;
    	
        //Try to find the image in the config cache
        String imageSource = MedwanQuery.getInstance().getConfigString("PDFIMG."+name+"."+project);
        if(imageSource!=null && imageSource.length()>0){
            try {
            	Debug.println("(config cache) imageSource : "+imageSource);
                image = com.itextpdf.text.Image.getInstance(new URL(imageSource));
                if(image!=null){
                    return image;
                }
            }
            catch (Exception e){}
        }
        imageSource=MedwanQuery.getInstance().getConfigString("imageSource","http://localhost/openclinic");
        
        //Try to find the image in the project image directory
        try{
        	Debug.println("(project image directory) imageSource : "+imageSource+"/projects/"+project+"/_img/"+name);
            image = com.itextpdf.text.Image.getInstance(new URL(imageSource+"/projects/"+project+"/_img/"+name));
            if(image!=null){
                MedwanQuery.getInstance().setConfigString("PDFIMG."+name+"."+project,imageSource+"/projects/"+project+"/_img/"+name);
                return image;
            }
        }
        catch (Exception e){}
        
        //Try to find the image in the default image directory
        try{
        	Debug.println("(default image directory) imageSource : "+imageSource+"/_img/"+name);
            image = com.itextpdf.text.Image.getInstance(new URL(imageSource+"/_img/"+name));
            if(image!=null){
                MedwanQuery.getInstance().setConfigString("PDFIMG."+name+"."+project,imageSource+"/_img/"+name);
                return image;
            }
        }
        catch (Exception e){}
        
        System.out.println("Could not find image "+name+" for project "+project);
        return image;
    }

    //--- GET IMAGE (2) ---------------------------------------------------------------------------
    public static java.awt.Image getImage(String name){
        java.awt.Image image = null;
        
        //Try to find the image in the config cache
        String imageSource = MedwanQuery.getInstance().getConfigString("JAVAIMG."+name);
        if(imageSource!=null && imageSource.length()>0){
            try {
                image = Toolkit.getDefaultToolkit().getImage(new URL(imageSource));
                return image;
            }
            catch (Exception e){}
        }
        imageSource=MedwanQuery.getInstance().getConfigString("imageSource","http://localhost/openclinic");
        
        //Try to find the image in the default image directory
        try{
            image = Toolkit.getDefaultToolkit().getImage(new URL(imageSource+"/_img/"+name));
            MedwanQuery.getInstance().setConfigString("JAVAIMG."+name,imageSource+"/_img/"+name);
            return image;
        }
        catch (Exception e){}
        
        return image;
    }

    //--- SET LAST ITEMS --------------------------------------------------------------------------
    public static void setLastItems(SessionContainerWO sessionContainerWO){
        if (sessionContainerWO.getHealthRecordVO() !=null){
            TransactionVO lastTransaction_biometry = null;
            TransactionVO lastTransaction_urineExamination = null;
            TransactionVO lastTransaction_audiometry = null;
            TransactionVO lastTransaction_ophtalmologyExamination = null;
            TransactionVO lastTransaction_generalClinicalExamination = null;
         
            Hashtable lastItems = MedwanQuery.getInstance().getLastItems(sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString());
            try{
                //Check if Driver Examination report is due
                if (sessionContainerWO.getHealthRecordVO().hashCode()!=0){
                    sessionContainerWO.getFlags().setLastDrivingCertificate(new VerifiedExaminationVO(-1,sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(),"","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DLC",sessionContainerWO));
                    sessionContainerWO.getFlags().getLastDrivingCertificate().setNewExaminationDueDate(new Date());
                    ItemVO drivingCertificateItemVO=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLC_VALIDITY");
                    if (drivingCertificateItemVO != null){
                        Date dueDrivingCertificateDate = MedwanCalendar.asDate(drivingCertificateItemVO.getValue());
                        sessionContainerWO.getFlags().getLastDrivingCertificate().setNewExaminationDueDate((Date)dueDrivingCertificateDate.clone());
                        long tolerance = 4*30*24;
                        tolerance = tolerance * 60 * 60 * 1000;
                        dueDrivingCertificateDate = MedwanCalendar.getNewDate(dueDrivingCertificateDate,-tolerance);
                        if (dueDrivingCertificateDate.before(new Date())){
                            sessionContainerWO.getFlags().getLastDrivingCertificate().setNewExaminationDue("medwan.common.true");
                        }
                        else {
                            sessionContainerWO.getFlags().getLastDrivingCertificate().setNewExaminationDue("medwan.common.false");
                        }
                    }
                    
                    //Check if Medical Examination report is to be renewed
                    sessionContainerWO.getFlags().setLastExaminationReport(new VerifiedExaminationVO(-1,sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(),"","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MER",sessionContainerWO));
                    sessionContainerWO.getFlags().getLastExaminationReport().setNewExaminationDueDate(new Date());
                    ItemVO examinationReportItemVO=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MER_EXPIRATION_DATE");
                    if (examinationReportItemVO != null && examinationReportItemVO.getValue()!=null && examinationReportItemVO.getValue().length()>=8){
                        Date dueExaminationReportDate = MedwanCalendar.asDate(examinationReportItemVO.getValue());
                        sessionContainerWO.getFlags().getLastExaminationReport().setNewExaminationDueDate((Date)dueExaminationReportDate.clone());
                        long tolerance = 2*30*24;
                        tolerance = tolerance * 60 * 60 * 1000;

                        dueExaminationReportDate = MedwanCalendar.getNewDate(dueExaminationReportDate,-tolerance);
                        if (dueExaminationReportDate.before(new Date())){
                            sessionContainerWO.getFlags().getLastExaminationReport().setNewExaminationDue("medwan.common.true");
                        }
                        else {
                            sessionContainerWO.getFlags().getLastExaminationReport().setNewExaminationDue("medwan.common.false");
                        }
                    }

                    //Check last work accident
                    sessionContainerWO.getFlags().setLastAO(new VerifiedExaminationVO(-1,sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(),"","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_AO",sessionContainerWO));
                    sessionContainerWO.getFlags().getLastAO().setNewExaminationDue("medwan.common.unknown");
                    if (sessionContainerWO.getFlags().getLastAO().getLastExaminationDate()!=null){
                        if (sessionContainerWO.getFlags().getLastExaminationReport().getLastExaminationDate()==null || sessionContainerWO.getFlags().getLastAO().getLastExaminationDate().after(sessionContainerWO.getFlags().getLastExaminationReport().getLastExaminationDate())){
                            sessionContainerWO.getFlags().getLastAO().setNewExaminationDue("medwan.common.true");
                        }
                        else {
                            sessionContainerWO.getFlags().getLastAO().setNewExaminationDue("medwan.common.false");
                        }
                    }

                }
                ItemVO item;
                TransactionVO transaction;
                String transactionType;

                //Biometrie
                transaction = lastTransaction_biometry;
                transactionType = IConstants.TRANSACTION_TYPE_BIOMETRY;

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                sessionContainerWO.setLastTransactionTypeBiometry( transaction );

                //Urine
                transaction = lastTransaction_urineExamination;
                transactionType = IConstants.TRANSACTION_TYPE_URINE_EXAMINATION;

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                sessionContainerWO.setLastTransactionTypeUrineExamination( transaction );

                //Audiometry
                transaction = lastTransaction_audiometry;
                transactionType = IConstants.TRANSACTION_TYPE_AUDIOMETRY;

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_LOSS");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_LOSS");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_LOSS");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_LOSS");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                sessionContainerWO.setLastTransactionTypeAudiometry( transaction );

                //Visus
                transaction = lastTransaction_ophtalmologyExamination;
                transactionType = IConstants.TRANSACTION_TYPE_OPTHALMOLOGY_EX_WITH_STEREOSCOPY;

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }
               
                sessionContainerWO.setLastTransactionTypeOphtalmology( transaction );

                //Clinical Examination
                transaction = lastTransaction_generalClinicalExamination;
                transactionType = IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION;

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
                item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
                if (item!=null){
                    if (transaction == null){
                        transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                        transaction.setItems(new Vector());
                    }
                    if (transaction.getUpdateTime()==null){
                        transaction.setUpdateTime(item.getDate());
                    }
                    else if (transaction.getUpdateTime().before(item.getDate())){
                        transaction.setUpdateTime(item.getDate());
                    }
                    transaction.getItems().add(item);
                }

                sessionContainerWO.setLastTransactionTypeGeneralClinicalExamination( transaction );

                Iterator ir = sessionContainerWO.getRiskProfileVO().getRiskCodes().iterator();
                boolean bDriversLicenseDue = false;
                RiskProfileRiskCodeVO riskProfileRiskCodeVO;
                while (ir.hasNext()){
                    riskProfileRiskCodeVO = (RiskProfileRiskCodeVO)ir.next();
                    if (riskProfileRiskCodeVO.getCode().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("codeChauffeurCat2"))){
                        bDriversLicenseDue=true;
                        break;
                    }
                }
                
                if (!bDriversLicenseDue && sessionContainerWO.getFlags().getLastDrivingCertificate()!=null){
                    sessionContainerWO.getFlags().getLastDrivingCertificate().setNewExaminationDue("medwan.common.unknown");
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    public static final int DAY_DIFF = 0;
    public static final int MONTH_DIFF = 1;
    public static final int YEAR_DIFF = 2;
    public static final int MILLI_DIFF = 3;
    public static final int SEC_DIFF = 4;

    /**
     * DateUtil.datediff(DateUtil.DAY_DIFF, date1, date2);
     * @param pintType The type of diff you want. It supports SECS/MILLI/DAYS/MONTHS and YEAR_DIFF
     * @param pdatValue1 The first day to substract from
     * @param pdatValue2 And the leaser date (Hopefully)
     * @return Returns the number of day/months or years between to values
     */
    public static long datediff(int pintType, Date pdatValue1, Date pdatValue2) {
        long datediff = 0;

        Calendar calValue1 = null;
        Calendar calValue2 = null;
        if (pintType != SEC_DIFF && pintType != MILLI_DIFF) {
	        calValue1 = Calendar.getInstance();
	        calValue1.setTime(pdatValue1);
	        calValue2 = Calendar.getInstance();
	        calValue2.setTime(pdatValue2);
        }

        switch (pintType) {
            case MILLI_DIFF:
                datediff = pdatValue1.getTime() - pdatValue2.getTime();
                break;

            case SEC_DIFF:
                datediff = (pdatValue1.getTime() - pdatValue2.getTime()) / 1000;
                break;

            case DAY_DIFF:
                if (calValue1.get(Calendar.YEAR) - calValue2.get(Calendar.YEAR) > 0) {
                    int years = calValue1.get(Calendar.YEAR) - calValue2.get(Calendar.YEAR);
                    datediff = years * 365;
                }
                datediff = datediff + calValue1.get(Calendar.DAY_OF_YEAR) - calValue2.get(Calendar.DAY_OF_YEAR);
                break;

            case MONTH_DIFF:
                if (calValue1.get(Calendar.YEAR) - calValue2.get(Calendar.YEAR) > 0) {
                    int years = calValue1.get(Calendar.YEAR) - calValue2.get(Calendar.YEAR);
                    datediff = years * 12;
                }
                datediff = datediff + calValue1.get(Calendar.MONTH) - calValue2.get(Calendar.MONTH);
                break;

            case YEAR_DIFF:
                datediff = calValue1.get(Calendar.YEAR) - calValue2.get(Calendar.YEAR);
                break;

            default:
                datediff = 0;
                break;
        }

        return datediff;
    }

}
