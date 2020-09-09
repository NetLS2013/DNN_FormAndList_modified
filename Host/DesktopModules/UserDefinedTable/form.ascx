<%@ Control Language="C#" Inherits="DotNetNuke.Modules.UserDefinedTable.EditForm" CodeBehind="Form.ascx.cs" AutoEventWireup="false" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>
<dnn:DnnCssInclude runat="server" FilePath="~/Resources/Shared/components/TimePicker/Themes/jquery-ui.css" />
<dnn:DnnCssInclude runat="server" FilePath="~/Resources/Shared/components/TimePicker/Themes/jquery.ui.theme.css" />


<div runat="server" id="divForm" class="dnnForm fnlForm dnnClear">

    <div runat="server" id="EditFormPlaceholder" />
    <asp:Panel ID="gRecaptcha" CssClass="recaptcha-container" runat="server" />
    <ul class="dnnActions dnnClear">
        <li>
            <asp:LinkButton ID="cmdUpdate" Text="Update" runat="server" resourcekey="cmdUpdate" CssClass="dnnPrimaryAction reCaptchaSubmit" />
        </li>
        <li>
            <asp:LinkButton ID="cmdCancel" Text="Cancel" CausesValidation="False" resourcekey="cmdCancel" runat="server" CssClass="dnnSecondaryAction" />
        </li>
        <li>
            <asp:LinkButton ID="cmdDelete" Text="Delete" CausesValidation="False" resourcekey="cmdDelete" runat="server" class="dnnSecondaryAction" />
        </li>
        <li>
            <asp:HyperLink runat="server" CssClass="dnnSecondaryAction" ID="cmdShowRecords" Visible="False"></asp:HyperLink>
        </li>
    </ul>
</div>
<div runat="server" id="MessagePlaceholder" />
<script type="text/javascript">
    /* Wrap your code in a function to avoid global scope and pass in any global objects */
    /* globals jQuery, window, Sys */
    (function ($, Sys) {

        /* wire up any plugins or other logic here */

        function setUpMyModule() {
            $('#<%=EditFormPlaceholder.ClientID%>').dnnPanels();
            $('.fnl-datepicker').datepicker({
                monthNames: [<%=LocalizeString("MonthNames")%>],
            dayNames: [<%=LocalizeString("DayNames")%>],
            dayNamesMin: [<%=LocalizeString("DayNamesMin")%>],
            firstDay:    <%:LocalizeString("FirstDay")%>,
            dateFormat:  '<%:JsUiDatePattern %>'
        });
        }

        /* wire up the call to your function on document ready */
        $(document).ready(function () {

            setUpMyModule();

            /* Wire up the call to your function after an update panel request */
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                setUpMyModule();
            });
        });

    }(jQuery, window.Sys))
</script>

<!-- js crutch for image filter -->
<!-- To make sure it's working correctly, you need to create folder "Portals\0\VacancyBackgroundImage" on server
    using any RichTextEditor (for instance in standard HTML module). Press insert image and in new window create new folder.
    Creating folder manually in file explorer or programmatically doesn't work.
    DataTypes.Image.cs contains commented code for programmatical folder creation. -->
<% if (NeedToApplyJsCrutch)
    { %>
<script type="text/javascript">
    $(document).ready(function () {
        let moduleScope = $('#<%=divForm.ClientID %>');

        const selector = 'input[type="file"]';
        const errorBlock = '.imgInputError';
        const submitButton = 'a[title="Upload Selected File"]';
        const linkTypeBlock = '.urlControlLinkType';
        const folder = '<% =JsCrutchBackgroundImgFolder %>';
        const folderSelector = `select option[value="${folder}"]`;

        $(linkTypeBlock, moduleScope).ready(() => {
            if (!$(`${linkTypeBlock} input[type="radio"]`, moduleScope).last().is(':checked')) {
                $(`${linkTypeBlock} input[type="radio"]`, moduleScope).last().click();
            } else {
                const folderText = $(folderSelector, moduleScope).val();
                if (!folderText) {
                    showImgError($('a[title="Upload New File"]', moduleScope).parents().eq(1)[0], `Folder ${folder} doesn't exist on server.
                        Please create it via any RichTextEditor after you click "paste image".`);
                    $('a[title="Upload New File"]').addClass('disabled-link');
                }
                const select = $(folderSelector, moduleScope).parent()[0];
                const currentFolder = $(select, moduleScope).val();
                if (currentFolder !== folder) {
                    $(select, moduleScope).val(folder);
                    $(select, moduleScope).change();
                }
                $(folderSelector, moduleScope).parent().parent().parent().hide();
                $(linkTypeBlock, moduleScope).hide();
            }
        });

        $(selector, moduleScope).on('change', (event) => {
            $(errorBlock, moduleScope).last().remove();
            const imgName = $(event.target, moduleScope).val();
            let imgType = imgName.split('.');
            imgType = imgType[imgType.length - 1];
            const isRightFormat = imgType == "jpg" || imgType == "jpeg" || imgType == "png";
            $(selector, moduleScope).css("width", "100%");
            $(selector, moduleScope).parent()[0].firstChild.textContent = imgName;

            if (!isRightFormat) {
                showImgError($(selector, moduleScope).parents().eq(3)[0], 'Only jpg/jpeg and png files are allowed!');
                $(submitButton, moduleScope).last().addClass('disabled-link')
            } else if (isRightFormat) {
                const img = new Image()
                img.src = window.URL.createObjectURL(event.target.files[0])
                img.onload = () => {
                    //data from configuration
                    const minWidth = <% =JsCrutchMinWidth %>;
                    const maxWidth = <% =JsCrutchMaxWidth %>;
                    const minHeight = <% =JsCrutchMinHeight %>;
                    const maxHeight = <% =JsCrutchMaxHeight %>;
                    //conditions
                    const minWidthCondition = minWidth ? img.width >= minWidth : true;
                    const maxWidthCondition = maxWidth ? img.width <= maxWidth : true;
                    const minHeightCondition = minHeight ? img.height >= minHeight : true;
                    const maxHeightCondition = maxHeight ? img.height <= maxHeight : true;
                    let minWidthMsg = minWidth ? `minimum ${minWidth} width` : '';
                    let minHeightMsg = minHeight ? `minimum ${minHeight} height` : '';
                    let maxWidthMsg = maxWidth ? `maximum ${maxWidth} width` : '';
                    let maxHeightMsg = maxHeight ? `maximum ${maxHeight} height` : '';
                    let totalErrorMsg = '';
                    [minWidthMsg, minHeightMsg, maxWidthMsg, maxHeightMsg].forEach((item) => {
                        if (totalErrorMsg && item) {
                            totalErrorMsg += ', ';
                        }
                        totalErrorMsg += item;
                    });
                    if (!(minWidthCondition && maxWidthCondition && minHeightCondition && maxHeightCondition)) {
                        showImgError($(selector, moduleScope).parents().eq(3)[0], `Sorry, this image doesn't look like the size we wanted. It's 
          ${ img.width} x ${img.height} but we require following sizes: ${totalErrorMsg}.`)
                        $(submitButton, moduleScope).last().addClass('disabled-link')
                    } else {
                        $(submitButton, moduleScope).last().removeClass('disabled-link')
                        $(errorBlock, moduleScope).last().remove();
                    }
                }
            }
        });

        function showImgError(errorBox, errorText) {
            $('<p/>', {
                text: errorText,
                class: 'imgInputError'
            }).appendTo(errorBox);
        };
    });
</script>
<% } %>