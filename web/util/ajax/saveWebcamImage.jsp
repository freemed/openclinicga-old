<%@page import="java.util.Map" %>
<%@page import="java.util.Iterator" %>
<%@page import="java.io.IOException" %>
<%@page import="java.io.BufferedOutputStream" %>
<%@page import="java.io.File" %>
<%@page import="java.io.FileOutputStream" %>
<%@page import="org.apache.commons.codec.binary.Base64" %>
<%@page import="be.mxs.common.util.system.Picture" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@include file="/includes/validateUser.jsp" %>

<%!
	private static void writeFile(byte[] tab, String fichier) throws IOException {
		File file = new File(fichier);
	    BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
	    bos.write(tab);
	    bos.close();
	}

    // Méthode pour décoder l'image
    // NB : la chaîne de caractères est le code Base64, le nom du fichier doit être complet (ie chemin relatif ou absolu et extension)
    private static void decoderImage(String image, String fichier) throws Exception {
        try {
            byte[] buffer = Base64.decodeBase64(image.getBytes());
            writeFile(buffer, fichier);
        } 
        catch (Exception e) {
            e.printStackTrace();
        }
    }
   %>
<%
    String sData = checkString(request.getParameter("imagedata"));
    try {
        if (sData.trim().length() > 0) {
            Picture p = new Picture();
            p.setPersonid(Integer.parseInt(activePatient.personid));
            p.setPicture(Base64.decodeBase64(sData.getBytes()));
            p.store();
        }
    } 
    catch (Exception e) {
        e.printStackTrace();
    }
%>
