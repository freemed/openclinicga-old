<%@ page import="be.mxs.common.util.system.Miscelaneous,be.mxs.common.util.db.MedwanQuery" %>
<%
    Miscelaneous.startApplication(MedwanQuery.getInstance().getConfigString("readPictureApplication","cmd /c d:/projects/openclinic/web/util/storePicture.bat")+" "+request.getParameter("personid"),
                                  MedwanQuery.getInstance().getConfigString("readPictureDirectory","d:/projects/openclinic/web/util"));
%>
<script>window.close();</script>