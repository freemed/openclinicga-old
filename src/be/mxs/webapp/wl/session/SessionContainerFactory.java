package be.mxs.webapp.wl.session;

import be.mxs.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * User: Michaël
 * Date: 18-avr.-2003
 */
public class SessionContainerFactory {

    private static SessionContainerFactory sessionContainerFactory = null;

    private static final String THIS_CLASS_NAME = "be.mxs.webapp.wl.session.SessionContainerFactory";
    public static final String WO_SESSION_CONTAINER = THIS_CLASS_NAME + ".WO_SESSION_CONTAINER";

    private SessionContainerFactory() {
    }

    public static SessionContainerFactory getInstance() {
        if (sessionContainerFactory == null) {
            sessionContainerFactory = new SessionContainerFactory();
        }

        return sessionContainerFactory;
    }

    public SessionContainerWO getSessionContainerWO(HttpServletRequest request) {
        HttpSession session = request.getSession();
        SessionContainerWO sessionContainerWO = (SessionContainerWO)session.getAttribute(this.WO_SESSION_CONTAINER);

        if (sessionContainerWO == null) {
            sessionContainerWO = new SessionContainerWO();
            session.setAttribute(this.WO_SESSION_CONTAINER, sessionContainerWO);
        }

        return sessionContainerWO;
    }

    public SessionContainerWO getSessionContainerWO(HttpServletRequest request, String containerClassName) throws SessionContainerFactoryException {
        HttpSession session = request.getSession();
        SessionContainerWO sessionContainerWO = (SessionContainerWO)session.getAttribute(this.WO_SESSION_CONTAINER);

        if (sessionContainerWO == null) {
            try {
                sessionContainerWO = ( SessionContainerWO ) Class.forName(containerClassName).newInstance();
            }
            catch (InstantiationException e) {
                throw new SessionContainerFactoryException(e.getMessage());
            }
            catch (IllegalAccessException e) {
                throw new SessionContainerFactoryException(e.getMessage());
            }
            catch (ClassNotFoundException e) {
                throw new SessionContainerFactoryException(e.getMessage());
            }

            session.setAttribute(this.WO_SESSION_CONTAINER, sessionContainerWO);
        }

        return sessionContainerWO;
    }
}
