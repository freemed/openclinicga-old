
function expandAllSections(sectionCount){
  for(var i=1; i<=sectionCount; i++){
    showSection("section"+i,"img"+i);
  }
}

function collapseAllSections(sectionCount){
  for(var i=1; i<=sectionCount; i++){
    hideSection("section"+i,"img"+i);
  }
}

function toggleSection(sectionElem,imgElem){
  if(document.getElementById(imgElem).src.indexOf("minus.jpg") < 0){
    document.getElementById(sectionElem).style.display = "";
    document.getElementById(imgElem).src = "_img/minus.jpg";
  }
  else{
    document.getElementById(sectionElem).style.display = "none";
    document.getElementById(imgElem).src = "_img/plus.jpg";
  }
}

function showSection(sectionElem,imgElem){
  document.getElementById(sectionElem).style.display = "";
  document.getElementById(imgElem).src = "_img/minus.jpg";
}

function hideSection(sectionElem,imgElem){
  document.getElementById(sectionElem).style.display = "none";
  document.getElementById(imgElem).src = "_img/plus.jpg";
}

function selectAllPeri(onoff){
  var peri = document.getElementById("peripheriqueTable");
  var checks = peri.getElementsByTagName("input");

  for(var i=0; i<checks.length; i++){
    checks[i].checked = onoff;
  }
}

function verifyStereo(){
  if(document.all["r15"].checked && document.all["r23"].checked && document.all["r32"].checked &&
     document.all["r44"].checked && document.all["r51"].checked){
    document.all["stereoNormal"].checked = true;
    document.all["stereoAbnormal"].checked = false;

    document.getElementById("normalRadioLabel").style.fontWeight = "bold";
    document.getElementById("abnormalRadioLabel").style.fontWeight = "";
    document.getElementById("normalOrAbnormal").value = "medwan.healthrecord.ophtalmology.Normal";
  }
  else{
    document.all["stereoAbnormal"].checked = true;
    document.all["stereoNormal"].checked = false;

    document.getElementById("abnormalRadioLabel").style.fontWeight = "bold";
    document.getElementById("normalRadioLabel").style.fontWeight = "";
    document.getElementById("normalOrAbnormal").value = "medwan.healthrecord.ophtalmology.Abnormal";
  }
}

function toggleColor(row,col){
  if(document.all["line-"+row+".col-"+col].className!="admin2"){
    document.all["r"+row+col].checked = false;
    document.all["line-"+row+".col-"+col].className = "admin2";
  }
  else{
    document.all["line-"+row+".col-1"].className = "admin2";
    document.all["line-"+row+".col-2"].className = "admin2";
    document.all["line-"+row+".col-3"].className = "admin2";
    document.all["line-"+row+".col-4"].className = "admin2";
    document.all["line-"+row+".col-5"].className = "admin2";

    var element_activated = "line-"+row+".col-"+col;
    if((row=="1" && col=="5") || (row=="2" && col=="3") ||
       (row=="3" && col=="2") || (row=="4" && col=="4") ||
       (row=="5" && col=="1")){
      document.all["line-"+row+".col-"+col].className = "menuItemGreen";
    }
    else{
      document.all["line-"+row+".col-"+col].className = "menuItemRed";
    }
  }

  verifyStereo();
}