<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<script type="text/javascript">window.resizeTo(400,300);</script>
<form name="takeOverForm" method="post" action="<c:url value='/popup.jsp'/>?Page=_common/search/takeOverTransaction.jsp&ts=<%=getTs()%>">
    <table width="100%" height="100%">
        <tr>
            <td>&nbsp;</td>
            <td>
                <table class="menu" width="100%">
                    <tr>
                        <td>
                            <center>
                                <br><br>
                                <%=getTran("web.occup","do_you_take_over_contact",sWebLanguage)%>
                                <br><br><br>

                                <input type="button" name="buttonYes" class="button" value="&nbsp;&nbsp;<%=getTran("web.occup","medwan.common.yes",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(1);"/>
                                &nbsp;
                                <input type="button" name="buttonNo" class="button" value="&nbsp;&nbsp;<%=getTran("web.occup","medwan.common.no",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(0)"/>

                                <br><br>
                            </center>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <script>
      function doClose(iReturn){
        window.returnValue = iReturn;
        window.close();
      }
    </script>
</form>
