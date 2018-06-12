<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="common/tags.jsp"%>
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<title>WeiHi Chat</title>
<meta name="renderer" content="webkit">
<meta http-equiv="Cache-Control" content="no-siteapp" />
<link rel="alternate icon" href="${contextPath}/resources/assets/i/favicon.ico">
<link rel="stylesheet" href="${contextPath}/resources/assets/css/amazeui.min.css">
<link rel="stylesheet" href="${contextPath}/resources/assets/css/app.css">
<link href="${contextPath}/resources/umeditor/themes/default/css/umeditor.css" rel="stylesheet">
<style>
.title {
	text-align: center;
}

.chat-content-container {
	height: 29rem;
	overflow-y: scroll;
	border: 1px solid silver;
}
</style>
</head>
<body>
 <div class="title">
  <div class="am-g am-g-fixed">
   <div class="am-u-sm-12">
    <h1 class="am-text-primary">WeiHi Chat</h1>
   </div>
  </div>
 </div>
 <div class="chat-content">
  <div class="am-g am-g-fixed chat-content-container">
   <div class="am-u-sm-12">
    <ul id="message-list" class="am-comments-list am-comments-list-flip"></ul>
   </div>
  </div>
 </div>
 <div class="message-input am-margin-top">
  <div class="am-g am-g-fixed">
   <div class="am-u-sm-12">
    <form class="am-form">
     <div class="am-form-group">
      <script type="text/plain" id="myEditor" style="width: 100%;height: 8rem;"></script>
     </div>
    </form>
   </div>
  </div>
  <div class="am-g am-g-fixed am-margin-top">
   <!-- <div class="am-u-sm-6">
    <div id="message-input-nickname" class="am-input-group am-input-group-primary">
     <span class="am-input-group-label"><i class="am-icon-user"></i></span>
     <input id="nickname" type="text" class="am-form-field" placeholder="Please enter nickname"/>
    </div>
   </div> -->
   <div class="am-u-sm-6">
    <button id="send" type="button" class="am-btn am-btn-primary">
     <i class="am-icon-send"></i> 发送
    </button>
   </div>
  </div>
 </div>
 <script src="${contextPath}/resources/assets/js/jquery.min.js"></script>
 <script charset="utf-8" src="${contextPath}/resources/umeditor/umeditor.config.js"></script>
 <script charset="utf-8" src="${contextPath}/resources/umeditor/umeditor.min.js"></script>
 <script src="${contextPath}/resources/umeditor/lang/zh-cn/zh-cn.js"></script>
 <script src="${contextPath}/resources/common/js/jquery.min.js"></script>
 <script src="${contextPath}/resources/common/js/bootstrap.min.js"></script>
 <script src="${contextPath}/resources/common/js/toast.js"></script>
 <script src="${contextPath}/resources/common/js/md5.js"></script>
 <script src="${contextPath}/resources/common/js/string.js"></script>
 <script src="${contextPath}/resources/common/common.js"></script>
 <script src="${contextPath}/resources/common/canvas-particle.js"></script>
 <script>
$(function() {
	// 初始化消息输入框
	var um = UM.getEditor('myEditor');
	
	// 新建WebSocket对象
	var socket = new WebSocket('ws://${pageContext.request.getServerName()}:${pageContext.request.getServerPort()}${pageContext.request.contextPath}/websocket');
	
	// 处理服务器端发送的数据
	socket.onmessage = function(event) {
		addMessage(event.data);
	};
	
	// 点击Send按钮时的操作
	$('#send').on('click', function() {
		//var nickname = $('#nickname').val();
		var nickname = getCookieValue("nickName");
		if (!um.hasContents()) {    // 判断消息输入框是否为空
			// 消息输入框获取焦点
			um.focus();
			// 添加抖动效果
			$('.edui-container').addClass('am-animation-shake');
			setTimeout("$('.edui-container').removeClass('am-animation-shake')", 1000);
		} else if (nickname == '') {    // 判断昵称框是否为空
        	//$('#nickname')[0].focus();
	        //$('#message-input-nickname').addClass('am-animation-shake');
	        //setTimeout("$('#message-input-nickname').removeClass('am-animation-shake')", 1000);
	        showtoastFromDiv("myEditor","获取用户信息失败，请重新登录","inline-block",1000);
	        window.setInterval(function(){ 
      				goTo("/login"); 
			},2000);
		} else {
        	// 发送消息
        	var content = window.pwdString.encrypt(um.getContent());
        	console.log('content:'+content);
	        socket.send(JSON.stringify({
	        	content : content,
	        	nickname : nickname
        	}));
	        um.setContent('');
	        um.focus();
		}
	});
	// 把消息添加到聊天内容中
	function addMessage(message) {
		message = JSON.parse(message);
		
		var messageItem = '';
		messageItem += '<li class="am-comment ' + (message.isSelf ? 'am-comment-flip' : 'am-comment') + '">';
		messageItem += '<a href="javascript:void(0)" >';
		messageItem += '<img src="assets/images/' + (message.isSelf ? 'self.png' : 'others.jpg') + '" alt="" class="am-comment-avatar" width="48" height="48"/>';
		messageItem += '</a>';
		messageItem += '<div class="am-comment-main">';
		messageItem += '<header class="am-comment-hd">';
		messageItem += '<div class="am-comment-meta">';
		messageItem += '<a href="javascript:void(0)" class="am-comment-author">' + message.nickname + '</a> ';
		messageItem += ' <time>' + message.date + '</time>';
		messageItem += '</div></header>';
		messageItem += '<div class="am-comment-bd">' + window.pwdString.decrypt(message.content) + '</div>';
		messageItem += '</div></li>';
		
		$(messageItem).appendTo('#message-list');
		// 把滚动条滚动到底部
		$(".chat-content-container").scrollTop($(".chat-content-container")[0].scrollHeight);
	}
  });
 </script>
</body>
</html>