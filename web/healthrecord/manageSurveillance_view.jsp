<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.surveillance","select",activeUser)%>
<%!
    private StringBuffer addSignesVitaux(int iTotal,String sHeure,String sSys,String sDias,String sRythme,String sTemp,String sFreq,String sSat, String sMode, String sObservation, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowSignesVitaux"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='javascript:deleteSignesVitaux(rowSignesVitaux"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='javascript:editSignesVitaux(rowSignesVitaux"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">" + sHeure + "</td>" +
                        "<td class=\"admin2\" width=\"75\">" +
                            sSys +
                        "</td>" +
                        "<td class=\"admin2\" width=\"75\">" +
                            sDias +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sRythme + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sTemp + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sFreq + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sSat + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sMode + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sObservation + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }

    private StringBuffer addConscience(int iTotal,String sHeure,String sYeux,String sMotrice,String sVerbale,String sTotal,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowConscience"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='javascript:deleteConscience(rowConscience"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='javascript:editConscience(rowConscience"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sHeure + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sYeux + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sMotrice + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sVerbale + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sTotal + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }

    private StringBuffer addBiometrie(int iTotal,String sHeure,String sPoids,String sTaille,String sBMI,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowBiometrie"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                        "   <a href='javascript:deleteBiometrie(rowBiometrie"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                        "   <a href='javascript:editBiometrie(rowBiometrie"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sHeure + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sPoids + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sTaille + "</td>" +
                        "<td class=\"admin2\">&nbsp;" + sBMI + "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }

    private StringBuffer addBilanEntree(int iTotal,String sHeure,String sLactate,String sGlucose,String sPhysio,String sHaem,String sTrans, String sSang,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowBilanEntree"+iTotal+"'>" +
                        "<td class=\"admin2\">" +
                            "<a href='javascript:deleteBilanEntree(rowBilanEntree"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                            "<a href='javascript:editBilanEntree(rowBilanEntree"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sHeure +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sLactate +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sGlucose +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sPhysio +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sHaem +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sTrans +
                        "</td>" +
                        "<td class=\"admin2\">&nbsp;" +
                            sSang +
                        "</td>" +
                        "<td class=\"admin2\">" +
                        "</td>" +
                    "</tr>"
        );

        return sTmp;
    }

    private StringBuffer addSitNutri(int iTotal,String sHeure,String sLait,String sBouillie,String sPotage,String sPB,String sPT, String sIMC,String sObservation,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append(
                    "<tr id='rowSitNutri"+iTotal+"'>"+
                        "<td class=\"admin2\" width=\"40\">" +
                            "<a href='javascript:deleteSitNutri(rowSitNutri"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> "+
                            "<a href='javascript:editSitNutri(rowSitNutri"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>" +
                        "</td>"+
                        "<td class=\"admin2\" width=\"100\">&nbsp;"+
                            sHeure +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sLait+
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sBouillie +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sPotage +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sPB +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sPT +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sIMC +
                        "</td>"+
                        "<td class=\"admin2\">&nbsp;"+
                            sObservation +
                        "</td>"+
                        "<td class=\"admin2\">"+
                        "</td>"+
                    "</tr>"
        );

        return sTmp;
    }
%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
<%
    StringBuffer sDivSignesVitaux = new StringBuffer();
    StringBuffer sSignesVitaux    = new StringBuffer();
    int iSignesVitauxTotal = 0;

    StringBuffer sDivConscience = new StringBuffer();
    StringBuffer sConscience    = new StringBuffer();
    int iConscienceTotal = 0;

    StringBuffer sDivBiometrie = new StringBuffer();
    StringBuffer sBiometrie    = new StringBuffer();
    int iBiometrieTotal = 0;

    StringBuffer sDivBilanEntree = new StringBuffer();
    StringBuffer sBilanEntree    = new StringBuffer();
    int iBilanEntreeTotal = 0;

    String sBilanSortieDiurese = "";
    String sBilanSortieDrainThoracique = "";
    String sBilanSortieSondeNasogastrique = "";
    String sBilanSortieAspiration = "";
    String sBilanSortieDrainAbdominal = "";
    String sBilanSortieVomissements = "";
    String sBilanSortieAutreDrain = "";
    String sBilanSortieAutresSorties = "";
    String sBilanSortieSelles = "";

    StringBuffer sDivSitNutri = new StringBuffer();
    StringBuffer sSitNutri    = new StringBuffer();
    int iSitNutriTotal = 0;

    if (transaction != null){
        TransactionVO tran = (TransactionVO)transaction;
        if (tran!=null){
            sSignesVitaux.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_1"));
            sSignesVitaux.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_2"));
            sSignesVitaux.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_3"));
            sSignesVitaux.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_4"));
            sSignesVitaux.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_5"));

            sConscience.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_1"));
            sConscience.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_2"));
            sConscience.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_3"));
            sConscience.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_4"));
            sConscience.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_5"));

            sBiometrie.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_1"));
            sBiometrie.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_2"));
            sBiometrie.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_3"));
            sBiometrie.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_4"));
            sBiometrie.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_5"));

            sBilanEntree.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_1"));
            sBilanEntree.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_2"));
            sBilanEntree.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_3"));
            sBilanEntree.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_4"));
            sBilanEntree.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_5"));

            sBilanSortieDiurese             = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DIURESE");
            sBilanSortieDrainThoracique     = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_THORACIQUE");
            sBilanSortieSondeNasogastrique  = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_SONDE_NASOGASTRIQUE");
            sBilanSortieAspiration          = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_ASPIRATION");
            sBilanSortieDrainAbdominal      = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_ABDOMINAL");
            sBilanSortieVomissements        = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_VOMISSEMENTS");
            sBilanSortieAutreDrain          = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRE_DRAIN");
            sBilanSortieAutresSorties       = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRES_SORTIES");
            sBilanSortieSelles              = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_SELLES");

            sSitNutri.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_1"));
            sSitNutri.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_2"));
            sSitNutri.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_3"));
            sSitNutri.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_4"));
            sSitNutri.append(getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_5"));
        }

        iSignesVitauxTotal = 1;

        if (sSignesVitaux.indexOf("£")>-1){
            StringBuffer sTmpSignesVitaux = sSignesVitaux;
            String sTmpHeure, sTmpSys, sTmpDias, sTmpRythme, sTmpTemp, sTmpFreq,sTmpSat,sTmpMode,sTmpObservation;
            sSignesVitaux = new StringBuffer();

            while (sTmpSignesVitaux.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpSys = "";
                sTmpDias = "";
                sTmpRythme = "";
                sTmpTemp = "";
                sTmpFreq = "";
                sTmpSat = "";
                sTmpMode = "";
                sTmpObservation = "";

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSys = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDias = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpRythme = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTemp = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpFreq = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSat = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("£")>-1){
                    sTmpMode = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("£"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSignesVitaux.toString().toLowerCase().indexOf("$")>-1){
                    sTmpObservation = sTmpSignesVitaux.substring(0,sTmpSignesVitaux.toString().toLowerCase().indexOf("$"));
                    sTmpSignesVitaux = new StringBuffer(sTmpSignesVitaux.substring(sTmpSignesVitaux.toString().toLowerCase().indexOf("$")+1));
                }

                sSignesVitaux.append("rowSignesVitaux"+iSignesVitauxTotal+"="+sTmpHeure+"£"+sTmpSys+"£"+sTmpDias+"£"+sTmpRythme+"£"+sTmpTemp+"£"+sTmpFreq+"£"+sTmpSat+"£"+sTmpMode+"£"+sTmpObservation+"$");
                sDivSignesVitaux.append(addSignesVitaux(iSignesVitauxTotal, sTmpHeure, sTmpSys, sTmpDias,sTmpRythme,sTmpTemp,sTmpFreq,sTmpSat,sTmpMode,sTmpObservation, sWebLanguage));
                iSignesVitauxTotal++;
            }
        }

        iConscienceTotal = 1;

        if (sConscience.indexOf("£")>-1){
            StringBuffer sTmpConscience = sConscience;
            String sTmpHeure, sTmpYeux, sTmpMotrice, sTmpVerbale, sTmpTotal;
            sConscience = new StringBuffer();

            while (sTmpConscience.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpYeux = "";
                sTmpMotrice = "";
                sTmpVerbale = "";
                sTmpTotal = "";

                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpYeux = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpMotrice = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpConscience.toString().toLowerCase().indexOf("£")>-1){
                    sTmpVerbale = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("£"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpConscience.toString().toLowerCase().indexOf("$")>-1){
                    sTmpTotal = sTmpConscience.substring(0,sTmpConscience.toString().toLowerCase().indexOf("$"));
                    sTmpConscience = new StringBuffer(sTmpConscience.substring(sTmpConscience.toString().toLowerCase().indexOf("$")+1));
                }

                sConscience.append("rowConscience"+iConscienceTotal+"="+sTmpHeure+"£"+sTmpYeux+"£"+sTmpMotrice+"£"+sTmpVerbale+"£"+sTmpTotal+"$");
                sDivConscience.append(addConscience(iConscienceTotal, sTmpHeure, sTmpYeux, sTmpMotrice,sTmpVerbale,sTmpTotal, sWebLanguage));
                iConscienceTotal++;
            }
        }

        iBiometrieTotal = 1;

        if (sBiometrie.indexOf("£")>-1){
            StringBuffer sTmpBiometrie = sBiometrie;
            String sTmpHeure, sTmpPoids, sTmpTaille, sTmpBMI;
            sBiometrie = new StringBuffer();

            while (sTmpBiometrie.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpPoids = "";
                sTmpTaille = "";
                sTmpBMI = "";

                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPoids = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBiometrie.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTaille = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("£"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBiometrie.toString().toLowerCase().indexOf("$")>-1){
                    sTmpBMI = sTmpBiometrie.substring(0,sTmpBiometrie.toString().toLowerCase().indexOf("$"));
                    sTmpBiometrie = new StringBuffer(sTmpBiometrie.substring(sTmpBiometrie.toString().toLowerCase().indexOf("$")+1));
                }

                sBiometrie.append("rowBiometrie"+iBiometrieTotal+"="+sTmpHeure+"£"+sTmpPoids+"£"+sTmpTaille+"£"+sTmpBMI+"$");
                sDivBiometrie.append(addBiometrie(iBiometrieTotal, sTmpHeure, sTmpPoids, sTmpTaille,sTmpBMI,sWebLanguage));
                iBiometrieTotal++;
            }
        }

        iBilanEntreeTotal = 1;

        if (sBilanEntree.indexOf("£")>-1){
            StringBuffer sTmpBilanEntree = sBilanEntree;
            String sTmpHeure, sTmpLactate, sTmpGlucose, sTmpPhysio, sTmpHaem, sTmpTrans, sTmpSang;
            sBilanEntree = new StringBuffer();

            while (sTmpBilanEntree.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpLactate = "";
                sTmpGlucose = "";
                sTmpPhysio = "";
                sTmpHaem = "";
                sTmpTrans = "";
                sTmpSang = "";

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpLactate = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpGlucose = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPhysio = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHaem = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTrans = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("£"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpBilanEntree.toString().toLowerCase().indexOf("$")>-1){
                    sTmpSang = sTmpBilanEntree.substring(0,sTmpBilanEntree.toString().toLowerCase().indexOf("$"));
                    sTmpBilanEntree = new StringBuffer(sTmpBilanEntree.substring(sTmpBilanEntree.toString().toLowerCase().indexOf("$")+1));
                }

                sBilanEntree.append("rowBilanEntree"+iBilanEntreeTotal+"="+sTmpHeure+"£"+sTmpLactate+"£"+sTmpGlucose+"£"+sTmpPhysio+"£"+sTmpHaem+"£"+sTmpTrans+"£"+sTmpSang+"$");
                sDivBilanEntree.append(addBilanEntree(iBilanEntreeTotal, sTmpHeure, sTmpLactate, sTmpGlucose,sTmpPhysio,sTmpHaem,sTmpTrans,sTmpSang,sWebLanguage));
                iBilanEntreeTotal++;
            }
        }

        iSitNutriTotal = 1;

        if (sSitNutri.indexOf("£")>-1){
            StringBuffer sTmpSitNutri = sSitNutri;
            String sTmpHeure, sTmpLait, sTmpBouillie, sTmpPotage, sTmpPB, sTmpPT, sTmpIMC,sTmpObservation;
            sSitNutri = new StringBuffer();

            while (sTmpSitNutri.toString().toLowerCase().indexOf("$")>-1) {
                sTmpHeure = "";
                sTmpLait = "";
                sTmpBouillie = "";
                sTmpPotage = "";
                sTmpPB = "";
                sTmpPT = "";
                sTmpIMC = "";
                sTmpObservation = "";

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpLait = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpBouillie = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPotage = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPB = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpPT = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("£")>-1){
                    sTmpIMC = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("£"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("£")+1));
                }

                if (sTmpSitNutri.toString().toLowerCase().indexOf("$")>-1){
                    sTmpObservation = sTmpSitNutri.substring(0,sTmpSitNutri.toString().toLowerCase().indexOf("$"));
                    sTmpSitNutri = new StringBuffer(sTmpSitNutri.substring(sTmpSitNutri.toString().toLowerCase().indexOf("$")+1));
                }

                sSitNutri.append("rowSitNutri"+iSitNutriTotal+"="+sTmpHeure+"£"+sTmpLait+"£"+sTmpBouillie+"£"+sTmpPotage+"£"+sTmpPB+"£"+sTmpPT+"£"+sTmpIMC+"£"+sTmpObservation+"$");
                sDivSitNutri.append(addSitNutri(iSitNutriTotal, sTmpHeure, sTmpLait, sTmpBouillie,sTmpPotage,sTmpPB,sTmpPT,sTmpIMC,sTmpObservation,sWebLanguage));
                iSitNutriTotal++;
            }
        }
    }
%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <%-- Signes Vitaux --%>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblSignesVitaux" class="list">
                    <tr class="admin">
                        <td colspan="11"><%=getTran("openclinic.chuk","vital.signs",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="40" rowspan="2"/>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin" width="100" colspan="2"><center><%=getTran("openclinic.chuk","ta",sWebLanguage)%></center></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","heartfrequency",sWebLanguage)%></td>
                        <td class="admin" width="90" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","respiration",sWebLanguage)%></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","sa",sWebLanguage)%> O2</td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","mode",sWebLanguage)%>O2</td>
                        <td class="admin" width="150" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
                        <td class="admin" rowspan="2"/>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("openclinic.chuk","sys",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","dias",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="text" class="text" size="5" name="svheure" value="" onblur="checkTime(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svsys" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svdias" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svrythme" value="" onblur="isNumber(this);"> /min
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svtemp" value="" onblur="isNumber(this);"> °C
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svfreq" value="" onblur="isNumber(this);"> /min
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svsat" value="" onblur="isNumber(this);"> %
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="svmode" value="" onblur="isNumber(this);"> %
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="50" name="svobservation" value="">
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddSignesVitaux" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addSignesVitaux();">
                            <input type="button" class="button" name="ButtonUpdateSignesVitaux" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateSignesVitaux();">
                        </td>
                    </tr>
                    <%=sDivSignesVitaux%>
                </table>
            </td>
        </tr>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_5" property="itemId"/>]>.value">
        <tr><td>&nbsp;</td></tr>
        <%-- Conscience --%>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblConscience" class="list">
                    <tr class="admin">
                        <td colspan="7"><%=getTran("openclinic.chuk","consciousness",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="40"/>
                        <td class="admin" width="75"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin" width="150"><%=getTran("openclinic.chuk","opening.eyes",sWebLanguage)%>( /4)</td>
                        <td class="admin" width="150"><%=getTran("openclinic.chuk","mot.reaction",sWebLanguage)%>( /6)</td>
                        <td class="admin" width="150"><%=getTran("openclinic.chuk","verb.reaction",sWebLanguage)%>( /5)</td>
                        <td class="admin" width="150"><%=getTran("web.occup","total",sWebLanguage)%>( /15)</td>
                        <td class="admin"/>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2"><input type="text" class="text" size="5" name="consheure" value="" onblur="checkTime(this);"></td>
                        <td class="admin2"><input type="text" class="text" size="4" name="consyeux" value="" onblur="if(!isNumberLimited(this,0,4))this.value='';calculateTotal();"></td>
                        <td class="admin2"><input type="text" class="text" size="4" name="consmotrice" value="" onblur="if(!isNumberLimited(this,0,6))this.value='';calculateTotal();"></td>
                        <td class="admin2"><input type="text" class="text" size="4" name="consverbale" value="" onblur="if(!isNumberLimited(this,0,5))this.value='';calculateTotal();"></td>
                        <td class="admin2"><input type="text" class="text" size="4" name="constotal" value="" onblur="if(!isNumberLimited(this,0,15))this.value='';"  readonly></td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddConscience" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addConscience();">
                            <input type="button" class="button" name="ButtonUpdateConscience" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateConscience();">
                        </td>
                    </tr>
                    <%=sDivConscience%>
                </table>
            </td>
        </tr>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_5" property="itemId"/>]>.value">
        <tr><td>&nbsp;</td></tr>
        <%-- Biometrie --%>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblBiometrie" class="list">
                    <tr class="admin">
                        <td colspan="6"><%=getTran("openclinic.chuk","biometry",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="40"/>
                        <td class="admin" width="75"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin" width="75"><%=getTran("openclinic.chuk","weigth",sWebLanguage)%></td>
                        <td class="admin" width="75"><%=getTran("openclinic.chuk","heigth",sWebLanguage)%></td>
                        <td class="admin" width="75"><%=getTran("openclinic.chuk","bmi",sWebLanguage)%></td>
                        <td class="admin"/>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2"><input type="text" class="text" size="5" name="bioheure" value="" onblur="checkTime(this);"></td>
                        <td class="admin2"><input type="text" class="text" size="4" name="biopoids" value="" onblur="isNumber(this);calculateBMI();"> kg</td>
                        <td class="admin2"><input type="text" class="text" size="4" name="biotaille" value="" onblur="isNumber(this);calculateBMI();"> cm</td>
                        <td class="admin2"><input type="text" class="text" size="4" name="biobmi" value="" readonly></td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddBiometrie" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addBiometrie();">
                            <input type="button" class="button" name="ButtonUpdateBiometrie" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateBiometrie();">
                        </td>
                    </tr>
                    <%=sDivBiometrie%>
                </table>
            </td>
        </tr>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_5" property="itemId"/>]>.value">
        <tr><td>&nbsp;</td></tr>
        <%-- Input summary --%>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" border="0" id="tblBilanEntree" class="list">
                    <tr class="admin">
                        <td colspan="9"><%=getTran("openclinic.chuk","input.summary",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="40" rowspan="2"/>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin" width="400" colspan="4"><center><%=getTran("openclinic.chuk","perfusions",sWebLanguage)%></center></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","transfusion",sWebLanguage)%></td>
                        <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","blood",sWebLanguage)%></td>
                        <td class="admin" rowspan="2"/>
                    </tr>
                    <tr>
                        <td class="admin" width="100"><%=getTran("openclinic.chuk","lactate",sWebLanguage)%></td>
                        <td class="admin" width="100"><%=getTran("openclinic.chuk","glucose",sWebLanguage)%> 5%</td>
                        <td class="admin" width="100"><%=getTran("openclinic.chuk","physiological",sWebLanguage)%></td>
                        <td class="admin" width="100"><%=getTran("openclinic.chuk","haem",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="text" class="text" size="5" name="bentreeheure" value="" onblur="checkTime(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreelactate" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreeglucose" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreephysio" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreehaem" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreetrans" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="4" name="bentreesang" value="" onblur="isNumber(this);">
                        </td>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddBilanEntree" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addBilanEntree();">
                            <input type="button" class="button" name="ButtonUpdateBilanEntree" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateBilanEntree();">
                        </td>
                    </tr>
                    <%=sDivBilanEntree%>
                </table>
            </td>
        </tr>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_5" property="itemId"/>]>.value">
        <tr><td>&nbsp;</td></tr>
        <%-- Output summary --%>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" border="0" width="100%" class="list">
                    <tr class="admin">
                        <td colspan="8"><%=getTran("openclinic.chuk","output.summary",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="150">
                            <%=getTran("openclinic.chuk","diuresis",sWebLanguage)%>
                        </td>
                        <td class="admin2" width="100">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_DIURESE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DIURESE" property="itemId"/>]>.value" value="<%=sBilanSortieDiurese%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin" width="150">
                            <%=getTran("openclinic.chuk","aspiration",sWebLanguage)%>
                        </td>
                        <td class="admin2" width="100">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_ASPIRATION")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_ASPIRATION" property="itemId"/>]>.value" value="<%=sBilanSortieAspiration%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin" width="150">
                            <%=getTran("openclinic.chuk","vomiting",sWebLanguage)%>
                        </td>
                        <td class="admin2" width="100">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_VOMISSEMENTS")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_VOMISSEMENTS" property="itemId"/>]>.value" value="<%=sBilanSortieVomissements%>" onblur="isNumber(this);"> /j
                        </td>
                        <td class="admin" width="150">
                            <%=getTran("openclinic.chuk","selles",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_SELLES")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_SELLES" property="itemId"/>]>.value" value="<%=sBilanSortieSelles%>" onblur="isNumber(this);"> /j
                        </td>
                    </tr>
                    <tr>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","thoracic.drain",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_THORACIQUE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_THORACIQUE" property="itemId"/>]>.value" value="<%=sBilanSortieDrainThoracique%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","abdominal.drain",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_ABDOMINAL")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_DRAIN_ABDOMINAL" property="itemId"/>]>.value" value="<%=sBilanSortieDrainAbdominal%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","other.drain",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRE_DRAIN")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRE_DRAIN" property="itemId"/>]>.value" value="<%=sBilanSortieAutreDrain%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin"/>
                        <td class="admin2"/>
                    </tr>
                    <tr>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","nasogastric.probe",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_SONDE_NASOGASTRIQUE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_SONDE_NASOGASTRIQUE" property="itemId"/>]>.value" value="<%=sBilanSortieSondeNasogastrique%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin"/>
                        <td class="admin2"/>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","other.exits",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <input <%=setRightClick("ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRES_SORTIES")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANSORTIE_AUTRES_SORTIES" property="itemId"/>]>.value" value="<%=sBilanSortieAutresSorties%>" onblur="isNumber(this);"> ml
                        </td>
                        <td class="admin"/>
                        <td class="admin2">
                    </tr>
                </table>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" border="0" width="100%" class="list">
                <%-- NUTRITIONAL SITUATION--%>
                    <tr class="admin">
                        <td colspan="3"><%=getTran("openclinic.chuk","nutritional.situation",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" rowspan="3" width="100"><%=getTran("openclinic.chuk","balanced.meal",sWebLanguage)%></td>
                        <td class="admin" width="50">   
                            <%=getTran("openclinic.chuk","morning",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MATIN")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MATIN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MATIN" property="value"/></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","midday",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MIDI")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MIDI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_MIDI" property="value"/></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin">
                            <%=getTran("openclinic.chuk","evening",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_SOIR")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_SOIR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_SOIR" property="value"/></textarea>
                        </td>
                    </tr>
                    <tr><td>&nbsp;</tr>
                    <tr>
                        <td colspan="3">
                            <table cellspacing="1" cellpadding="0" border="0" width="100%" id="tblSitNutri" class="list">
                                <tr>
                                    <td class="admin" width="40" rowspan="2"></td>
                                    <td class="admin" width="75" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                                    <td class="admin" width="225" colspan="3"><center><%=getTran("openclinic.chuk","nutritive.liquid",sWebLanguage)%></center></td>
                                    <td class="admin" width="225" colspan="3"><center><%=getTran("openclinic.chuk","nutritional.state",sWebLanguage)%></center></td>
                                    <td class="admin" width="*" rowspan="2" style="vertical-align:bottom;padding-bottom:4px;"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
                                    <td class="admin" width="200" rowspan="2"></td>
                                </tr>
                                <tr>
                                    <td class="admin"><%=getTran("openclinic.chuk","milk",sWebLanguage)%></td>
                                    <td class="admin"><%=getTran("openclinic.chuk","pulp",sWebLanguage)%></td>
                                    <td class="admin"><%=getTran("openclinic.chuk","soup",sWebLanguage)%></td>
                                    <td class="admin"><%=getTran("openclinic.chuk","pb",sWebLanguage)%></td>
                                    <td class="admin"><%=getTran("openclinic.chuk","pt",sWebLanguage)%></td>
                                    <td class="admin"><%=getTran("openclinic.chuk","imc",sWebLanguage)%></td>
                                </tr>
                                <tr>
                                    <td class="admin2"/>
                                    <td class="admin2">
                                        <input type="text" class="text" size="5" name="sitnutriheure" value="" onblur="checkTime(this);">
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutrilait" value="" onblur="isNumber(this);"> ml
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutribouillie" value="" onblur="isNumber(this);"> ml
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutripotage" value="" onblur="isNumber(this);"> ml
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutripb" value="" onblur="isNumber(this);"> cm
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutript" value="" onblur="isNumber(this);"> cm
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="4" name="sitnutriimc" value="" onblur="isNumber(this);" readonly>
                                    </td>
                                    <td class="admin2">
                                        <input type="text" class="text" size="50" name="sitnutriobservation" value="">
                                    </td>
                                    <td class="admin2">
                                        <input type="button" class="button" name="ButtonAddSitNutri" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addSitNutri();">
                                        <input type="button" class="button" name="ButtonUpdateSitNutri" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateSitNutri();">
                                    </td>
                                </tr>
                                <%=sDivSitNutri%>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_1" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_2" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_3" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_4" property="itemId"/>]>.value">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_5" property="itemId"/>]>.value">
        <%-- Other --%>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" border="0" width="100%" class="list">
                    <tr class="admin">
                        <td colspan="2"><%=getTran("openclinic.chuk","other",sWebLanguage).toUpperCase()%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","other",sWebLanguage)%></td>
                        <td class="admin2">
                            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROTSURV_AUTRES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_AUTRES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_AUTRES" property="value"/></textarea>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.surveillance.add") || activeUser.getAccessRight("occup.surveillance.edit")){
    %>
                <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>
<script>
var iSignesVitauxIndex = <%=iSignesVitauxTotal%>;
var sSignesVitaux = "<%=sSignesVitaux%>";
var editSignesVitauxRowid = "";

var iConscienceIndex = <%=iConscienceTotal%>;
var sConscience = "<%=sConscience%>";
var editConscienceRowid = "";

var iBiometrieIndex = <%=iBiometrieTotal%>;
var sBiometrie = "<%=sBiometrie%>";
var editBiometrieRowid = "";

var iBilanEntreeIndex = "<%=iBilanEntreeTotal%>";
var sBilanEntree = "<%=sBilanEntree%>";
var editBilanEntreeRowid = "";

var iSitNutriIndex = <%=iSitNutriTotal%>;
var sSitNutri = "<%=sSitNutri%>";
var editSitNutriRowid = "";

<%-- SIGNES VITAUX FUNCTIONS -------------------------------------------------------------------------%>
function addSignesVitaux(){
  if(isAtLeastOneSignesVitauxFieldFilled()){
      iSignesVitauxIndex++;
      if(transactionForm.svheure.value == ""){
        getTime(transactionForm.svheure);
      }
      sSignesVitaux+="rowSignesVitaux"+iSignesVitauxIndex+"="+transactionForm.svheure.value+"£"
                                                 +transactionForm.svsys.value+"£"
                                                 +transactionForm.svdias.value+"£"
                                                 +transactionForm.svrythme.value+"£"
                                                 +transactionForm.svtemp.value+"£"
                                                 +transactionForm.svfreq.value+"£"
                                                 +transactionForm.svsat.value+"£"
                                                 +transactionForm.svmode.value+"£"
                                                 +transactionForm.svobservation.value+"$";
      var tr = tblSignesVitaux.insertRow(tblSignesVitaux.rows.length);
      tr.id = "rowSignesVitaux"+iSignesVitauxIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteSignesVitaux(rowSignesVitaux"+iSignesVitauxIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editSignesVitaux(rowSignesVitaux"+iSignesVitauxIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.svheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.svsys.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.svdias.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.svrythme.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.svtemp.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;"+transactionForm.svfreq.value;
      tr.appendChild(td);

      td = tr.insertCell(7);
      td.innerHTML =  "&nbsp;"+transactionForm.svsat.value;
      tr.appendChild(td);

      td = tr.insertCell(8);
      td.innerHTML = "&nbsp;"+transactionForm.svmode.value;
      tr.appendChild(td);

      td = tr.insertCell(9);
      td.innerHTML = "&nbsp;"+transactionForm.svobservation.value;
      tr.appendChild(td);

      td = tr.insertCell(10);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSignesVitauxFields()
      transactionForm.ButtonUpdateSignesVitaux.disabled = true;
  }
  return true;
}

function updateSignesVitaux(){
  if(isAtLeastOneSignesVitauxFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.svheure.value == ""){
        getTime(transactionForm.svheure);
      }
    newRow = editSignesVitauxRowid.id+"="
                                         +transactionForm.svheure.value+"£"
                                         +transactionForm.svsys.value+"£"
                                         +transactionForm.svdias.value+"£"
                                         +transactionForm.svrythme.value+"£"
                                         +transactionForm.svtemp.value+"£"
                                         +transactionForm.svfreq.value+"£"
                                         +transactionForm.svsat.value+"£"
                                         +transactionForm.svmode.value+"£"
                                         +transactionForm.svobservation.value;

    sSignesVitaux = replaceRowInArrayString(sSignesVitaux,newRow,editSignesVitauxRowid.id);

    <%-- update table object --%>
    row = tblSignesVitaux.rows[editSignesVitauxRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteSignesVitaux("+editSignesVitauxRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editSignesVitaux("+editSignesVitauxRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.svheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.svsys.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.svdias.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.svrythme.value;
    row.cells[5].innerHTML = "&nbsp;"+transactionForm.svtemp.value;
    row.cells[6].innerHTML = "&nbsp;"+transactionForm.svfreq.value;
    row.cells[7].innerHTML = "&nbsp;"+transactionForm.svsat.value;
    row.cells[8].innerHTML = "&nbsp;"+transactionForm.svmode.value;
    row.cells[9].innerHTML = "&nbsp;"+transactionForm.svobservation.value;

    setCellStyle(row);
    <%-- reset --%>
    clearSignesVitauxFields();
    transactionForm.ButtonUpdateSignesVitaux.disabled = true;
  }
}

function isAtLeastOneSignesVitauxFieldFilled(){
  //if(transactionForm.svheure.value != "")       return true;
  if(transactionForm.svsys.value != "")         return true;
  if(transactionForm.svdias.value != "")        return true;
  if(transactionForm.svrythme.value != "")      return true;
  if(transactionForm.svtemp.value != "")        return true;
  if(transactionForm.svfreq.value != "")        return true;
  if(transactionForm.svsat.value != "")         return true;
  if(transactionForm.svmode.value != "")        return true;
  if(transactionForm.svobservation.value != "") return true;
  return false;
}

function clearSignesVitauxFields(){
  transactionForm.svheure.value = "";
  transactionForm.svsys.value = "";
  transactionForm.svdias.value = "";
  transactionForm.svrythme.value = "";
  transactionForm.svtemp.value = "";
  transactionForm.svfreq.value = "";
  transactionForm.svsat.value = "";
  transactionForm.svmode.value = "";
  transactionForm.svobservation.value = "";
}

function deleteSignesVitaux(rowid){
    if(yesnoDeleteDialog()){
    sSignesVitaux = deleteRowFromArrayString(sSignesVitaux,rowid.id);
    tblSignesVitaux.deleteRow(rowid.rowIndex);
    clearSignesVitauxFields();
  }
}

function editSignesVitaux(rowid){
  var row = getRowFromArrayString(sSignesVitaux,rowid.id);
  transactionForm.svheure.value = getCelFromRowString(row,0);
  transactionForm.svsys.value = getCelFromRowString(row,1);
  transactionForm.svdias.value = getCelFromRowString(row,2);
  transactionForm.svrythme.value = getCelFromRowString(row,3);
  transactionForm.svtemp.value = getCelFromRowString(row,4);
  transactionForm.svfreq.value = getCelFromRowString(row,5);
  transactionForm.svsat.value = getCelFromRowString(row,6);
  transactionForm.svmode.value = getCelFromRowString(row,7);
  transactionForm.svobservation.value = getCelFromRowString(row,8);

  editSignesVitauxRowid = rowid;
  transactionForm.ButtonUpdateSignesVitaux.disabled = false;
}

<!-- CONSCIENCE -->

function addConscience(){
  if(isAtLeastOneConscienceFieldFilled()){
      iConscienceIndex++;
      if(transactionForm.consheure.value == ""){
        getTime(transactionForm.consheure);
      }

      sConscience+="rowConscience"+iConscienceIndex+"="+transactionForm.consheure.value+"£"
                                                       +transactionForm.consyeux.value+"£"
                                                       +transactionForm.consmotrice.value+"£"
                                                       +transactionForm.consverbale.value+"£"
                                                       +transactionForm.constotal.value+"$";
      var tr;
      tr = tblConscience.insertRow(tblConscience.rows.length);
      tr.id = "rowConscience"+iConscienceIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteConscience(rowConscience"+iConscienceIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editConscience(rowConscience"+iConscienceIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.consheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.consyeux.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.consmotrice.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.consverbale.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.constotal.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearConscienceFields()
      transactionForm.ButtonUpdateConscience.disabled = true;
  }
  return true;
}

function updateConscience(){
  if(isAtLeastOneConscienceFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.consheure.value == ""){
      getTime(transactionForm.consheure);
    }
    newRow = editConscienceRowid.id+"="+transactionForm.consheure.value+"£"
                                       +transactionForm.consyeux.value+"£"
                                       +transactionForm.consmotrice.value+"£"
                                       +transactionForm.consverbale.value+"£"
                                       +transactionForm.constotal.value;

    sConscience = replaceRowInArrayString(sConscience,newRow,editConscienceRowid.id);

    <%-- update table object --%>
    row = tblConscience.rows[editConscienceRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteConscience("+editConscienceRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editConscience("+editConscienceRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.consheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.consyeux.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.consmotrice.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.consverbale.value;
    row.cells[5].innerHTML = "&nbsp;"+transactionForm.constotal.value;

    setCellStyle(row);
    <%-- reset --%>
    clearConscienceFields();
    transactionForm.ButtonUpdateConscience.disabled = true;
  }
}

function isAtLeastOneConscienceFieldFilled(){
  if(transactionForm.consheure.value != "")       return true;
  if(transactionForm.consyeux.value != "")         return true;
  if(transactionForm.consmotrice.value != "")        return true;
  if(transactionForm.consverbale.value != "")      return true;
  if(transactionForm.constotal.value != "")        return true;
  return false;
}

function clearConscienceFields(){
  transactionForm.consheure.value = "";
  transactionForm.consyeux.value = "";
  transactionForm.consmotrice.value = "";
  transactionForm.consverbale.value = "";
  transactionForm.constotal.value = "";
}

function deleteConscience(rowid){
    if(yesnoDeleteDialog()){
    sConscience = deleteRowFromArrayString(sConscience,rowid.id);
    tblConscience.deleteRow(rowid.rowIndex);
    clearConscienceFields();
  }
}

function editConscience(rowid){
  var row = getRowFromArrayString(sConscience,rowid.id);

  transactionForm.consheure.value = getCelFromRowString(row,0);
  transactionForm.consyeux.value = getCelFromRowString(row,1);
  transactionForm.consmotrice.value = getCelFromRowString(row,2);
  transactionForm.consverbale.value = getCelFromRowString(row,3);
  transactionForm.constotal.value = getCelFromRowString(row,4);

  editConscienceRowid = rowid;
  transactionForm.ButtonUpdateConscience.disabled = false;
}

<!-- BIOMETRIE -->

function addBiometrie(){
  if(isAtLeastOneBiometrieFieldFilled()){
      iBiometrieIndex++;
      if(transactionForm.bioheure.value == ""){
        getTime(transactionForm.bioheure);
      }
      sBiometrie+="rowBiometrie"+iBiometrieIndex+"="+transactionForm.bioheure.value+"£"
                                                    +transactionForm.biopoids.value+"£"
                                                    +transactionForm.biotaille.value+"£"
                                                    +transactionForm.biobmi.value+"$";

      var tr = tblBiometrie.insertRow(tblBiometrie.rows.length);
      tr.id = "rowBiometrie"+iBiometrieIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteBiometrie(rowBiometrie"+iBiometrieIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editBiometrie(rowBiometrie"+iBiometrieIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.bioheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.biopoids.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.biotaille.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.biobmi.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearBiometrieFields()
      transactionForm.ButtonUpdateBiometrie.disabled = true;
  }
  return true;
}

function updateBiometrie(){
  if(isAtLeastOneBiometrieFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.bioheure.value == ""){
      getTime(transactionForm.bioheure);
    }
    newRow = editBiometrieRowid.id+"="+transactionForm.bioheure.value+"£"
                                       +transactionForm.biopoids.value+"£"
                                       +transactionForm.biotaille.value+"£"
                                       +transactionForm.biobmi.value;

    sBiometrie = replaceRowInArrayString(sBiometrie,newRow,editBiometrieRowid.id);

    <%-- update table object --%>
    row = tblBiometrie.rows[editBiometrieRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteBiometrie("+editBiometrieRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editBiometrie("+editBiometrieRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.bioheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.biopoids.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.biotaille.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.biobmi.value;

    setCellStyle(row);
    <%-- reset --%>
    clearBiometrieFields();
    transactionForm.ButtonUpdateBiometrie.disabled = true;
  }
}

function isAtLeastOneBiometrieFieldFilled(){
  if(transactionForm.bioheure.value != "")       return true;
  if(transactionForm.biopoids.value != "")         return true;
  if(transactionForm.biotaille.value != "")        return true;
  if(transactionForm.biobmi.value != "")      return true;
  return false;
}

function clearBiometrieFields(){
  transactionForm.bioheure.value = "";
  transactionForm.biopoids.value = "";
  transactionForm.biotaille.value = "";
  transactionForm.biobmi.value = "";
}

function deleteBiometrie(rowid){
    if(yesnoDeleteDialog()){
    sBiometrie = deleteRowFromArrayString(sBiometrie,rowid.id);
    tblBiometrie.deleteRow(rowid.rowIndex);
    clearBiometrieFields();
  }
}

function editBiometrie(rowid){
  var row = getRowFromArrayString(sBiometrie,rowid.id);

  transactionForm.bioheure.value = getCelFromRowString(row,0);
  transactionForm.biopoids.value = getCelFromRowString(row,1);
  transactionForm.biotaille.value = getCelFromRowString(row,2);
  transactionForm.biobmi.value = getCelFromRowString(row,3);

  editBiometrieRowid = rowid;
  transactionForm.ButtonUpdateBiometrie.disabled = false;
}

<!-- BILAN ENTREE -->
function addBilanEntree(){
  if(isAtLeastOneBilanEntreeFieldFilled()){
      iBilanEntreeIndex++;
      if(transactionForm.bentreeheure.value == ""){
        getTime(transactionForm.bentreeheure);
      }
      sBilanEntree+="rowBilanEntree"+iBilanEntreeIndex+"="+transactionForm.bentreeheure.value+"£"
                                               +transactionForm.bentreelactate.value+"£"
                                               +transactionForm.bentreeglucose.value+"£"
                                               +transactionForm.bentreephysio.value+"£"
                                               +transactionForm.bentreehaem.value+"£"
                                               +transactionForm.bentreetrans.value+"£"
                                               +transactionForm.bentreesang.value+"$";
      var tr = tblBilanEntree.insertRow(tblBilanEntree.rows.length);
      tr.id = "rowBilanEntree"+iBilanEntreeIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteBilanEntree(rowBilanEntree"+iBilanEntreeIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editBilanEntree(rowBilanEntree"+iBilanEntreeIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.bentreeheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.bentreelactate.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.bentreeglucose.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.bentreephysio.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.bentreehaem.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;"+transactionForm.bentreetrans.value;
      tr.appendChild(td);

      td = tr.insertCell(7);
      td.innerHTML = "&nbsp;"+transactionForm.bentreesang.value;
      tr.appendChild(td);

      td = tr.insertCell(7);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearBilanEntreeFields()
      transactionForm.ButtonUpdateBilanEntree.disabled = true;
  }
  return true;
}

function updateBilanEntree(){
  if(isAtLeastOneBilanEntreeFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.bentreeheure.value == ""){
      getTime(transactionForm.bentreeheure);
    }
    newRow = editBilanEntreeRowid.id+"="+transactionForm.bentreeheure.value+"£"
                                        +transactionForm.bentreelactate.value+"£"
                                        +transactionForm.bentreeglucose.value+"£"
                                        +transactionForm.bentreephysio.value+"£"
                                        +transactionForm.bentreehaem.value+"£"
                                        +transactionForm.bentreetrans.value+"£"
                                        +transactionForm.bentreesang.value;

    sBilanEntree = replaceRowInArrayString(sBilanEntree,newRow,editBilanEntreeRowid.id);

    <%-- update table object --%>
    row = tblBilanEntree.rows[editBilanEntreeRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteBilanEntree("+editBilanEntreeRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editBilanEntree("+editBilanEntreeRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.bentreeheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.bentreelactate.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.bentreeglucose.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.bentreephysio.value;
    row.cells[5].innerHTML = "&nbsp;"+transactionForm.bentreehaem.value;
    row.cells[6].innerHTML = "&nbsp;"+transactionForm.bentreetrans.value;
    row.cells[7].innerHTML = "&nbsp;"+transactionForm.bentreesang.value;

    setCellStyle(row);
    <%-- reset --%>
    clearBilanEntreeFields();
    transactionForm.ButtonUpdateBilanEntree.disabled = true;
  }
}

function isAtLeastOneBilanEntreeFieldFilled(){
  if(transactionForm.bentreeheure.value != "")    return true;
  if(transactionForm.bentreelactate.value != "")    return true;
  if(transactionForm.bentreeglucose.value != "")   return true;
  if(transactionForm.bentreephysio.value != "")      return true;
  if(transactionForm.bentreehaem.value != "")    return true;
  if(transactionForm.bentreetrans.value != "")   return true;
  if(transactionForm.bentreesang.value != "")      return true;
  return false;
}

function clearBilanEntreeFields(){
  transactionForm.bentreeheure.value    = "";
  transactionForm.bentreelactate.value    = "";
  transactionForm.bentreeglucose.value    = "";
  transactionForm.bentreephysio.value   = "";
  transactionForm.bentreehaem.value      = "";
  transactionForm.bentreetrans.value   = "";
  transactionForm.bentreesang.value      = "";
}

function deleteBilanEntree(rowid){
    if(yesnoDeleteDialog()){
    sBilanEntree = deleteRowFromArrayString(sBilanEntree,rowid.id);
    tblBilanEntree.deleteRow(rowid.rowIndex);
    clearBilanEntreeFields();
  }
}

function editBilanEntree(rowid){
  var row = getRowFromArrayString(sBilanEntree,rowid.id);

  transactionForm.bentreeheure.value    = getCelFromRowString(row,0);
  transactionForm.bentreelactate.value  = getCelFromRowString(row,1);
  transactionForm.bentreeglucose.value  = getCelFromRowString(row,2);
  transactionForm.bentreephysio.value   = getCelFromRowString(row,3);
  transactionForm.bentreehaem.value     = getCelFromRowString(row,4);
  transactionForm.bentreetrans.value    = getCelFromRowString(row,5);
  transactionForm.bentreesang.value     = getCelFromRowString(row,6);

  editBilanEntreeRowid = rowid;
  transactionForm.ButtonUpdateBilanEntree.disabled = false;
}

<!-- Situation nutritionelle-->
function addSitNutri(){
  if(isAtLeastOneSitNutriFieldFilled()){
      iSitNutriIndex++;
      if(transactionForm.sitnutriheure.value.length==0){
        getTime(transactionForm.sitnutriheure);
      }
      sSitNutri+="rowSitNutri"+iSitNutriIndex+"="+transactionForm.sitnutriheure.value+"£"
                                         +transactionForm.sitnutrilait.value+"£"
                                         +transactionForm.sitnutribouillie.value+"£"
                                         +transactionForm.sitnutripotage.value+"£"
                                         +transactionForm.sitnutripb.value+"£"
                                         +transactionForm.sitnutript.value+"£"
                                         +transactionForm.sitnutriimc.value+"£"
                                         +transactionForm.sitnutriobservation.value+"$";
      var tr = tblSitNutri.insertRow(tblSitNutri.rows.length);
      tr.id = "rowSitNutri"+iSitNutriIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteSitNutri(rowSitNutri"+iSitNutriIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                     +"<a href='javascript:editSitNutri(rowSitNutri"+iSitNutriIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutriheure.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutrilait.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutribouillie.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutripotage.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutripb.value;
      tr.appendChild(td);

      td = tr.insertCell(6);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutript.value;
      tr.appendChild(td);

      td = tr.insertCell(7);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutriimc.value;
      tr.appendChild(td);

      td = tr.insertCell(8);
      td.innerHTML = "&nbsp;"+transactionForm.sitnutriobservation.value;
      tr.appendChild(td);

      td = tr.insertCell(9);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearSitNutriFields()
      transactionForm.ButtonUpdateSitNutri.disabled = true;
  }
  return true;
}

function updateSitNutri(){
  if(isAtLeastOneSitNutriFieldFilled()){
    <%-- update arrayString --%>
    var newRow,row;
    if(transactionForm.sitnutriheure.value == ""){
      getTime(transactionForm.sitnutriheure);
    }
    newRow = editSitNutriRowid.id+"="+transactionForm.sitnutriheure.value+"£"
                                        +transactionForm.sitnutrilait.value+"£"
                                        +transactionForm.sitnutribouillie.value+"£"
                                        +transactionForm.sitnutripotage.value+"£"
                                        +transactionForm.sitnutripb.value+"£"
                                        +transactionForm.sitnutript.value+"£"
                                        +transactionForm.sitnutriimc.value+"£"
                                        +transactionForm.sitnutriobservation.value;

    sSitNutri = replaceRowInArrayString(sSitNutri,newRow,editSitNutriRowid.id);

    <%-- update table object --%>
    row = tblSitNutri.rows[editSitNutriRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteSitNutri(rowSitNutri"+iSitNutriIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editSitNutri(rowSitNutri"+iSitNutriIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+transactionForm.sitnutriheure.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.sitnutrilait.value;
    row.cells[3].innerHTML = "&nbsp;"+transactionForm.sitnutribouillie.value;
    row.cells[4].innerHTML = "&nbsp;"+transactionForm.sitnutripotage.value;
    row.cells[5].innerHTML = "&nbsp;"+transactionForm.sitnutripb.value;
    row.cells[6].innerHTML = "&nbsp;"+transactionForm.sitnutript.value;
    row.cells[7].innerHTML = "&nbsp;"+transactionForm.sitnutriimc.value;
    row.cells[8].innerHTML = "&nbsp;"+transactionForm.sitnutriobservation.value;

    setCellStyle(row);
    <%-- reset --%>
    clearSitNutriFields();
    transactionForm.ButtonUpdateSitNutri.disabled = true;
  }
}

function isAtLeastOneSitNutriFieldFilled(){
  if(transactionForm.sitnutriheure.value != "")         return true;
  if(transactionForm.sitnutrilait.value != "")          return true;
  if(transactionForm.sitnutribouillie.value != "")      return true;
  if(transactionForm.sitnutripotage.value != "")        return true;
  if(transactionForm.sitnutripb.value != "")            return true;
  if(transactionForm.sitnutript.value != "")            return true;
  if(transactionForm.sitnutriimc.value != "")           return true;
  if(transactionForm.sitnutriobservation.value != "")   return true;
  return false;
}

function clearSitNutriFields(){
  transactionForm.sitnutriheure.value    = "";
  transactionForm.sitnutrilait.value    = "";
  transactionForm.sitnutribouillie.value    = "";
  transactionForm.sitnutripotage.value   = "";
  transactionForm.sitnutripb.value      = "";
  transactionForm.sitnutript.value   = "";
  transactionForm.sitnutriimc.value      = "";
  transactionForm.sitnutriobservation.value      = "";
}

function deleteSitNutri(rowid){
    if(yesnoDeleteDialog()){
    sSitNutri = deleteRowFromArrayString(sSitNutri,rowid.id);
    tblSitNutri.deleteRow(rowid.rowIndex);
    clearSitNutriFields();
  }
}

function editSitNutri(rowid){
  var row = getRowFromArrayString(sSitNutri,rowid.id);

  transactionForm.sitnutriheure.value       = getCelFromRowString(row,0);
  transactionForm.sitnutrilait.value        = getCelFromRowString(row,1);
  transactionForm.sitnutribouillie.value    = getCelFromRowString(row,2);
  transactionForm.sitnutripotage.value      = getCelFromRowString(row,3);
  transactionForm.sitnutripb.value          = getCelFromRowString(row,4);
  transactionForm.sitnutript.value          = getCelFromRowString(row,5);
  transactionForm.sitnutriimc.value         = getCelFromRowString(row,6);
  transactionForm.sitnutriobservation.value = getCelFromRowString(row,7);

  editSitNutriRowid = rowid;
  transactionForm.ButtonUpdateSitNutri.disabled = false;
}

<!-- GENERAL FUNCTIONS -->
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
    }
  }
  return array.join("$");
}

function getRowFromArrayString(sArray, rowid) {
    var array = sArray.split("$");
    var row = "";
    for (var i = 0; i < array.length; i++) {
        if (array[i].indexOf(rowid) > -1) {
            row = array[i].substring(array[i].indexOf("=") + 1);
            break;
        }
    }
    return row;
}

function getCelFromRowString(sRow, celid) {
    var row = sRow.split("£");
    return row[celid];
}

function replaceRowInArrayString(sArray, newRow, rowid) {
    var array = sArray.split("$");
    for (var i = 0; i < array.length; i++) {
        if (array[i].indexOf(rowid) > -1) {
            array.splice(i, 1, newRow);
            break;
        }
    }
    var result = array.join("$");
    return result;//.substring(0, result.length - 1);
}

function submitForm() {
    var maySubmit = true;
    // check familiaal-fields for content
    if (isAtLeastOneSignesVitauxFieldFilled()) {
        if (maySubmit) {
            if (!addSignesVitaux()) {
                maySubmit = false;
            }
        }
    }

    if (isAtLeastOneConscienceFieldFilled()) {
        if (maySubmit) {
            if (!addConscience()) {
                maySubmit = false;
            }
        }
    }

    if (isAtLeastOneBiometrieFieldFilled()) {
        if (maySubmit) {
            if (!addBiometrie()) {
                maySubmit = false;
            }
        }
    }

    if (isAtLeastOneBilanEntreeFieldFilled()) {
        if (maySubmit) {
            if (!addBilanEntree()) {
                maySubmit = false;
            }
        }
    }

    if (isAtLeastOneSitNutriFieldFilled()) {
        if (maySubmit) {
            if (!addSitNutri()) {
                maySubmit = false;
            }
        }
    }

    var sTmpBegin;
    var sTmpEnd;
    while (sSignesVitaux.indexOf("rowSignesVitaux") > -1) {
        sTmpBegin = sSignesVitaux.substring(sSignesVitaux.indexOf("rowSignesVitaux"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sSignesVitaux = sSignesVitaux.substring(0, sSignesVitaux.indexOf("rowSignesVitaux")) + sTmpEnd;
    }

    while (sConscience.indexOf("rowConscience") > -1) {
        sTmpBegin = sConscience.substring(sConscience.indexOf("rowConscience"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sConscience = sConscience.substring(0, sConscience.indexOf("rowConscience")) + sTmpEnd;
    }

    while (sBiometrie.indexOf("rowBiometrie") > -1) {
        sTmpBegin = sBiometrie.substring(sBiometrie.indexOf("rowBiometrie"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sBiometrie = sBiometrie.substring(0, sBiometrie.indexOf("rowBiometrie")) + sTmpEnd;
    }

    while (sBilanEntree.indexOf("rowBilanEntree") > -1) {
        sTmpBegin = sBilanEntree.substring(sBilanEntree.indexOf("rowBilanEntree"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sBilanEntree = sBilanEntree.substring(0, sBilanEntree.indexOf("rowBilanEntree")) + sTmpEnd;
    }

    while (sSitNutri.indexOf("rowSitNutri") > -1) {
        sTmpBegin = sSitNutri.substring(sSitNutri.indexOf("rowSitNutri"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sSitNutri = sSitNutri.substring(0, sSitNutri.indexOf("rowSitNutri")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_1" property="itemId"/>]>.value")[0].value = sSignesVitaux.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_2" property="itemId"/>]>.value")[0].value = sSignesVitaux.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_3" property="itemId"/>]>.value")[0].value = sSignesVitaux.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_4" property="itemId"/>]>.value")[0].value = sSignesVitaux.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SIGN_VITAUX_5" property="itemId"/>]>.value")[0].value = sSignesVitaux.substring(1016,1270);

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_1" property="itemId"/>]>.value")[0].value = sConscience.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_2" property="itemId"/>]>.value")[0].value = sConscience.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_3" property="itemId"/>]>.value")[0].value = sConscience.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_4" property="itemId"/>]>.value")[0].value = sConscience.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_CONSCIENCE_5" property="itemId"/>]>.value")[0].value = sConscience.substring(1016,1270);

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_1" property="itemId"/>]>.value")[0].value = sBiometrie.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_2" property="itemId"/>]>.value")[0].value = sBiometrie.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_3" property="itemId"/>]>.value")[0].value = sBiometrie.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_4" property="itemId"/>]>.value")[0].value = sBiometrie.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BIOMETRIE_5" property="itemId"/>]>.value")[0].value = sBiometrie.substring(1016,1270);

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_1" property="itemId"/>]>.value")[0].value = sBilanEntree.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_2" property="itemId"/>]>.value")[0].value = sBilanEntree.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_3" property="itemId"/>]>.value")[0].value = sBilanEntree.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_4" property="itemId"/>]>.value")[0].value = sBilanEntree.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_BILANENTREE_5" property="itemId"/>]>.value")[0].value = sBilanEntree.substring(1016,1270);

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_1" property="itemId"/>]>.value")[0].value = sSitNutri.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_2" property="itemId"/>]>.value")[0].value = sSitNutri.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_3" property="itemId"/>]>.value")[0].value = sSitNutri.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_4" property="itemId"/>]>.value")[0].value = sSitNutri.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROTSURV_SITUATION_NUTRITIONAL_5" property="itemId"/>]>.value")[0].value = sSitNutri.substring(1016,1270);



    if(maySubmit){
      transactionForm.saveButton.disabled = true;
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
}

function calculateBMI() {
    var _BMI = 0;
    var vWeight = transactionForm.biopoids.value;
    var vHeight = transactionForm.biotaille.value;

    if (vHeight != null && vWeight != null && vHeight > 0) {
        _BMI = (vWeight * 10000) / (vHeight * vHeight);
        if (_BMI > 100 || _BMI < 5) {
            transactionForm.biobmi.value = "";
            transactionForm.sitnutriimc.value = "";
        } else {
            transactionForm.biobmi.value = Math.round(_BMI * 10) / 10;
            transactionForm.sitnutriimc.value = Math.round(_BMI * 10) / 10;
        }
    }
}

function calculateTotal(){
    var vConYeux = transactionForm.consyeux.value;
    var vConMotrice = transactionForm.consmotrice.value;
    var vConVerbale = transactionForm.consverbale.value;

    transactionForm.constotal.value = (vConYeux*1) + (vConMotrice*1) + (vConVerbale*1); 
}


function setCellStyle(row){
    for(i =0;i<row.cells.length;i++){
        row.cells[i].style.color = "#333333";
        row.cells[i].style.fontFamily = "arial";
        row.cells[i].style.fontSize = "10px";
        row.cells[i].style.fontWeight = "normal";
        row.cells[i].style.textAlign = "left";
        row.cells[i].style.paddingLeft = "5px";
        row.cells[i].style.paddingRight = "1px";
        row.cells[i].style.paddingTop = "1px";
        row.cells[i].style.paddingBottom = "1px";
        row.cells[i].style.backgroundColor = "#E0EBF2";
      }
}
</script>