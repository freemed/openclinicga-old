package org.hnrw.chin.extractors;

import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;

import org.dom4j.Element;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 22-mei-2008
 * Time: 22:57:58
 * To change this template use File | Settings | File Templates.
 */
public abstract class Extractor {
    Date lastExtract;

    abstract public void getMessage();

    public Extractor(Date lastExtract){
        this.lastExtract=lastExtract;
    }

    abstract public String getExtractorID();

    public  Extractor() {
        lastExtract=getLastExtract();
    }

    public Date getLastExtract() {
        String lastExtract = MedwanQuery.getInstance().getConfigString("lastExtract"+getExtractorID(),"");
        if(lastExtract.length()==0){
            return setLastExtract();
        }
        else {
            try {
                return new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(lastExtract);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public Date setLastExtract(){
        Date dDate=new Date();
        MedwanQuery.getInstance().setConfigString("lastExtract"+getExtractorID(),new SimpleDateFormat("yyyyMMddHHmmssSSS").format(dDate));
        return dDate;
    }

    public void setLastExtract(Date lastExtract){
        MedwanQuery.getInstance().setConfigString("lastExtract"+getExtractorID(),new SimpleDateFormat("yyyyMMddHHmmssSSS").format(lastExtract));
        this.lastExtract=lastExtract;
    }
}
