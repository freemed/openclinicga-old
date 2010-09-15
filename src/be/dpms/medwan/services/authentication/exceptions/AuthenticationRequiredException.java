package be.dpms.medwan.services.authentication.exceptions;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 10-avr.-2003
 * Time: 21:09:53
 */
public class AuthenticationRequiredException extends Exception {

    public AuthenticationRequiredException() {
    }

    public AuthenticationRequiredException(String s) {
        super(s);
    }
}
