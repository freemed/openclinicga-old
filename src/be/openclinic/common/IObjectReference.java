package be.openclinic.common;

public abstract class IObjectReference extends OC_Object {
    public abstract String getObjectType();
    public abstract String getObjectUid();

    public ObjectReference getObjectReference(){
        return new ObjectReference(getObjectType(),getObjectUid());
    }
    
    public String getUid(){
    	return getObjectUid();
    }
}
