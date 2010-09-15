package be.mxs.webapp.wl.session;

import be.mxs.webapp.wl.exceptions.InvalidSessionKeyException;

import java.util.Hashtable;
import java.util.Random;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-avr.-2003
 * Time: 14:50:19
 * To change this template use Options | File Templates.
 */
public class SessionKeyFactory {

    private static SessionKeyFactory    sessionKeyFactory = null;
    private Hashtable                   sessionKeys = null;
    private int                         sessionId = 0;
    private Random                      random = null;
    private String                      sessionKeyPrefix = "MEDWAN_";
    private String                      sessionKeyRandomSeparator = "_R";
    private String                      sessionKeyTimeSeparator = "_T";

    private final long                  sessionKeyTimeout = 1200000;

    private SessionKeyFactory() {
        sessionKeys = new Hashtable();
        sessionId = 0;
        random = new Random();
    }

    public static SessionKeyFactory getInstance() {

        if (sessionKeyFactory == null) sessionKeyFactory = new SessionKeyFactory();

        return sessionKeyFactory;
    }

    public String createSessionKey() {

        sessionId++;

        String sessionKey = this.sessionKeyPrefix + sessionId + this.sessionKeyRandomSeparator + random.nextLong() + this.sessionKeyTimeSeparator + new Date().getTime();

        sessionKeys.put(new Integer(sessionId), sessionKey);

        ////Debug.println("********************************************************************************************");
        ////Debug.println("SessionKeyFactory.createSessionKey() [" + sessionKey + "]");
        ////Debug.println("********************************************************************************************");

        return sessionKey;
    }

    public boolean isValid(String sessionKey) throws InvalidSessionKeyException {

        ////Debug.println("********************************************************************************************");
        ////Debug.println("SessionKeyFactory.isValid() [" + sessionKey + "]");
        ////Debug.println("********************************************************************************************");

        if (sessionKey == null) throw new InvalidSessionKeyException("SessionKey is null!!!");

        boolean isValid = false;
        String _sessionKeyArg = new String(sessionKey);

        if ( _sessionKeyArg.startsWith( this.sessionKeyPrefix ) ) { // SessionKeyPrefix is OK

            _sessionKeyArg = _sessionKeyArg.substring(this.sessionKeyPrefix.length());

            String  candidateSessionId  = _sessionKeyArg.substring(0, _sessionKeyArg.indexOf(this.sessionKeyRandomSeparator));
            String  candidateTime       = _sessionKeyArg.substring(_sessionKeyArg.indexOf(this.sessionKeyTimeSeparator)+2);
            long    timeUsed            = new Date().getTime() - Long.parseLong(candidateTime);

            try {

                int isessionId = Integer.parseInt(candidateSessionId);
                Integer sessionId = new Integer(isessionId);
                String _sessionKey = (String)sessionKeys.get(sessionId);

                if (_sessionKey == null) {
                    throw new InvalidSessionKeyException();
                }

                if (!_sessionKey.equals(sessionKey)) {

                    throw new InvalidSessionKeyException();

                } else if (timeUsed > this.sessionKeyTimeout) {

                    throw new InvalidSessionKeyException();

                } else {
                    isValid = true;
                }



            } catch (NumberFormatException e) {
                throw new InvalidSessionKeyException();
            }

        }

        ////Debug.println("********************************************************************************************");
        ////Debug.println("SessionKeyFactory.isValid() [" + sessionKey + "] - return value : "+isValid);
        ////Debug.println("********************************************************************************************");

        return isValid;
    }
}
