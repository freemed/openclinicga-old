package be.mxs.common.model.vo.healthrecord.util;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.common.model.vo.authentication.UserVO;

import java.util.Date;
import java.util.Vector;

public class TransactionFactoryGeneral extends TransactionFactory {

	//--- CREATE TRANSACTIONVO --------------------------------------------------------------------
	// only for inheritance
    public TransactionVO createTransactionVO(UserVO userVO){
        return null;
    }
    
    //--- CREATE TRANSACTIONVO (2) ----------------------------------------------------------------
    public TransactionVO createTransactionVO(UserVO userVO, String transactionType){
        return createTransactionVO(userVO,transactionType,true);	
    }
    
    public TransactionVO createTransactionVO(UserVO userVO, String transactionType, boolean loadDefaultValues){
        ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
        Vector items = MedwanQuery.getInstance().loadTransactionItems(transactionType,itemContextVO,loadDefaultValues);
        
        // add common items
        addItem(items, new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID,
                                    this.getActiveContext().getConvocationId(),
                                    new Date(),
                                    itemContextVO));
        addItem(items, new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT,
                                    this.getActiveContext().getDepartment(),
                                    new Date(),
                                    itemContextVO));
        addItem(items, new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CONTEXT_CONTEXT,
                                    this.getActiveContext().getContext(),
                                    new Date(),
                                    itemContextVO));
        
        return new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),transactionType,new Date(),new Date(), IConstants.TRANSACTION_STATUS_CLOSED, userVO,items);
    }

    //--- ADD ITEM --------------------------------------------------------------------------------
    private void addItem(Vector items,ItemVO item){
        for (int n=0;n<items.size();n++){
            if (((ItemVO)items.elementAt(n)).getType().equalsIgnoreCase(item.getType())){
                return;
            }
        }
        items.add(item);
    }
    
}
