package be.mxs.common.util.date;

import java.util.GregorianCalendar;
import java.util.Date;

public class MedwanCalendar extends GregorianCalendar {
    public static Date getNewDate(Date originalDate,long timeInMilliSeconds){
        try{
            MedwanCalendar cal = new MedwanCalendar();
            cal.setTime(originalDate);
            cal.setTimeInMillis(cal.getTimeInMillis()+timeInMilliSeconds);
            return cal.getTime();
        }
        catch (Exception e){
            return new Date();
        }
    }

    public static Date asDate(String sDate){

        Date date = null;
        if (sDate.length()>0){
            MedwanCalendar cal = new MedwanCalendar();
            sDate.replace('.','/');
            sDate.replace('-','/');
            sDate.replace('_','/');
            sDate.replace(' ','/');
            sDate.replace('\\','/');
            int nDay=0;
            int nMonth=0;
            int nYear=0;
            int nDelimiterPos=sDate.indexOf('/');
            if (nDelimiterPos>-1){
                nDay = Integer.parseInt(sDate.substring(0,nDelimiterPos));
                sDate = sDate.substring(nDelimiterPos+1);
                nDelimiterPos=sDate.indexOf('/');
                if (nDelimiterPos>-1){
                    nMonth = Integer.parseInt(sDate.substring(0,nDelimiterPos));
                    sDate = sDate.substring(nDelimiterPos+1);
                    nDelimiterPos=sDate.indexOf('/');
                    if (nDelimiterPos>-1){
                        nYear = Integer.parseInt(sDate.substring(0,nDelimiterPos));
                    }
                    else {
                        nYear = Integer.parseInt(sDate);
                    }
                    try {
                        cal.set(nYear, nMonth-1, nDay);
                        date = cal.getTime();
                    }
                    catch (Exception e){
                        //
                    }
                }
            }
        }
        return date;
    }
}
