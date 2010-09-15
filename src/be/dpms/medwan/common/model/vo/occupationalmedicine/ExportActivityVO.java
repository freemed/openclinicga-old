package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.util.db.MedwanQuery;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.Vector;

/**
 * User: frank
 * Date: 20-aug-2005
 */
public class ExportActivityVO {
    int personId;
    int userId;
    java.util.Date date;
    java.util.Date validated;
    String code="";
    String id="";
    String userName="";
    String medicalCenter="";
    String MD="";
    String para="";
    String provider="";
    String value="";

    public ExportActivityVO(int personId,int userId,java.util.Date date,String code,String id){
        this.personId=personId;
        this.userId=userId;
        this.date=date;
        this.code=code;
        this.id=id;
    }

    public ExportActivityVO(int personId,int userId,String date,String code,String id){
        this.personId=personId;
        this.userId=userId;
        try {
            this.date=new SimpleDateFormat("dd/MM/yyyy").parse(date);
        } catch (ParseException e) {
            this.date=null;
            e.printStackTrace();
        }
        this.code=code;
        this.id=id;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public void setUserName(String userName){
        this.userName=userName;
    }

    public String getUserName(){
        return userName;
    }

    public int getPersonId(){
        return personId;
    }

    public int getUserId(){
        return userId;
    }

    public java.util.Date getActivityDateTime(){
        return date;
    }

    public String getActivityCode(){
        return code;
    }

    public String getActivityId(){
        return id;
    }

    public java.util.Date getDate() {
        return date;
    }

    public void setDate(java.util.Date date) {
        this.date = date;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public java.util.Date getValidated() {
        return validated;
    }

    public void setValidated(java.util.Date validated) {
        this.validated = validated;
    }

    public String getMedicalCenter() {
        return medicalCenter;
    }

    public void setMedicalCenter(String medicalCenter) {
        this.medicalCenter = medicalCenter;
    }

    public String getMD() {
        return MD;
    }

    public void setMD(String MD) {
        this.MD = MD;
    }

    public String getPara() {
        return para;
    }

    public void setPara(String para) {
        this.para = para;
    }

    public boolean remove(){
        return MedwanQuery.getInstance().removeActivity(id,false);
    }

    public void setId(String id){
        this.id = id;
    }

    public boolean store(boolean eraseOld,String workinguserid){
        if (eraseOld){
            if (!remove()){
                return false;
            }
        }
        return MedwanQuery.getInstance().storeActivity(personId,userId,date,code,id,provider,value,MD,workinguserid,medicalCenter,para);
    }

    public boolean setCodeWhereExists(String elementType){
        code = MedwanQuery.getInstance().getActivityCodeWhereExists(elementType);
        return code!=null;
    }

    public boolean setCodeWhereValueLike(String elementType,String elementValue){
        code = MedwanQuery.getInstance().getActivityCodeWhereValueLike(elementType,elementValue);
        return code!=null;
    }

    public Vector validate(){
        /*
        System.out.println("\n=============== DEBUG ==================");
        System.out.println("MD            : "+MD);
        System.out.println("para          : "+para);
        System.out.println("medicalCenter : "+medicalCenter);
        System.out.println("provider      : "+provider);

        System.out.println("MD       needed for code "+code+" : "+MedwanQuery.getInstance().getActivity(code).md);
        System.out.println("provider needed for code "+code+" : "+MedwanQuery.getInstance().getActivity(code).provider);
        */

        Vector errors = new Vector();
        if ((MD==null || MD.trim().length()==0) && (para==null || para.trim().length()==0)){
            errors.add("error.md-or-para-needed");
        }
        else {
            // check MD code
            if (MD!=null && MD.trim().length()>0 && MD.trim().length()!=3){
                errors.add("error.md-code-needs-3-characters");
            }
            else if(MD==null && MedwanQuery.getInstance().getActivity(code).md){
                errors.add("error.md-code-needed-for-this-activity");
            }
            else if (MD!=null && MD.trim().length()>0){
                try{
                    if (Integer.parseInt(MD)<0){
                        errors.add("error.md-code-not-numeric");
                    }
                }
                catch (NumberFormatException e){
                    errors.add("error.md-code-not-numeric");
                }
            }

            // check para code
            if (para!=null && para.trim().length()>0 && para.trim().length()!=3){
                errors.add("error.para-code-needs-3-characters");
            }
            else if (para!=null && para.trim().length()>0){
                try{
                    if (para!=null && para.trim().length()>0 && Integer.parseInt(para)<0){
                        errors.add("error.para-code-not-numeric");
                    }
                }
                catch (NumberFormatException e){
                    errors.add("error.para-code-not-numeric");
                }
            }
        }

        // check medical center
        if (medicalCenter==null || medicalCenter.trim().length()==0){
            errors.add("error.medical-center-needed");
        }
        else if(medicalCenter.trim().length()!=5){
            errors.add("error.medical-center-needs-5-characters");
        }
        else {
            try{
                if (Integer.parseInt(medicalCenter)<0){
                    errors.add("error.medical-center-code-not-numeric");
                }
                else if (medicalCenter.substring(2,4).equalsIgnoreCase("09")){
                    errors.add("error.medical-center-activity-codes-not-permitted");
                }
            }
            catch (NumberFormatException e){
                errors.add("error.medical-center-code-not-numeric");
            }
        }

        // check provider code
        if ((provider==null || provider.trim().length()==0) && MedwanQuery.getInstance().getActivity(code).provider){
            errors.add("error.provider-needed");
        }

        return errors;
    }

}
