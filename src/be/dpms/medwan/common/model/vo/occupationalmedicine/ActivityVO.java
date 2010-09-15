package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

public class ActivityVO implements Serializable, IIdentifiable {
    public String datetime;
    public String duration;
    public String activity;
    public String transactionId;
    public String serverId;

    public ActivityVO(String datetime,String duration,String activity,String transactionId,String serverId){
        this.datetime = datetime;
        this.duration = duration;
        this.activity = activity;
        this.transactionId=transactionId;
        this.serverId=serverId;
    }
    public String getDateTime(){
        return datetime;
    }

    public String getDuration(){
        return duration;
    }

    public String getActivity(){
        return activity;
    }

    public String getTransactionId(){
        return transactionId;
    }

    public String getServerId(){
        return serverId;
    }
}
