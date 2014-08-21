package be.mxs.common.util.system;

import java.util.Vector;

public class SessionMessage {
	private Vector messages = new Vector();
	
	public void setMessage(String s){
		messages.add(s);
		System.out.println(s);
	}
	
	public Vector getMessages(){
		return messages;
	}
	
	public String getLastMessages(){
		StringBuffer s = new StringBuffer();
		for(int n=0;n<messages.size();n++){
			s.append((String)messages.elementAt(n)+"\r\n");
		}
		messages = new Vector();
		return s.toString();
	}

}
