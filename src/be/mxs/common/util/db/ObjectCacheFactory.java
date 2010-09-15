package be.mxs.common.util.db;

public class ObjectCacheFactory {
	private static ObjectCacheFactory objectCacheFactory;
	
	private ObjectCache objectCache=new ObjectCache();
	
	public static ObjectCacheFactory getInstance(){
		if(objectCacheFactory==null){
			objectCacheFactory=new ObjectCacheFactory();
		}
		return objectCacheFactory;
	}
	
	public ObjectCache getObjectCache(){
		return objectCache;
	}
	
	public void setObjectCacheSize(int size){
		objectCache.maxSize=size;
	}
	
	public void resetObjectCache(){
		objectCache=new ObjectCache();
	}
}
