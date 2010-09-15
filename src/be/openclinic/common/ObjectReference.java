package be.openclinic.common;

/**
 * Created by IntelliJ IDEA.
 * User: Frank Verbeke
 * Date: 10-sep-2006
 * Time: 21:26:35
 * To change this template use Options | File Templates.
 */
public class ObjectReference {
    private String objectType;
    private String objectUid;

    public ObjectReference(){

    }

    public ObjectReference(String objectType,String objectUid){
        this.setObjectUid(objectUid);
        this.setObjectType(objectType);
    }

    public String getObjectType() {
        return objectType;
    }

    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    public String getObjectUid() {
        return objectUid;
    }

    public void setObjectUid(String objectUid) {
        this.objectUid = objectUid;
    }

    public boolean equals(ObjectReference objectReference){
        return objectReference.getObjectType().equalsIgnoreCase(this.getObjectType()) && objectReference.getObjectUid().equalsIgnoreCase(this.getObjectUid());
    }
}
