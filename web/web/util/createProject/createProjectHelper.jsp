<%@page import="java.util.Vector"%>
<%!
    public static Vector pathDisplayer(String paths, String src,String dest){
        Vector vPaths = new Vector();
        String sTmp, sNewPath;
        int index;

        paths = paths.trim();

        while((index = paths.indexOf("\n"))>=0){
            sTmp =  paths.substring(0,index);
            sNewPath = dest + "\\" + sTmp.substring((sTmp.indexOf(src) + src.length()),sTmp.length());
            sNewPath = sNewPath.replaceAll("\\\\","/").trim();
            sNewPath = sNewPath.replaceAll("//","/");
            vPaths.addElement(sNewPath);
            paths = paths.substring(index+1,paths.length());
        }

        if(index < 0 && paths.length()>0){
            sNewPath = dest + "\\" + paths.substring((paths.indexOf(src) + src.length()),paths.length());
            sNewPath = sNewPath.replaceAll("\\\\","/").trim();
            sNewPath = sNewPath.replaceAll("//","/");
            vPaths.addElement(sNewPath);
        }

        return vPaths;
    }
%>