package be.mxs.webapp.wl.exceptions;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-avr.-2003
 * Time: 15:19:02
 * To change this template use Options | File Templates.
 */
public class InvalidSessionKeyException extends Exception {

    public InvalidSessionKeyException() {
    }

    public InvalidSessionKeyException(String s) {
        super(s);
    }
}
