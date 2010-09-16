/******************************
* GnooCalendar 1.4
* calendrier dynamique en javascript
* v1 	27/04/2004
* v1.1	19/09/2004 + drag&drop
* v1.2	03/10/2004 + bouton de fermeture 
                   + passage de l'année en paramètre
                   + passage du mois en paramètre
* v1.3	25/11/2004 + fermeture automatique à la sélection d'une date
				   + correction bug lié au positionnement lors du masquage
* v1.4	09/01/2005 + correction bug scrollbar des listes avec Mozilla
* Auteur : zegnoo
* Contact : gleroy@zegnoo.net
******************************/
function GnooCalendar(n, min, max, format,_date)
{
    this.target= null;
	this.format = new String("fr");
	this.name = new String(n);
	this.tag = new String();
	this.title =  new String("GnooCalendar");
	this.date=_date;
	this.moving = new Boolean(false);
	this.vis = new Boolean(false);
	this.free = new Boolean(false);
	this.curYear = new Number(this.date.getFullYear());
	this.maxYear = new Number(this.curYear+max);
	this.minYear = new Number(this.curYear-min);
	this.curMonth= new Number(this.date.getMonth());
/*
* GnooCalendar.setFormat(String format)
* format de date : "fr"=français, "us"=englais
*/
	this.setFormat=function(f)
	{
		this.format=f;
		return;
	}
/*
* GnooCalendar.setFree(Boolean vis)
* affiche ou non des jours feries
*/
	this.setFree=function(vis)
	{
		this.free=vis;
		if(this.vis==true)
			this.show();
		return;
	}

/*
* GnooCalendar.endMove()
* termine le drag & drop
*/
	this.endMove=function()
	{
		if(self.movingCalendar!=null)
		{
			self.movingCalendar.moving=false;
		}
		return false;
	}
/*
* GnooCalendar.getMouse(Event evt)
* change la liste des jours feriés jours feries
*/
	this.getMouse=function(evt)
	{
		
		var event;
		if(document.all)
		{
			event = window.event;
			var scrollObj = (document.documentElement) ? document.documentElement : document.body;
			this.posX = self.event.clientX+scrollObj.scrollLeft;
			this.posY = self.event.clientY+scrollObj.scrollTop;
		}
		else
		{
			event = evt;
			this.posX = evt.pageX ;
			this.posY = evt.pageY ;
		}
		if(self.movingCalendar!=null)
		{
			if(self.movingCalendar.moving==true && self.movingCalendar.vis==true )
				self.movingCalendar.move(this.posY-self.movingCalendar.fixY, this.posX-self.movingCalendar.fixX);
		}
		return false;
	}
/*
* GnooCalendar.move(Number x, Number y)
* déplace le calendrier
*/
	this.move=function(x, y)
	{
		if(!document.layers)
		{
			document.getElementById(this.div).style.top = x+"px";
			document.getElementById(this.div).style.left = y+"px";
		}
		return false;
	}

/*
* GnooCalendar.setFreeDay(Array fd)
* change la liste des jours feriés jours feries
*/
	this.setFreeDay=function(fd)
	{
		this.freeday.length=0;
		for(var i=0; i<fd.length; i++)
			this.freeday[i] = new String(fd[i]);
		if(this.vis==true)
			this.show();
		return;
	}
/*
* GnooCalendar.isFreeDay(d,m)
* true si jour ferié
*/
	this.isFreeDay=function(d,m)
	{
		var tmp = this.checkDate(d)+"/"+this.checkDate(parseInt(m)+1);
		if(this.free==false)
			return false;
		for(var i=0; i<this.freeday.length; i++)
			if( tmp == this.freeday[i])
				return true;
		return false;
	}
/*
* GnooCalendar.setTitle(t)
* change le titre du calendrier
*/
	this.setTitle=function(t)
	{
		this.title = t;
		if(this.vis==true)
			this.show();
		return;
	}
/*
* GnooCalendar.mList()
* retourne la liste des mois 
*/
	this.mList=function()
	{
		var tmp = "<table border='0' cellpadding='0' cellspacing='0' class='Gtab'>";
	
		tmp += "<tr><td align='center' colspan='2' class='Gname'>";
	/*	if(document.layers)
		{
			tmp += "<table width='100%'>";
			tmp += "<tr>";
			tmp += "<td class='Gname' align='center'>"+this.title+"</td>";
			tmp += "<td><a href='javascript://' onclick='"+this.name+".hide();' class='Gname'>X</a></td>";
			tmp += "</tr>";
			tmp += "</table>";
		}
		else
		{
			tmp += "<span style='float:left; text-indent:20px;'>"+this.title+"</span>";
			tmp += "<span style='float:right;'>";
			tmp += "<a href='javascript://' onclick='"+this.name+".hide();' class='Gname'>X</a>";
			tmp += "</span>";
		}       */
		tmp += "</td></tr>";
		tmp += "<tr>";
		tmp += "<td class='Gtxt'><select name='"+this.name+"month' class='Gtxt monthselect' ";
		tmp += "onchange='"+this.name+".setMonth(this[this.selectedIndex].value)' >\n";
		for(var i=0; i<this.month.length; i++)
		{			
			tmp += "<option value='"+i+"'";
			if(this.curMonth==i)
				tmp += " selected";
			tmp += ">"+ this.month[i] +"</option>\n";
		}
		tmp += "</select></td><td class='Gtxt'>\n";
		tmp += this.yList();
		tmp += "</td></tr></table>";
		tmp += this.dList();
		return tmp;
	}
/*
* GnooCalendar.yList()
* retourne la liste des années 
*/
	this.yList=function()
	{
		var tmp = "<select style='width=' name='"+this.name+"year' class='Gtxt yearselect' ";
		tmp += "onchange='"+this.name+".setYear(this[this.selectedIndex].value);' >\n";
		for(var i=this.minYear; i<=this.maxYear; i+=1)
		{
			tmp += "<option value='"+i+"'";
			if(this.curYear==i)
				tmp += " selected";
			tmp += ">"+ i +"</option>\n";
		}
		tmp += "</select>\n";
		return tmp;
	}

	this.dayCell=function(d,n)
	{
		var tmp = new String("");
		var now = new Date();
        //alert("daycell"+now);
        if(this.isFreeDay(d,this.curMonth))
		{
			tmp += "<td class='Gfree'";
		}
		else if (this.checkDate(d)==this.date.getDate()
				&& this.curMonth==this.date.getMonth()
				&& this.curYear==this.date.getFullYear()) 
		{
             // alert(now.getDate()+ " - "+this.date+" "+);
            tmp += "<td class='Gc'";
		}
		else
		{
			tmp += "<td class='Gc"+n+"'";
		}
		if(!document.layers)
		{
			tmp += "title='"+this.checkDate(d)+" "+this.month[this.curMonth]+" "+this.curYear+"'";
			tmp += " onmousedown='addDays(\"";
			tmp += this.formatDate(d);
			tmp += "\",0);' ";
			tmp += " onmouseover='this.className=this.className+\"on\";' ";
			tmp += " onmouseout='this.className= this.className.substring(0,this.className.indexOf(\"on\"));'";
		}
		else
			tmp += " width='22' height='16' ";
		tmp += ">";
		return tmp;
	}
/*
* GnooCalendar.dList()
* retourne le tableau des jours
*/
	this.dList=function()
	{
		var cur=new Number(1);
     //   alert(cur);
        var tmpDate = new Date();
		var tmp = new String("<table border='0' cellpadding='0' cellspacing='0' class='Gtab'>");
		tmpDate.setDate(cur);
		tmpDate.setMonth(this.curMonth);
		tmpDate.setFullYear(this.curYear);
		tmp += "<tr>\n";
		for(var i=1; i<this.day.length; i++)
			tmp += "<td class='Gh"+i+"'>"+ this.day[i] +"</td>\n";
		tmp += "<td class='Gh0'>"+ this.day[0] +"</td>\n";
		tmp += "</tr>\n";
		for(var j=0; j<6; j++)
		{
			tmp += "<tr>\n";
			for(var i=1; i<this.day.length; i++)
			{
				tmpDate.setDate(cur);			
				if( cur<=31 && i==tmpDate.getDay() && this.curMonth==tmpDate.getMonth())
				{
					tmp += this.dayCell(cur,i);
					tmp += this.getLink(cur);
					cur+=1;
				}
				else
				{
                    tmp += "<td class='Gc"+i+"'";
					tmp += ">&nbsp;";
				}
				tmp += "</td>\n";
				tmpDate.setDate(cur);
			}
			if( cur==tmpDate.getDate() && this.curMonth==tmpDate.getMonth())
			{
				tmp += this.dayCell(cur,0);
				tmp += this.getLink(cur);
				cur+=1;
			}
			else
			{
				tmp += "<td class='Gc0'";
				tmp += ">&nbsp;";
			}
			tmp += "</td>\n</tr>\n";
		}
		tmp += "</table>\n";
		return tmp;
	}
/*
* GnooCalendar.getLink(c)
* retourne la balise d'un lien
*/
	this.getLink = function(c)
	{
		var tmp = new String("");
		if(document.layers)
		{
			tmp = "<a href='javascript://' ";
			tmp += "onclick='"+this.name+".getDate(\"";
			tmp += this.formatDate(c);
			tmp += "\");' class='NSday'>"+(c)+"</a>";
		}
		else
		{
			tmp = (c);
		}
		return tmp;
	}
/*
* GnooCalendar.setMonth( Integer m )
* modifie le mois à afficher
*/
	this.setMonth = function(m)
	{
		this.curMonth = m;
		this.show();
		return;
	}
/*
* GnooCalendar.getYear( Integer y )
* modifie l'année à afficher
*/
	this.getYear = function (y)
	{
		if(document.layers)
		{
			for(var i=0; i<document.layers[this.div].document.forms[this.name+"_form"][this.name+"year"].length; i++)
			{
				if(document.layers[this.div].document.forms[this.name+"_form"][this.name+"year"][i].value==y)
				{
					document.layers[this.div].document.forms[this.name+"_form"][this.name+"year"].selectedIndex=i;
					this.setYear(y);
					return;
				}
			}
		}
		else
		{
			for(var i=0; i<document.forms[this.name+"_form"].elements[this.name+"year"].length; i++)
			{
				if(document.forms[this.name+"_form"].elements[this.name+"year"][i].value==y)
				{
					document.forms[this.name+"_form"].elements[this.name+"year"].selectedIndex=i;
					this.setYear(y);
					return;
				}
			}
		}
		return;
	}
/*
* GnooCalendar.getMonth( Integer m )
* modifie le mois à afficher
*/
	this.getMonth = function (d)
	{
		if(document.layers)
		{
			for(var i=0; i<document.layers[this.div].document.forms[this.name+"_form"][this.name+"month"].length; i++)
			{
				if(document.layers[this.div].document.forms[this.name+"_form"][this.name+"month"][i].value==d)
				{
					document.layers[this.div].document.forms[this.name+"_form"][this.name+"month"].selectedIndex=i;
					this.setMonth(d);
					return;
				}
			}
		}
		else
		{
			for(var i=0; i<document.forms[this.name+"_form"].elements[this.name+"month"].length; i++)
			{
				if(document.forms[this.name+"_form"].elements[this.name+"month"][i].value==d)
				{
					document.forms[this.name+"_form"].elements[this.name+"month"].selectedIndex=i;
					this.setMonth(d);
					return;
				}
			}
		}
		return;
	}
/*
* GnooCalendar.setYear( Integer y )
* modifie l'année à afficher
*/
	this.setYear = function (y)
	{
		this.curYear = y;
		this.show();
		return;
	}
/*
* GnooCalendar.setTarget( Object obj )
* change le champs cible d'affichage de la date
* BUG OPERA!
*/
	this.setTarget = function (obj)
	{
		this.target = obj;

        return;
	}
/*
* GnooCalendar.hide()
* masque le calendrier
*/
	this.hide = function()
	{
		if(document.layers)
			document.layers[this.div].visibility='hide';
		else
		{
			document.getElementById(this.div).style.visibility = 'hidden';
			document.getElementById(this.div).style.display = 'none';
		}
		this.vis = false;
		this.endMove();
		return;
	}

/*
* GnooCalendar.getDate()
* retourne la date selectionnée dans le champs cible
*/
	this.getDate = function(d)
	{
        if(this.target!=null)
		{

            this.target.value=d;
             executeDate();
            //this.hide();
		}
		return;
	}

/*
* GnooCalendar.show()
* affiche le calendrier
*/
	this.show = function()
	{

        this.vis = true;
		this.tag = "<form name='"+this.name+"_form' method='post'>\n";
		this.tag += this.mList();
		this.tag += "</form>\n";
		if(document.layers)
		{
			with(document.layers[this.div])
			{				
				document.open("text/html");
				document.write(this.tag);
				document.close();
				visibility='show';
			}
		}
		else
		{

            document.getElementById(this.div).innerHTML = ""+this.tag;
			document.getElementById(this.div).style.visibility = 'visible';
			document.getElementById(this.div).style.display = 'block';
		}
		return;
	}
/*
* GnooCalendar.init( String d )
* initialise le Calendrier à la date actuelle
* paramêtres : 
* d : nom du calque d'affichage
* obj : objet dont la propriété value va recevoir le String de la date
*/
	this.init = function(d, obj)
	{
		this.div=d;
		this.target = obj;
		this.date=new Date();
		this.date.setDate(1);		
		this.curMonth = this.date.getMonth();
		this.curYear = this.date.getFullYear();
		if(!self.movingCalendar)
			self.movingCalendar=null;
		return;
	}
    this.change = function(d, obj,_date)
	{
		this.div=d;
		this.target = obj;
		this.date=_date;
        //this.date.setDate(this.date.getDate());

        this.curMonth = this.date.getMonth();
		this.curYear = this.date.getFullYear();
        //alert(this.date.getMonth()+" "+this.date.getDate()+" "+this.date.getFullYear());
        this.date.getDate();
        if(!self.movingCalendar)
			self.movingCalendar=null;
		return;
	}
/*
* GnooCalendar.checkDate( Integer d )
* paramêtre : le jour d'une date
*/
	this.checkDate = function(d)
	{
		if(parseInt(d)<=9)
			return "0"+parseInt(d);
		return parseInt(d);
	}
/*
* GnooCalendar.formatDate( Integer d, Integer m, Integer y )
* paramêtre : le jour d'une date
*/
	this.formatDate = function(c)
	{
		var tmp = "";
		switch(this.format)
		{
			case "us":	// englais	
				tmp = this.curYear+"-";
				tmp += this.checkDate(1+parseInt(this.curMonth))+"-";
				tmp += this.checkDate(c);
				break;
			default: 	// français
				tmp = this.checkDate(c)+"/";
				tmp += this.checkDate(1+parseInt(this.curMonth))+"/";
				tmp += this.curYear;
				break;
		}
		return tmp;

	}
	return this;
}
/******************************/
GnooCalendar.prototype.day = ["D", "L", "M", "M", "J", "V", "S" ];
GnooCalendar.prototype.month = ["Janvier", 
				"F&eacute;vrier", 
				"Mars", 
				"Avril", 
				"Mai", 
				"Juin", 
				"Juillet", 
				"Ao&ucirc;t", 
				"Septembre", 
				"Octobre", 
				"Novembre", 
				"D&eacute;cembre"];
/* jours feriés français */
GnooCalendar.prototype.freeday= ["01/01","01/05","08/05","14/07","15/08","01/11","11/11","25/12"];
/******************************/
