package be.openclinic.archiving;

import java.io.File;
import java.io.FileOutputStream;

public class StorageEngine {
	
	private String rootPath="c:/temp/archiving";

	public String getRootPath() {
		return rootPath;
	}

	public void setRootPath(String rootPath) {
		this.rootPath = rootPath;
	}

	public String getPath(String code){
		String path="";
		for(int n=0;n<=code.length()-1;n=n+2){
			if(code.length()-n>2){
				//Add a path
				path+=code.substring(n,n+2)+"/";
			}
		}
		return path;
	}
	
	public String toLetterCode(int id){
		return Integer.toString(id,36).toUpperCase();	
	}
	
	public String reverse(String s) {
        int length = s.length(), last = length - 1;
        char[] chars = s.toCharArray();
        for ( int i = 0; i < length/2; i++ ) {
            char c = chars[i];
            chars[i] = chars[last - i];
            chars[last - i] = c;
        }
        return new String(chars);
    }
	
	public void createPath(String fullyQualifiedFilename){
		File file = new File(fullyQualifiedFilename.substring(0,fullyQualifiedFilename.lastIndexOf("/")));
		file.mkdirs();
	}
	
	public void storeFile(String fullyQualifiedFilename,byte[] content){
		try{
			createPath(fullyQualifiedFilename);
			FileOutputStream fos = new FileOutputStream(fullyQualifiedFilename);
			fos.write(content);
			fos.close();
		}
		catch (Exception e){
			e.printStackTrace();
		}
	}

}
