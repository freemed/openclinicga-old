<script src="<%=sCONTEXTPATH%>/_common/_script/popupsearch.js"></script>
<script src="<%=sCONTEXTPATH%>/_common/_script/prototype.js"></script>
<script src="<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js"></script>

<script>
  Ajax.Responders.register({
    onCreate: function(request){
      Ajax.activeRequestCount++;

      if($("ajaxFloatingLoader")!=null){
        ToggleFloatingLayer("ajaxFloatingLoader",1);
      }

      if($("ajaxLoader")!=null){
        if($("ajaxLoader").style.display=="none" && Ajax.activeRequestCount>0){
          $("ajaxLoader").style.display = "block";
        }
      }
    },
    onComplete: function(request){
      Ajax.activeRequestCount--;

      if($("ajaxFloatingLoader")!=null){
        ToggleFloatingLayer("ajaxFloatingLoader",0);
      }

      if($("ajaxLoader")!=null){
        if($("ajaxLoader").style.display=="block" && Ajax.activeRequestCount==0){
          $("ajaxLoader").style.display = "none";
        }
      }
    },
    onException:function(request){
    }
  });
</script>