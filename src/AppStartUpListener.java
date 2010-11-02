import be.openclinic.system.Application;
import be.mxs.common.util.db.MedwanQuery;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.net.InetAddress;
import java.net.UnknownHostException;

import com.jpos.POStest.DS6708;

public final class AppStartUpListener implements ServletContextListener {
    private ServletContext context = null;
    public AppStartUpListener() {}
    public void contextDestroyed(ServletContextEvent event){
        System.out.println("Application Shutdown Process Starting…");
        this.context = null;
        System.out.println("Application Shutdown Process Done…");
    }
    public void contextInitialized(ServletContextEvent event){
        try{
            this.context = event.getServletContext();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
}
