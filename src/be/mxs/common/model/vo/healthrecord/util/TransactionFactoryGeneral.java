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

    public TransactionVO createTransactionVO(UserVO userVO) {

        return null;
    }
    public TransactionVO createTransactionVO(UserVO userVO,String transactionType) {
        ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
        Vector items= MedwanQuery.getInstance().loadTransactionItems(transactionType,itemContextVO);
        addItem(items, new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                            IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID,
                                            this.getActiveContext().getConvocationId(),
                                            new Date(),
                                            itemContextVO));
        addItem(items, new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                            IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT,
                                            this.getActiveContext().getDepartment(),
                                            new Date(),
                                            itemContextVO));
        addItem(items, new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                            IConstants.ITEM_TYPE_CONTEXT_CONTEXT,
                                            this.getActiveContext().getContext(),
                                            new Date(),
                                            itemContextVO));
        TransactionVO transactionVO;
        transactionVO = new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),transactionType,new Date(),new Date(), IConstants.TRANSACTION_STATUS_CLOSED, userVO,items);
        return transactionVO;
    }

    private void addItem(Vector items,ItemVO item){
        for (int n=0;n<items.size();n++){
            if (((ItemVO)items.elementAt(n)).getType().equalsIgnoreCase(item.getType())){
                return;
            }
        }
        items.add(item);
    }
}
