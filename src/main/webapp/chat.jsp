<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bean.Chat"%>
<%@ page import="util.IconUtil"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
    List<Chat> chatHistory = (List<Chat>) request.getAttribute("chatHistory");
    List<HashMap<String, Object>> contactList = (List<HashMap<String, Object>>) request.getAttribute("contactList");

    String currentRole = (request.getAttribute("senderRole") != null)
                         ? request.getAttribute("senderRole").toString()
                         : "Parent";
    boolean isTeacherView = "Teacher".equalsIgnoreCase(currentRole);

    int activeParentID = (request.getAttribute("parentID") != null) ? (int) request.getAttribute("parentID") : 0;
    int activeTeacherID = (request.getAttribute("teacherID") != null) ? (int) request.getAttribute("teacherID") : 0;

    String pName = (request.getAttribute("parentName") != null && !request.getAttribute("parentName").toString().isEmpty())
                   ? request.getAttribute("parentName").toString()
                   : (session.getAttribute("parentName") != null ? session.getAttribute("parentName").toString() : "Parent");
    String tName = (request.getAttribute("teacherName") != null && !request.getAttribute("teacherName").toString().isEmpty())
                   ? request.getAttribute("teacherName").toString()
                   : (session.getAttribute("teacherName") != null ? session.getAttribute("teacherName").toString() : "Teacher");

    String activeChatPartner = isTeacherView ? pName : tName;
    String activePartnerBadge = isTeacherView ? "Parent / Guardian" : "Teacher";
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent-Teacher Hub - Keedsflix Centre</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/icons.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/chat.css">

</head>
<body>

<div class="app-layout">

    <aside class="app-sidebar-wrapper">
        <jsp:include page="sidebar.jsp" />
    </aside>

    <main class="app-main-wrapper">

        <div class="app-header-wrapper">
            <jsp:include page="header.jsp" />
        </div>

        <div class="app-content-body">
            <div class="nb-hub-card">

                <!-- TOP YELLOW HEADER -->
                <div class="hub-top-banner">
                    <div style="display: flex; align-items: center; gap: 14px;">
                        <div class="hub-icon-box">
                            <%= IconUtil.icon("MessageCircle", "icon-md") %>
                        </div>
                        <div>
                            <h2 style="font-size: 1.25rem; font-weight: 900; letter-spacing: -0.3px;">Parent-Teacher Hub</h2>
                            <p style="font-size: 0.78rem; font-weight: 600; color: #334155;">
                                Komunikasi langsung antara guru dan penjaga berkaitan pembelajaran murid
                            </p>
                        </div>
                    </div>

                    <div class="student-context-pill">
                        <span style="background: #FEF3C7; padding: 4px 6px; border-radius: 8px; border: 1.5px solid #F59E0B; display: inline-flex; align-items: center; color: #D97706;">
                            <%= IconUtil.icon("GraduationCap", "icon-sm") %>
                        </span>
                        <span>Murid: ${not empty studentName ? studentName : 'Tiada Rekod'}</span>
                        <span style="color: #94A3B8;">·</span>
                        <span style="color: #64748B; font-weight: 700;">${not empty studentClass ? studentClass : '-'}</span>
                    </div>
                </div>

                <div class="chat-workspace">

                    <!-- LEFT CONTACTS SIDEBAR -->
                    <div class="chat-sidebar">
                        <div class="search-box-wrap">
                            <span class="search-icon"><%= IconUtil.icon("Search", "icon-sm") %></span>
                            <input type="text" class="search-input" id="chatSearchInput" placeholder="Search chats..." onkeyup="filterContacts()">
                        </div>

                        <div class="security-banner">
                            <span style="color: #0D9488; display: inline-flex; margin-top: 1px;">
                                <%= IconUtil.icon("ShieldCheck", "icon-sm") %>
                            </span>
                            <div>
                                <strong style="color: #0F766E;">End-to-End Secure:</strong> All data is fully protected and adheres strictly to school privacy agreements.
                            </div>
                        </div>

                        <div class="contact-list" id="contactList">
                            <%
                                if (contactList != null && !contactList.isEmpty()) {
                                    for (HashMap<String, Object> contact : contactList) {
                                        int cId = (int) contact.get("id");
                                        String cName = (String) contact.get("name");
                                        String cSub = (String) contact.get("subtitle");
                                        boolean isActiveContact = isTeacherView ? (cId == activeParentID) : (cId == activeTeacherID);
                                        String targetUrl = isTeacherView
                                            ? ("ChatServlet?parentID=" + cId + "&teacherID=" + activeTeacherID + "&senderRole=Teacher")
                                            : ("ChatServlet?parentID=" + activeParentID + "&teacherID=" + cId + "&senderRole=Parent");
                            %>
                                        <a href="<%= targetUrl %>" style="text-decoration: none; color: inherit;">
                                            <div class="contact-item <%= isActiveContact ? "active" : "" %>">
                                                <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
                                                    <div class="contact-avatar">
                                                        <%= isTeacherView ? IconUtil.icon("Users", "icon-md") : IconUtil.icon("UserCheck", "icon-md") %>
                                                    </div>
                                                    <div style="min-width: 0;">
                                                        <h4 style="font-size: 0.82rem; font-weight: 900; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                            <%= cName %>
                                                        </h4>
                                                        <p style="font-size: 0.7rem; color: #64748B; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                            <%= cSub %>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                            <%
                                    }
                                } else {
                            %>
                                    <div class="contact-item active">
                                        <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
                                            <div class="contact-avatar">
                                                <%= isTeacherView ? IconUtil.icon("Users", "icon-md") : IconUtil.icon("UserCheck", "icon-md") %>
                                            </div>
                                            <div style="min-width: 0;">
                                                <h4 style="font-size: 0.82rem; font-weight: 900;"><%= activeChatPartner %></h4>
                                                <p style="font-size: 0.7rem; color: #64748B; font-weight: 700;">Active Now</p>
                                            </div>
                                        </div>
                                    </div>
                            <%
                                }
                            %>
                        </div>
                    </div>

                    <!-- RIGHT CONVERSATION AREA -->
                    <div class="chat-main">

                        <!-- Active Chat Header -->
                        <div class="chat-header">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 38px; height: 38px; background: var(--yellow-accent); border: 2px solid var(--border-dark); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                                    <%= isTeacherView ? IconUtil.icon("Users", "icon-md") : IconUtil.icon("UserCheck", "icon-md") %>
                                </div>
                                <div>
                                    <h4 style="font-size: 0.92rem; font-weight: 900;">
                                        <%= activeChatPartner %> (<%= activePartnerBadge %>)
                                    </h4>
                                    <div style="font-size: 0.72rem; color: #10B981; font-weight: 800; display: flex; align-items: center; gap: 5px;">
                                        <span style="width: 7px; height: 7px; background: #10B981; border-radius: 50%; display: inline-block;"></span>
                                        Online
                                    </div>
                                </div>
                            </div>

                            <div class="header-tools">
                                <span title="Audio"><%= IconUtil.icon("Volume2", "icon-sm") %></span>
                                <span style="color: #CBD5E1;">|</span>
                                <span title="Voice Call"><%= IconUtil.icon("Phone", "icon-sm") %></span>
                                <span title="Video Call"><%= IconUtil.icon("Video", "icon-sm") %></span>
                                <span title="More Options"><%= IconUtil.icon("MoreVertical", "icon-sm") %></span>
                            </div>
                        </div>

                        <!-- Sub-Header Strip -->
                        <div class="sim-banner">
                            <span style="color: #6D28D9; font-weight: 800; display: inline-flex; align-items: center; gap: 6px;">
                                <%= IconUtil.icon("Sparkles", "icon-xs") %> Direct messaging with <%= activeChatPartner %>!
                            </span>
                            <span style="color: #64748B; font-weight: 600;">
                                Select quick templates below to ask questions!
                            </span>
                        </div>

                        <!-- MESSAGE STREAM -->
                        <div class="msg-stream" id="msgStream">
                            <%
                                SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

                                if (chatHistory != null && !chatHistory.isEmpty()) {
                                    for (Chat chat : chatHistory) {
                                        String msgRole = (chat.getSenderRole() != null) ? chat.getSenderRole() : "Parent";
                                        boolean isOwn = msgRole.equalsIgnoreCase(currentRole);
                                        String displaySender = "parent".equalsIgnoreCase(msgRole) ? pName : (tName + " (Teacher)");
                                        String formattedTime = (chat.getSentDateTime() != null) ? timeFmt.format(chat.getSentDateTime()) : "";
                            %>
                                        <div class="msg-group <%= isOwn ? "own" : "other" %>">
                                            <div class="msg-sender-label"><%= displaySender %></div>
                                            <div class="msg-bubble <%= isOwn ? "msg-own" : "msg-other" %>">
                                                <div><%= chat.getMessageContent() %></div>
                                                <div class="msg-meta">
                                                    <span><%= formattedTime %></span>
                                                    <% if (isOwn) { %>
                                                        <span title="<%= chat.isRead() ? "Dibaca" : "Dihantar" %>" style="display: inline-flex; align-items: center;">
                                                            <i data-lucide="check-check" class="icon-xs <%= chat.isRead() ? "icon-read-blue" : "icon-sent-gray" %>"></i>
                                                        </span>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                            <%
                                    }
                                } else {
                            %>
                                    <div style="text-align: center; color: #94A3B8; font-size: 0.8rem; font-weight: 700; margin-top: 40px;">
                                        Tiada rekod perbualan lagi. Mulakan mesej anda di bawah!
                                    </div>
                            <%
                                }
                            %>
                        </div>

                        <!-- QUICK TEMPLATES -->
                        <div class="quick-templates-bar">
                            <% if (isTeacherView) { %>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Selamat sejahtera, anak anda menunjukkan peningkatan yang sangat baik dalam kelas hari ini!')">
                                    <%= IconUtil.icon("Star", "icon-xs") %> Kongsi Pencapaian Murid
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Sila semak modul Learning Progress untuk laporan pentaksiran mingguan terkini.')">
                                    <%= IconUtil.icon("BarChart3", "icon-xs") %> Maklum Laporan Mingguan
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Terima kasih atas kerjasama pihak ibu bapa dalam memantau latihan di rumah.')">
                                    <%= IconUtil.icon("HeartHandshake", "icon-xs") %> Penghargaan Penjaga
                                </button>
                            <% } else { %>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Ask about Math progress: How is my child doing in counting activities this week?')">
                                    <%= IconUtil.icon("BarChart3", "icon-xs") %> Ask about Math progress
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Ask about Pencil Grip: Has there been improvement in tripod grip during writing?')">
                                    <%= IconUtil.icon("PenTool", "icon-xs") %> Ask about Pencil Grip
                                </button>
                                <button type="button" class="template-pill" onclick="setQuickMsg('Thank you teacher for the detailed update and guidance!')">
                                    <%= IconUtil.icon("Heart", "icon-xs") %> Send Encouragement
                                </button>
                            <% } %>
                        </div>

                        <!-- BOTTOM FORM -->
                        <form action="${pageContext.request.contextPath}/ChatServlet" method="POST" class="chat-input-form">
                            <input type="hidden" name="parentID" value="<%= activeParentID %>">
                            <input type="hidden" name="teacherID" value="<%= activeTeacherID %>">
                            <input type="hidden" name="senderRole" value="<%= isTeacherView ? "Teacher" : "Parent" %>">

                            <div class="input-action-icons">
                                <span title="Emoji"><%= IconUtil.icon("Smile", "icon-md") %></span>
                                <span title="Attach File"><%= IconUtil.icon("Paperclip", "icon-md") %></span>
                            </div>

                            <input type="text" name="messageContent" id="messageInput" class="chat-text-input" 
                                   placeholder="Type a message as <%= isTeacherView ? "Teacher" : "Parent" %>..." required autocomplete="off">
                            
                            <button type="submit" class="send-icon-btn" title="Hantar Mesej">
                                <%= IconUtil.icon("Send", "icon-md") %>
                            </button>
                        </form>

                    </div>
                </div>

            </div>
        </div>
    </main>
</div>

<script>
    function setQuickMsg(text) {
        const input = document.getElementById('messageInput');
        input.value = text;
        input.focus();
    }

    function filterContacts() {
        const query = document.getElementById('chatSearchInput').value.toLowerCase();
        document.querySelectorAll('#contactList a').forEach(item => {
            const text = item.innerText.toLowerCase();
            item.style.display = text.includes(query) ? 'block' : 'none';
        });
    }

    window.onload = function() {
        var stream = document.getElementById('msgStream');
        if (stream) stream.scrollTop = stream.scrollHeight;
    };
</script>

<jsp:include page="icons.jsp" />
</body>
</html>