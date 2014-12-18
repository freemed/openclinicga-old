package be.mxs.common.util.system;

public class HearingLoss {
    public double loss0125;
    public double loss0250;
    public double loss0500;
    public double loss1000;
    public double loss2000;
    public double loss3000;
    public double loss4000;
    public double loss6000;
    public double loss8000;

    public HearingLoss(){
    }

    public HearingLoss(double loss0125, double loss0250, double loss0500, double loss1000,
    		           double loss2000, double loss3000, double loss4000, double loss6000,
    		           double loss8000){
        this.loss0125 = loss0125;
        this.loss0250 = loss0250;
        this.loss0500 = loss0500;
        this.loss1000 = loss1000;
        this.loss2000 = loss2000;
        this.loss3000 = loss3000;
        this.loss4000 = loss4000;
        this.loss6000 = loss6000;
        this.loss8000 = loss8000;
    }

    public double getLoss0125(){
        return loss0125;
    }

    public void setLoss0125(double loss0125){
        this.loss0125 = loss0125;
    }

    public double getLoss0250(){
        return loss0250;
    }

    public void setLoss0250(double loss0250){
        this.loss0250 = loss0250;
    }

    public double getLoss0500(){
        return loss0500;
    }

    public void setLoss0500(double loss0500){
        this.loss0500 = loss0500;
    }

    public double getLoss1000(){
        return loss1000;
    }

    public void setLoss1000(double loss1000){
        this.loss1000 = loss1000;
    }

    public double getLoss2000(){
        return loss2000;
    }

    public void setLoss2000(double loss2000){
        this.loss2000 = loss2000;
    }

    public double getLoss3000(){
        return loss3000;
    }

    public void setLoss3000(double loss3000){
        this.loss3000 = loss3000;
    }

    public double getLoss4000(){
        return loss4000;
    }

    public void setLoss4000(double loss4000){
        this.loss4000 = loss4000;
    }

    public double getLoss6000(){
        return loss6000;
    }

    public void setLoss6000(double loss6000){
        this.loss6000 = loss6000;
    }

    public double getLoss8000(){
        return loss8000;
    }

    public void setLoss8000(double loss8000){
        this.loss8000 = loss8000;
    }

}