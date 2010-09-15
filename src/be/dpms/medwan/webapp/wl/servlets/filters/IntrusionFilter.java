package be.dpms.medwan.webapp.wl.servlets.filters;

import be.mxs.common.util.system.IntrusionDetector;
import be.mxs.common.util.db.MedwanQuery;

import javax.servlet.Filter;
import javax.servlet.ServletException;
import javax.servlet.FilterConfig;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * User: stijn smets
 * Date: 5-mei-2006
 */
public class IntrusionFilter implements Filter {

    private FilterConfig config;

    //--- INIT ------------------------------------------------------------------------------------
    public void init(FilterConfig config) {
        this.config = config;
    }

    //--- DESTROY ---------------------------------------------------------------------------------
    public void destroy(){

    }

    //--- DO FILTER -------------------------------------------------------------------------------
    public void doFilter(javax.servlet.ServletRequest request, javax.servlet.ServletResponse response,
                         javax.servlet.FilterChain filterChain)
            throws java.io.IOException, javax.servlet.ServletException {

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    	try{
            Connection conn = ad_conn;

            // check wether the intruder is blocked
            String sIntrusionID;
            String sUserLogin = request.getParameter("login");
            if(sUserLogin!=null && sUserLogin.length() > 0){
               sIntrusionID = sUserLogin;
            }
            else{
               sIntrusionID = request.getRemoteAddr();
            }

            boolean blockedTemporarily = false;
            boolean blockedPermanently = IntrusionDetector.isIntruderBlockedPermanently(conn,sIntrusionID);
            int remainingBlockDuration = -1; // all OK

            if(blockedPermanently){
                remainingBlockDuration = 0;
            }
            else{
                blockedTemporarily = IntrusionDetector.isIntruderBlockedTemporarily(conn,sIntrusionID);
                if(blockedTemporarily){
                    remainingBlockDuration = IntrusionDetector.getRemainingBlockDuration(conn,sIntrusionID);
                }
            }

            if(remainingBlockDuration >= 0){
                // go to a page telling the user he has to wait
                String sBlockPage = MedwanQuery.getInstance().getConfigString("Intrusion_BlockPage");
                if(sBlockPage == null){
                    //throw new Exception("IntrusionFilter : configString 'Intrusion_BlockPage' is null");
                    // when throwing an exception, the program can never be accessed, nor can the configString be set.
                    sBlockPage = "blocked.jsp"; // default value
                }
                config.getServletContext().getRequestDispatcher("/"+sBlockPage+"?duration="+remainingBlockDuration).forward(request,response);
            }
            else{
                // no blocking applied : go to the next filter in chain
                filterChain.doFilter(request,response);
            }
            ad_conn.close();
        }
        catch(ServletException se){
            throw new ServletException(se.getMessage());
        }
        catch(SQLException se){
            // table 'intrusionAttempts' not found, so do not register this attempt.
            // The next time, the missing table will have been added by login.jsp.
            filterChain.doFilter(request,response);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- SET FILTER CONFIG -----------------------------------------------------------------------
    public void setFilterConfig(FilterConfig filterConfig){
        init(filterConfig);
    }

    //--- GET FILTER CONFIG -----------------------------------------------------------------------
    public FilterConfig getFilterConfig(){
        return config;
    }

}
