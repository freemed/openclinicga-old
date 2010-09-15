package be.mxs.common.util.system;

import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 27-sep-2005
 * Time: 8:48:29
 * To change this template use Options | File Templates.
 */
public class Audiometry {
    public static HearingLoss calculateHearingloss(int age,String gender){
        HearingLoss loss= new HearingLoss();
        HearingLoss low ,high;
        Hashtable male = new Hashtable();
        Hashtable female = new Hashtable();
        male.put("20",new HearingLoss(0.01,0.01,0.01,0.02,0.03,0.05,0.06,0.07,0.09));
        male.put("30",new HearingLoss(0.43,0.43,0.5,0.58,1.01,1.66,2.3,2.59,3.17));
        male.put("40",new HearingLoss(1.45,1.45,1.69,1.94,3.39,5.57,7.74,8.71,10.65));
        male.put("50",new HearingLoss(3.07,3.07,3.58,4.1,7.17,11.78,16.38,18.43,22.53));
        male.put("60",new HearingLoss(5.29,5.29,6.17,7.06,12.35,20.29,28.22,31.75,38.81));
        male.put("70",new HearingLoss(8.11,8.11,9.46,10.82,18.93,31.1,43.26,48.67,59.49));
        female.put("20",new HearingLoss(0.01,0.01,0.01,0.02,0.03,0.05,0.06,0.07,0.09));
        female.put("30",new HearingLoss(0.43,0.43,0.5,0.58,0.86,1.08,1.3,1.73,2.16));
        female.put("40",new HearingLoss(1.45,1.45,1.69,1.94,2.9,3.63,4.36,5.81,7.26));
        female.put("50",new HearingLoss(3.07,3.07,3.58,4.1,6.14,7.68,9.22,12.29,15.36));
        female.put("60",new HearingLoss(5.29,5.29,6.17,7.06,10.58,13.23,15.88,21.17,26.46));
        female.put("70",new HearingLoss(8.11,8.11,9.46,10.82,16.22,20.28,24.34,32.45,40.56));
        //First find the lower age-class
        String lowerLoss = Integer.toString(new Integer(age / 10).intValue() * 10);
        int lowAge=Integer.parseInt(lowerLoss);
        if (lowAge<20){
            lowAge=20;
            lowerLoss="20";
        }
        else if (lowAge>70){
            lowAge=70;
            lowerLoss="70";
        }
        String upperLoss = Integer.toString(new Integer(age / 10).intValue() * 10 + 10);
        int highAge=Integer.parseInt(upperLoss);
        if (age % 10==0){
            upperLoss=lowerLoss;
            highAge=lowAge;
        }
        else if (highAge<20){
            highAge=20;
            upperLoss="20";
        }
        else if (highAge>70){
            highAge=70;
            upperLoss="70";
        }
        if (gender.equalsIgnoreCase("M")){
            if (upperLoss.equalsIgnoreCase(lowerLoss)){
                return (HearingLoss)male.get(lowerLoss);
            }
            else {
                low = (HearingLoss)male.get(lowerLoss);
                high = (HearingLoss)male.get(upperLoss);
            }
        }
        else {
            if (upperLoss.equalsIgnoreCase(lowerLoss)){
                return (HearingLoss)female.get(lowerLoss);
            }
            else {
                low = (HearingLoss)female.get(lowerLoss);
                high = (HearingLoss)female.get(upperLoss);
            }
        }
        loss.setLoss250(low.getLoss250()+(high.getLoss250()-low.getLoss250())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss500(low.getLoss500()+(high.getLoss500()-low.getLoss500())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss1000(low.getLoss1000()+(high.getLoss1000()-low.getLoss1000())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss2000(low.getLoss2000()+(high.getLoss2000()-low.getLoss2000())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss3000(low.getLoss3000()+(high.getLoss3000()-low.getLoss3000())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss4000(low.getLoss4000()+(high.getLoss4000()-low.getLoss4000())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss6000(low.getLoss6000()+(high.getLoss6000()-low.getLoss6000())*(age-lowAge)/(highAge-lowAge));
        loss.setLoss8000(low.getLoss8000()+(high.getLoss8000()-low.getLoss8000())*(age-lowAge)/(highAge-lowAge));
        return loss;
    }
}
