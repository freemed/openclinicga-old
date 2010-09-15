package be.mxs.common.util.system;

import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

import org.apache.commons.math.stat.regression.SimpleRegression;

import be.openclinic.common.KeyValue;
import be.openclinic.common.NumericKeyValue;

public class StatFunctions {
	public static Object getMedian(Vector values){
		Collections.sort(values);
    	int middle = values.size()/2;
    	return(values.elementAt(middle));
	}
	
	public static double getSimpleRegression(int[] values,int position){
		SimpleRegression simpleRegression = new SimpleRegression();
		for(int n=0;n<values.length-1;n++){
			simpleRegression.addData(n, values[n]);
		}
		return simpleRegression.predict(position);
	}
	
	public static double getSimpleRegression(double[] values,int position){
		SimpleRegression simpleRegression = new SimpleRegression();
		for(int n=0;n<values.length-1;n++){
			simpleRegression.addData(n, values[n]);
		}
		return simpleRegression.predict(position);
	}
	
	public static SortedSet sort(Hashtable v){
		SortedSet m = new TreeSet();
		Enumeration e=v.keys();
		while(e.hasMoreElements()){
			String key=(String)e.nextElement();
			Double value=new Double(0);
			if(v.get(key).getClass().getName().indexOf("Integer")>-1){
				value=new Double(((Integer)v.get(key)).intValue());
			}
			else if(v.get(key).getClass().getName().indexOf("Double")>-1){
				value=(Double)v.get(key);
			}
			else {
				value=new Double(0);
			}
			if(Double.isNaN(value.doubleValue())){
				value=new Double(0);
			}
			m.add(new NumericKeyValue(key, value));
		}
		return m;
	}

	public static KeyValue[] getTop(Hashtable v,int count){
		try{
			SortedSet set = sort(v);
			if(count>v.size()){
				count=v.size();
			}
			KeyValue[] topvalues = new KeyValue[count];
			Iterator iterator = set.iterator();
			int n=0;
			NumericKeyValue numVal;
			while(iterator.hasNext() && n<count ){
				numVal=(NumericKeyValue)iterator.next();
				topvalues[n]=new KeyValue(numVal.getKey(),numVal.getValue()+"");
				n++;
			}
			return topvalues;
		}
		catch (Exception e){
			e.printStackTrace();
			return new KeyValue[0];
		}
	}

	public static KeyValue[] getTopSorted(SortedSet set,int count){
		try{
			if(count>set.size()){
				count=set.size();
			}
			KeyValue[] topvalues = new KeyValue[count];
			Iterator iterator = set.iterator();
			int n=0;
			NumericKeyValue numVal;
			while(iterator.hasNext() && n<count ){
				numVal=(NumericKeyValue)iterator.next();
				topvalues[n]=new KeyValue(numVal.getKey(),numVal.getValue()+"");
				n++;
			}
			return topvalues;
		}
		catch (Exception e){
			e.printStackTrace();
			return new KeyValue[0];
		}
	}

	public static KeyValue[] getTop(Hashtable values,int count,double minval){
		HashSet keys=new HashSet();
		if(count>values.size()){
			count=values.size();
		}
		if(count<0){
			return new KeyValue[0];
		}
		KeyValue[] topvalues = new KeyValue[count];
		double totalVal=0;
		for(int n=0;n<count;n++){
			double maxVal=-99999999;
			double val=0;
			String maxobject=null;
			Enumeration e=values.keys();
			while(e.hasMoreElements()){
				String key=(String)e.nextElement();
				if(values.get(key).getClass().getName().indexOf("Integer")>-1){
					val = ((Integer)values.get(key)).intValue();
				}
				else if(values.get(key).getClass().getName().indexOf("Double")>-1){
					val = ((Double)values.get(key)).doubleValue();
				}
				if(n==0){
					totalVal++;
				}
				if(val>maxVal){
					maxVal=val;
					maxobject=key;
				}
			}
			topvalues[n]=new KeyValue(maxobject,maxVal+"");
			keys.add(maxobject);
			values.remove(maxobject);
		}
		Enumeration e=values.keys();
		
		while(e.hasMoreElements()){
			double val=0;
			String key=(String)e.nextElement();
			if(!keys.contains(key)){
				if(values.get(key).getClass().getName().indexOf("Integer")>-1){
					val = ((Integer)values.get(key)).intValue();
				}
				else if(values.get(key).getClass().getName().indexOf("Double")>-1){
					val = ((Double)values.get(key)).doubleValue();
				}
				if(val>minval){
					KeyValue[] topvalues2 = new KeyValue[topvalues.length+1];
					System.arraycopy(topvalues, 0, topvalues2, 0, topvalues.length);
					topvalues=topvalues2;
					topvalues[topvalues.length-1]=new KeyValue(key,val+"");
				}
			}
		}
		return topvalues;
	}
}