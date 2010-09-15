package be.mxs.services.healthrecord.exceptions;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-avr.-2003
 * Time: 13:57:55
 * To change this template use Options | File Templates.
 */
public class TransactionNotFoundException extends Exception {

    public TransactionNotFoundException() {
    }

    public TransactionNotFoundException(String s) {
        super(s);
    }
}
