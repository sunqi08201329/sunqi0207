$(function() {
	//社会化登录列表效果
	$(".dl_publish_media").hover(function(){
		$(".dl_media_list").slideDown("300");
	},function(){
		$(".dl_media_list").slideUp("300");
	});
});

function dlReplyControl(name) {
	var cId = "c" + name;
	var buttonUp = $("#" + cId).find(".dl_reply_up");
	var display = buttonUp.css("display");
	if(display == "none"){
		$("#" + cId).find(".dl_name").append("<span class='dl_name_reply'>回复被收起</span>");
		$("#" + cId).addClass("dl_post_select");
	}else{
		$("#" + cId).find(".dl_name").find(".dl_name_reply").remove();
		$("#" + cId).removeClass("dl_post_select");
	}
}
