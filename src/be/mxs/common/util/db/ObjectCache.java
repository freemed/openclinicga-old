package be.mxs.common.util.db;

import be.openclinic.common.OC_Object;

import java.text.DecimalFormat;
import java.util.*;


/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 2-mrt-2009
 * Time: 16:48:08
 * To change this template use File | Settings | File Templates.
 */
public class ObjectCache {
    Hashtable objectsTable=new Hashtable();
    Vector timeTable=new Vector();
    int maxSize=10000;
    int hits=0;
    int puts=0;
    int removals=0;
    int requests=0;

    public void putObject(String type,OC_Object object){
    	if(object!=null){
	    	timeTable.add(type+"."+object.getUid());
	        objectsTable.put(type+"."+object.getUid(),object);
	        puts++;
	        while (timeTable.size()>maxSize){
	            objectsTable.remove(timeTable.firstElement());
	            timeTable.remove(0);
	            removals++;
	        }
    	}
    }
    
    public int size(){
    	return objectsTable.size();
    }
    
    public void removeObject(String type, String uid){
    	objectsTable.remove(type+"."+uid);
    }

    public OC_Object getObject(String type,String uid){
    	requests++;
        OC_Object object = (OC_Object)objectsTable.get(type+"."+uid);
        if(object!=null){
        	hits++;
        }
        return object;
    }
    
    public StringBuffer getStatus(){
    	StringBuffer s = new StringBuffer();
    	s.append("Number of cached objects: "+timeTable.size()+"\n");
    	if(requests>0){
    		s.append("Number of hits: "+hits+" ("+new DecimalFormat("#.##").format(100*hits/requests)+"%)\n");
    	}
    	s.append("Number of puts: "+puts+"\n");
    	s.append("Number of removals: "+removals+"\n");
    	return s;
    }

}
