package be.mxs.common.model.vo.healthrecord.util;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;

import java.util.Date;
import java.util.Vector;

public class TransactionFactoryAlerts extends TransactionFactory {

    public TransactionVO createTransactionVO(UserVO userVO) {
        ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");

        Vector items = new Vector();
        items.add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), IConstants.ITEM_TYPE_ALERTS_LABEL,"",new Date(),itemContextVO));
        items.add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), IConstants.ITEM_TYPE_ALERTS_DESCRIPTION,"",new Date(),itemContextVO));
        items.add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), IConstants.ITEM_TYPE_ALERTS_EXPIRATION_DATE,"",new Date(),itemContextVO));

        return new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),IConstants.TRANSACTION_TYPE_ALERT,new Date(),new Date(),IConstants.TRANSACTION_STATUS_CLOSED, userVO,items);
    }
}
