<link href="../_common/_css/metro/lightgray/jtable.css" rel="stylesheet" type="text/css" />
<link href="../_common/_css/jquery-ui.css" rel="stylesheet" type="text/css" />

<script src="../_common/_script/jquery-1.8.2.js" type="text/javascript"></script>
<script src="../_common/_script/jquery-ui.js" type="text/javascript"></script>
<script src="../_common/_script/jquery.jtable.js" type="text/javascript"></script>

<script type="text/javascript">
        $(document).ready(function() {
                $('#StudentTableContainer').jtable({
                        title : 'Students List',
                        paging: true,
                        actions : {
                                listAction : 'http://localhost/openclinic/util/controller.jsp?action=list',
                                    selecting: true, //Enable selecting
                                    multiselect: true, //Allow multiple selecting
                                    selectingCheckboxes: true, //Show checkboxes on first column
                                    selectOnRowClick: false //Enable this to only select using checkboxes
                        },
                        fields : {
                                id : {
                                        title : 'Id',
                                        width : '20%',
                                        key : true,
                                        list : true,
                                        create : false
                                },
                                lastname : {
                                        title : 'LastName',
                                        width : '40%',
                                        edit : false
                                },
                                firstname : {
                                        title : 'Firstname',
                                        width : '40%',
                                        edit : false
                                },
                        }
                });
                $('#StudentTableContainer').jtable('load');
        });
</script>

<div style="text-align: center;">
        <h4>jQuery jTable Setup in java</h4>
        <div id="StudentTableContainer"></div>
</div>
