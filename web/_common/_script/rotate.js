// Version 1.0, 7/2011, Written by David Votrubec (davidjs.com) and Michal Tehnik (@Mictech) for ST-Software.com
(function ($){
  $.fn.rotateTableCellContent = function(options){
var cssClass = ((options) ? options.className : false) || "vertical";

var cellsToRotate = $('.'+cssClass,this);
var betterCells = [];
cellsToRotate.each(function (){
var cell = $(this), newText = cell.text(),
height = cell.height(), 
width = cell.width(), 
newDiv = $('<div>', { height: width, width: height }),
newInnerDiv = $('<div>', { text: newText, 'class': 'rotated' });

newInnerDiv.css('-webkit-transform-origin', (width / 2)+'px '+(width / 2)+'px');
newInnerDiv.css('-moz-transform-origin', (width / 2)+'px '+(width / 2)+'px');
newDiv.append(newInnerDiv);

betterCells.push(newDiv);
});

cellsToRotate.each(function (i){
$(this).html(betterCells[i]);
});
};
})(jQuery);