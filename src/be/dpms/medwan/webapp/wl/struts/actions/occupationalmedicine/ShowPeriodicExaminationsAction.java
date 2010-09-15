package be.dpms.medwan.webapp.wl.struts.actions.occupationalmedicine;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.Vector;
import java.util.Hashtable;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileVO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.model.vo.healthrecord.HealthRecordVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 02-avr.-2003
 * Time: 8:54:50
 */
public class ShowPeriodicExaminationsAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {


        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );

        RiskProfileVO riskProfileVO = null;

        try {

            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            PersonVO personVO = sessionContainerWO.getPersonVO();
            //Debug.println("personVO="+personVO);

            HealthRecordVO healthRecordVO = null;

            //healthRecordVO = HealthRecordBusinessDelegate.getInstance().findHealthRecord(personVO, "be.mxs.healthrecord.transactionVO.date");
            healthRecordVO = MedwanQuery.getInstance().loadHealthRecord(personVO, "be.mxs.healthrecord.transactionVO.date",sessionContainerWO);
            //Debug.println("healthRecordVO="+healthRecordVO);

            sessionContainerWO.setHealthRecordVO(healthRecordVO);

            //riskProfileVO = MedwanBusinessDelegate.getInstance().getCurrentProfile( personVO );
            riskProfileVO = MedwanQuery.getInstance().getRiskProfileVO(new Long(personVO.getPersonId().longValue()),sessionContainerWO);

            sessionContainerWO.setRiskProfileVO( riskProfileVO );

            //RiskProfileVO RiskProfileVO = MedwanQuery.getInstance().getRiskProfileVO(riskProfileVO.getPersonId(),sessionContainerWO);
            //if (RiskProfileVO != null) //Debug.println("Found profile for personId "+RiskProfileVO.getPersonId());

            TransactionVO lastTransaction_biometry = null;
            if (healthRecordVO !=null){
                Hashtable lastItems = MedwanQuery.getInstance().getLastItems(healthRecordVO.getHealthRecordId().toString());
                try{
                    ItemVO item;
                    TransactionVO transaction;
                    String transactionType;

                    //Biometrie
                    transaction = lastTransaction_biometry;
                    transactionType = IConstants.TRANSACTION_TYPE_BIOMETRY;

                    //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
                    item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
                    if (item!=null){
                        if (transaction == null){
                            transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                            transaction.setItems(new Vector());
                        }
                        if (transaction.getUpdateTime()==null){
                            transaction.setUpdateTime(item.getDate());
                        }
                        else if (transaction.getUpdateTime().before(item.getDate())){
                            transaction.setUpdateTime(item.getDate());
                        }
                        transaction.getItems().add(item);
                    }

                    //item = MedwanQuery.getInstance().getLastItemVO(healthRecordVO.getHealthRecordId().toString(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
                    item=(ItemVO)lastItems.get("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
                    if (item!=null){
                        if (transaction == null){
                            transaction = new TransactionVO(new Integer(0),transactionType,null,null,IConstants.TRANSACTION_STATUS_CLOSED,null,null);
                            transaction.setItems(new Vector());
                        }
                        if (transaction.getUpdateTime()==null){
                            transaction.setUpdateTime(item.getDate());
                        }
                        else if (transaction.getUpdateTime().before(item.getDate())){
                            transaction.setUpdateTime(item.getDate());
                        }
                        transaction.getItems().add(item);
                    }

                    if (transaction != null) sessionContainerWO.setLastTransactionTypeBiometry( transaction );


                }
                catch (Exception e){
                    e.printStackTrace();
                }
            }

//        } catch (InternalServiceException e) {
//            e.printStackTrace();
//            actionForward = mapping.findForward( "failure" );
//        } catch (RiskProfileNotFoundException e) {
//            e.printStackTrace();
//            actionForward = mapping.findForward( "failure.riskProfile.RiskProfileNotFoundException" );
        } catch (SessionContainerFactoryException e) {
            e.printStackTrace();
            actionForward = mapping.findForward( "failure.webapp.SessionContainerFactoryException" );
//        } catch (PersonNotFoundException e) {
//            e.printStackTrace();
//            actionForward = mapping.findForward( "failure" );
//        } catch (be.mxs.services.exceptions.InternalServiceException e) {
//            e.printStackTrace();
//            actionForward = mapping.findForward( "failure" );
        }

       // long end = new java.util.Date().getTime();

        //Debug.println("#### ShowPeriodicExaminationsAction done in " + (end-start) + " msec");

        return actionForward;
    }
}
