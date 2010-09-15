function toggle(element) {

    element_details = element + "-details";
    element_plus = element + "-plus";
    element_minus = element + "-minus";

    if (document.all[element_details].style.display == '') {
        document.all[element_details].style.display = 'none';
        document.all[element_plus].style.display = '';
        document.all[element_minus].style.display = 'none';
    } else {
        document.all[element_details].style.display = '';
        document.all[element_plus].style.display = 'none';
        document.all[element_minus].style.display = '';
    }

}

function toggle_id(element) {

    if (document.all[element].style.display == '') {
        document.all[element].style.display = 'none';
    } else {
        document.all[element].style.display = '';
    }

}

function show(element) {
    document.all[element].style.display = '';
}

function hide(element) {
    document.all[element].style.display = 'none';
}

function popup(mylink, windowname)
{
    if (! window.focus)return true;

    var href;

    if (typeof(mylink) == 'string')
       href=mylink;
    else
       href=mylink.href;

    window.open(href, windowname, 'width=400,height=400,scrollbars=yes');
    return false;
}
